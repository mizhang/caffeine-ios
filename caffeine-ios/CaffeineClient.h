//
//  CaffeineClient.h
//  caffeine-ios
//
//  Created by Drew Crawford on 2/12/14.
//  Copyright (c) 2014 DrewCrawfordApps. All rights reserved.
//

#import <Foundation/Foundation.h>

/**A Caffeine client represents a client object.  An instance of this class isn't threadsafe, but you can use clientOnCurrentQueueForURL: to find an appropriate client. */
@interface CaffeineClient : NSObject

- (instancetype) initWithURL:(NSURL*) url;


/**Issue the request to the server and get the response */
-(NSData*) responseForRequest:(NSData*) data;

/**Calls an RPC class method.
 @param method Name of the method (e.g. as determined by a directory() call)
 @param klass Name of the class (e.g. as determined by a directory() call)
 @param arguments The (unserialized) arguments for the method call.  Caffeine expects keyword arguments as name/value pairs. */
-(id) RPCClassMethod:(NSString*) method inClass:(NSString*) klass withArguments:(NSDictionary*) arguments;


@end
