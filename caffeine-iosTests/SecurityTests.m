//
//  SecurityTests.m
//  caffeine-ios
//
//  Created by Drew Crawford on 2/16/14.
//  Copyright (c) 2014 DrewCrawfordApps. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "zmq_test.h"

@interface SecurityTests : XCTestCase

@end

@implementation SecurityTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

-(void) testSecurity {
    int returnCode = securityTest();
    XCTAssertEqual(returnCode, 0, @"security failure");
}
@end
