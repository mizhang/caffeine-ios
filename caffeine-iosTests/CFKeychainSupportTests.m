//
//  CFKeychainSupportTests.m
//  caffeine-ios
//
//  Created by Drew Crawford on 8/2/14.
//  Copyright (c) 2014 DrewCrawfordApps. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CFKeychainSupport.h"
@interface CFKeychainSupportTests : XCTestCase {
    NSURL *testURL;
}

@end

@implementation CFKeychainSupportTests

- (void)setUp
{
    [super setUp];
    testURL = [NSURL URLWithString:@"tcp://whoever:whatever@localhost?foreignkey"];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAddKeychain {
    NSData *data1 = [CFKeychainSupport combinedDataForURL:testURL];
    [CFKeychainSupport reKeyForURL:testURL];
    NSData *data2 = [CFKeychainSupport combinedDataForURL:testURL];
    [CFKeychainSupport reKeyForURL:[NSURL URLWithString:@"tcp://localhost:66666?foreignkey"]];
    NSData *data3 = [CFKeychainSupport combinedDataForURL:testURL];
    XCTAssertNotEqual(data1, data2, @"data wasn't rekeyed");
    XCTAssertNotEqual(data2, data3, @"data wasn't rekeyed");
}

- (void) testPreserveKeys {
    [CFKeychainSupport reKeyIfNeededForURL:testURL];
    NSData *data1 = [CFKeychainSupport combinedDataForURL:testURL];
    [CFKeychainSupport reKeyIfNeededForURL:testURL];
    NSData *data2 = [CFKeychainSupport combinedDataForURL:testURL];
    XCTAssertEqualObjects(data1, data2, @"Unequal data.");
}

@end
