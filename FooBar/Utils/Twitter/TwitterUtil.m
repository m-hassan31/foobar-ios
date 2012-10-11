#import "TwitterUtil.h"
#import "SBJSON.h"
#import "FooBarConstants.h"
#import "FooBarUtils.h"
#import "EndPoints.h"
#import "EndPointsKeys.h"
#import "TWAPIManager.h"
#import "TWSignedRequest.h"

@implementation TwitterUtil
@synthesize _delegate;
@synthesize twitterFollowersCurrentPageIndex;
@synthesize twitterFollowersPagesCount;

#ifdef __IPHONE_5_0

@synthesize phoneTwitterAccount;

-(void)executeTwitterRequest:(TWRequest*)request completionHandler:(void (^)(NSData *responseData,NSHTTPURLResponse *urlResponse, NSError *error) )handler
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *previousUserName = [defaults objectForKey:kTwitterUsername];
    
    if([TWTweetComposeViewController canSendTweet])
    {
        ACAccountStore *store = [[ACAccountStore alloc] init];
        ACAccountType *twitterType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [store requestAccessToAccountsWithType:twitterType withCompletionHandler:^(BOOL granted, NSError *error){
            if(granted)
            {
                NSArray *arrayOfAccounts =  [store accountsWithAccountType:twitterType];
                ACAccount *account = nil;
                if (arrayOfAccounts != nil && [arrayOfAccounts count]>0) {
                    if (previousUserName) {
                        for(ACAccount *anAccount in arrayOfAccounts)
                        {
                            if ([anAccount.username isEqualToString:previousUserName] ) {
                                account = anAccount;
                                break;
                            }
                        }
                    }
                    //previous account was deleted if a userName match was not found
                    //show the picker or just pick the first account.
                    //TODO: provide a picker from here as well.
                    
                    if (account == nil) {
                        account = [arrayOfAccounts objectAtIndex:0];
                    }
                    
                    //save the account info in defaults
                    [self setTwitterUsername:account.username];
                    //now that account has been created, call the request
                    [request setAccount:account];
                    [request performRequestWithHandler:handler];
                }
            }
        }];
        
        //handler(nil,nil,[NSError errorWithDomain:@"" code:999 userInfo:nil]);
    }
    
}

#endif

-(id) initWithDelegate:(id)delegate{
	
	self = [super init];
	
    if(self)
    {
        twitterFollowersCurrentPageIndex = 0;
        twitterFollowersPagesCount = 0;
        self._delegate = delegate;
    }
	return self;
}

- (BOOL)isAuthorized
{
    return [TWTweetComposeViewController canSendTweet];
}

-(BOOL)isTwitterConfigured
{
	NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
	BOOL isConfigured= [defaults boolForKey:kIsTwitterConfigured];
	return isConfigured;
}

-(void)setTwitterConfigured:(BOOL)config
{
	NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
	[defaults setBool:config forKey:kIsTwitterConfigured];
	[defaults synchronize];
}

-(void)setTwitterUsername:(NSString*)username
{
	NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
	[defaults setObject:username forKey:kTwitterUsername];
	[defaults synchronize];
}

-(NSString *)getTwitterUsername
{
    NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
	NSString *username = [defaults objectForKey:kTwitterUsername];
    return username;
}

-(BOOL)isTwitterEnabled
{
	NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
	BOOL isFacebookEnabled= [defaults boolForKey:kIsTwitterEnabled];
	return isFacebookEnabled;
}

-(void)setTwitterEnabled:(BOOL)state
{
    NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
	[defaults setBool:state forKey:kIsTwitterEnabled];
	[defaults synchronize];
}

