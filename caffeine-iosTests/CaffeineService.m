
//
//  CaffeineService.m
//
//  Created by caffeine-codegen
//  This file is automatically generated by caffeine.  You **MUST NOT** modify it.  
//  This code is provided under the terms of the caffeine license for Python.  To use this software you must agree to its terms.

#import "CaffeineService.h"
#import "CaffeineClient.h"
@implementation CaffeineService
static NSURL *clientURL;

+ (void)load {
    clientURL = [NSURL URLWithString:@"tcp://yxDrGth0x7Mp6gZdcb2iFymACxoPbXgbgMFT7rELGmI-:WSKWXvnHyF7_jNEchETg1NoZte6Nsd3htA4CWRqZv1A-@127.0.0.1:55555?yxDrGth0x7Mp6gZdcb2iFymACxoPbXgbgMFT7rELGmI-"];
}

+ (Schema)directoryWithError:(NSError**)error  {
            CaffeineClient *currentClient = [CaffeineClient clientOnThread:[NSThread currentThread] forURL:clientURL];
    NSString *result = [currentClient RPCClassMethod:@"directory" inClass:NSStringFromClass([self class]) withArguments:nil];
    if ([result isKindOfClass:[NSError class]]) {
        *error = (NSError*)result;
        return result;
    }
    return result;
};

@end