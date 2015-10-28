
/* Copyright (c) 2006-2010, Stefan Eilemann <eile@equalizergraphics.com> 
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

// Tests network throughput
// Usage: see 'netPerf -h'

#include <pthread.h> // must come first!

#define EQ_TEST_NO_WATCHDOG
#include <test.h>
#include <eq/base/scopedMutex.h>
#include <eq/base/monitor.h>
#include <eq/base/rng.h>
#include <eq/base/sleep.h>
#include <eq/net/connection.h>
#include <eq/net/connectionDescription.h>
#include <eq/net/connectionSet.h>
#include <eq/net/connectionType.h>
#include <eq/net/init.h>

#ifndef MIN
#  define MIN EQ_MIN
#endif
#include <tclap/CmdLine.h>

#include <iostream>

#define NTHREADS 1

using namespace eq::net;

namespace
{
eq::base::Lock      _mutexPrint;

class Receiver : public eq::base::Thread
{
public:
    Receiver( const size_t packetSize, ConnectionPtr connection )
            : _connection( connection )
            , _mBytesSec( packetSize / 1024.f / 1024.f * 1000.f )
            , _nSamples( 0 )
            , _lastPacket( 0 )
        { 
            _buffer.resize( packetSize );
        }

    virtual ~Receiver() {}

    virtual void* run()
        {
            _clock.reset();
            while( _connection->isConnected( ))
            {
                _connection->recvNB( _buffer.getData(), _buffer.getSize( ));
                TEST( _connection->recvSync( 0, 0 ));
                const float time = _clock.getTimef();
                ++_nSamples;

                if( time > 1000.f )
                {
                    const eq::base::ScopedMutex mutex( _mutexPrint );
                    std::cerr << "Recv perf: " << _mBytesSec / time * _nSamples 
                              << "MB/s (" << _nSamples/ time * 1000.f  << "pps)"
                              << std::endl;

                    _nSamples = 0;
                    _clock.reset();
                }
            }
            const float time = _clock.getTimef();
            if( _nSamples != 0 )
            {
                const eq::base::ScopedMutex mutex( _mutexPrint );
                std::cerr << "Recv perf: " << _mBytesSec / time * _nSamples 
                          << "MB/s (" << _nSamples / time * 1000.f  << "pps)"
                          << std::endl;
            }
            return EXIT_SUCCESS;
        }

private:
    eq::base::Clock _clock;
    eq::base::RNG _rng;

    eq::base::Bufferb _buffer;
    ConnectionPtr _connection;
    const float _mBytesSec;
    size_t      _nSamples;
    size_t      _packetSize;
    uint8_t    _lastPacket;
};

class Sender : public eq::base::Thread
{
public:
    Sender( const size_t packetSize, ConnectionPtr connection )
            : _connection( connection )
            , _mBytesSec( packetSize / 1024.f / 1024.f * 1000.f )
            , _nSamples( 0 )
            , _lastPacket( 0 )
        { 
            _buffer.resize( packetSize );
        }

    virtual ~Sender() {}

    virtual void* run()
        {
            _clock.reset();
            while( _connection->isConnected( ))
            {
                TEST(_connection->send( _buffer.getData(), _buffer.getSize( )));
                const float time = _clock.getTimef();
                ++_nSamples;

                if( time > 1000.f )
                {
                    const eq::base::ScopedMutex mutex( _mutexPrint );
                    std::cerr << "Send perf: " << _mBytesSec / time * _nSamples 
                              << "MB/s (" << _nSamples/ time * 1000.f  << "pps)"
                              << std::endl;

                    _nSamples = 0;
                    _clock.reset();
                }
            }
            const float time = _clock.getTimef();
            if( _nSamples != 0 )
            {
                const eq::base::ScopedMutex mutex( _mutexPrint );
                std::cerr << "Send perf: " << _mBytesSec / time * _nSamples 
                          << "MB/s (" << _nSamples / time * 1000.f  << "pps)"
                          << std::endl;
            }
            return EXIT_SUCCESS;
        }

private:
    eq::base::Clock _clock;
    eq::base::RNG _rng;

    eq::base::Bufferb _buffer;
    ConnectionPtr _connection;
    const float _mBytesSec;
    size_t      _nSamples;
    size_t      _packetSize;
    uint8_t    _lastPacket;
};
}

int main( int argc, char **argv )
{
    TEST( eq::net::init( argc, argv ));

    ConnectionDescriptionPtr description = new ConnectionDescription;
    description->type = CONNECTIONTYPE_TCPIP;
    description->port = 4242;

    bool isClient     = true;
    size_t packetSize = 1048576;
    size_t nPackets   = 0xffffffffu;
    size_t waitTime   = 0;

    try // command line parsing
    {
        TCLAP::CmdLine command( "netPerf - Equalizer network benchmark tool\n");
        TCLAP::ValueArg< std::string > clientArg( "c", "client",
                                                  "run as client", true, "",
                                                  "IP[:port][:protocol]" );
        TCLAP::ValueArg< std::string > serverArg( "s", "server",
                                                  "run as server", true, "",
                                                  "IP[:port][:protocol]" );
        TCLAP::ValueArg<size_t> sizeArg( "p", "packetSize", "packet size", 
                                         false, packetSize, "unsigned", 
                                         command );
        TCLAP::ValueArg<size_t> packetsArg( "n", "numPackets", 
                                            "number of packets to send", 
                                            false, nPackets, "unsigned",
                                            command );
        TCLAP::ValueArg<size_t> waitArg( "w", "wait", 
                                   "wait time (ms) between sends (client only)",
                                         false, 0, "unsigned", command );

        command.xorAdd( clientArg, serverArg );
        command.parse( argc, argv );

        if( clientArg.isSet( ))
            description->fromString( clientArg.getValue( ));
        else if( serverArg.isSet( ))
        {
            isClient = false;
            description->fromString( serverArg.getValue( ));
        }

        if( sizeArg.isSet( ))
            packetSize = sizeArg.getValue();
        if( packetsArg.isSet( ))
            nPackets = packetsArg.getValue();
        if( waitArg.isSet( ))
            waitTime = waitArg.getValue();
    }
    catch( TCLAP::ArgException& exception )
    {
        EQERROR << "Command line parse error: " << exception.error() 
                << " for argument " << exception.argId() << std::endl;

        eq::net::exit();
        return EXIT_FAILURE;
    }

    // run
    if( isClient )
    {
        Sender* sender[ NTHREADS ];
        Receiver* receiver[ NTHREADS ];
        for( size_t i = 0; i < NTHREADS; ++i )
        {
            ConnectionPtr connection = Connection::create( description );
            TEST( connection->connect( ));

            receiver[ i ] = new Receiver( packetSize, connection );
            receiver[ i ]->start();

            eq::base::sleep( 100 );
            sender[ i ] = new Sender( packetSize, connection );
            sender[ i ]->start();
        }
        for( size_t i = 0; i < NTHREADS; ++i )
        {
            sender[ i ]->join();
        }
    }
    else
    {
        ConnectionPtr connection = Connection::create( description );
        TEST( connection->listen( ));

        Sender* sender[ NTHREADS ];
        Receiver* receiver[ NTHREADS ];
        for( size_t i = 0; i < NTHREADS; ++i )
        {
            connection->acceptNB();
            ConnectionPtr reader = connection->acceptSync();

            receiver[ i ] = new Receiver( packetSize, reader );
            receiver[ i ]->start();

            eq::base::sleep( 100 );
            sender[ i ] = new Sender( packetSize, reader );
            sender[ i ]->start();
        }
        for( size_t i = 0; i < NTHREADS; ++i )
        {
            receiver[ i ]->join();
        }
    }
    return EXIT_SUCCESS;
}