-(id)checkTwitterResponse:(NSData*)responseData error:(NSError*)error
{
    if(error != nil)
    {
        // twitter request error
        return nil;
    }
    
    id parsedData = nil;
    
    if(responseData == nil)
    {
        parsedData = nil;
    }
    else
    {
        NSError *jsonError = nil;
        id jsonData = [NSJSONSerialization JSONObjectWithData:responseData
                                                      options:0
                                                        error:&jsonError];
        
        if(jsonError != nil)
        {
            // json error
            return nil;
        }
        
        parsedData = jsonData;
        
        if(jsonData == nil)
        {
            parsedData = nil;
        }
        else
        {
            if([jsonData isKindOfClass:[NSDictionary class]])
            {
                NSString* errorMessage = [jsonData objectForKey:@"error"];
                if(errorMessage != nil)
                {
                    if([errorMessage respondsToSelector:@selector(isEqualToString:)])
                    {
                        if([errorMessage isEqualToString:@""])
                        {
                            parsedData = nil;
                        }
                    }
                }
            }
        }
    }
    
    return parsedData;
}

-(void) getAccessToken
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *previousUserName = [defaults objectForKey:kTwitterUsername];
    
    if([TWTweetComposeViewController canSendTweet])
    {
        ACAccountStore *store = [[ACAccountStore alloc] init];
        ACAccountType *twitterType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [store requestAccessToAccountsWithType:twitterType withCompletionHandler:^(BOOL granted, NSError *error){
            if(granted)
            {
                NSArray *arrayOfAccounts =  [store accountsWithAccountType:twitterType];
                ACAccount *account = nil;
                if (arrayOfAccounts != nil && [arrayOfAccounts count]>0) {
                    if (previousUserName) {
                        for(ACAccount *anAccount in arrayOfAccounts)
                        {
                            if ([anAccount.username isEqualToString:previousUserName] ) {
                                account = anAccount;
                                break;
                            }
                        }
                    }
                    /*//previous account was deleted if a userName match was not found
                     //show the picker or just pick the first account.
                     //TODO: provide a picker from here as well.
                     
                     if (account == nil) {
                     account = [arrayOfAccounts objectAtIndex:0];
                     }*/
                    
                    //save the account info in defaults
                    [self setTwitterUsername:account.username];
                    //now that account has been created, call the request
                    
                    [self performSelectorOnMainThread:@selector(accessTokenForAccount:) withObject:account waitUntilDone:NO];
                }
            }
        }];
    }
}

-(void)accessTokenForAccount:(ACAccount*)_account
{
    TWAPIManager *apiManager = [[[TWAPIManager alloc] init] autorelease];
    [apiManager performReverseAuthForAccount:_account withHandler:^(NSData *responseData, NSError *error) {
        if (responseData) {
            NSString *responseStr = [[NSString alloc]
                                     initWithData:responseData
                                     encoding:NSUTF8StringEncoding];
            
            NSArray *parts = [responseStr
                              componentsSeparatedByString:@"&"];
            
            NSString *lined = [parts componentsJoinedByString:@"\n"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"Success!"
                                      message:lined
                                      delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
                [alert show];
            });
        }
        else 
        {
            NSLog(@"Error!\n%@", [error localizedDescription]);
        }
    }];
}


