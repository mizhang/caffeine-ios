//
//  zmq_test.cpp
//  caffeine-ios
//
//  Created by Drew Crawford on 2/14/14.
//  Copyright (c) 2014 DrewCrawfordApps. All rights reserved.
//

#include "zmq_test.h"
#include "zmq.h"
#include "zmq_utils.h"
#include <assert.h>
#include <unistd.h>
#include <stdarg.h>

//prototypes
void setup_test_environment();
void
bounce (void *server, void *client);
void
expect_bounce_fail (void *server, void *client);
void close_zero_linger (void *socket);
static void zap_handler (void *handler);





//  We'll generate random test keys at startup
static char client_public [41];
static char client_secret [41];
static char server_public [41];
static char server_secret [41];

extern "C" int securityTest(void)
{

    
    //  Generate new keypairs for this test
    int rc = zmq_curve_keypair (client_public, client_secret);
    assert (rc == 0);
    rc = zmq_curve_keypair (server_public, server_secret);
    assert (rc == 0);
    
    setup_test_environment ();
    void *ctx = zmq_ctx_new ();
    assert (ctx);
    
    //  Spawn ZAP handler
    //  We create and bind ZAP socket in main thread to avoid case
    //  where child thread does not start up fast enough.
    void *handler = zmq_socket (ctx, ZMQ_REP);
    assert (handler);
    rc = zmq_bind (handler, "inproc://zeromq.zap.01");
    assert (rc == 0);
    void *zap_thread = zmq_threadstart (&zap_handler, handler);
    
    //  Server socket will accept connections
    void *server = zmq_socket (ctx, ZMQ_DEALER);
    assert (server);
    int as_server = 1;
    rc = zmq_setsockopt (server, ZMQ_CURVE_SERVER, &as_server, sizeof (int));
    assert (rc == 0);
    rc = zmq_setsockopt (server, ZMQ_CURVE_SECRETKEY, server_secret, 40);
    assert (rc == 0);
    rc = zmq_setsockopt (server, ZMQ_IDENTITY, "IDENT", 6);
    assert (rc == 0);
    rc = zmq_bind (server, "tcp://127.0.0.1:9998");
    assert (rc == 0);
    
    //  Check CURVE security with valid credentials
    void *client = zmq_socket (ctx, ZMQ_DEALER);
    assert (client);
    rc = zmq_setsockopt (client, ZMQ_CURVE_SERVERKEY, server_public, 40);
    assert (rc == 0);
    rc = zmq_setsockopt (client, ZMQ_CURVE_PUBLICKEY, client_public, 40);
    assert (rc == 0);
    rc = zmq_setsockopt (client, ZMQ_CURVE_SECRETKEY, client_secret, 40);
    assert (rc == 0);
    rc = zmq_connect (client, "tcp://localhost:9998");
    assert (rc == 0);
    bounce (server, client);
    rc = zmq_close (client);
    assert (rc == 0);
    
    //  Check CURVE security with a garbage server key
    //  This will be caught by the curve_server class, not passed to ZAP
    char garbage_key [] = "0000111122223333444455556666777788889999";
    client = zmq_socket (ctx, ZMQ_DEALER);
    assert (client);
    rc = zmq_setsockopt (client, ZMQ_CURVE_SERVERKEY, garbage_key, 40);
    assert (rc == 0);
    rc = zmq_setsockopt (client, ZMQ_CURVE_PUBLICKEY, client_public, 40);
    assert (rc == 0);
    rc = zmq_setsockopt (client, ZMQ_CURVE_SECRETKEY, client_secret, 40);
    assert (rc == 0);
    rc = zmq_connect (client, "tcp://localhost:9998");
    assert (rc == 0);
    expect_bounce_fail (server, client);
    close_zero_linger (client);
    
    //  Check CURVE security with a garbage client public key
    //  This will be caught by the curve_server class, not passed to ZAP
    client = zmq_socket (ctx, ZMQ_DEALER);
    assert (client);
    rc = zmq_setsockopt (client, ZMQ_CURVE_SERVERKEY, server_public, 40);
    assert (rc == 0);
    rc = zmq_setsockopt (client, ZMQ_CURVE_PUBLICKEY, garbage_key, 40);
    assert (rc == 0);
    rc = zmq_setsockopt (client, ZMQ_CURVE_SECRETKEY, client_secret, 40);
    assert (rc == 0);
    rc = zmq_connect (client, "tcp://localhost:9998");
    assert (rc == 0);
    expect_bounce_fail (server, client);
    close_zero_linger (client);
    
    //  Check CURVE security with a garbage client secret key
    //  This will be caught by the curve_server class, not passed to ZAP
    client = zmq_socket (ctx, ZMQ_DEALER);
    assert (client);
    rc = zmq_setsockopt (client, ZMQ_CURVE_SERVERKEY, server_public, 40);
    assert (rc == 0);
    rc = zmq_setsockopt (client, ZMQ_CURVE_PUBLICKEY, client_public, 40);
    assert (rc == 0);
    rc = zmq_setsockopt (client, ZMQ_CURVE_SECRETKEY, garbage_key, 40);
    assert (rc == 0);
    rc = zmq_connect (client, "tcp://localhost:9998");
    assert (rc == 0);
    expect_bounce_fail (server, client);
    close_zero_linger (client);
    
    //  Check CURVE security with bogus client credentials
    //  This must be caught by the ZAP handler
    char bogus_public [41];
    char bogus_secret [41];
    zmq_curve_keypair (bogus_public, bogus_secret);
    
    client = zmq_socket (ctx, ZMQ_DEALER);
    assert (client);
    rc = zmq_setsockopt (client, ZMQ_CURVE_SERVERKEY, server_public, 40);
    assert (rc == 0);
    rc = zmq_setsockopt (client, ZMQ_CURVE_PUBLICKEY, bogus_public, 40);
    assert (rc == 0);
    rc = zmq_setsockopt (client, ZMQ_CURVE_SECRETKEY, bogus_secret, 40);
    assert (rc == 0);
    rc = zmq_connect (client, "tcp://localhost:9998");
    assert (rc == 0);
    expect_bounce_fail (server, client);
    close_zero_linger (client);
    
    //  Shutdown
    rc = zmq_close (server);
    assert (rc == 0);
    rc = zmq_ctx_term (ctx);
    assert (rc == 0);
    
    //  Wait until ZAP handler terminates
    zmq_threadclose (zap_thread);
    
    return 0;
}


