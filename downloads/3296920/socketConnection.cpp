
/* Copyright (c) 2005-2010, Stefan Eilemann <eile@equalizergraphics.com> 
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License version 2.1 as published
 * by the Free Software Foundation.
 *  
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
 * details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#include "socketConnection.h"

#include "connectionDescription.h"

#include <eq/base/base.h>
#include <eq/base/log.h>
#include <eq/base/sleep.h>

#include <limits>
#include <sstream>
#include <string.h>
#include <sys/types.h>

#ifdef WIN32
#  include <Mswsock.h>

#  ifndef WSA_FLAG_SDP
#    define WSA_FLAG_SDP 0x40
#  endif
#  define EQTIMER_WSA_IO_PENDING 250
#else
#  include <arpa/inet.h>
#  include <netdb.h>
#  include <netinet/tcp.h>
#  include <sys/errno.h>
#  include <sys/socket.h>

#  ifndef AF_INET_SDP
#    define AF_INET_SDP 27
#  endif
#endif

namespace eq
{
namespace net
{
SocketConnection::SocketConnection( const ConnectionType type )
#ifdef WIN32
        : _overlappedAcceptData( 0 )
        , _overlappedSocket( INVALID_SOCKET )
        , _overlappedDone( 0 )
#endif
{
#ifdef WIN32
    memset( &_overlapped, 0, sizeof( _overlapped ));
#endif

    EQASSERT( type == CONNECTIONTYPE_TCPIP || type == CONNECTIONTYPE_SDP );
    _description->type = type;
    _description->bandwidth = (type == CONNECTIONTYPE_TCPIP) ?
                                  102400 : 819200; // 100MB : 800 MB

    EQVERB << "New SocketConnection @" << (void*)this << std::endl;
}

SocketConnection::~SocketConnection()
{
}

//----------------------------------------------------------------------
// connect
//----------------------------------------------------------------------
bool SocketConnection::connect()
{
    EQASSERT( _description->type == CONNECTIONTYPE_TCPIP ||
              _description->type == CONNECTIONTYPE_SDP );
    if( _state != STATE_CLOSED )
        return false;

    if( _description->port == 0 )
        return false;

    _state = STATE_CONNECTING;
    _fireStateChanged();

    if( _description->getHostname().empty( ))
        _description->setHostname( "localhost" );

    sockaddr_in address;
    if( !_parseAddress( address ))
    {
        EQWARN << "Can't parse connection parameters" << std::endl;
        return false;
    }

    if( !_createSocket( ))
        return false;

    if( address.sin_addr.s_addr == 0 )
    {
        EQWARN << "Refuse to connect to 0.0.0.0" << std::endl;
        close();
        return false;
    }

#ifdef WIN32
    const bool connected = WSAConnect( _readFD, (sockaddr*)&address, 
                                       sizeof( address ), 0, 0, 0, 0 ) == 0;
#else
    const bool connected = (::connect( _readFD, (sockaddr*)&address, 
                                       sizeof( address )) == 0);
#endif

    if( !connected )
    {
        EQWARN << "Could not connect to '" << _description->getHostname() << ":"
               << _description->port << "': " << base::sysError << std::endl;
        close();
        return false;
    }

    _initAIORead();
    _state = STATE_CONNECTED;
    _fireStateChanged();

    EQINFO << "Connected " << _description << std::endl;
    return true;
}

void SocketConnection::close()
{
    if( _state == STATE_CLOSED )
        return;

    if( isListening( ))
        _exitAIOAccept();
    else if( isConnected( ))
        _exitAIORead();

    _state = STATE_CLOSED;
    EQASSERT( _readFD > 0 ); 

#ifdef WIN32
    const bool closed = ( ::closesocket(_readFD) == 0 );
#else
    const bool closed = ( ::close(_readFD) == 0 );
#endif

    if( !closed )
        EQWARN << "Could not close socket: " << base::sysError << std::endl;

    _readFD  = INVALID_SOCKET;
    _writeFD = INVALID_SOCKET;
    _fireStateChanged();
}

//----------------------------------------------------------------------
// Async IO handles
//----------------------------------------------------------------------
void SocketConnection::_initAIOAccept(){ /* NOP */ }
void SocketConnection::_exitAIOAccept(){ /* NOP */ }
void SocketConnection::_initAIORead(){ /* NOP */ }
void SocketConnection::_exitAIORead(){ /* NOP */ }

//----------------------------------------------------------------------
// accept
//----------------------------------------------------------------------
#ifdef WIN32
void SocketConnection::acceptNB()
{
}
    
