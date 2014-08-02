//
//  CFKeychainSupport.m
//  caffeine-ios
//
//  Created by Drew Crawford on 8/2/14.
//  Copyright (c) 2014 DrewCrawfordApps. All rights reserved.
//

#import "CFKeychainSupport.h"
#import "libnitrogen.h"
#import "NSURL+CaffeineURLTools.h"

@implementation CFKeychainSupport

const NSString *service = @"Caffeine";

+ (NSMutableDictionary *)searchDictionaryWithKey:(id)key {
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] initWithCapacity:10];
    searchDictionary[(__bridge id)kSecClass] = (__bridge id)(kSecClassGenericPassword);
    searchDictionary[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    searchDictionary[(__bridge id<NSCopying>)(kSecAttrService)] = service;
    searchDictionary[(__bridge id)kSecAttrAccount] = key;
    searchDictionary[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;
    return searchDictionary;
}

+(NSData*) combinedDataForURL:(NSURL*) url {
    url = [url URLByStrippingAllNitrogenCredentials];
    NSDictionary *searchDictionary = [CFKeychainSupport searchDictionaryWithKey:[url absoluteString]];
    CFDataRef data = nil;
    SecItemCopyMatching((__bridge CFDictionaryRef)searchDictionary, (CFTypeRef*)&data);
    return (NSData*) CFBridgingRelease(data);
}

+ (void)reKeyIfNeededForURL:(NSURL *)url {
    if (![self combinedDataForURL:url]) {
        [self reKeyForURL:url];
    }
}

+ (void)populatePublicPrivateNitrogenKeysForURL:(NSURL *)url public:(uint8_t *)public private:(uint8_t *)private {
    [self reKeyIfNeededForURL:url];
    NSData *data = [self combinedDataForURL:url];
    NSAssert(data.length==2*LIBNITROGEN_KEYSIZE, @"Data size mismatch?");
    memcpy(public, data.bytes, LIBNITROGEN_KEYSIZE);
    memcpy(private, data.bytes+LIBNITROGEN_KEYSIZE, LIBNITROGEN_KEYSIZE);
}

+ (void)reKeyForURL:(NSURL *)url {
    url = [url URLByStrippingAllNitrogenCredentials];
    uint8_t publicKey[LIBNITROGEN_KEYSIZE];
    uint8_t privateKey[LIBNITROGEN_KEYSIZE];
    
    n_public_private_keygen(publicKey, privateKey);
    NSData *publicKeyData = [[NSData alloc] initWithBytes:publicKey length:LIBNITROGEN_KEYSIZE];
    NSData *privateKeyData = [[NSData alloc] initWithBytes:privateKey length:LIBNITROGEN_KEYSIZE];
    
    NSMutableData *combinedData = [[NSMutableData alloc] initWithData:publicKeyData];
    [combinedData appendData:privateKeyData];
    
    
    //either there's a match already or not
    if ([self combinedDataForURL:url]) {
        NSMutableDictionary *searchDictionary = [self searchDictionaryWithKey:[url absoluteString]];
        [searchDictionary removeObjectForKey:(__bridge id) kSecReturnData]; //these two keys cause
        [searchDictionary removeObjectForKey:(__bridge id) kSecMatchLimit]; //-50 OSError
        NSDictionary *updateData = @{(__bridge id)kSecValueData:combinedData,(__bridge id)kSecAttrAccessible:(__bridge id)kSecAttrAccessibleWhenUnlockedThisDeviceOnly};
        OSStatus result = SecItemUpdate((__bridge CFDictionaryRef)(searchDictionary), (__bridge CFDictionaryRef)(updateData));
        if (result != errSecSuccess) {
            NSLog(@"Keychain error code %d",(int)result);
            abort();
        }
        return;
    }
    else { //no existing match; let's insert
        
        NSDictionary *addData = @{(__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword,(__bridge id)kSecAttrService:service,(__bridge id)kSecAttrAccount:[url absoluteString],(__bridge id)kSecValueData:combinedData,(__bridge id)kSecAttrAccessible:(__bridge id)kSecAttrAccessibleWhenUnlockedThisDeviceOnly};
        OSStatus result = SecItemAdd((__bridge CFDictionaryRef)(addData), NULL);
        if (result != errSecSuccess) {
            NSLog(@"Keychain error code %d",(int)result);
            abort();
        }
    }

}
@end
