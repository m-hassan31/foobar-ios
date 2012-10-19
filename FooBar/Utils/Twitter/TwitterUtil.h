#import <Foundation/Foundation.h>
#import <Twitter/TWRequest.h>
#import <Twitter/TWTweetComposeViewController.h>
#import <Accounts/Accounts.h>

@protocol TwitterDelegate;

typedef enum TWITTER_REQUEST_TYPE
{
	TW_PROFILE_INFO,
    TW_PROFILE_IMAGE,
	TW_FOLLOWERS_INFO,
    TW_FOLLOWERS_IDS,
	TW_SEND_MESSAGE,
    TW_SEND_UPDATE
}TWRequestType;

@interface TwitterUtil : NSObject
{	
	id<TwitterDelegate> _delegate;
	TWRequestType requestType;
    NSUInteger twitterFollowersCurrentPageIndex;
    NSUInteger twitterFollowersPagesCount;
    
    ACAccount* phoneTwitterAccount;
}

@property(nonatomic,assign,getter = delegate,setter = setDelegate:)id<TwitterDelegate> _delegate;
@property(nonatomic,retain) ACAccount* phoneTwitterAccount;
@property(nonatomic, retain)NSMutableArray *followerIdsArray;
@property(nonatomic, assign) NSUInteger twitterFollowersCurrentPageIndex;
@property(nonatomic, assign) NSUInteger twitterFollowersPagesCount;


-(BOOL) isAuthorized;
-(BOOL) isTwitterConfigured;
-(void) setTwitterConfigured:(BOOL)config;
-(void) setTwitterUsername:(NSString*)username;
-(NSString*) getTwitterUsername;

-(void) getAccessToken;

-(void) sendDirectMessage:(NSString*)message to:(NSString*)userId;
-(void) sendUpdate:(NSString*)status;
-(void) getTwitterInfo:(NSString*)userId;
-(void) getTwitterProfilePicForId:(NSString*)userId;
-(void) getTwitterFollowers;
-(NSArray*)formCommaSeperatedIds:(NSArray*) followersIdsData;
-(void) requestForFollowersDetails:(NSString*)idsString;
-(id) initWithDelegate:(id)delegate;
-(void)getTwitterFollowersInfo;

// for notifying delegate on the main thread
// This was required because the handler block can be called on any thread.
-(void)notifyDelegateWithSuccessData:(id)data;
-(void)notifyDelegateWithFailedData:(id)data;
-(void)notifyDelegateForTwitterProfilePicWithSuccess:(UIImage*)pic;
-(void)notifyDelegateForTwitterProfilePicWithFailure:(UIImage*)pic;
-(void)notifyDelegateForTwitterProfileInfoWithSuccess:(NSDictionary*)data;
-(void)notifyDelegateForTwitterProfileInfoWithFailure:(NSDictionary*)data;
-(void)notifyDelegateOnSuccessfulTwitterInvitationForUser:(NSString*)userId;
-(void)notifyDelegateOnFailedTwitterInvitationForUser:(NSString*)userId;
-(void)notifyDelegateForSuccessfulTweetResponseReceive;
-(void)notifyDelegateForFailedTweetResponseReceive;


//executes a twitter request by fetching a new account object.
-(void)executeTwitterRequest:(TWRequest*)request completionHandler:(void (^)(NSData *responseData,NSHTTPURLResponse *urlResponse, NSError *error) )handler;

//checks and parses twitter API response
-(id)checkTwitterResponse:(NSData*)responseData error:(NSError*)error;

/*!
  saves the user picked twitter account username in defaults
  this can be used to get the same twitter account on relaunches. 
 */


@end

@protocol TwitterDelegate <NSObject>

@optional

- (void) twitterAccessTokenReceived:(NSString*)authToken;
- (void) onTwitterInvitationResponse:(BOOL)status identifier:(NSString*)userId;
- (void) twitterProfileInfo:(NSDictionary*)data status:(BOOL)status;
- (void) twitterProfilePicReceived:(UIImage *)image status:(BOOL)status;
- (void) twitterConnectionFinished:(NSString *)connectionIdentifier;
- (void) onTwitterFriendsReceived:(NSArray *)friendsInfoArray;
- (void) onTwitterFriendsFailedWithErrorMessage:(NSString*)message;
- (void) onTweetResponseReceived:(BOOL)status;

@end