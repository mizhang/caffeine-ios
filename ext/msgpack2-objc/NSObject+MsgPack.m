//
//  NSObject+MsgPack.m
//  caffeine-ios
//
//  Created by Drew Crawford on 1/24/14.
//  Copyright (c) 2014 DrewCrawfordApps. All rights reserved.
//

#import "NSObject+MsgPack.h"
#import "MsgPack2Objc.h"
#import <Endian.h>

#if BYTE_ORDER==LITTLE_ENDIAN
#define _msgpack_be16(x) __DARWIN_OSSwapInt16(x)
#define _msgpack_be32(x) __DARWIN_OSSwapInt32(x)
#define _msgpack_be64(x) __DARWIN_OSSwapInt64(x)

#define _msgpack_load16(cast, from) ((cast)( \
(((uint16_t)((uint8_t*)(from))[0]) << 8) | \
(((uint16_t)((uint8_t*)(from))[1])     ) ))

#define _msgpack_load32(cast, from) ((cast)( \
(((uint32_t)((uint8_t*)(from))[0]) << 24) | \
(((uint32_t)((uint8_t*)(from))[1]) << 16) | \
(((uint32_t)((uint8_t*)(from))[2]) <<  8) | \
(((uint32_t)((uint8_t*)(from))[3])      ) ))

#define _msgpack_load64(cast, from) ((cast)( \
(((uint64_t)((uint8_t*)(from))[0]) << 56) | \
(((uint64_t)((uint8_t*)(from))[1]) << 48) | \
(((uint64_t)((uint8_t*)(from))[2]) << 40) | \
(((uint64_t)((uint8_t*)(from))[3]) << 32) | \
(((uint64_t)((uint8_t*)(from))[4]) << 24) | \
(((uint64_t)((uint8_t*)(from))[5]) << 16) | \
(((uint64_t)((uint8_t*)(from))[6]) << 8)  | \
(((uint64_t)((uint8_t*)(from))[7])     )  ))

#elif BYTE_ORDER==BIG_ENDIAN
#define _msgpack_be16(x) (x)
#define _msgpack_be32(x) (x)
#define _msgpack_be64(x) (x)

#define _msgpack_load16(cast, from) ((cast)( \
(((uint16_t)((uint8_t*)from)[0]) << 8) | \
(((uint16_t)((uint8_t*)from)[1])     ) ))

#define _msgpack_load32(cast, from) ((cast)( \
(((uint32_t)((uint8_t*)from)[0]) << 24) | \
(((uint32_t)((uint8_t*)from)[1]) << 16) | \
(((uint32_t)((uint8_t*)from)[2]) <<  8) | \
(((uint32_t)((uint8_t*)from)[3])      ) ))

#define _msgpack_load64(cast, from) ((cast)( \
(((uint64_t)((uint8_t*)from)[0]) << 56) | \
(((uint64_t)((uint8_t*)from)[1]) << 48) | \
(((uint64_t)((uint8_t*)from)[2]) << 40) | \
(((uint64_t)((uint8_t*)from)[3]) << 32) | \
(((uint64_t)((uint8_t*)from)[4]) << 24) | \
(((uint64_t)((uint8_t*)from)[5]) << 16) | \
(((uint64_t)((uint8_t*)from)[6]) << 8)  | \
(((uint64_t)((uint8_t*)from)[7])     )  ))

#else
#error Not big endian or little endian??
#endif


#define _msgpack_store16(to, num) \
do { uint16_t val = _msgpack_be16(num); memcpy(to, &val, 2); } while(0)
#define _msgpack_store32(to, num) \
do { uint32_t val = _msgpack_be32(num); memcpy(to, &val, 4); } while(0)
#define _msgpack_store64(to, num) \
do { uint64_t val = _msgpack_be64(num); memcpy(to, &val, 8); } while(0)


static unsigned char NIL = MSGPACK_TYPE_NIL;
@implementation NSNull(MsgPack)

