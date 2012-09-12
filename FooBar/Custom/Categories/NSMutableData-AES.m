//
//  NSMutableData-AES.m
//  Spynergy
//
//  Created by tapjoy on 3/12/12.
//  Copyright (c) 2012 Futur. All rights reserved.
//

#import "NSMutableData-AES.h"

@implementation NSMutableData(AES)

- (NSData*)EncryptAES:(NSString *)key
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero( keyPtr, sizeof(keyPtr) );
    [key getCString: keyPtr maxLength: sizeof(keyPtr) encoding: NSUTF16StringEncoding];
    size_t numBytesEncrypted = 0;
    NSUInteger dataLength = [self length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    CCCryptorStatus result = CCCrypt( kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                     keyPtr, kCCKeySizeAES256,
                                     NULL,
                                     [self mutableBytes], [self length],
                                     buffer, bufferSize,
                                     &numBytesEncrypted );
    
    NSData *output = [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    
    if(result == kCCSuccess )
    return output;

    return nil;
}

- (NSData*)DecryptAES:(NSString *)key
{ 
    char keyPtr[kCCKeySizeAES256+1]; bzero( keyPtr, sizeof(keyPtr) );
    [key getCString: keyPtr maxLength: sizeof(keyPtr) encoding: NSUTF16StringEncoding];
    size_t numBytesEncrypted = 0;
    NSUInteger dataLength = [self length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer_decrypt = malloc(bufferSize);    

    CCCryptorStatus result = CCCrypt( kCCDecrypt , kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                     keyPtr, kCCKeySizeAES256,
                                     NULL,
                                     [self mutableBytes], [self length],
                                     buffer_decrypt, bufferSize,
                                     &numBytesEncrypted );
    
    NSData *output_decrypt = [NSData dataWithBytesNoCopy:buffer_decrypt length:numBytesEncrypted];
    
    if(result == kCCSuccess )
    return output_decrypt;

    return nil;
}

@end
