//
//  MsgPack2Objc.h
//  caffeine-ios
//
//  Created by Drew Crawford on 1/24/14.
//  Copyright (c) 2014 DrewCrawfordApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MsgPackable.h"

//https://github.com/msgpack/msgpack/blob/master/spec.md
NS_ENUM(unsigned char, MSGPACK_TYPE) {
    
    MSGPACK_TYPE_POSITIVE_FIXINT_START = 0x00,
    MSGPACK_TYPE_POSITIVE_FIXINT_END = 0x7f,
    
    MSGPACK_TYPE_FIXMAP_START = 0x80,
    MSGPACK_TYPE_FIXMAP_END = 0x8f,
    
    MSGPACK_TYPE_FIXARRAY_START = 0x90,
    MSGPACK_TYPE_FIXARRAY_END = 0x9f,
    
    MSGPACK_TYPE_FIXSTR_START = 0xa0,
    MSGPACK_TYPE_FIXSTR_END = 0xbf,
    
    MSGPACK_TYPE_NIL = 0xc0,
    
    MSGPACK_TYPE_FALSE = 0xc2,
    MSGPACK_TYPE_TRUE = 0xc3,
    
    MSGPACK_TYPE_BIN8 = 0xc4,
    MSGPACK_TYPE_BIN16 = 0xc5,
    MSGPACK_TYPE_BIN32 = 0xc6,
    
    MSGPACK_TYPE_EXT8 = 0xc7,
    MSGPACK_TYPE_EXT16 = 0xc8,
    MSGPACK_TYPE_EXT32 = 0xc9,
    
    MSGPACK_TYPE_FLOAT32 = 0xca,
    MSGPACK_TYPE_FLOAT64 = 0xcb,
    
    MSGPACK_TYPE_UINT8 = 0xcc,
    MSGPACK_TYPE_UINT16 = 0xcd,
    MSGPACK_TYPE_UINT32 = 0xce,
    MSGPACK_TYPE_UINT64 = 0xcf,
    
    MSGPACK_TYPE_INT8 = 0xd0,
    MSGPACK_TYPE_INT16 = 0xd1,
    MSGPACK_TYPE_INT32 = 0xd2,
    MSGPACK_TYPE_INT64 = 0xd3,
    
    MSGPACK_TYPE_FIXEXT1 = 0xd4,
    MSGPACK_TYPE_FIXEXT2 = 0xd5,
    MSGPACK_TYPE_FIXEXT4 = 0xd6,
    MSGPACK_TYPE_FIXEXT8 = 0xd7,
    MSGPACK_TYPE_FIXEXT16 = 0xd8,
    
    MSGPACK_TYPE_STR8 = 0xd9,
    MSGPACK_TYPE_STR16 = 0xda,
    MSGPACK_TYPE_STR32 = 0xdb,
    
    MSGPACK_TYPE_ARR16 = 0xdc,
    MSGPACK_TYPE_ARR32 = 0xdd,
    
    MSGPACK_TYPE_MAP16 = 0xde,
    MSGPACK_TYPE_MAP32 = 0xdf,
    
    MSGPACK_TYPE_NEGATIVE_FIXINT_START = 0xe0,
    MSGPACK_TYPE_NEGATIVE_FIXINT_END = 0xff
    
};

/**It's worth documenting why we need Yet Another MsgPack Library.
 
 The first problem is that the obvious contender https://github.com/msgpack/msgpack-objectivec is ridiculously out of date and doesn't support the latest msgpack spec at all which adds features caffeine critically needs.  Strike one.
 
 The second issue is that the C/C++ library on which the ObjC library is based doesn't support the new spec *well* https://github.com/msgpack/msgpack-c/issues/57.  I took a crack at it but I ended up in template hell.  The new spec caused something of a rift in the community, and my guess is that it's not really possible to make the C/C++ library behave reasonably because too many people depend on weird quirks.
 
 The third issue is that C++ template hell underlying ObjC serialization is an all-around terrible idea.
 
 So what we have here is a clean-room, pure ObjC implementation direct from the MsgPack spec.  There's enough test coverage that it's probably pretty good.
 
 Unfortunately the caffeine license makes re-use in other projects complicated, so feel free to contact the author to discuss licensing terms.  This is, to put it mildly, the only sane ObjC MsgPack library that currently exists, so I'd recommend licensing it.
 
 */
 
 
@interface MsgPack2Objc : NSObject

@end