- (void)msgPackWithMutableData:(NSMutableData *)data {
    [data appendBytes:&NIL length:1];
}

+ (instancetype)unMsgPackFromData:(NSData *)data bytesRead:(int *)bytePtr {
    NSAssert(((unsigned char*)data.bytes)[0]==MSGPACK_TYPE_NIL,@"Not nil?");
    *bytePtr += 1;
    return [NSNull null];
}
@end

@implementation NSNumber(MsgPack)
int pack_ulonglong(NSMutableData *data, unsigned long long value) {
    //https://github.com/msgpack/msgpack/blob/master/spec.md#formats-int
    if (value < 0b01111111) {
        [data appendBytes:&value length:1];
        return 1;
    }
    else if (value <= UINT8_MAX) {
        unsigned char buf[2] = {MSGPACK_TYPE_UINT8,(uint8_t)value};
        [data appendBytes:buf length:2];
        return 2;
    }
    else if (value <= UINT16_MAX) {
        unsigned char buf[3] = {MSGPACK_TYPE_UINT16};
        _msgpack_store16(&buf[1], value);
        [data appendBytes:buf length:3];
        return 3;
    }
    else if (value <= UINT32_MAX) {
        unsigned char buf[5] = {MSGPACK_TYPE_UINT32};
        _msgpack_store32(&buf[1], value);
        [data appendBytes:buf length:5];
        return 5;
    }
    else if (value <= UINT64_MAX) {
        unsigned char buf[9] = {MSGPACK_TYPE_UINT64};
        _msgpack_store64(&buf[1],value);
        [data appendBytes:buf length:9];
        return 9;
    }
    else {
        abort();
    }
}
int pack_slonglong(NSMutableData *data, signed long long value) {
    if (value >= 0) {
        //todo: we could probably replace this with just the positive fixnum check to preserve signedness better.
        return pack_ulonglong(data, value);
    }
    else if (value * -1 < 0b00011111) {
        unsigned char fixneg = 0b11100000 | value;
        [data appendBytes:&fixneg length:1];
        return 1;
    }
    else if (value <= INT8_MAX && value >= INT8_MIN) {
        unsigned char buf[2] = {MSGPACK_TYPE_INT8,(uint8_t)value};
        [data appendBytes:buf length:2];
        return 2;
    }
    else if (value <= INT16_MAX && value >= INT16_MIN) {
        unsigned char buf[3] = {MSGPACK_TYPE_INT16};
        _msgpack_store16(&buf[1], value);
        [data appendBytes:buf length:3];
        return 3;
    }
    else if (value <= INT32_MAX && value >= INT32_MIN) {
        unsigned char buf[5] = {MSGPACK_TYPE_INT32};
        _msgpack_store32(&buf[1], value);
        [data appendBytes:buf length:5];
        return 5;
    }
    else if (value <= INT64_MAX && value >= INT64_MIN) {
        unsigned char buf[9] = {MSGPACK_TYPE_INT64};
        _msgpack_store64(&buf[1],value);
        [data appendBytes:buf length:9];
        return 9;
    }
    else {
        abort();
    }
}


