//
//  Foo.m
//  caffeine-ios
//
//  Created by Drew Crawford on 2/13/14.
//  Copyright (c) 2014 DrewCrawfordApps. All rights reserved.
//

#import "Foo.h"
#import "CaffeineClient.h"
@implementation Foo
static NSURL *clientURL;

+ (void)load {
    clientURL = [NSURL URLWithString:@"tcp://K21KJFQvTXRmdWRFNGF5QUxuNy5kcy5eQTRARExnRndDZ0xVKVJFVg--:c1Q2ZXJ9blpNLiVidHRCR0hCK0YqOG1yXkpKfXIjVjwpZHU4S1h1cA--@127.0.0.1:66666?K21KJFQvTXRmdWRFNGF5QUxuNy5kcy5eQTRARExnRndDZ0xVKVJFVg--"];
}
+ (NSString *)helloWorldWithError:(NSError *__autoreleasing *)error {
    CaffeineClient *currentClient = [CaffeineClient clientOnThread:[NSThread currentThread] forURL:clientURL];
    NSString *result = [currentClient RPCClassMethod:@"hello_world" inClass:@"Foo" withArguments:@{}];
    if ([result isKindOfClass:[NSError class]]) {
        *error = (NSError*)result;
        return nil;
    }
    return result;
}
@end