//  Bounce a message from client to server and back
//  For REQ/REP or DEALER/DEALER pairs only

void
bounce (void *server, void *client)
{
    const char *content = "12345678ABCDEFGH12345678abcdefgh";
    
    //  Send message from client to server
    int rc = zmq_send (client, content, 32, ZMQ_SNDMORE);
    assert (rc == 32);
    rc = zmq_send (client, content, 32, 0);
    assert (rc == 32);
    
    //  Receive message at server side
    char buffer [32];
    rc = zmq_recv (server, buffer, 32, 0);
    assert (rc == 32);
    //  Check that message is still the same
    assert (memcmp (buffer, content, 32) == 0);
    int rcvmore;
    size_t sz = sizeof (rcvmore);
    rc = zmq_getsockopt (server, ZMQ_RCVMORE, &rcvmore, &sz);
    assert (rc == 0);
    assert (rcvmore);
    rc = zmq_recv (server, buffer, 32, 0);
    assert (rc == 32);
    //  Check that message is still the same
    assert (memcmp (buffer, content, 32) == 0);
    rc = zmq_getsockopt (server, ZMQ_RCVMORE, &rcvmore, &sz);
    assert (rc == 0);
    assert (!rcvmore);
    
    //  Send two parts back to client
    rc = zmq_send (server, buffer, 32, ZMQ_SNDMORE);
    assert (rc == 32);
    rc = zmq_send (server, buffer, 32, 0);
    assert (rc == 32);
    
    //  Receive the two parts at the client side
    rc = zmq_recv (client, buffer, 32, 0);
    assert (rc == 32);
    //  Check that message is still the same
    assert (memcmp (buffer, content, 32) == 0);
    rc = zmq_getsockopt (client, ZMQ_RCVMORE, &rcvmore, &sz);
    assert (rc == 0);
    assert (rcvmore);
    rc = zmq_recv (client, buffer, 32, 0);
    assert (rc == 32);
    //  Check that message is still the same
    assert (memcmp (buffer, content, 32) == 0);
    rc = zmq_getsockopt (client, ZMQ_RCVMORE, &rcvmore, &sz);
    assert (rc == 0);
    assert (!rcvmore);
}

