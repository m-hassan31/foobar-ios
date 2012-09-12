#import <Foundation/Foundation.h>

@interface FooBarUtils : NSObject

+(BOOL)isDeviceOS5;
+(BOOL)isConnectedToInternet;
+(void)showAlertMessage:(NSString *)message;
+(UIButton*)backButton;
+(UIImage*)scaleImage:(UIImage*)image ToSize: (CGSize)size;
+(BOOL)isEmailFormatValid:(NSString *)email;

@end
