#import "FooBarUtils.h"
#import "FooBarConstants.h"
#import "Reachability.h"
#import "SBJsonWriter.h"
#import "FooBarConstants.h"
#import "NSMutableData-AES.h"
#import "NSData+Encoder.h"

@implementation FooBarUtils

+(BOOL)isConnectedToInternet
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];  
    NetworkStatus networkStatus = [reachability currentReachabilityStatus]; 
    NSLog(@"Utils : Is Connected To Internet : %@", (!(networkStatus == NotReachable)) ? @"YES" : @"NO");
    return !(networkStatus == NotReachable);
}

+(void)showAlertMessage:(NSString *)message
{	    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"FooBar" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

+(UIButton*)backButton
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(20, 7, 44, 30);
    [backButton setImage:[UIImage imageNamed:@"Back.png"] forState:UIControlStateNormal];
    return backButton;
}

+(UIImage*)scaleImage:(UIImage*)image ToSize: (CGSize)size
{
    // Scaling selected image to targeted size
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
    CGContextClearRect(context, CGRectMake(0, 0, size.width, size.height));
    CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), image.CGImage);
    CGImageRef scaledImage=CGBitmapContextCreateImage(context);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    UIImage *finalImage = [UIImage imageWithCGImage: scaledImage];    
    CGImageRelease(scaledImage);
    return finalImage;
}

+(BOOL)isEmailFormatValid:(NSString *)email
{
	if ([email rangeOfString:@"@"].length == 0 ){
		return NO;
	}
	else{
		NSArray* splitArray = [email componentsSeparatedByString:@"@"];
		if ([[splitArray objectAtIndex:splitArray.count-1] rangeOfString:@"."].location +1 
			>=
			[[splitArray objectAtIndex:splitArray.count-1] length]){
			
			return NO;
		}
	}
	
	return YES;
}

+(NSData*)jsonFromDictionary:(NSDictionary*)dict
{
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    NSString *postString = [jsonWriter stringWithObject:dict];
    NSData *body = [postString dataUsingEncoding:NSUTF8StringEncoding];
    [jsonWriter release];
    return body;
}