//  Same as bounce, but expect messages to never arrive
//  for security or subscriber reasons.

void
expect_bounce_fail (void *server, void *client)
{
    const char *content = "12345678ABCDEFGH12345678abcdefgh";
    char buffer [32];
    
    //  Send message from client to server
    int rc = zmq_send (client, content, 32, ZMQ_SNDMORE);
    assert (rc == 32);
    rc = zmq_send (client, content, 32, 0);
    assert (rc == 32);
    
    //  Receive message at server side (should not succeed)
    int timeout = 150;
    rc = zmq_setsockopt (server, ZMQ_RCVTIMEO, &timeout, sizeof (int));
    assert (rc == 0);
    rc = zmq_recv (server, buffer, 32, 0);
    assert (rc == -1);
    assert (zmq_errno () == EAGAIN);
    
    //  Send message from server to client to test other direction
    rc = zmq_send (server, content, 32, ZMQ_SNDMORE);
    assert (rc == 32);
    rc = zmq_send (server, content, 32, 0);
    assert (rc == 32);
    
    //  Receive message at client side (should not succeed)
    rc = zmq_setsockopt (client, ZMQ_RCVTIMEO, &timeout, sizeof (int));
    assert (rc == 0);
    rc = zmq_recv (client, buffer, 32, 0);
    assert (rc == -1);
    assert (zmq_errno () == EAGAIN);
}

//  Receive 0MQ string from socket and convert into C string
//  Caller must free returned string. Returns NULL if the context
//  is being terminated.
char *
s_recv (void *socket) {
    char buffer [256];
    int size = zmq_recv (socket, buffer, 255, 0);
    if (size == -1)
        return NULL;
    if (size > 255)
        size = 255;
    buffer [size] = 0;
    return strdup (buffer);
}

//  Convert C string to 0MQ string and send to socket
int
s_send (void *socket, const char *string) {
    int size = zmq_send (socket, string, strlen (string), 0);
    return size;
}

//  Sends string as 0MQ string, as multipart non-terminal
int
s_sendmore (void *socket, const char *string) {
    int size = zmq_send (socket, string, strlen (string), ZMQ_SNDMORE);
    return size;
}

#define streq(s1,s2)    (!strcmp ((s1), (s2)))
#define strneq(s1,s2)   (strcmp ((s1), (s2)))

const char *SEQ_END = (const char *) 1;

//  Sends a message composed of frames that are C strings or null frames.
//  The list must be terminated by SEQ_END.
//  Example: s_send_seq (req, "ABC", 0, "DEF", SEQ_END);
void s_send_seq (void *socket, ...)
{
    va_list ap;
    va_start (ap, socket);
    const char * data = va_arg (ap, const char *);
    while (true)
    {
        const char * prev = data;
        data = va_arg (ap, const char *);
        bool end = data == SEQ_END;
        
        if (!prev) {
            int rc = zmq_send (socket, 0, 0, end ? 0 : ZMQ_SNDMORE);
            assert (rc != -1);
        }
        else {
            int rc = zmq_send (socket, prev, strlen (prev)+1, end ? 0 : ZMQ_SNDMORE);
            assert (rc != -1);
        }
        if (end)
            break;
    }
    va_end (ap);
}

