//
//  NSURL+CaffeineURLTools.m
//  caffeine-ios
//
//  Created by Drew Crawford on 8/2/14.
//  Copyright (c) 2014 DrewCrawfordApps. All rights reserved.
//

#import "NSURL+CaffeineURLTools.h"
#import "CFKeychainSupport.h"
#import "libnitrogen.h"
#import "NSData+Y64.h"

@implementation NSURL (CaffeineURLTools)
- (NSURL *)URLByStrippingLocalNitrogenCredentials {
    NSError *err = nil;
    NSString *pattern = [NSString stringWithFormat:@"%@:%@@",self.user,self.password];
    
    NSRegularExpression *re = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:&err];
    NSString *urlString = [re stringByReplacingMatchesInString:self.absoluteString options:0 range:NSMakeRange(0, self.absoluteString.length) withTemplate:@""];
    return [[NSURL alloc] initWithString:urlString];
}

- (NSURL *)URLByStrippingAllNitrogenCredentials {
    NSURL *url = [self URLByStrippingLocalNitrogenCredentials];
    NSError *err = nil;
    NSString *pattern = @"\\?.*";
    NSRegularExpression *re = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:&err];
    NSString *urlString = [re stringByReplacingMatchesInString:url.absoluteString options:0 range:NSMakeRange(0, url.absoluteString.length) withTemplate:@""];
    return [[NSURL alloc] initWithString:urlString];
}

- (NSURL *)URLByPopulatingLocalNitrogenCredentials {
    NSData *combined = [CFKeychainSupport combinedDataForURL:self];
    if (!combined) {
        [CFKeychainSupport reKeyIfNeededForURL:self];
        combined = [CFKeychainSupport combinedDataForURL:self];
        if (!combined) {
            NSLog(@"Error: serious problem fetching keychain data.");
            return nil;
        }
    }
    NSData *public = [combined subdataWithRange:NSMakeRange(0, LIBNITROGEN_KEYSIZE)];
    NSData *private = [combined subdataWithRange:NSMakeRange(LIBNITROGEN_KEYSIZE, LIBNITROGEN_KEYSIZE)];
    NSString *user = [public y64String];
    NSString *password = [private y64String];
    NSString *URLTemplate = [NSString stringWithFormat:@"%@://%@:%@@%@:%@?%@",self.scheme,user,password,self.host,self.port,self.query];
    return [[NSURL alloc] initWithString:URLTemplate];
}
@end
