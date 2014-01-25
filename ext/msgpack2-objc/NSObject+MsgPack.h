//
//  NSObject+MsgPack.h
//  caffeine-ios
//
//  Created by Drew Crawford on 1/24/14.
//  Copyright (c) 2014 DrewCrawfordApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MsgPackable.h"

@interface NSObject (MsgPack)<MsgPackable>
@end

@interface NSNull (MsgPack) <MsgPackable>
@end

@interface NSNumber (MsgPack) <MsgPackable>
@end

@interface NSString (MsgPack) <MsgPackable>
@end

@interface NSData (MsgPack) <MsgPackable>
@end

@interface NSArray (MsgPack) <MsgPackable>
@end

@interface NSDictionary (MsgPack) <MsgPackable>
@end