ConnectionPtr SocketConnection::acceptSync()
{
    EQASSERT( _state == STATE_LISTENING );
    if( _state != STATE_LISTENING )
        return 0;

    // accept new socket
    sockaddr_in data;
    int size = sizeof( data );
    SOCKET socket = WSAAccept( _readFD, (sockaddr*)&data, &size, 0, 0 );

    if( socket == INVALID_SOCKET )
    {
        EQERROR << "Could not create accept socket: " << base::sysError
            << ", closing listening socket" << std::endl;
        close();
        return 0;
    }

    _tuneSocket( socket );

    SocketConnection* newConnection = new SocketConnection(_description->type );
    ConnectionPtr connection( newConnection ); // to keep ref-counting correct

    newConnection->_readFD  = socket;
    newConnection->_writeFD = socket;
    newConnection->_initAIORead();

    newConnection->_state                  = STATE_CONNECTED;
    newConnection->_description->bandwidth = _description->bandwidth;
    newConnection->_description->port      = ntohs( data.sin_port );
    newConnection->_description->setHostname( inet_ntoa( data.sin_addr ));

    EQINFO << "accepted connection from " << inet_ntoa( data.sin_addr ) 
           << ":" << ntohs( data.sin_port ) << std::endl;

    return connection;
}

#else // !WIN32

void SocketConnection::acceptNB(){ /* NOP */ }
 
ConnectionPtr SocketConnection::acceptSync()
{
    if( _state != STATE_LISTENING )
        return 0;

    sockaddr_in newAddress;
    socklen_t   newAddressLen = sizeof( newAddress );

    Socket    fd;
    unsigned  nTries = 1000;
    do
        fd = ::accept( _readFD, (sockaddr*)&newAddress, &newAddressLen );
    while( fd == INVALID_SOCKET && errno == EINTR && --nTries );

    if( fd == INVALID_SOCKET )
    {
        EQWARN << "accept failed: " << base::sysError << std::endl;
        return 0;
    }

    _tuneSocket( fd );

    SocketConnection* newConnection = new SocketConnection( _description->type);

    newConnection->_readFD      = fd;
    newConnection->_writeFD     = fd;
    newConnection->_state       = STATE_CONNECTED;
    newConnection->_description->bandwidth = _description->bandwidth;
    newConnection->_description->setHostname( inet_ntoa( newAddress.sin_addr ));
    newConnection->_description->port      = ntohs( newAddress.sin_port );

    EQVERB << "accepted connection from " << inet_ntoa(newAddress.sin_addr) 
           << ":" << ntohs( newAddress.sin_port ) << std::endl;

    return newConnection;
}

#endif // !WIN32



#ifdef WIN32
//----------------------------------------------------------------------
// read
//----------------------------------------------------------------------
void SocketConnection::readNB( void* buffer, const uint64_t bytes )
{
}

int64_t SocketConnection::readSync( void* buffer, const uint64_t bytes )
{
    if( _state == STATE_CLOSED )
        return -1;

    if( _readFD == INVALID_SOCKET )
    {
        EQERROR << "Invalid read handle" << std::endl;
        return -1;
    }

    DWORD startTime = 0;

    while( true )
    {
        const int len = EQ_MIN( bytes, 32767 );

        EQINFO << "Pull " << len << std::endl;
        const int result = ::recv( _readFD, (char*)buffer, len, 0 );

        if( result > 0 )// got data
        {
            EQINFO << "Got " << result << std::endl;
            return result;
        }
        if( result == 0 ) // socket closed 
        {
            EQINFO << "Got EOF, closing connection" << std::endl;
            close();
            return -1;
        }

        EQWARN << "Recv error: " << base::sysError << std::endl;

        const int err = WSAGetLastError();
        switch( err )
        {
            case WSASYSCALLFAILURE:  // happens sometimes!?
                return 0;

            case WSA_IO_PENDING:
                EQWARN << "WSARecv loop WSA_IO_PENDING" << std::endl;
                if( startTime == 0)
                    startTime = GetTickCount();
                else
                {
                    base::sleep( 1 ); // one millisecond to recover
                
                    //timeout   
                    if( GetTickCount() - startTime > EQTIMER_WSA_IO_PENDING )
                    {
                        EQWARN << "got timeout " << std::endl;
                        return -1;
                    }
                }
                break;

            case ERROR_INVALID_HANDLE:
                EQWARN << "Got " << base::sysError << ", closing connection"
                       << std::endl;
                close();
                return -1;

            default:
                EQWARN << "unknown error " << base::sysError << std::endl;
                close();
                return -1;
        }
    }
}

int64_t SocketConnection::write( const void* buffer, const uint64_t bytes)
{
    if( _state != STATE_CONNECTED || _writeFD == INVALID_SOCKET )
        return -1;

    const int len = EQ_MIN( bytes, 32767 );
    while( true )
    {
        EQINFO << "Put " << len << std::endl;
        const int wrote = ::send( _writeFD, (const char*)buffer, len, 0 );
        if( wrote > 0 )
        {
            EQINFO << "Sent " << wrote << std::endl;
            return wrote;
        }

        // error
        if( GetLastError( ) != WSAEWOULDBLOCK )
        {
            EQWARN << "Error during write: " << base::sysError << std::endl;
            return -1;
        }

        // Buffer full - try again
#if 1
        // Wait for writable socket
        fd_set set;
        FD_ZERO( &set );
        FD_SET( _writeFD, &set );

        const int result = select( _writeFD+1, 0, &set, 0, 0 );
        if( result <= 0 )
        {
            EQWARN << "Error during select: " << base::sysError << std::endl;
            return -1;
        }
#endif
    }

    EQUNREACHABLE;
    return -1;
}
#endif // WIN32

