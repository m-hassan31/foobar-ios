#import <Foundation/Foundation.h>
#import "FooBarUtils.h"

@interface SocialUser : NSObject

@property(nonatomic, assign) enum Account_Type socialAccountType;
@property(nonatomic, retain) NSString* socialId;
@property(nonatomic, retain) NSString* username;
@property(nonatomic, retain) NSString* firstname;
@property(nonatomic, retain) NSString* photoUrl;
@property(nonatomic, retain) NSString* accessToken;

+(void)saveCurrentUser:(SocialUser *)user;
+(SocialUser*)currentUser;

@end
