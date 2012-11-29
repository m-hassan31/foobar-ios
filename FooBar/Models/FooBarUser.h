#import <Foundation/Foundation.h>
#import "FooBarUtils.h"

@interface FooBarUser : NSObject

@property(nonatomic, retain) NSString *userId;
@property(nonatomic, retain) NSString *username;
@property(nonatomic, retain) NSString *firstname;
@property(nonatomic, retain) NSString *photoUrl;
@property(nonatomic, assign) enum Account_Type socialAccountType;
@property(nonatomic, retain) NSString *created_dt;
@property(nonatomic, retain) NSString *updated_dt;
@property(nonatomic, retain) NSString *socialId;
@property(nonatomic, retain) NSString *accessToken;

+(void)saveCurrentUser:(FooBarUser *)user;
+(FooBarUser*)currentUser;
+(void)clearCurrentUser;

-(BOOL)authenticated;

@end
