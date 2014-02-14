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
/**@param URL e.g. tcp://user:pass@localhost:5555
 @param queue the queue from which you will use the client.  The client can only be used on the given queue.*/
-(instancetype) initWithURL:(NSURL*) url onQueue:(dispatch_queue_t) queue;

/**@param URL e.g. tcp://user:pass@localhost:5555
 @param thread the thread from which you will use the client.  The client can only be used on the given thread.*/
-(instancetype) initWithURL:(NSURL*) url onThread:(NSThread*) thread;

/**Issue the request to the server and get the response */
-(NSData*) responseForRequest:(NSData*) data;

/**Calls an RPC class method.
 @param method Name of the method (e.g. as determined by a directory() call)
 @param klass Name of the class (e.g. as determined by a directory() call)
 @param arguments The (unserialized) arguments for the method call.  Caffeine expects keyword arguments as name/value pairs. */
-(id) RPCClassMethod:(NSString*) method inClass:(NSString*) klass withArguments:(NSDictionary*) arguments;

/**Finds or creates a client that is legal on the given queue for you to use. */
+(instancetype) clientOnQueue:(dispatch_queue_t) queue forURL:(NSURL*) url;

/**Finds or creates a client that is legal on the given thread for you to use. */
+(instancetype) clientOnThread:(NSThread *) thread forURL:(NSURL*) url;
@end
