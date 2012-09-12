//
//  NSMutableData-AES.h
//  Spynergy
//
//  Created by tapjoy on 3/12/12.
//  Copyright (c) 2012 Futur. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>

@interface NSMutableData(AES)

- (NSData*)EncryptAES:(NSString *)key;
- (NSData*)DecryptAES:(NSString *)key;

@end
