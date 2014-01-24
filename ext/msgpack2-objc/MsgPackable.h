//
//  MsgPackable.h
//  caffeine-ios
//
//  Created by Drew Crawford on 1/24/14.
//  Copyright (c) 2014 DrewCrawfordApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MsgPackable <NSObject>
-(NSData*) msgPack;
-(instancetype) unMsgPackFromData:(NSData*) data;
@end