//  Receives message a number of frames long and checks that the frames have
//  the given data which can be either C strings or 0 for a null frame.
//  The list must be terminated by SEQ_END.
//  Example: s_recv_seq (rep, "ABC", 0, "DEF", SEQ_END);
void s_recv_seq (void *socket, ...)
{
    zmq_msg_t msg;
    zmq_msg_init (&msg);
    
    int more;
    size_t more_size = sizeof(more);
    
    va_list ap;
    va_start (ap, socket);
    const char * data = va_arg (ap, const char *);
    
    while (true) {
        int rc = zmq_msg_recv (&msg, socket, 0);
        assert (rc != -1);
        
        if (!data)
            assert (zmq_msg_size (&msg) == 0);
        else
            assert (strcmp (data, (const char *)zmq_msg_data (&msg)) == 0);
        
        data = va_arg (ap, const char *);
        bool end = data == SEQ_END;
        
        rc = zmq_getsockopt (socket, ZMQ_RCVMORE, &more, &more_size);
        assert (rc == 0);
        
        assert (!more == end);
        if (end)
            break;
    }
    va_end (ap);
    
    zmq_msg_close (&msg);
}


// Sets a zero linger period on a socket and closes it.
void close_zero_linger (void *socket)
{
    int linger = 0;
    int rc = zmq_setsockopt (socket, ZMQ_LINGER, &linger, sizeof(linger));
    assert (rc == 0 || errno == ETERM);
    rc = zmq_close (socket);
    assert (rc == 0);
}

void setup_test_environment()
{
#if defined _WIN32
#   if defined _MSC_VER
    _set_abort_behavior( 0, _WRITE_ABORT_MSG);
    _CrtSetReportMode( _CRT_ASSERT, _CRTDBG_MODE_FILE );
    _CrtSetReportFile( _CRT_ASSERT, _CRTDBG_FILE_STDERR );
#   endif
#endif
}

//  Provide portable millisecond sleep
// http://www.cplusplus.com/forum/unices/60161/    http://en.cppreference.com/w/cpp/thread/sleep_for
void msleep (int milliseconds)
{
#ifdef ZMQ_HAVE_WINDOWS
    Sleep (milliseconds);
#else
    usleep (static_cast <useconds_t> (milliseconds) * 1000);
#endif
}




//  --------------------------------------------------------------------------
//  Encode a binary frame as a string; destination string MUST be at least
//  size * 5 / 4 bytes long plus 1 byte for the null terminator. Returns
//  dest. Size must be a multiple of 4.

static void zap_handler (void *handler)
{
    //  Process ZAP requests forever
    while (true) {
        char *version = s_recv (handler);
        if (!version)
            break;          //  Terminating
        
        char *sequence = s_recv (handler);
        char *domain = s_recv (handler);
        char *address = s_recv (handler);
        char *identity = s_recv (handler);
        char *mechanism = s_recv (handler);
        uint8_t client_key [32];
        int size = zmq_recv (handler, client_key, 32, 0);
        assert (size == 32);
        
        char client_key_text [41];
        zmq_z85_encode (client_key_text, client_key, 32);
        
        assert (streq (version, "1.0"));
        assert (streq (mechanism, "CURVE"));
        assert (streq (identity, "IDENT"));
        
        s_sendmore (handler, version);
        s_sendmore (handler, sequence);
        
        if (streq (client_key_text, client_public)) {
            s_sendmore (handler, "200");
            s_sendmore (handler, "OK");
            s_sendmore (handler, "anonymous");
            s_send     (handler, "");
        }
        else {
            s_sendmore (handler, "400");
            s_sendmore (handler, "Invalid client public key");
            s_sendmore (handler, "");
            s_send     (handler, "");
        }
        free (version);
        free (sequence);
        free (domain);
        free (address);
        free (identity);
        free (mechanism);
    }
    zmq_close (handler);
}