bool SocketConnection::_createSocket()
{
#ifdef WIN32
    const DWORD flags = _description->type == CONNECTIONTYPE_SDP ?
                            WSA_FLAG_SDP : 0;

    const SOCKET fd = WSASocket( AF_INET, SOCK_STREAM, IPPROTO_TCP, 0,0,flags );

    if( _description->type == CONNECTIONTYPE_SDP )
        EQINFO << "Created SDP socket" << std::endl;
#else
    Socket fd;
    if( _description->type == CONNECTIONTYPE_SDP )
        fd = ::socket( AF_INET_SDP, SOCK_STREAM, IPPROTO_TCP );
    else
        fd = ::socket( AF_INET, SOCK_STREAM, IPPROTO_TCP );
#endif

    if( fd == INVALID_SOCKET )
    {
        EQERROR << "Could not create socket: " << base::sysError << std::endl;
        return false;
    }

    _tuneSocket( fd );

    _readFD  = fd;
    _writeFD = fd; // TCP/IP sockets are bidirectional
    return true;
}

void SocketConnection::_tuneSocket( const Socket fd )
{
    const int on         = 1;
    setsockopt( fd, IPPROTO_TCP, TCP_NODELAY, 
                reinterpret_cast<const char*>( &on ), sizeof( on ));
    setsockopt( fd, SOL_SOCKET, SO_REUSEADDR, 
                reinterpret_cast<const char*>( &on ), sizeof( on ));
    
#ifdef WIN32
    const int size = 65535;
    setsockopt( fd, SOL_SOCKET, SO_RCVBUF, 
                reinterpret_cast<const char*>( &size ), sizeof( size ));
    setsockopt( fd, SOL_SOCKET, SO_SNDBUF,
                reinterpret_cast<const char*>( &size ), sizeof( size ));
#endif
}

bool SocketConnection::_parseAddress( sockaddr_in& address )
{
    address.sin_family      = AF_INET;
    address.sin_addr.s_addr = htonl( INADDR_ANY );
    address.sin_port        = htons( _description->port );
    memset( &(address.sin_zero), 0, 8 ); // zero the rest

    const std::string& hostname = _description->getHostname();
    if( !hostname.empty( ))
    {
        hostent *hptr = gethostbyname( hostname.c_str( ));
        if( hptr )
            memcpy( &address.sin_addr.s_addr, hptr->h_addr, hptr->h_length );
        else
        {
            EQWARN << "Can't resolve host " << hostname << std::endl;
            return false;
        }
    }

    EQVERB << "Address " << inet_ntoa( address.sin_addr ) << ":" 
           << ntohs( address.sin_port ) << std::endl;
    return true;
}
//----------------------------------------------------------------------
// listen
//----------------------------------------------------------------------
bool SocketConnection::listen()
{
    EQASSERT( _description->type == CONNECTIONTYPE_TCPIP || 
              _description->type == CONNECTIONTYPE_SDP );

    if( _state != STATE_CLOSED )
        return false;

    _state = STATE_CONNECTING;
    _fireStateChanged();

    sockaddr_in address;
    const size_t size = sizeof( sockaddr_in ); 

    if( !_parseAddress( address ))
    {
        EQWARN << "Can't parse connection parameters" << std::endl;
        return false;
    }

    if( !_createSocket())
        return false;

    const bool bound = (::bind(_readFD, (sockaddr *)&address, size) == 0);

    if( !bound )
    {
        EQWARN << "Could not bind socket " << _readFD << ": " 
               << base::sysError << " to " << inet_ntoa( address.sin_addr )
               << ":" << ntohs( address.sin_port ) << " AF "
               << (int)address.sin_family << std::endl;

        close();
        return false;
    }
    else if( address.sin_port == 0 )
        EQINFO << "Bound to port " << _getPort() << std::endl;

    const bool listening = (::listen( _readFD, 10 ) == 0);
        
    if( !listening )
    {
        EQWARN << "Could not listen on socket: "<< base::sysError << std::endl;
        close();
        return false;
    }

    // get socket parameters
    socklen_t used = size;
    getsockname( _readFD, (struct sockaddr *)&address, &used ); 

    _description->port = ntohs( address.sin_port );

    const std::string& hostname = _description->getHostname();
    if( hostname.empty( ))
    {
        if( address.sin_addr.s_addr == INADDR_ANY )
        {
            char cHostname[256];
            gethostname( cHostname, 256 );
            _description->setHostname( cHostname );
        }
        else
            _description->setHostname( inet_ntoa( address.sin_addr ));
    }
    
    _initAIOAccept();
    _state = STATE_LISTENING;
    _fireStateChanged();

    EQINFO << "Listening on " << _description->getHostname() << "["
           << inet_ntoa( address.sin_addr ) << "]:" << _description->port
           << " (" << _description->toString() << ")" << std::endl;
    
    return true;
}

uint16_t SocketConnection::_getPort() const
{
    sockaddr_in address;
    socklen_t used = sizeof( address );
    getsockname( _readFD, (struct sockaddr *) &address, &used ); 
    return ntohs(address.sin_port);
}

}
}