- (void)getTwitterInfo:(NSString *)userId
{
	requestType=TW_PROFILE_INFO;
    
    NSURL *profileURL = [NSURL URLWithString:@"https://api.twitter.com/1/users/show.json"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                [self getTwitterUsername], @"screen_name",
                                @"true", @"include_entities", nil];
    
    TWRequest* twitterRequest_5 = [[[TWRequest alloc] initWithURL:profileURL
                                                       parameters:parameters
                                                    requestMethod:TWRequestMethodGET]autorelease];
    
    
    id handler = ^(NSData *responseData,NSHTTPURLResponse *urlResponse, NSError *error)
    {
        //handle stuff
        
        if (self._delegate != nil && [_delegate respondsToSelector:@selector(twitterProfileInfo:status:)])
        {
            id profileData = [self checkTwitterResponse:responseData error:error];
            
            if(profileData != nil)
            {
                NSString *socialId = [profileData objectForKey:kTWitterIdStr];
                NSString *userName=[profileData objectForKey:kTwitterName];
                NSString *profileImageUrl=[profileData objectForKey:kTwitterProfileImgURL];
                NSString *websiteURL = [profileData objectForKey:kTwitterWebsiteURL];
                NSString *bio = [profileData objectForKey:kTwitterBio];
                
                NSMutableDictionary *responseDict = [[[NSMutableDictionary alloc]initWithCapacity:5] autorelease];
                
                if(userName)
                    [responseDict setObject:userName forKey:kNSignupUserNameGETValue];
                else
                    [responseDict setObject:[NSNull null] forKey:kNSignupUserNameGETValue];
                
                if(profileImageUrl)
                    [responseDict setObject:profileImageUrl forKey:kNSignupProfilePicGETValue];
                else
                    [responseDict setObject:[NSNull null] forKey:kNSignupProfilePicGETValue];
                
                if(socialId)
                    [responseDict setObject:socialId forKey:kNSignupSocialIdGETValue];
                else
                    [responseDict setObject:[NSNull null] forKey:kNSignupSocialIdGETValue];
                
                if(websiteURL)
                    [responseDict setObject:websiteURL forKey:kNSignupSocialWebsiteURL];
                else
                    [responseDict setObject:[NSNull null] forKey:kNSignupSocialWebsiteURL];
                
                if(bio)
                    [responseDict setObject:bio forKey:kNSignupSocialBio];
                else
                    [responseDict setObject:[NSNull null] forKey:kNSignupSocialBio];
                
                [self performSelectorOnMainThread:@selector(notifyDelegateForTwitterProfileInfoWithSuccess:)
                                       withObject:responseDict waitUntilDone:NO];
            }
            else
            {
                [self performSelectorOnMainThread:@selector(notifyDelegateForTwitterProfileInfoWithFailure:)
                                       withObject:nil waitUntilDone:NO];
            }
        }
        else
        {
            // delegate is invalid
        }
    };
    
    [self executeTwitterRequest:twitterRequest_5 completionHandler:handler];
}

- (void)notifyDelegateForTwitterProfileInfoWithSuccess:(NSDictionary*)data
{
    [_delegate twitterProfileInfo:data status:YES];
}

- (void)notifyDelegateForTwitterProfileInfoWithFailure:(NSDictionary*)data
{
    [_delegate twitterProfileInfo:nil status:NO];
}


- (void)getTwitterProfilePicForId:(NSString *)userId;
{
	requestType=TW_PROFILE_IMAGE;
    
    NSString* profilePic = [NSString stringWithFormat:@"https://api.twitter.com/1/users/profile_image?screen_name=%@&size=bigger", userId];
    NSURL *profilePicURL = [NSURL URLWithString:profilePic];
    TWRequest* twitterRequest_5 = [[[TWRequest alloc] initWithURL:profilePicURL
                                                       parameters:nil
                                                    requestMethod:TWRequestMethodGET] autorelease];
    
    id handler = ^(NSData *responseData,NSHTTPURLResponse *urlResponse, NSError *error)
    {
        //handle stuff
        
        if(self._delegate != nil && [_delegate respondsToSelector:@selector(twitterProfilePicReceived:status:)])
        {
            if(responseData)
            {
                UIImage *profilePic = [[[UIImage alloc] initWithData:responseData] autorelease];
                
                [self performSelectorOnMainThread:@selector(notifyDelegateForTwitterProfilePicWithSuccess:)
                                       withObject:profilePic waitUntilDone:NO];
            }
            else
            {
                [self performSelectorOnMainThread:@selector(notifyDelegateForTwitterProfilePicWithFailure:)
                                       withObject:nil waitUntilDone:NO];
            }
        }
        
        else
        {
            // delegate is invalid
        }
    };
    
    [self executeTwitterRequest:twitterRequest_5 completionHandler:handler];
}

-(void)notifyDelegateForTwitterProfilePicWithSuccess:(UIImage *)pic
{
    [_delegate twitterProfilePicReceived:pic status:YES];
}

-(void)notifyDelegateForTwitterProfilePicWithFailure:(UIImage *)pic
{
    [_delegate twitterProfilePicReceived:nil status:NO];
}

