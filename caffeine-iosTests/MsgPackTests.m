//
//  MsgPackTests.m
//  caffeine-ios
//
//  Created by Drew Crawford on 1/25/14.
//  Copyright (c) 2014 DrewCrawfordApps. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSObject+MsgPack.h"

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
    //char
    NSNumber *char1 = [NSNumber numberWithChar:2];
    NSMutableData *data = [[NSMutableData alloc] init];
    [char1 msgPackWithMutableData:data];
    
}

@end
