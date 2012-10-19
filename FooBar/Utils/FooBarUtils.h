#import <Foundation/Foundation.h>
#import "SocialUser.h"

enum Account_Type
{
    FacebookAccount = 0,
    TwitterAccount
};

@interface FooBarUtils : NSObject

+(BOOL)isConnectedToInternet;
+(void)showAlertMessage:(NSString *)message;
+(UIButton*)backButton;
+(UIImage*)scaleImage:(UIImage*)image ToSize: (CGSize)size;
+(BOOL)isEmailFormatValid:(NSString *)email;

+(NSData*)jsonFromDictionary:(NSDictionary*)dict;
+(NSData*)encryptVal:(NSString*)val;
+(NSString*)decryptValForKey:(NSString*)key;

@end
