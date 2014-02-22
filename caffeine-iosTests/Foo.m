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
    clientURL = [NSURL URLWithString:@"tcp://yxDrGth0x7Mp6gZdcb2iFymACxoPbXgbgMFT7rELGmI-:WSKWXvnHyF7_jNEchETg1NoZte6Nsd3htA4CWRqZv1A-@127.0.0.1:55555?WSKWXvnHyF7_jNEchETg1NoZte6Nsd3htA4CWRqZv1A-"];
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
