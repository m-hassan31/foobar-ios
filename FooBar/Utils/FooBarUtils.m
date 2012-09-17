#import "FooBarUtils.h"
#import "FooBarConstants.h"
#import "Reachability.h"

@implementation FooBarUtils

+(BOOL)isDeviceOS5
{
    NSString *reqSysVer = @"5.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    return ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
}

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

@end
