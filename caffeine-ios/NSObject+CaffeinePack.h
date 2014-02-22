//
//  NSObject+CaffeinePack.h
//  caffeine-ios
//
//  Created by Drew Crawford on 2/16/14.
//  Copyright (c) 2014 DrewCrawfordApps. All rights reserved.
// **Implements the CaffeinePack protocol on top of MsgPack2.


#import <Foundation/Foundation.h>
#import "MsgPackable.h"
@protocol CaffeinePackable

/**This method returns an object graph where each element in the object graph is MsgPackable. */
-(id<MsgPackable>) caffeinePackObjectRepresentation;
@end

@interface NSDictionary (CaffeinePack)  <CaffeinePackable>
@end

@interface NSArray (CaffeinePack) <CaffeinePackable>
@end

@interface NSNumber (CaffeinePack)<CaffeinePackable>
@end

@interface NSString  (CaffeinePack)<CaffeinePackable>
@end


@interface NSObject (CaffeinePack)

@end
