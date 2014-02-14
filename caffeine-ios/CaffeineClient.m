//
//  CaffeineClient.m
//  caffeine-ios
//
//  Created by Drew Crawford on 2/12/14.
//  Copyright (c) 2014 DrewCrawfordApps. All rights reserved.
//

#import "CaffeineClient.h"
#import "zmq.h"
#import "NSObject+MsgPack.h"
#import "NSData+Y64.h"
static void *context;
static NSPointerArray *allInstances;
@interface CaffeineClient() {
    @public //not really
    void *zmqSocket;
    dispatch_queue_t associatedQueue;
    NSThread *associatedThread;
    NSURL *originalURL;
}
@end
@implementation CaffeineClient
- (instancetype) initWithURL:(NSURL*) url {
    if (self = [super init]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            context = zmq_ctx_new();
            allInstances = [NSPointerArray weakObjectsPointerArray];
        });
        [allInstances addPointer:(__bridge void *)(self)];
        originalURL = url;
        NSString *urlForZmq = [NSString stringWithFormat:@"%@://%@:%@",url.scheme,url.host,url.port];
        zmqSocket = zmq_socket(context, ZMQ_REQ);
        if (url.user) {
            //decode the URL
            NSData *userData = [[NSData alloc] initWithY64EncodedString:url.user];
            int rc = zmq_setsockopt(zmqSocket, ZMQ_CURVE_PUBLICKEY, userData.bytes, userData.length);
            NSAssert(rc==0, @"sockopt error %d",errno);
            NSData *passwordData = [[NSData alloc] initWithY64EncodedString:url.password];
            rc = zmq_setsockopt(zmqSocket, ZMQ_CURVE_SECRETKEY, passwordData.bytes, passwordData.length);
            NSAssert(rc==0, @"sockopt error");
            NSData *serverData = [[NSData alloc] initWithY64EncodedString:url.user];
            rc = zmq_setsockopt(zmqSocket, ZMQ_CURVE_SERVERKEY, serverData.bytes,serverData.length);
            NSAssert(rc==0, @"sockopt error");
            
        }
        int rc = zmq_connect(zmqSocket, [urlForZmq cStringUsingEncoding:NSUTF8StringEncoding]);
        NSAssert(rc==0, @"Connection error?");
    }
    return self;
}
- (instancetype)initWithURL:(NSURL *)url onQueue:(dispatch_queue_t)queue {
    if (self = [self initWithURL:url]) {
        associatedQueue = queue;
    }
    return self;
}
- (instancetype)initWithURL:(NSURL *)url onThread:(NSThread *)thread {
    if (self = [self initWithURL:url]) {
        associatedThread = thread;
    }
    return self;
}

- (NSData *)responseForRequest:(NSData *)data {
    NSAssert(dispatch_get_current_queue()==associatedQueue || [NSThread currentThread]==associatedThread, @"This isn't threadsafe");
    int rc = zmq_send(zmqSocket, data.bytes, data.length, 0);
    NSAssert(rc==0, @"send error");
    zmq_msg_t msg;
    zmq_msg_init(&msg);
    NSAssert(rc==0, @"Msg error");
    rc = zmq_msg_recv (&msg, zmqSocket, 0);
    NSAssert(rc != 0, @"Msg error 2");
    
    //thanks Apple!
    NSData *returnMe = [[NSData alloc] initWithBytesNoCopy:zmq_msg_data(&msg) length:zmq_msg_size(&msg) deallocator:^(void *bytes, NSUInteger length) {
        zmq_msg_close((zmq_msg_t*)&msg);
    }];
    return returnMe;
}

- (id)RPCClassMethod:(NSString *)method inClass:(NSString *)klass withArguments:(NSDictionary *)arguments {
    NSDictionary *dict = @{@"_a": arguments,@"_c":klass,@"_m":method};
    NSMutableData *msgPackData = [[NSMutableData alloc] init];
    [dict msgPackWithMutableData:msgPackData];
    NSData *responseData = [self responseForRequest:msgPackData];
    id responseObject = [NSObject unMsgPackFromData:responseData bytesRead:0];
    return responseObject;
}

+ (instancetype)clientOnQueue:(dispatch_queue_t) queue forURL :(NSURL *)url {
    for(CaffeineClient *client in allInstances) {
        if (client->associatedQueue==queue && [client->originalURL isEqual:url]) {
            return client;
        }
    }
    return [[self alloc] initWithURL:url onQueue:queue];
}

+ (instancetype)clientOnThread:(NSThread *)thread forURL:(NSURL *)url {
    for(CaffeineClient *client in allInstances) {
        if (client->associatedThread==thread && [client->originalURL isEqual:url]) {
            return client;
        }
    }
    return [[self alloc] initWithURL:url onThread:thread];
}


@end
