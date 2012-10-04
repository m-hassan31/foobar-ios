#import <Foundation/Foundation.h>

enum Account_Type
{
    FacebookAccount = 0,
    TwitterAccount
};

@interface FooBarUtils : NSObject

+(BOOL)isDeviceOS5;
+(BOOL)isConnectedToInternet;
+(void)showAlertMessage:(NSString *)message;
+(UIButton*)backButton;
+(UIImage*)scaleImage:(UIImage*)image ToSize: (CGSize)size;
+(BOOL)isEmailFormatValid:(NSString *)email;


+(NSData*)jsonFromDictionary:(NSDictionary*)dict;

@end
