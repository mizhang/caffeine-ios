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
- (NSString *)y64String {
    NSMutableString *b64 = [[self base64EncodedStringWithOptions:0] mutableCopy];
    [b64 replaceOccurrencesOfString:@"/" withString:@"_" options:0 range:NSMakeRange(0, b64.length)];
    [b64 replaceOccurrencesOfString:@"=" withString:@"-" options:0 range:NSMakeRange(0, b64.length)];
    [b64 replaceOccurrencesOfString:@"+" withString:@"." options:0 range:NSMakeRange(0, b64.length)];
    return [b64 copy];
}
- (BOOL)isInsecureKey {
    return [self.y64String isEqualToString:@"YmFkpcMa0YH_iuJ8bNtaZCmjL_FHtE4UBlKkm4wnQSY-"] || [self.y64String isEqualToString:@".bY4DWxI9vSgFMw7WZAmDgnUFIKW.NHIWrsAB..t3ms-"];
}
@end
