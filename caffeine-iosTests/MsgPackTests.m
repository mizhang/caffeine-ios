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

-(void) testMap {
#define TEST(input,knownOutput)\
data = [[NSMutableData alloc] init];\
knownOutputData = [NSData dataWithBytes:knownOutput length:sizeof(knownOutput)];\
[input msgPackWithMutableData:data];\
XCTAssertEqualObjects(data,knownOutputData,@"Serialization error");\
bytesRead = 0;\
reserialized = [NSDictionary unMsgPackFromData:data bytesRead:&bytesRead];\
XCTAssertEqualObjects(input,reserialized)
    
    NSMutableData *data = nil;
    NSDictionary *reserialized = nil;
    NSData *knownOutputData = nil;
    int bytesRead = 0;
    
    NSDictionary *input = @{@"k":@"v"};
    char buf[] = {0x81, 0xa1, 0x6b, 0xa1, 0x76};
    TEST(input, buf);
    
#undef TEST
#define TEST(input,firstByte)\
data = [[NSMutableData alloc] init];\
[input msgPackWithMutableData:data];\
XCTAssertEqual(((char*)data.bytes)[0],(char)firstByte,@"Serialization error");\
bytesRead = 0;\
reserialized = [NSDictionary unMsgPackFromData:data bytesRead:&bytesRead];\
XCTAssertEqualObjects(input,reserialized)
    
    input = @{@"k":@"v",@"a":@"v",@"b":@"v",@"c":@"v",@"d":@"v",@"e":@"v",@"f":@"f",@"g":@"g",@"h":@"h",@"I":@"I",@"j":@"j",@"k":@"k",@"l":@"L",@"m":@"M",@"n":@"N",@"O":@"O",@"p":@"P"};
    
    TEST(input, 0xde);
    
    //array32
    /*NSMutableDictionary *dict32 = [[NSMutableDictionary alloc] init];
    for(int i = 0; i < 65536; i++) {
        dict32[@(i)]=@YES;
    }
    TEST(dict32, 0xdf);*/
    
    
    
}

-(void) testArray {
#undef TEST
#define TEST(input,knownOutput)\
data = [[NSMutableData alloc] init];\
knownOutputData = [NSData dataWithBytes:knownOutput length:sizeof(knownOutput)];\
[input msgPackWithMutableData:data];\
XCTAssertEqualObjects(data,knownOutputData,@"Serialization error");\
bytesRead = 0;\
reserialized = [NSArray unMsgPackFromData:data bytesRead:&bytesRead];\
XCTAssertEqualObjects(input,reserialized)

    NSMutableData *data = nil;
    NSArray *reserialized = nil;
    NSData *knownOutputData = nil;
    int bytesRead = 0;
    
    //fixarray
    NSArray *input = @[@1,@2];
    char buf[] = {0x92,0x01,0x02};
    TEST(input, buf);
    
    //array16
    input = @[@1,@2,@3,@4,@5,@6,@7,@8,@9,@10,@11,@12,@13,@14,@15,@16];
    char buf1[] = {0xdc, 0x00, 0x10, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c ,0x0d, 0x0e, 0x0f, 0x10};
    TEST(input, buf1);
    
    //array32
    /*NSMutableArray *in1 = [[NSMutableArray alloc] initWithCapacity:65536];
    for (int i = 0; i < 65536; i++) {
        [in1 addObject:@YES];
    }
    data = [[NSMutableData alloc] init];
    [in1 msgPackWithMutableData:data];
    bytesRead = 0;
    reserialized = [NSArray unMsgPackFromData:data bytesRead:&bytesRead];
    XCTAssertEqualObjects(in1,reserialized);*/
    
}

-(void) testString {
#undef TEST
#define TEST(input,knownOutput)\
data = [[NSMutableData alloc] init];\
knownOutputData = [NSData dataWithBytes:knownOutput length:sizeof(knownOutput)];\
[input msgPackWithMutableData:data];\
XCTAssertEqualObjects(data,knownOutputData,@"Serialization error");\
bytesRead = 0;\
reserialized = [NSString unMsgPackFromData:data bytesRead:&bytesRead];\
XCTAssertEqualObjects(input,reserialized)
    
    NSMutableData *data = nil;
    NSString *reserialized = nil;
    NSData *knownOutputData = nil;
    int bytesRead = 0;
    
    //fixstr
    NSString *input = @"test";
    unsigned char buf[] = {0xa4,0x74,0x65,0x73,0x74};
    TEST(input, buf);
    
    //str8
    input = @"testABCDEFGHIJKLAJWOERIQUAJFLWOF";
    unsigned char buf1[] = {0xd9,0x20,0x74,0x65,0x73,0x74,0x41,0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4a, 0x4b, 0x4c, 0x41, 0x4a, 0x57, 0x4f, 0x45, 0x52, 0x49, 0x51, 0x55, 0x41, 0x4a, 0x46, 0x4c, 0x57, 0x4f, 0x46};
    TEST(input, buf1);

//too big to construct the output so we just verify the first byte
#undef TEST
#define TEST(input,firstByte)\
data = [[NSMutableData alloc] init];\
[input msgPackWithMutableData:data];\
XCTAssertEqual(((char*)data.bytes)[0],(char)firstByte,@"Not expected header.");\
bytesRead = 0;\
reserialized = [NSString unMsgPackFromData:data bytesRead:&bytesRead];\
XCTAssertEqualObjects(input,reserialized)
    //str16
    NSMutableString *buildAString = [[NSMutableString alloc] init];
    while (buildAString.length < 400) {
        [buildAString appendString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ"];
    }
    TEST(buildAString, 0xda);
    
    //str32
    while(buildAString.length < 65536) {
        [buildAString appendString:buildAString];
    }
    TEST(buildAString, 0xdb);
    

    
    
}

-(void) testData {
#undef TEST
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
