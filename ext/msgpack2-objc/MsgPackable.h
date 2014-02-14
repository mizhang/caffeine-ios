//
//  MsgPackable.h
//  caffeine-ios
//
//  Created by Drew Crawford on 1/24/14.
//  Copyright (c) 2014 DrewCrawfordApps. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol MsgPackable <NSObject>
-(void) msgPackWithMutableData:(NSMutableData*) data;

/**
 The statement below is false.  Somebody should go in here and update this.  
 @warning this documentation is unreliable
 
 This is sort of an interesting API choice, but it turns out that [NSData subdataWithRange:] is copy-free.  So we can just use that to return the new data.  See below for the benchmark code. */
+(instancetype) unMsgPackFromData:(NSData*) data bytesRead:(int*)bytePtr;

/*    //benchmark 1
 NSData *bytes = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"1mb" ofType:@"txt"]];
 NSData *subData = bytes;
 NSDate *start = [NSDate date];
 for(int i = 0; i < 10000; i++) {
 subData = [bytes subdataWithRange:NSMakeRange(1, subData.length - 1)];
 char byte =  ((char*)subData.bytes)[0];
 byte++;
 }
 NSDate *end = [NSDate date];
 NSLog(@"Time was %f", [end timeIntervalSinceDate:start]);
 
 //benchmark 2
 start = [NSDate date];
 char *buff = malloc(bytes.length);
 for(int i = 0; i < 10000; i++) {
 [bytes getBytes:buff range:NSMakeRange(1, subData.length - 1)];
 char byte = buff[0];
 byte++;
 }
 end = [NSDate date];
 NSLog(@"Time was %f",[end timeIntervalSinceDate:start]);
 
 Outputs:  2014-01-24 23:00:31.912 SubDataWithRangeBenchmark[6883:70b] Time was 0.005565
 2014-01-24 23:00:32.732 SubDataWithRangeBenchmark[6883:70b] Time was 0.818437
 */
@end
