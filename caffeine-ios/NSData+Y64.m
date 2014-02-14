//
//  NSData+ModifiedBase64.m
//  caffeine-ios
//
//  Created by Drew Crawford on 2/14/14.
//  Copyright (c) 2014 DrewCrawfordApps. All rights reserved.
//

#import "NSData+Y64.h"

@implementation NSData (Y64)
-(instancetype) initWithY64EncodedString:(NSString *)base64String {
    NSMutableString *originalBase64 = [[NSMutableString alloc] initWithString:base64String];
    [originalBase64 replaceOccurrencesOfString:@"_" withString:@"/" options:0 range:NSMakeRange(0, originalBase64.length)];
    [originalBase64 replaceOccurrencesOfString:@"-" withString:@"=" options:0 range:NSMakeRange(0, originalBase64.length)];
    [originalBase64 replaceOccurrencesOfString:@"." withString:@"+" options:0 range:NSMakeRange(0, originalBase64.length)];
    if (self = [self initWithBase64EncodedString:originalBase64 options:0]) {
        
    }
    return self;
}
@end