+(NSData*)encryptVal:(NSString*)val
{    
    NSMutableData *valData = [[val dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    NSData *encryptedValData = [valData EncryptAES:kEncryptionKey];
    [valData release];
    return encryptedValData;
}

+(NSString*)decryptValForKey:(NSString*)key
{    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *decryptData = [userDefaults objectForKey:key];
    NSMutableData *retVal = [decryptData mutableCopy];
    NSData *decrypted = [retVal DecryptAES:kEncryptionKey];
    NSString *retValString = [[[NSString alloc] initWithData:decrypted
                                                    encoding:NSUTF8StringEncoding] autorelease];
    [retVal release];
    return retValString;
}

#define kChosenCipherBlockSize         kCCBlockSizeAES128
#define kChosenCipherKeySize           kCCKeySizeAES128
#define kChosenDigestLength            CC_SHA1_DIGEST_LENGTH

+(NSData*) dataFromHexString:(NSString *)command
{    
	NSMutableData *commandToSend= [[NSMutableData alloc] init];
	unsigned char whole_byte;
	char byte_chars[3] = {'\0','\0','\0'};
	int len=[command length]/2;
	int i;
	
    for (i=0; i < len; i++)
    {
		byte_chars[0] = [command characterAtIndex:i*2];
		byte_chars[1] = [command characterAtIndex:i*2+1];
		whole_byte = strtol(byte_chars, NULL, 16);
		[commandToSend appendBytes:&whole_byte length:1]; 
	}
	
    NSLog(@"%@", commandToSend);
	return [commandToSend autorelease];
}


+(NSData *) doCipher:(NSData *)plainText key:(NSData *)symmetricKey iv:(NSData *)initVector context:(CCOperation)encryptOrDecrypt padding:(CCOptions *)pkcs7 
{   
    // Symmetric crypto reference.
    CCCryptorRef thisEncipher = NULL;
    // Cipher Text container.
    NSData * cipherOrPlainText = nil;
    // Pointer to output buffer.
    uint8_t * bufferPtr = NULL;
    // Total size of the buffer.
    size_t bufferPtrSize = 0;
    // Remaining bytes to be performed on.
    size_t remainingBytes = 0;
    // Number of bytes moved to buffer.
    size_t movedBytes = 0;
    // Length of plainText buffer.
    size_t plainTextBufferSize = 0;
    // Placeholder for total written.
    size_t totalBytesWritten = 0;
    // A friendly helper pointer.
    uint8_t * ptr;
    
    NSUInteger len = [initVector length];
    
    // Initialization vector; dummy in this case 0's.
    uint8_t iv[len];
    //memset((void *) iv, 0x0, (size_t) sizeof(iv));
	memcpy(iv, [initVector bytes], len);
    
    
    plainTextBufferSize = [plainText length];
	// We don't want to toss padding on if we don't need to
    if (encryptOrDecrypt == kCCEncrypt) {
        if (*pkcs7 != kCCOptionECBMode) {
            if ((plainTextBufferSize % kChosenCipherBlockSize) == 0) {
                *pkcs7 = 0x0000;
            } else {
                *pkcs7 = kCCOptionPKCS7Padding;
            }
        }
    } else if (encryptOrDecrypt != kCCDecrypt) {
		
    } 
    
    // Create and Initialize the crypto reference.
    CCCryptorCreate( encryptOrDecrypt, 
							   kCCAlgorithmAES128, 
							   *pkcs7, 
							   (const void *)[symmetricKey bytes], 
							   kChosenCipherKeySize, 
							   (const void *)iv, 
							   &thisEncipher
							   );
    
	// Calculate byte block alignment for all calls through to and including final.
    bufferPtrSize = CCCryptorGetOutputLength(thisEncipher, plainTextBufferSize, true);
    
    // Allocate buffer.
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t) );
    
    // Zero out buffer.
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    // Initialize some necessary book keeping.
    
    ptr = bufferPtr;
    
    // Set up initial size.
    remainingBytes = bufferPtrSize;
    
    // Actually perform the encryption or decryption.
    CCCryptorUpdate( thisEncipher,
							   (const void *) [plainText bytes],
							   plainTextBufferSize,
							   ptr,
							   remainingBytes,
							   &movedBytes
							   );
    
    // Handle book keeping.
    ptr += movedBytes;
    remainingBytes -= movedBytes;
    totalBytesWritten += movedBytes;
    
    // Finalize everything to the output buffer.
    CCCryptorFinal(  thisEncipher,
							  ptr,
							  remainingBytes,
							  &movedBytes
							  );
    
    totalBytesWritten += movedBytes;
    
    if (thisEncipher) {
        (void) CCCryptorRelease(thisEncipher);
        thisEncipher = NULL;
    }
    
    
    cipherOrPlainText = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)totalBytesWritten];
	
    if (bufferPtr) free(bufferPtr);
    
    return cipherOrPlainText;    
}

+ (NSString *)getAccessTokenForId:(NSString*)Id
{    
    //construct all the encryption params
    NSData *keyData=[FooBarUtils dataFromHexString:kOpenIdEncryptionKey];
    NSData *ivData=[FooBarUtils dataFromHexString:kOpenIdEncryptionIv];
    NSData *openIdData=[Id dataUsingEncoding:NSASCIIStringEncoding];
    CCOptions padding=kCCOptionPKCS7Padding;
    NSData *cipher=[FooBarUtils doCipher:openIdData key:keyData
                                iv:ivData context:kCCEncrypt padding:&padding];
    //base64 encoding before sending
    NSString *encodedCipher = [cipher base64EncodedString];
    
    NSString * escapedencodedCipher =
    (NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                        NULL,
                                                        (CFStringRef)encodedCipher,
                                                        NULL,
                                                        (CFStringRef)@"!*'();:@=+$,/?%#[]",
                                                        kCFStringEncodingUTF8 );
    return [escapedencodedCipher autorelease];
}

@end
