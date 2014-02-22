//
//  NSObject+CaffeinePack.m
//  caffeine-ios
//
//  Created by Drew Crawford on 2/16/14.
//  Copyright (c) 2014 DrewCrawfordApps. All rights reserved.
//

#import "NSObject+CaffeinePack.h"
#import "NSObject+MsgPack.h"

@implementation NSDictionary(CaffeinePack)

- (id<MsgPackable>)caffeinePackObjectRepresentation {
    NSMutableDictionary *dikt = [[NSMutableDictionary alloc] init];
    for(id<CaffeinePackable> subkey in self.allKeys) {
        id<MsgPackable,NSCopying> packableKey =  (id<MsgPackable,NSCopying>) [subkey caffeinePackObjectRepresentation];
        id<MsgPackable> packableValue = [self[subkey] caffeinePackObjectRepresentation];
        dikt[packableKey] = packableValue;
    }
    return @{@"_c":@"dict",@"dict":dikt};
}
@end


@implementation  NSArray (CaffeinePack)

- (id<MsgPackable>)caffeinePackObjectRepresentation {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(id<CaffeinePackable> element in self) {
        [array addObject:[element caffeinePackObjectRepresentation]];
    }
    return @{@"_c":@"list",@"list":array};
}

@end

@implementation NSNumber (CaffeinePack)

- (id<MsgPackable>)caffeinePackObjectRepresentation {
    return self;
}

@end

@implementation NSString (CaffeinePack)

-(id<MsgPackable>)caffeinePackObjectRepresentation {
    return self;
}

@end


@implementation NSObject (CaffeinePack)

@end
