//
//  Foo.h
//  caffeine-ios
//
//  Created by Drew Crawford on 2/13/14.
//  Copyright (c) 2014 DrewCrawfordApps. All rights reserved.
//

#import "CaffeineRemoteObject.h"

@interface Foo : CaffeineRemoteObject
+(NSString*) helloWorldWithError:(NSError**) error;

@end
