//
//  MultiplatformTests.m
//  caffeine-ios
//
//  Created by Drew Crawford on 2/13/14.
//  Copyright (c) 2014 DrewCrawfordApps. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Foo.h"

@interface MultiplatformTests : XCTestCase

@end

@implementation MultiplatformTests

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



- (void)testHelloWorld {
    NSError *err = nil;
    NSString *helloWorldResponse = [Foo helloWorldWithError:&err];
    XCTAssertNil(err, @"Got error unexpectedly");
    XCTAssertEqualObjects(helloWorldResponse, @"hello world", @"Hello world wasn't as expected.");
}

@end