- (void)msgPackWithMutableData:(NSMutableData *)data {
    //http://nshipster.com/type-encodings/
    switch(self.objCType[0]) {
        case 'c':
            pack_slonglong(data, [self charValue]);
            break;
            
        case 'i':
            pack_slonglong(data, [self intValue]);
            break;
            
        case 's':
            pack_slonglong(data, [self shortValue]);
            break;
            
        case 'l':
            pack_slonglong(data, [self longValue]);
            break;
            
        case 'q':
            pack_slonglong(data, [self longLongValue]);
            break;
            
        case 'C':
            pack_ulonglong(data, [self unsignedCharValue]);
            break;
            
        case 'I':
            pack_ulonglong(data, [self unsignedIntValue]);
            break;
            
        case 'S':
            pack_ulonglong(data, [self unsignedShortValue]);
            break;
            
        case 'L':
            pack_ulonglong(data, [self unsignedLongValue]);
            break;
            
        case 'Q':
            pack_ulonglong(data, [self unsignedLongLongValue]);
            break;
            
        case 'f': {
            union { float f; uint32_t i; } mem;
            mem.f = [self floatValue];
            unsigned char buf[5];
            buf[0] = 0xca; _msgpack_store32(&buf[1], mem.i);
            [data appendBytes:buf length:5];
            break;
        }
            
        case 'd': {
            union { double f; uint64_t i; } mem;
            mem.f = [self doubleValue];
            unsigned char buf[9];
            buf[0] = 0xcb;
#if defined(__arm__) && !(__ARM_EABI__) // arm-oabi
            // https://github.com/msgpack/msgpack-perl/pull/1
            mem.i = (mem.i & 0xFFFFFFFFUL) << 32UL | (mem.i >> 32UL);
#endif
            _msgpack_store64(&buf[1], mem.i);
            [data appendBytes:buf length:9];
            break;
        }
            
        case 'B': {
            unsigned char magic = 0xff;
            
            if ([self boolValue]) {
                magic = MSGPACK_TYPE_TRUE;
            }
            else {
                magic = MSGPACK_TYPE_FALSE;
            }
            [data appendBytes:&magic length:1];
        }
        default:
            abort();
    }

}

+ (instancetype)unMsgPackFromData:(NSData *)data bytesRead:(int *)bytePtr {
    unsigned char *bytes = (unsigned char*) data.bytes;
    unsigned char header = bytes[0];
    if (header >= MSGPACK_TYPE_POSITIVE_FIXINT_START && header <= MSGPACK_TYPE_POSITIVE_FIXINT_END) {
        uint8_t fixint = bytes[1];
        *bytePtr += 1;
        return [NSNumber numberWithUnsignedInt:fixint];
    }
    else if (header >= MSGPACK_TYPE_NEGATIVE_FIXINT_START && header <= MSGPACK_TYPE_NEGATIVE_FIXINT_END) {
        uint8_t fixint = bytes[1] & 0b00011111;
        *bytePtr += 1;
        return [NSNumber numberWithInt:-1 * fixint];
    }
    else if (header==MSGPACK_TYPE_UINT8) {
        uint8_t fixint = bytes[1];
        *bytePtr += 2;
        return [NSNumber numberWithUnsignedShort:fixint];
    }
    else if (header==MSGPACK_TYPE_UINT16) {
        uint16_t fixint = _msgpack_load16(uint16_t, &bytes[1]);
        *bytePtr += 3;
        return [NSNumber numberWithUnsignedInt:fixint];
    }
    else if (header==MSGPACK_TYPE_UINT32) {
        uint32_t fixint = _msgpack_load32(uint32_t, &bytes[1]);
        *bytePtr += 5;
        return [NSNumber numberWithUnsignedLong:fixint];
    }
    else if (header==MSGPACK_TYPE_UINT64) {
        uint64_t fixint = _msgpack_load64(uint64_t, &bytes[1]);
        bytePtr += 9;
        return [NSNumber numberWithUnsignedLongLong:fixint];
    }
    else if (header==MSGPACK_TYPE_INT8) {
        int8_t fixint = bytes[1];
        *bytePtr += 2;
        return [NSNumber numberWithShort:fixint];
    }
    else if (header==MSGPACK_TYPE_INT16) {
        int16_t fixint = _msgpack_load16(int16_t, &bytes[1]);
        *bytePtr += 3;
        return [NSNumber numberWithInt:fixint];
    }
    else if (header==MSGPACK_TYPE_INT32) {
        int32_t fixint = _msgpack_load32(int32_t, &bytes[1]);
        *bytePtr += 5;
        return [NSNumber numberWithUnsignedLong:fixint];
    }
    else if (header==MSGPACK_TYPE_INT64) {
        int64_t fixint = _msgpack_load64(int64_t, &bytes[1]);
        *bytePtr += 9;
        return [NSNumber numberWithUnsignedLongLong:fixint];
    }
    else if (header==MSGPACK_TYPE_FLOAT32) {
        
        union { float f; uint32_t i; } mem;
        mem.i = _msgpack_load32(uint32_t, &bytes[1]);
        bytePtr += 5;
        return [NSNumber numberWithFloat:mem.f];
    }
    else if (header==MSGPACK_TYPE_FLOAT64) {
        union { double f; uint64_t i; } mem;
        mem.i = _msgpack_load64(uint64_t, &bytes[1]);
        bytePtr += 9;
        return [NSNumber numberWithDouble:mem.f];
    }
    else if (header==MSGPACK_TYPE_TRUE) {
        *bytePtr += 1;
        return [NSNumber numberWithBool:YES];
    }
    else if (header==MSGPACK_TYPE_FALSE) {
        *bytePtr += 1;
        return [NSNumber numberWithBool:NO];
    }
    else {
        abort();
    }
    
}

