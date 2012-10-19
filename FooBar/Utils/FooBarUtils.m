#import "FooBarUtils.h"
#import "FooBarConstants.h"
#import "Reachability.h"
#import "SBJsonWriter.h"
#import "FooBarConstants.h"
#import "NSMutableData-AES.h"

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

@end