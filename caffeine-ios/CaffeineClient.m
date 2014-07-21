//
//  CaffeineClient.m
//  caffeine-ios
//
//  Created by Drew Crawford on 2/12/14.
//  Copyright (c) 2014 DrewCrawfordApps. All rights reserved.
//

#import "CaffeineClient.h"
#import "libnitrogen.h"
#import "NSObject+MsgPack.h"
#import "NSData+Y64.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSObject+CaffeinePack.h"
static NSPointerArray *allInstances;
@interface CaffeineClient() {
    @public //not really
    NSURL *originalURL;
    int nitrogenSocket;
}
@end
@implementation CaffeineClient
- (instancetype) initWithURL:(NSURL*) url {
    if (self = [super init]) {

        originalURL = url;
        NSString *urlForNitrogen = [NSString stringWithFormat:@"%@://%@:%@",url.scheme,url.host,url.port];
#ifdef CAFFEINE_OVERRIDE_URL
        NSLog(@"Overriding URL with command-line version %@",CAFFEINE_OVERRIDE_URL);
        urlForNitrogen = CAFFEINE_OVERRIDE_URL;
#endif
        NSData *userData = [[NSData alloc] initWithY64EncodedString:url.user];
        NSData *passwordData = [[NSData alloc] initWithY64EncodedString:url.password];
        NSData *serverData = [[NSData alloc] initWithY64EncodedString:url.user];

        nitrogenSocket = n_client([urlForNitrogen cStringUsingEncoding:NSUTF8StringEncoding], (uint8_t*) userData.bytes, (uint8_t*)passwordData.bytes, (uint8_t*)serverData.bytes);
        NSAssert(nitrogenSocket >= 0,@"Invalid socket?");
    }
    return self;
}

- (NSData *)responseForRequest:(NSData *)data {
    NSAssert(data.length < INT_MAX, @"Data length violates constraint");
    int rc = n_clientmsgsend(nitrogenSocket, data.bytes, (int)data.length);
    NSAssert(rc ==data.length, @"Send error");
    char *buf = NULL;
    int size = rc = n_clientmsgrecv(nitrogenSocket, &buf);
    NSAssert(rc>=0, @"receive error");
    
    //thanks Apple!
    NSData *returnMe = [[NSData alloc] initWithBytesNoCopy:buf length:size deallocator:^(void *bytes, NSUInteger length) {
        printf("Zeroing a message\n");
        n_clientmsgdispose(nitrogenSocket,buf);
    }];
    return returnMe;
}

- (id)RPCClassMethod:(NSString *)method inClass:(NSString *)klass withArguments:(NSDictionary *)arguments {
    if (!arguments) arguments = @{};
    NSDictionary *dict = @{@"_a": [arguments caffeinePackObjectRepresentation],@"_c":klass,@"_s":method};
    NSMutableData *msgPackData = [[NSMutableData alloc] init];
    [dict msgPackWithMutableData:msgPackData];
    NSData *responseData = [self responseForRequest:msgPackData];
    int bytesRead = 0;
    id responseObject = [NSObject unMsgPackFromData:responseData bytesRead:&bytesRead];
    return responseObject;
}


@end
