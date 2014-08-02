//
//  CFKeychainSupport.h
//  caffeine-ios
//
//  Created by Drew Crawford on 8/2/14.
//  Copyright (c) 2014 DrewCrawfordApps. All rights reserved.
//

#import <Foundation/Foundation.h>
/**Stores nitrogen credentials in the keychain, using caffeine URLs as a key.
Keying is based on the URLs *without* any nitrogen credentials.  (So scheme, host, port only). */

@interface CFKeychainSupport : NSObject
/**forces a re-key for the given URL.*/
+(void) reKeyForURL:(NSURL*) url;

/**Re-keys only if required for the given URL */
+(void) reKeyIfNeededForURL:(NSURL*) url;

/** Returns the combinedData (concatenated public/private keys) for the URL, or nil */
+(NSData*) combinedDataForURL:(NSURL*) url;

/**Fills the arrays with the keys stored in the keychain.  If nothing is in the keychain, generates new keys.*/
+(void) populatePublicPrivateNitrogenKeysForURL:(NSURL*) url public:(uint8_t *)public private:(uint8_t *)private;

@end