@end

@implementation NSString (MsgPack)

- (void)msgPackWithMutableData:(NSMutableData *)data {
    NSData *bytes = [self dataUsingEncoding:NSUTF8StringEncoding];
    if (bytes.length <=31) {
        unsigned char header = 0b10100000 | bytes.length;
        [data appendBytes:&header length:1];
    }
    else if (bytes.length < 256) {
        unsigned char buf[2] = {MSGPACK_TYPE_STR8,bytes.length};
        [data appendBytes:&buf length:2];
    }
    else if (bytes.length < 65536) {
        unsigned char buf[3] = {MSGPACK_TYPE_STR16};
        _msgpack_store16(&buf[1], bytes.length);
        [data appendBytes:&buf length:3];
    }
    else {
        unsigned char buf[5] = {MSGPACK_TYPE_STR32};
        _msgpack_store32(&buf[1], bytes.length);
        [data appendBytes:&buf length:5];
    }
    [data appendData:bytes];
}

+ (instancetype)unMsgPackFromData:(NSData *)data bytesRead:(int *)bytePtr {
    unsigned char *bytes = (unsigned char*) data.bytes;
    unsigned char header = bytes[0];
    NSData *utfData = nil;
    if (header >= MSGPACK_TYPE_FIXSTR_START && header <= MSGPACK_TYPE_FIXSTR_END) {
        int length = 0b00011111 & bytes[1];
        *bytePtr += length + 1;
        utfData = [[NSData alloc] initWithBytes:&bytes[1] length:length];
    }
    else if (header==MSGPACK_TYPE_STR8) {
        int length = bytes[1];
        *bytePtr += length + 2;
        utfData = [[NSData alloc] initWithBytes:&bytes[2] length:length];
    }
    else if (header==MSGPACK_TYPE_STR16) {
        uint16_t length = _msgpack_load16(uint16_t, &bytes[1]);
        *bytePtr += length + 3;
        utfData = [[NSData alloc] initWithBytes:&bytes[3] length:length];
    }
    else if (header==MSGPACK_TYPE_STR32) {
        uint32_t length = _msgpack_load32(uint32_t, &bytes[1]);
        *bytePtr += length + 5;
        utfData = [[NSData alloc] initWithBytes:&bytes[1] length:length];
    }
    else {
        abort();
    }
    return [[NSString alloc] initWithData:utfData encoding:NSUTF8StringEncoding];
}

@end

@implementation NSData (MsgPack)

- (void)msgPackWithMutableData:(NSMutableData *)data {
    if (self.length <= 255) {
        unsigned char buf[2] = {MSGPACK_TYPE_BIN8,self.length};
        [data appendBytes:buf length:2];
    }
    else if (self.length <= 65535) {
        unsigned char buf[3] = {MSGPACK_TYPE_BIN16};
        _msgpack_store16(&buf[1], self.length);
        [data appendBytes:buf length:3];
    }
    else  {
        unsigned char buf[5] = {MSGPACK_TYPE_BIN32};
        _msgpack_store32(&buf[1], self.length);
        [data appendBytes:buf length:5];
    }
    [data appendData:self];
}

