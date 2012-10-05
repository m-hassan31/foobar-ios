#import <Foundation/Foundation.h>
#import "FBConnect.h"

enum CurrentFacebookAction 
{
	FB_SIGNUP,
	FB_PROFILE,
    FB_PROFILE_PICTURE,
	FB_POST,
	FB_FRIENDS,
	FB_INVITATION,
	FB_NONE
};

@protocol FacebookUtilDelegate;

@interface FacebookUtil : NSObject <FBDialogDelegate,FBSessionDelegate,FBRequestDelegate>
{
	id<FacebookUtilDelegate> delegate;
	enum CurrentFacebookAction currentFacebookAction;
	NSMutableDictionary* userIdMapping;
@private
	Facebook *facebook;
}

@property (nonatomic, assign) id<FacebookUtilDelegate> delegate;
@property (nonatomic, retain) Facebook* facebook;

+(id) getSharedFacebookUtil;
+(NSData*)encryptVal:(NSString*)val;
+(NSString*)decryptValForKey:(NSString*)key;
+(NSDate *) fbExpirationDate;

-(void) clearFacebookCredentials;
-(BOOL) isFacebookConfigured;
-(BOOL) isFacebookSessionValid;
-(BOOL) isFacebookEnabled;
-(NSString *) getFacebookAuthToken;
-(void) setFacebookConfigured:(BOOL)config;
-(void) setFacebookEnabled:(BOOL)state;
-(void) getMyFacebookProfile:(id) utilDelegate;
-(void) getMyFacebookProfilePic:(id) utilDelegate;

-(void) sharePhotoOnFacebook:(NSString*)failURL 
             previewImageURL:(NSString*)imageURL
                   withTitle:(NSString*)shareTitle 
             withDescription:(NSString*)shareDescription 
                fromDelegate:(id) utilDelegate;

-(void) getFacebookFriendsWithDelegate:(id)_delegate;
-(void) inviteUser:(NSString*)userId fromDelegate:(id) utilDelegate;
-(void) configureFacebook:(id) utilDelegate;
-(void) authorize:(id) utilDelegate;
-(BOOL) handleOpenURL:(NSURL *)url;
-(void) logout:(id) utilDelegate;

@end

@protocol FacebookUtilDelegate<NSObject>

@optional

-(void) facebookDidLogout;
-(void) onFacebookProfileRecieved:(NSDictionary *)info;
-(void) onFacebookAuthorized:(BOOL)status;
-(void) onFacebookPostResponse:(BOOL)status;
-(void) onFacebookFriendsReceived:(NSDictionary *)friendsDictionary status:(BOOL)status;
-(void) onFacebookInvitationResponse:(BOOL)status identifier:(NSString*)userId;
-(void) onFacebookProfilePicReceived:(UIImage*)image status:(BOOL)status;

@end

