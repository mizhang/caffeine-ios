//
//  NSData+ModifiedBase64.h
//  caffeine-ios
//
//  Created by Drew Crawford on 2/14/14.
//  Copyright (c) 2014 DrewCrawfordApps. All rights reserved.
//

#import <Foundation/Foundation.h>

//http://www.yuiblog.com/blog/2010/07/06/in-the-yui-3-gallery-base64-and-y64-encoding/
@interface NSData (Y64)
-(instancetype) initWithY64EncodedString:(NSString *)base64String;
-(NSString*) y64String;
-(BOOL) isInsecureKey;
@end