+ (instancetype)unMsgPackFromData:(NSData *)data bytesRead:(int *)bytePtr {
    unsigned char *bytes = (unsigned char*) data.bytes;
    unsigned char header = bytes[0];
    unsigned long length = -1;
    unsigned long extraBytes = -1;
    if (header==MSGPACK_TYPE_BIN8) {
        length = bytes[1];
        extraBytes =2;
    }
    else if (header==MSGPACK_TYPE_BIN16) {
        length = _msgpack_load16(uint16_t, &bytes[1]);
        extraBytes = 3;
    }
    else if (header==MSGPACK_TYPE_BIN32) {
        length = _msgpack_load64(uint32_t, &bytes[1]);
        extraBytes = 5;
    }
    *bytePtr += extraBytes + length;
    return [[NSData alloc] initWithBytes:&data.bytes[extraBytes-1] length:length];
}

@end

@implementation NSArray (MsgPack)

- (void)msgPackWithMutableData:(NSMutableData *)data {
    if (self.count <= 15) {
        unsigned char length = 0b10010000 | self.count;
        [data appendBytes:&length length:1];
    }
    else if (self.count <= 65535) {
        unsigned char buf[3] = {MSGPACK_TYPE_ARR16};
        _msgpack_store16(&buf[1], self.count);
        [data appendBytes:&buf length:2];
    }
    else {
        unsigned char buf[5] = {MSGPACK_TYPE_ARR32};
        _msgpack_store32(&buf[1], self.count);
        [data appendBytes:&buf length:5];
    }
    for (id<MsgPackable> obj in self) {
        [obj msgPackWithMutableData:data];
    }
}

+ (instancetype)unMsgPackFromData:(NSData *)data bytesRead:(int *)bytePtr {
    unsigned char *bytes = (unsigned char*) data.bytes;
    unsigned char header = bytes[0];
    unsigned long length = -1;
    unsigned long extraBytes = -1;
    if (header >= MSGPACK_TYPE_FIXARRAY_START && header <= MSGPACK_TYPE_FIXARRAY_END) {
        length = 0b00001111 & bytes[1];
        extraBytes = 1;
    }
    else if (header==MSGPACK_TYPE_ARR16) {
        length = _msgpack_load16(unsigned long, &bytes[1]);
        extraBytes = 3;
    }
    else if (header==MSGPACK_TYPE_ARR32) {
        length = _msgpack_load32(unsigned long, &bytes[1]);
        extraBytes = 5;
    }
    else {
        abort();
    }
    unsigned long currentPosition = extraBytes;
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:length];
    for(int i = 0; i < length; i++) {
        NSData *subdata = [data subdataWithRange:NSMakeRange(currentPosition, data.length - currentPosition)];
        int bytesRead = 0;
        id<MsgPackable> subObj = [NSObject unMsgPackFromData:subdata bytesRead:&bytesRead];
        [array addObject:subObj];
        currentPosition += bytesRead;
    }
    *bytePtr += currentPosition;
    return [array copy];
}

@end

@implementation NSDictionary (MsgPack)
- (void)msgPackWithMutableData:(NSMutableData *)data {
    if (self.count <= 15) {
        unsigned char length = 0b10000000 | self.count;
        [data appendBytes:&length length:1];
    }
    else if (self.count <= 65535) {
        unsigned char buf[3] = {MSGPACK_TYPE_MAP16};
        _msgpack_store16(&buf[1], self.count);
        [data appendBytes:&buf length:2];
    }
    else {
        unsigned char buf[5] = {MSGPACK_TYPE_MAP32};
        _msgpack_store32(&buf[1], self.count);
        [data appendBytes:&buf length:5];
    }
    for (id<MsgPackable> key in self.keyEnumerator) {
        [key msgPackWithMutableData:data];
        id<MsgPackable> value = self[key];
        [value msgPackWithMutableData:data];
    }
}

