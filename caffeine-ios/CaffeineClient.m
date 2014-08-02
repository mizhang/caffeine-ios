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
#import "NSURL+CaffeineURLTools.h"
#import <UIKit/UIKit.h>
static NSMutableDictionary *allInstances;
@interface CaffeineClient() {
    @public //not really
    NSURL *keyedURL;
    int nitrogenSocket;
}
@end
@implementation CaffeineClient
+ (instancetype)clientForURL:(NSURL *)url {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        allInstances = [[NSMutableDictionary alloc] init];
    });
    if (allInstances[url]) {
        return allInstances[url];
    }
    allInstances[url] = [[CaffeineClient alloc] initWithURL:url];
    return allInstances[url];
}
- (instancetype) initWithURL:(NSURL*) url {
    if (self = [super init]) {
        if (url.user) {
            NSLog(@"Populating credentials from URL and ignoring keychain values.");
        }
        else {
            url = [url URLByPopulatingLocalNitrogenCredentials];
        }
        keyedURL = url; //it's conceivable that a process might have multiple users using different credentials against the same endpoint
        NSString *urlForNitrogen = url.URLByStrippingAllNitrogenCredentials.absoluteString;
#ifdef CAFFEINE_OVERRIDE_URL
        NSLog(@"Overriding nitrogen-passed URL with command-line version %@",CAFFEINE_OVERRIDE_URL);
        urlForNitrogen = CAFFEINE_OVERRIDE_URL;
#endif
        NSData *userData = [[NSData alloc] initWithY64EncodedString:url.user];
        NSData *passwordData = [[NSData alloc] initWithY64EncodedString:url.password];
        NSData *serverData = [[NSData alloc] initWithY64EncodedString:url.query];
        if (serverData.isInsecureKey) {
            /**Sure, you can comment out this line.  But you can't comment out the weak authentication mechanism it represents.*/
            [[[UIAlertView alloc] initWithTitle:@"caffeine dev version" message:@"This version of caffeine is licensed for development and noncommercial use purposes only.  Weak authentication is being used; this is not suitable for storing sensitive data." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        }
        NSLog(@"Logging in as credential %@",url.user);
        
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
