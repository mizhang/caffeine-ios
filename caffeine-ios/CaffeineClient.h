//
//  CaffeineClient.h
//  caffeine-ios
//
//  Created by Drew Crawford on 2/12/14.
//  Copyright (c) 2014 DrewCrawfordApps. All rights reserved.
//

#import <Foundation/Foundation.h>

/**A Caffeine client represents a remote endpoint (URL).  Usually there is just one instance of this class for every remote endpoint.  The instance is threadsafe.  The instance (in a future release) transparently manages multiple parallel requests.  */

@interface CaffeineClient : NSObject

+ (instancetype) clientForURL:(NSURL*) url;


/**Issue the request to the server and get the response */
-(NSData*) responseForRequest:(NSData*) data;

/**Calls an RPC class method.
 @param method Name of the method (e.g. as determined by a directory() call)
 @param klass Name of the class (e.g. as determined by a directory() call)
 @param arguments The (unserialized) arguments for the method call.  Caffeine expects keyword arguments as name/value pairs. */
-(id) RPCClassMethod:(NSString*) method inClass:(NSString*) klass withArguments:(NSDictionary*) arguments;


@end