+ (instancetype)unMsgPackFromData:(NSData *)data bytesRead:(int *)bytePtr {
    unsigned char *bytes = (unsigned char*) data.bytes;
    unsigned char header = bytes[0];
    unsigned long length = -1;
    unsigned long extraBytes = -1;
    if (header >= MSGPACK_TYPE_FIXMAP_START && header <= MSGPACK_TYPE_FIXMAP_END) {
        length = 0b00001111 & bytes[1];
        extraBytes = 1;
    }
    else if (header==MSGPACK_TYPE_MAP16) {
        length = _msgpack_load16(unsigned long, &bytes[1]);
        extraBytes = 3;
    }
    else if (header==MSGPACK_TYPE_MAP32) {
        length = _msgpack_load32(unsigned long, &bytes[1]);
        extraBytes = 5;
    }
    else {
        abort();
    }
    unsigned long currentPosition = extraBytes;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:length];
    for(int i = 0; i < length; i++) {
        NSData *subdata = [data subdataWithRange:NSMakeRange(currentPosition, data.length - currentPosition)];
        int bytesRead = 0;
        id<MsgPackable,NSCopying> key = (id<MsgPackable,NSCopying>)[NSObject unMsgPackFromData:subdata bytesRead:&bytesRead];
        currentPosition += bytesRead;
        bytesRead = 0;
        subdata = [data subdataWithRange:NSMakeRange(currentPosition, data.length - currentPosition)];
        id<MsgPackable> value = [NSObject unMsgPackFromData:subdata bytesRead:&bytesRead];
        currentPosition += bytesRead;
        dict[key] = value;
    }
    *bytePtr += currentPosition;
    return [dict copy];
}
@end

@implementation NSObject (MsgPack)
- (void)msgPackWithMutableData:(NSMutableData *)data {
    abort();
}
+ (instancetype)unMsgPackFromData:(NSData *)data bytesRead:(int *)bytePtr {
    unsigned char *bytes = (unsigned char*) data.bytes;
    unsigned char header = bytes[0];
    if (header>=MSGPACK_TYPE_POSITIVE_FIXINT_START && header <= MSGPACK_TYPE_POSITIVE_FIXINT_END) {
        return [NSNumber unMsgPackFromData:data bytesRead:bytePtr];
    }
    else if (header >= MSGPACK_TYPE_FIXMAP_START && header <= MSGPACK_TYPE_FIXSTR_END) {
        return [NSDictionary unMsgPackFromData:data bytesRead:bytePtr];
    }
    else if (header >= MSGPACK_TYPE_FIXARRAY_START && header <= MSGPACK_TYPE_FIXARRAY_END) {
        return [NSArray unMsgPackFromData:data bytesRead:bytePtr];
    }
    else if (header >= MSGPACK_TYPE_FIXSTR_START && header <= MSGPACK_TYPE_FIXSTR_END) {
        return [NSArray unMsgPackFromData:data bytesRead:bytePtr];
    }
    else if (header >= MSGPACK_TYPE_NEGATIVE_FIXINT_START && header <= MSGPACK_TYPE_NEGATIVE_FIXINT_END) {
        return [NSNumber unMsgPackFromData:data bytesRead:bytePtr];
    }
    switch(header) {
        case MSGPACK_TYPE_NIL:
            return [NSNull unMsgPackFromData:data bytesRead:bytePtr];
            break;
            
        case MSGPACK_TYPE_FALSE:
        case MSGPACK_TYPE_TRUE:
        case MSGPACK_TYPE_FLOAT32:
        case MSGPACK_TYPE_FLOAT64:
        case MSGPACK_TYPE_UINT8:
        case MSGPACK_TYPE_UINT16:
        case MSGPACK_TYPE_UINT32:
        case MSGPACK_TYPE_UINT64:
        case MSGPACK_TYPE_INT8:
        case MSGPACK_TYPE_INT16:
        case MSGPACK_TYPE_INT32:
        case MSGPACK_TYPE_INT64:
            return [NSNumber unMsgPackFromData:data bytesRead:bytePtr];
            break;
            
        case MSGPACK_TYPE_BIN8:
        case MSGPACK_TYPE_BIN16:
        case MSGPACK_TYPE_BIN32:
            return [NSData unMsgPackFromData:data bytesRead:bytePtr];
            break;
        
        case MSGPACK_TYPE_STR8:
        case MSGPACK_TYPE_STR16:
        case MSGPACK_TYPE_STR32:
            return [NSString unMsgPackFromData:data bytesRead:bytePtr];
            break;
        
        case MSGPACK_TYPE_ARR16:
        case MSGPACK_TYPE_ARR32:
            return [NSArray unMsgPackFromData:data bytesRead:bytePtr];
        
        case MSGPACK_TYPE_MAP16:
        case MSGPACK_TYPE_MAP32:
            return [NSDictionary unMsgPackFromData:data bytesRead:bytePtr];
        
            default:
            abort();
            
    }
}

