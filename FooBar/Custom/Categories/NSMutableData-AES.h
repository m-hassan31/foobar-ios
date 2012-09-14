#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>

@interface NSMutableData(AES)

- (NSData*)EncryptAES:(NSString *)key;
- (NSData*)DecryptAES:(NSString *)key;

@end