-(void)getTwitterFollowers
{
	requestType = TW_FOLLOWERS_IDS;
    
    NSURL *followersIdsURL = [NSURL URLWithString:@"https://api.twitter.com/1/followers/ids.json"];
    
    if([TWTweetComposeViewController canSendTweet])
    {
        TWRequest* twitterRequest_5 = [[[TWRequest alloc] initWithURL:followersIdsURL
                                                           parameters:nil
                                                        requestMethod:TWRequestMethodGET] autorelease];
        
        id handler = ^(NSData *responseData,NSHTTPURLResponse *urlResponse, NSError *error)
        {
            NSDictionary* followersIdsData = (NSDictionary*)[self checkTwitterResponse:responseData error:error];
            NSArray* _idsArray = [followersIdsData objectForKey:@"ids"];
            
            if (self._delegate != nil &&
                [_delegate respondsToSelector:@selector(onTwitterFriendsReceived:)] &&
                [_delegate respondsToSelector:@selector(onTwitterFriendsFailedWithErrorMessage:)] )
            {
                // now get all the ids and pass as parameter to look up api call
                if(_idsArray != nil)
                {
                    followerIdsArray = [[NSMutableArray alloc] init];
                    [followerIdsArray addObjectsFromArray:[self formCommaSeperatedIds:_idsArray]];
                    [self getTwitterFollowersInfo];
                }
                else
                {
                    [self performSelectorOnMainThread:@selector(notifyDelegateWithFailedData:) withObject:nil waitUntilDone:NO];
                }
            }
            else
            {
                // delegate is invalid
            }
        };
        
        [self executeTwitterRequest:twitterRequest_5 completionHandler:handler];
    }
}

- (NSArray*)formCommaSeperatedIds:(NSArray*)followersIdsArray
{
    NSMutableArray* idsIn100 = [[NSMutableArray alloc] init];
    
    NSString* idsString = @"";
    int id100Count = 1;
    BOOL bExtra = TRUE;
    
    for(id userid in followersIdsArray)
    {
        bExtra = TRUE;
        
        if(id100Count < 100)
        {
            NSString* previd = idsString;
            if([previd isEqualToString:@""])
                idsString = [NSString stringWithFormat:@"%@,", userid];
            else
                idsString = [NSString stringWithFormat:@"%@%@,",previd, userid];
            id100Count++;
        }
        else
        {
            ++twitterFollowersPagesCount;
            [idsIn100 addObject:idsString];
            idsString = @"";
            id100Count = 1;
            bExtra = FALSE;
        }
    }
    
    if(bExtra)
    {
        //       ++twitterFollowersPagesCount;
        [idsIn100 addObject:idsString];
    }
    
    return [idsIn100 autorelease];
}

- (void)getTwitterFollowersInfo
{
    [self requestForFollowersDetails:[followerIdsArray objectAtIndex:twitterFollowersCurrentPageIndex]];
}

- (void)requestForFollowersDetails:(NSString*)idsString
{
    requestType = TW_FOLLOWERS_INFO;
    
    NSString* followersInfoURLString = [NSString stringWithFormat:@"https://api.twitter.com/1/users/lookup.json?user_id=%@",idsString];
    NSURL *followersInfoURL = [NSURL URLWithString:followersInfoURLString];
    TWRequest* twitterRequest_5_Next = [[[TWRequest alloc] initWithURL:followersInfoURL
                                                            parameters:nil
                                                         requestMethod:TWRequestMethodGET] autorelease];
    
    id handler = ^(NSData *responseData,NSHTTPURLResponse *urlResponse, NSError *error)
    {
        //handle stuff
        
        
        if (self._delegate != nil &&
            [_delegate respondsToSelector:@selector(onTwitterFriendsReceived:)] &&
            [_delegate respondsToSelector:@selector(onTwitterFriendsFailedWithErrorMessage:)] )
        {
            id followersData = [self checkTwitterResponse:responseData error:error];
            
            if(followersData != nil)
            {
                [self performSelectorOnMainThread:@selector(notifyDelegateWithSuccessData:)
                                       withObject:followersData
                                    waitUntilDone:NO];
            }
            else
            {
                // error in parsing
                [self performSelectorOnMainThread:@selector(notifyDelegateWithFailedData:)
                                       withObject:nil
                                    waitUntilDone:NO];
            }
        }
        else
        {
            // delegate is invalid
        }
    };
    
    [self executeTwitterRequest:twitterRequest_5_Next completionHandler:handler];
}