@end
        
        


/*
@implementation NSNumber(MsgPack)
- (void)msgPackWithPacker:(msgpack_packer *)packer {
    
    //http://nshipster.com/type-encodings/
    switch(self.objCType[0]) {
        case 'c':
            
            msgpack_pack_char(packer, [self charValue]);
            break;
            
        case 'i':
            msgpack_pack_int(packer, [self intValue]);
            break;
            
        case 's':
            msgpack_pack_short(packer, [self shortValue]);
            break;
            
        case 'l':
            NSAssert([self intValue] < INT32_MAX, @"msgpack error");
            msgpack_pack_int32(packer, [self intValue]);
            break;
            
        case 'q':
            NSAssert(sizeof(long long)==64, @"Unexpected size for long long");
            msgpack_pack_int64(packer, [self longLongValue]);
            break;
            
        case 'C':
            msgpack_pack_unsigned_char(packer, [self unsignedCharValue]);
            break;
            
        case 'I':
            msgpack_pack_unsigned_int(packer, [self unsignedIntValue]);
            break;
            
        case 'S':
            msgpack_pack_unsigned_short(packer, [self unsignedShortValue]);
            break;
            
        case 'L':
            msgpack_pack_unsigned_long(packer, [self unsignedLongValue]);
            break;
            
        case 'Q':
            msgpack_pack_unsigned_long_long(packer, [self unsignedLongLongValue]);
            break;
            
        case 'f':
            msgpack_pack_float(packer, [self floatValue]);
            break;
            
        case 'd':
            msgpack_pack_double(packer, [self doubleValue]);
            break;
            
        case 'B':
            if ([self boolValue]) {
                msgpack_pack_true(packer);
            }
            else {
                msgpack_pack_false(packer);
            }
            
        default:
            abort();
    }
    
}

+ (instancetype)unMsgPackFromObject:(msgpack_object)o {
    switch(o.type) {
        case MSGPACK_OBJECT_BOOLEAN:
            return [NSNumber numberWithBool:o.via.boolean];
            break;
        case MSGPACK_OBJECT_DOUBLE:
            return [NSNumber numberWithDouble:o.via.dec];
            break;
            
        case MSGPACK_OBJECT_POSITIVE_INTEGER:
            return [NSNumber numberWithUnsignedLongLong:o.via.u64];
            break;
        case MSGPACK_OBJECT_NEGATIVE_INTEGER:
            return [NSNumber numberWithLongLong:o.via.i64];
            break;
        default:
            abort();
    }
}

@end

@implementation NSNull(MsgPack)

- (void)msgPackWithPacker:(msgpack_packer *)packer {
    msgpack_pack_nil(packer);
}

+ (instancetype)unMsgPackFromObject:(msgpack_object)o {
    NSAssert(o.type==MSGPACK_OBJECT_NIL, @"Not nil?");
    return [NSNull null];
}


@end

@implementation NSString(MsgPack)

- (void)msgPackWithPacker:(msgpack_packer *)packer {
    msgpack_pack_ra
}

@end*/