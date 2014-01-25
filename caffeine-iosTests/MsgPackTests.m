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

-(NSData*) testDataOfLength:(uint32_t) length {
    char *bytes = calloc(length, 1);
    bytes[0] = 0x99;
    bytes[length - 1] = 0x99;
    NSData *testData = [NSData dataWithBytes:bytes length:length];
    free(bytes);
    return testData;
}

-(void) testData {
#define TEST(input,knownOutput)\
data = [[NSMutableData alloc] init];\
knownOutputData = [NSData dataWithBytes:knownOutput length:sizeof(knownOutput)];\
[input msgPackWithMutableData:data];\
XCTAssertEqualObjects(data,knownOutputData,@"Serialization error");\
bytesRead = 0;\
reserialized = [NSData unMsgPackFromData:data bytesRead:&bytesRead];\
XCTAssertEqualObjects(input,reserialized)
    
    NSMutableData *data = nil;
    NSData *reserialized = nil;
    NSData *knownOutputData = nil;
    int bytesRead = 0;
    
    NSData *input = [self testDataOfLength:3];
    unsigned char buf[] = {0xc4,0x03,0x99,0x00,0x99};
    TEST(input, buf);
    
    input = [self testDataOfLength:65530];
    data = [[NSMutableData alloc] init];
    [input msgPackWithMutableData:data];
    char *bytes = (char*) data.bytes;
    XCTAssertEqual(bytes[0], (char) 0xc5, @"bin16");
    XCTAssertEqual(bytes[1], (char) 0xff, @"bin16"); //65530
    XCTAssertEqual(bytes[2], (char) 0xfa, @"bin16"); //
    XCTAssertEqual(bytes[3], (char) 0x99, @"bin16"); //data
    XCTAssertEqual(bytes[4], (char) 0x00, @"bin16"); //data
    XCTAssertEqual(bytes[65528+3], (char) 0x00, @"bin16"); //data
    XCTAssertEqual(bytes[65529+3], (char) 0x99, @"bin16"); //data
    bytesRead = 0;
    reserialized = [NSData unMsgPackFromData:data bytesRead:&bytesRead];
    XCTAssertEqualObjects(input, reserialized, @"deserialization issue");
    
    

    input = [self testDataOfLength:65536];
    data = [[NSMutableData alloc] init];
    [input msgPackWithMutableData:data];
    bytes = (char*) data.bytes;
    XCTAssertEqual(bytes[0], (char) 0xc6, @"bin32");
    XCTAssertEqual(bytes[1], (char) 0x00, @"bin32"); //65536
    XCTAssertEqual(bytes[2], (char) 0x01, @"bin32"); //
    XCTAssertEqual(bytes[3], (char) 0x00, @"bin32"); //
    XCTAssertEqual(bytes[4], (char) 0x00, @"bin32"); //
    XCTAssertEqual(bytes[5], (char) 0x99, @"bin32"); //data
    XCTAssertEqual(bytes[6], (char) 0x00, @"bin32"); //data
    XCTAssertEqual(bytes[65534+5], (char) 0x00, @"bin32"); //data
    XCTAssertEqual(bytes[65535+5], (char) 0x99, @"bin32"); //data
    bytesRead = 0;
    reserialized = [NSData unMsgPackFromData:data bytesRead:&bytesRead];
    XCTAssertEqualObjects(input, reserialized, @"deserialization issue");
    
}

- (void)testNSNumber {
#undef TEST
#define TEST(input,knownOutput)\
data = [[NSMutableData alloc] init];\
knownOutputData = [NSData dataWithBytes:knownOutput length:sizeof(knownOutput)];\
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
    
    unsigned char buf[] = {0x02};
    //fixint
    TEST(test, buf);
    
    //fixint negative
    test = [NSNumber numberWithChar:-2];
    unsigned char buf2[] = {0xfe};
    TEST(test,buf2);
    
    //bool
    //be advised, ObjC pretty much treats BOOL as 0,1.  So if you were expecting MsgPack's actual bool (c3), be prepared to be surprised.
    unsigned char buf4[] = {0x01};
    TEST([NSNumber numberWithBool:YES],buf4);
    unsigned char buf3[] = {0x00};
    TEST(@NO,buf3);
    
    //however, it's easy to verify that the reverse works as expected
    NSData *oobdata = [NSData dataWithBytes:(unsigned char[]){0xc3} length:1];
    bytesRead = 0;
    NSNumber *yes = [NSNumber unMsgPackFromData:oobdata bytesRead:&bytesRead];
    XCTAssertTrue(yes.boolValue, @"Not true?");
    oobdata = [NSData dataWithBytes:(unsigned char[]){0xc2} length:1];
    bytesRead = 0;
    NSNumber *no = [NSNumber unMsgPackFromData:oobdata bytesRead:&bytesRead];
    XCTAssertFalse(no.boolValue, @"Not no?");
    
    //float
    NSNumber *f = [NSNumber numberWithFloat:3.5];
    unsigned char buf5[] = {0xca,0x40,0x60,0x00,0x00};
    TEST(f, buf5);
    
    //double
    f = [NSNumber numberWithDouble:3.5];
    unsigned char buf6[] = {0xcb, 0x40 ,0x0c ,00 ,00 ,00 ,00 ,00 ,00};
    TEST(f, buf6);
    
    //uint types
    //uint8
    NSNumber *u = [NSNumber numberWithUnsignedInteger:255];
    unsigned char buf7[] = {0xcc,0xff};
    TEST(u, buf7);
    //uint16
    u = [NSNumber numberWithUnsignedInteger:256];
    unsigned char buf8[] = {0xcd, 0x01, 0x00};
    TEST(u, buf8);
    //uint32
    u = [NSNumber numberWithUnsignedInteger:65536];
    unsigned char buf9[] = {0xce,00,01,00,00};
    TEST(u, buf9);
    //uint64
    u = [NSNumber numberWithUnsignedLongLong:123456789012];
    unsigned char buf10[] = {0xcf,00, 00, 00, 0x1c, 0xbe, 0x99, 0x1a,0x14};
    TEST(u, buf10);
    
    //int types
    //int8
    NSNumber *i = [NSNumber numberWithInt:-100];
    unsigned char buf11[] = {0xd0,0x9c};
    TEST(i, buf11);
    //int16
    i = [NSNumber numberWithInt:-200];
    unsigned char buf12[] = {0xd1,0xff,0x38};
    TEST(i, buf12);
    //int32
    i = [NSNumber numberWithInt:-50000];
    unsigned char buf13[] = {0xd2, 0xff, 0xff, 0x3c, 0xb0};
    TEST(i, buf13);
    //int64
    i = [NSNumber numberWithLongLong:-5000000000];
    unsigned char buf14[] = {0xd3, 0xff, 0xff, 0xff, 0xfe, 0xd5, 0xfa, 0x0e, 00};
    TEST(i, buf14);
    
}

@end