-(void)notifyDelegateWithSuccessData:(id)data
{
    if (self._delegate != nil &&[_delegate respondsToSelector:@selector(onTwitterFriendsReceived:)])
        [_delegate onTwitterFriendsReceived:data];
}

-(void)notifyDelegateWithFailedData:(id)data
{
    if (self._delegate != nil &&[_delegate respondsToSelector:@selector(onTwitterFriendsFailedWithErrorMessage:)])
        [_delegate onTwitterFriendsFailedWithErrorMessage:kTwitterFollowersErrorMessage];
}

- (void)sendDirectMessage:(NSString *)message to:(NSString *)userId
{
	requestType = TW_SEND_MESSAGE;
    
    NSURL *messageURL = [NSURL URLWithString:@"https://api.twitter.com/1/direct_messages/new.json"];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                userId, @"user_id",
                                message, @"text", nil];
    
    if([TWTweetComposeViewController canSendTweet])
    {
        TWRequest* twitterRequest_5 = [[[TWRequest alloc] initWithURL:messageURL
                                                           parameters:parameters
                                                        requestMethod:TWRequestMethodPOST] autorelease];
        
        id handler = ^(NSData *responseData,NSHTTPURLResponse *urlResponse, NSError *error)
        {
            //handle stuff
            if (self._delegate != nil &&[_delegate respondsToSelector:@selector(onTwitterInvitationResponse:identifier:)])
            {
                id parsedData = [self checkTwitterResponse:responseData error:error];
                
                if (parsedData != nil)
                {
                    [self performSelectorOnMainThread:@selector(notifyDelegateOnSuccessfulTwitterInvitationForUser:) withObject:userId waitUntilDone:NO];
                }
                else
                {
                    [self performSelectorOnMainThread:@selector(notifyDelegateOnFailedTwitterInvitationForUser:) withObject:nil waitUntilDone:NO];
                }
            }
            else
            {
                // delegate is invalid
            }
            
        };
        
        [self executeTwitterRequest:twitterRequest_5 completionHandler:handler];
    }
}

-(void)notifyDelegateOnSuccessfulTwitterInvitationForUser:(NSString*)userId
{
    [_delegate onTwitterInvitationResponse:YES identifier:userId];
}

-(void)notifyDelegateOnFailedTwitterInvitationForUser:(NSString*)userId
{
    [_delegate onTwitterInvitationResponse:NO identifier:nil];
}

- (void)sendUpdate:(NSString *)status
{
    requestType = TW_SEND_UPDATE;
    
    NSURL *statusURL = [NSURL URLWithString:@"https://api.twitter.com/1/statuses/update.json"];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                status, @"status",
                                @"true", @"wrap_links", nil];
    
    if([TWTweetComposeViewController canSendTweet])
    {
        
        TWRequest* twitterRequest_5 = [[[TWRequest alloc] initWithURL:statusURL
                                                           parameters:parameters
                                                        requestMethod:TWRequestMethodPOST] autorelease];
        
        id handler = ^(NSData *responseData,NSHTTPURLResponse *urlResponse, NSError *error)
        {
            if (self._delegate != nil &&[_delegate respondsToSelector:@selector(onTweetResponseReceived:)])
            {
                id parsedData = [self checkTwitterResponse:responseData error:error];
                
                if (parsedData != nil)
                {
                    [self performSelectorOnMainThread:@selector(notifyDelegateForSuccessfulTweetResponseReceive) withObject:nil
                                        waitUntilDone:NO];
                }
                else
                {
                    [self performSelectorOnMainThread:@selector(notifyDelegateForFailedTweetResponseReceive) withObject:nil
                                        waitUntilDone:NO];
                }
            }
            else
            {
                // delegate is invalid
            }
        };
        
        [self executeTwitterRequest:twitterRequest_5 completionHandler:handler];
    }
}

-(void)notifyDelegateForSuccessfulTweetResponseReceive
{
    [_delegate onTweetResponseReceived:YES];
}
-(void)notifyDelegateForFailedTweetResponseReceive
{
    [_delegate onTweetResponseReceived:NO];
}

-(void)dealloc
{
    NSLog(@"TwitterUtil : dealloc");
    
    [followerIdsArray release];
	[super dealloc];
}

@end
