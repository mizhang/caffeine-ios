//
//  URLTests.m
//  caffeine-ios
//
//  Created by Drew Crawford on 8/2/14.
//  Copyright (c) 2014 DrewCrawfordApps. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSURL+CaffeineURLTools.h"

@interface URLTests : XCTestCase

@end

@implementation URLTests

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

- (void)testURLStrip
{
    NSURL *url = [[NSURL alloc] initWithString:@"tcp://root:password@localhost:55555?remotekeys"];
    url = [url URLByStrippingLocalNitrogenCredentials];
    NSURL *expectedURL = [[NSURL alloc] initWithString:@"tcp://localhost:55555?remotekeys"];
    XCTAssertEqualObjects(url, expectedURL, @"URL mismatch");
}

-(void) testURLStripAll {
    NSURL *url = [[NSURL alloc] initWithString:@"tcp://root:password@localhost:55555?remotekeys"];
    url = [url URLByStrippingAllNitrogenCredentials];
    NSURL *expectedURL = [[NSURL alloc] initWithString:@"tcp://localhost:55555"];
    XCTAssertEqualObjects(url, expectedURL, @"URL mismatch");
}

@end
