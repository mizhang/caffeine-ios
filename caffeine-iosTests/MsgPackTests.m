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

    
    
    //fixint
    NSNumber *test = [NSNumber numberWithChar:2];
    NSMutableData *data = nil;
    NSNumber *reserialized = nil;
    NSData *knownOutputData = nil;
    int bytesRead = 0;
    

    TEST(test, {0x02});
    
    //fixint negative
    test = [NSNumber numberWithChar:-2];
    TEST(test,{0xfe});
    
    
    test = [NSNumber numberWithBool:YES];
    data = [NSMutableData data];
    
    
    
}

@end
