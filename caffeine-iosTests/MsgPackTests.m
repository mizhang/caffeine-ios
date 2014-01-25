//
//  MsgPackTests.m
//  caffeine-ios
//
//  Created by Drew Crawford on 1/25/14.
//  Copyright (c) 2014 DrewCrawfordApps. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSObject+MsgPack.h"
#import "MsgPack2Objc.h"

@interface MsgPackTests : XCTestCase

@end

@implementation MsgPackTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testNSNumber {
    
#define TEST(input,knownOutput)\
data = [[NSMutableData alloc] init];\
knownOutputData = [NSData dataWithBytes:(unsigned char[])knownOutput length:sizeof((unsigned char[]) knownOutput)];\
[input msgPackWithMutableData:data];\
XCTAssertEqualObjects(data,knownOutputData,@"Serialization error");\
bytesRead = 0;\
reserialized = [NSNumber unMsgPackFromData:data bytesRead:&bytesRead];\
XCTAssertEqualObjects(input,reserialized)

    
    
    NSNumber *test = [NSNumber numberWithChar:2];
    NSMutableData *data = nil;
    NSNumber *reserialized = nil;
    NSData *knownOutputData = nil;
    int bytesRead = 0;
    
    //fixint
    TEST(test, {0x02});
    
    //fixint negative
    test = [NSNumber numberWithChar:-2];
    TEST(test,{0xfe});
    
    //bool
    //be advised, ObjC pretty much treats BOOL as 0,1.  So if you were expecting MsgPack's actual bool (c3), be prepared to be surprised.
    TEST([NSNumber numberWithBool:YES],{0x01});
    TEST(@NO,{0x00});
    
    //however, it's easy to verify that the reverse works as expected
    NSData *oobdata = [NSData dataWithBytes:(unsigned char[]){0xc3} length:1];
    bytesRead = 0;
    NSNumber *yes = [NSNumber unMsgPackFromData:oobdata bytesRead:&bytesRead];
    XCTAssertTrue(yes.boolValue, @"Not true?");
    oobdata = [NSData dataWithBytes:(unsigned char[]){0xc2} length:1];
    bytesRead = 0;
    NSNumber *no = [NSNumber unMsgPackFromData:oobdata bytesRead:&bytesRead];
    XCTAssertFalse(no.boolValue, @"Not no?");
    
    
    
}

@end
