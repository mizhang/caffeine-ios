//
//  NSURL+CaffeineURLTools.h
//  caffeine-ios
//
//  Created by Drew Crawford on 8/2/14.
//  Copyright (c) 2014 DrewCrawfordApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (CaffeineURLTools)
-(NSURL*) URLByStrippingLocalNitrogenCredentials;
-(NSURL*) URLByStrippingAllNitrogenCredentials;
/** Finds nitrogen credentials for the URL from the keychain.
 Attempts to rekey if no credentials can be fetched.*/
-(NSURL*) URLByPopulatingLocalNitrogenCredentials;
@end
