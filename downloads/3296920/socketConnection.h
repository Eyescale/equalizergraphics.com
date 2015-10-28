
/* Copyright (c) 2005-2009, Stefan Eilemann <eile@equalizergraphics.com> 
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

#ifndef EQNET_SOCKETCONNECTION_H
#define EQNET_SOCKETCONNECTION_H

#include <eq/base/base.h>
#include <eq/base/buffer.h> // member

#ifdef WIN32
#  include <eq/net/connection.h>
#else
#  include "fdConnection.h"
#  include <netinet/in.h>
#endif


namespace eq
{
namespace net
{
    /** A socket connection (TCPIP or SDP). */
    class EQ_EXPORT SocketConnection
#ifdef WIN32
        : public Connection
#else
        : public FDConnection
#endif
    {
    public:
        /** 
         * Create a new socket-based connection
         * 
         * @param type the connection type, can be CONNECTIONTYPE_TCPIP or
         *             CONNECTIONTYPE_SDP.
         */
        SocketConnection( const ConnectionType type = CONNECTIONTYPE_TCPIP );

        virtual bool connect();            
        virtual bool listen();             
        virtual void acceptNB();           
        virtual ConnectionPtr acceptSync();
        virtual void close();              


#ifdef WIN32
        /** @sa Connection::getNotifier */
        virtual Notifier getNotifier() const { return _overlapped.hEvent; }
#endif

    protected:
        virtual ~SocketConnection();

#ifdef WIN32
        virtual void readNB( void* buffer, const uint64_t bytes );
        virtual int64_t readSync( void* buffer, const uint64_t bytes );
        virtual int64_t write( const void* buffer, const uint64_t bytes );

        typedef SOCKET Socket;
#else
        //! @cond IGNORE
        typedef int    Socket;
        enum
        {
            INVALID_SOCKET = -1
        };
        //! @endcond
#endif

    private:
        void _initAIOAccept();
        void _exitAIOAccept();
        void _initAIORead();
        void _exitAIORead();

        bool _createSocket();
        void _tuneSocket( const Socket fd );
        bool _parseAddress( sockaddr_in& address );
        uint16_t _getPort() const;

#ifdef WIN32
        union
        {
            SOCKET _readFD;
            SOCKET _writeFD;
        };

        // overlapped data structures
        OVERLAPPED _overlapped;
        void*      _overlappedAcceptData;
        SOCKET     _overlappedSocket;
        DWORD      _overlappedDone;

        CHECK_THREAD_DECLARE( _recvThread );
#endif
    };
}
}

#endif //EQNET_SOCKETCONNECTION_H
