#import "FacebookUtil.h"
#import "NSObject+SBJSON.h"
#import "NSString+SBJSON.h"
#import "NSMutableData-AES.h"

#define kFB_ACCESS_TOKEN_KEY            @"FB_ACCESS_TOKEN_KEY"
#define kFB_EXPIRATION_DATE_KEY         @"FB_EXPIRATION_DATE_KEY"
#define	kIsFacebookConfigured			@"facebookConfiguration"
#define kFBUsername                     @"fbUsername"
#define kIsFacebookEnabled				@"facebookEnabled"
#define kEncryptionKey                  @"6b2c8762aedjkee0bce1485da86530dc0*2-01dn102)-1-~~`%$#@#"

#define	kFBUsernameField						   @"username"
#define	kFBUserIdField							   @"id"
#define	kFBEmailField							   @"email"
#define	kFBAccessTokenField						   @"access_token"
#define	kFBFirstNameField						   @"first_name"
#define	kFBProfilePictureField					   @"profile_pic"
#define kFBProfilePictureURL					   @"https://graph.facebook.com/me/picture?type=normal&access_token=%@"

static FacebookUtil *sharedFacebookUtil = nil;
const static NSString* kFacebookAppId = @"157363651053951";

@interface FacebookUtil(PRIVATE)

-(NSDictionary *) parseFacebookProfile:(FBRequest *) request result:(id)result;

+(void) renewSharedFacebookUtil;

@end

@implementation FacebookUtil

@synthesize delegate,facebook;

+(NSData*)encryptVal:(NSString*)val
{
    NSLog(@"Utils : encryptVal");
    
    NSMutableData *valData = [[val dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    NSData *encryptedValData = [valData EncryptAES:kEncryptionKey];
    [valData release];
    return encryptedValData;
}

+(NSString*)decryptValForKey:(NSString*)key
{
    NSLog(@"Utils : decryptValForKey");
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *decryptData = [userDefaults objectForKey:key];
    NSMutableData *retVal = [decryptData mutableCopy];
    NSData *decrypted = [retVal DecryptAES:kEncryptionKey];
    NSString *retValString = [[[NSString alloc] initWithData:decrypted
                                                    encoding:NSUTF8StringEncoding] autorelease];
    [retVal release];
    return retValString;
}

+(NSDate *) fbExpirationDate
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:kFB_EXPIRATION_DATE_KEY];
}

#pragma mark -
#pragma mark singleton functions

+ (id)getSharedFacebookUtil
{
	@synchronized(self) 
    {
        if(sharedFacebookUtil == nil)
        {
            sharedFacebookUtil = [[super allocWithZone:NULL] init];
            Facebook *facebook = [[Facebook alloc] initWithAppId:[NSString stringWithFormat:@"%@",kFacebookAppId]];
            sharedFacebookUtil.facebook = facebook;
            [facebook release];
            
            if([sharedFacebookUtil isFacebookConfigured]) 
            {
                sharedFacebookUtil.facebook.accessToken=[FacebookUtil decryptValForKey:kFB_ACCESS_TOKEN_KEY];
                sharedFacebookUtil.facebook.expirationDate = [FacebookUtil fbExpirationDate];
            }
        }
    }
    return sharedFacebookUtil;
}

+ (void)renewSharedFacebookUtil
{    
    @synchronized(self)
    {
        [sharedFacebookUtil release];
        sharedFacebookUtil=nil;
        [FacebookUtil getSharedFacebookUtil];         
    }
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [sharedFacebookUtil retain];
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (id)retain
{
	return self;
}

- (NSUInteger)retainCount
{
	
	return NSUIntegerMax;  //denotes an object that cannot be released
}

- (oneway void)release
{
    //do nothing
    return;
}

- (id)autorelease
{	
	return self;
}

- (BOOL)handleOpenURL:(NSURL *)url
{
	return [sharedFacebookUtil.facebook handleOpenURL:url];
}

- (void)configureFacebook:(id) utilDelegate
{
	[self authorize:utilDelegate];
}

- (void)clearFacebookCredentials
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
	[defaults removeObjectForKey:kFB_ACCESS_TOKEN_KEY];         //clear the fb access token
    [defaults removeObjectForKey:kFB_EXPIRATION_DATE_KEY];      //clear the fb exp date
    sharedFacebookUtil.facebook.accessToken=nil;
    sharedFacebookUtil.facebook.expirationDate=nil;
    [self setFacebookConfigured:NO];
}

- (void)authorize:(id)utilDelegate
{	
	self.delegate= utilDelegate;	
	NSArray *permissions= [NSArray arrayWithObjects:@"read_stream",@"publish_stream",
                           @"email",@"offline_access",nil] ;
	[sharedFacebookUtil.facebook authorize:permissions delegate:self];
}

- (BOOL)isFacebookSessionValid
{	
    if([sharedFacebookUtil.facebook isSessionValid])
        return YES;
	return NO;
}

- (NSString*)getFacebookAuthToken
{
	NSString *token=[FacebookUtil decryptValForKey:kFB_ACCESS_TOKEN_KEY];
	return token;	
}

- (BOOL)isFacebookConfigured
{	
	NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];	
	BOOL isConfigured= [defaults boolForKey:kIsFacebookConfigured];
	return isConfigured;
}

- (void)setFacebookConfigured:(BOOL)config
{
    NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];	
	[defaults setBool:config forKey:kIsFacebookConfigured];
	[defaults synchronize];
}

- (BOOL)isFacebookEnabled
{	
    NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];	
    BOOL isFacebookEnabled= [defaults boolForKey:kIsFacebookEnabled];
    return isFacebookEnabled;
}

-(void)setFacebookEnabled:(BOOL)state
{
    NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
	[defaults setBool:state forKey:kIsFacebookEnabled];
	[defaults synchronize];    
}

- (void)logout:(id)utilDelegate
{
    self.delegate=utilDelegate;
    [sharedFacebookUtil.facebook logout:self];
}

- (void)getMyFacebookProfile:(id)utilDelegate
{	
	self.delegate= utilDelegate;
	currentFacebookAction = FB_PROFILE;
	[sharedFacebookUtil.facebook requestWithGraphPath:[NSString stringWithFormat:@"me?fields=%@,%@,%@,%@", kFBUserIdField,kFBUsernameField,kFBFirstNameField,kFBEmailField] andDelegate:self];	
}

- (void)getMyFacebookProfilePic:(id)utilDelegate
{
	self.delegate= utilDelegate;
	currentFacebookAction = FB_PROFILE_PICTURE;
	[sharedFacebookUtil.facebook requestWithGraphPath:@"me/picture?type=large" andDelegate:self];
}

- (void)sharePhotoOnFacebook:(NSString*)failURL 
             previewImageURL:(NSString*)imageURL 
                   withTitle:(NSString*)shareTitle 
             withDescription:(NSString*)shareDescription 
                fromDelegate:(id) utilDelegate
{
	self.delegate= utilDelegate;
	currentFacebookAction = FB_POST;
    
    NSString* shareText = [NSString stringWithFormat:@"%@", shareDescription];
	NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									shareText, @"comment",
									failURL,@"url",
									imageURL,@"image",
									nil];
    
	[sharedFacebookUtil.facebook requestWithMethodName: @"links.post"
											 andParams: params
										 andHttpMethod: @"POST"
										   andDelegate: self];
}

- (void)getFacebookFriendsWithDelegate:(id)_delegate
{
	self.delegate= _delegate;
	currentFacebookAction = FB_FRIENDS;
	[sharedFacebookUtil.facebook requestWithGraphPath:@"me/friends" andDelegate:self];
}

- (void)inviteUser:(NSString*)userId fromDelegate:(id)utilDelegate
{    
    self.delegate= utilDelegate;
    currentFacebookAction = FB_INVITATION;
    
	if(!userIdMapping)
        userIdMapping = [[NSMutableDictionary alloc] init];
	
	//Facebook Request
	NSString* request = [NSString stringWithFormat:@"%@/feed",userId];
	NSString* reqKey = [NSString stringWithFormat:@"https://graph.facebook.com/%@",request];
	[userIdMapping setObject:userId forKey:reqKey];
	/*[sharedFacebookUtil.facebook requestWithGraphPath:request 
											andParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:
													   kFriendInviteBody, @"message",
													   kInviteTitle,@"name",
													   kFontliURL, @"link",
													   kFontliIconURL, @"picture",
													   nil]
										andHttpMethod:@"POST"
										  andDelegate:self];*/
}

- (NSDictionary *)parseFacebookProfile:(FBRequest *) request result:(id)result
{
	NSString *jsonStringParams = (NSString *)[request.params JSONRepresentation];
	NSDictionary *userDict = (NSDictionary *)[jsonStringParams JSONValue];
	NSString *accessToken = ((NSString*)[userDict objectForKey:kFBAccessTokenField]);
	NSDictionary *userInfo=result;
	NSMutableDictionary *facebookProfileDict=[[[NSMutableDictionary alloc] init] autorelease];
    
	if([userInfo  objectForKey:kFBUserIdField]) 
        [facebookProfileDict setObject:[userInfo objectForKey:kFBUserIdField] forKey:kFBUserIdField];	
	
	if([userInfo  objectForKey:kFBUsernameField])
        [facebookProfileDict setObject:[userInfo objectForKey:kFBUsernameField] forKey:kFBUsernameField];	
    
	if([userInfo  objectForKey:kFBEmailField])
        [facebookProfileDict setObject:[userInfo objectForKey:kFBEmailField] forKey:kFBEmailField];	
    
	if([userInfo  objectForKey:kFBFirstNameField])
        [facebookProfileDict setObject:[userInfo objectForKey:kFBFirstNameField] forKey:kFBFirstNameField];	
	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kFBProfilePictureURL, accessToken]];
	NSData *data = [NSData dataWithContentsOfURL:url];
	UIImage *profilePic = [[[UIImage alloc] initWithData:data] autorelease];
	
	if(profilePic) 
        [facebookProfileDict setObject:profilePic forKey:kFBProfilePictureField];	
	
	return facebookProfileDict;
}

#pragma mark -
#pragma mark facebook delegate methods

/*
 * Called when the user has logged in successfully.
 */

- (void)fbDidLogin 
{
	NSLog(@"FacebookUtil : fbDidLogin");
	
	//save accessToken for later use
	
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
    [defaults setObject:[FacebookUtil encryptVal:sharedFacebookUtil.facebook.accessToken] forKey:kFB_ACCESS_TOKEN_KEY];
	[defaults setObject:sharedFacebookUtil.facebook.expirationDate forKey:kFB_EXPIRATION_DATE_KEY];
	[defaults setBool:YES forKey:kIsFacebookConfigured];
	[defaults synchronize];
    [formatter release];
	
	NSLog(@"fb accessToken: %@", sharedFacebookUtil.facebook.accessToken);
	NSLog(@"fb expiration date: %@", sharedFacebookUtil.facebook.expirationDate);
	
    [self setFacebookEnabled:YES];
	
	if([delegate respondsToSelector:@selector(onFacebookAuthorized:)])
        [delegate onFacebookAuthorized:YES];
}

/*
 * Called when the user canceled the authorization dialog.
 */

- (void)fbDidNotLogin:(BOOL)cancelled 
{
	NSLog(@"FacebookUtil : fbDidNotLogin");
	
	if([delegate respondsToSelector:@selector(onFacebookAuthorized:)]) 
        [delegate performSelector:@selector(onFacebookAuthorized:) withObject:NO];
}

/*
 * Called when the request logout has succeeded.
 */

- (void)fbDidLogout 
{
	NSLog(@"FacebookUtil : fbDidLogout");
    
    [self clearFacebookCredentials];
    if ([delegate respondsToSelector:@selector(facebookDidLogout)]) 
        [delegate performSelector:@selector(facebookDidLogout)];
}


// FBRequestDelegate

/**
 * Called when the Facebook API request has returned a response. This callback
 * gives you access to the raw response. It's called before
 * (void)request:(FBRequest *)request didLoad:(id)result,
 * which is passed the parsed response object.
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response
{
	NSLog(@"FacebookUtil :FBRequest didReceiveResponse");
}

/**
 * Called when a request returns and its response has been parsed into
 * an object. The resulting object may be a dictionary, an array, a string,
 * or a number, depending on the format of the API response. If you need access
 * to the raw response, use:
 *
 * (void)request:(FBRequest *)request
 *      didReceiveResponse:(NSURLResponse *)response
 */
- (void)request:(FBRequest *)request didLoad:(id)result
{
	NSLog(@"FacebookUtil : FBRequest didLoad");
	
	if (currentFacebookAction == FB_PROFILE/* it is get fb user info*/) 
	{		
		if([delegate respondsToSelector:@selector(onFacebookProfileRecieved:)])			
            [delegate performSelector:@selector(onFacebookProfileRecieved:) withObject:[self parseFacebookProfile:request result:result]];
	}
    
	else if(currentFacebookAction == FB_POST/* facebook post response */) 
	{
		if ([delegate respondsToSelector:@selector(onFacebookPostResponse:)])
            [delegate onFacebookPostResponse:YES];			
	}
    
	else if(currentFacebookAction == FB_INVITATION/* facebook invitaiton*/)
	{
		if ([delegate respondsToSelector:@selector(onFacebookInvitationResponse:identifier:)])
            [delegate onFacebookInvitationResponse:YES identifier:[userIdMapping objectForKey:request.url]];			
	}
    
	else if(currentFacebookAction == FB_FRIENDS/* facebook friends*/)
	{
		if ([delegate respondsToSelector:@selector(onFacebookFriendsReceived:status:)])
            [delegate onFacebookFriendsReceived:(NSDictionary*)result status:YES];			
	}
    
    else if(currentFacebookAction == FB_PROFILE_PICTURE /*facebook profile picture in large dimension*/)
    {
        if([result isKindOfClass:[NSData class]])
        {
            UIImage *profilePic = [[[UIImage alloc] initWithData:result] autorelease];
            if([delegate respondsToSelector:@selector(onFacebookProfilePicReceived:status:)])
                [delegate onFacebookProfilePicReceived:profilePic status:YES];
        }
        else
        {
            if([delegate respondsToSelector:@selector(onFacebookProfilePicReceived:status:)])
                [delegate onFacebookProfilePicReceived:nil status:NO];
        }
    }
}


- (void)request:(FBRequest *)request didFailWithError:(NSError *)error
{
	NSLog(@"FacebookUtil : FBRequest didFailWithError: ");
    NSLog(@"[error localizedDescription] %@",[error localizedDescription]);
    NSLog(@"[error localizedFailureReason] %@",[error localizedFailureReason]);
    NSLog(@"[error localizedRecoveryOptions] %@",[error localizedRecoveryOptions]);
    NSLog(@"[error localizedRecoverySuggestion] %@",[error localizedRecoverySuggestion]);
	
	if (currentFacebookAction == FB_PROFILE/* it is get fb user info*/) 
	{		
	}
    
	else if(currentFacebookAction == FB_POST/* facebook post response */) 
	{
		if ([delegate respondsToSelector:@selector(onFacebookPostResponse:)])
            [delegate performSelector:@selector(onFacebookPostResponse:) withObject:NO];
	}
    
	else if(currentFacebookAction == FB_INVITATION/* facebook invitaiton*/)
	{
		if ([delegate respondsToSelector:@selector(onFacebookInvitationResponse:identifier:)])
            [delegate performSelector:@selector(onFacebookInvitationResponse:identifier:) 
                           withObject:NO withObject:[userIdMapping objectForKey:request.url]];
	}
    
	else if(currentFacebookAction == FB_FRIENDS/* facebook friends*/)
	{
		if ([delegate respondsToSelector:@selector(onFacebookFriendsReceived:status:)])
            [delegate performSelector:@selector(onFacebookFriendsReceived:status:) withObject:nil withObject:NO];
	}
};


////////////////////////////////////////////////////////////////////////////////
// FBDialogDelegate

/**
 * Called when a UIServer Dialog successfully return.
 */
- (void)dialogDidComplete:(FBDialog *)dialog 
{
	NSLog(@"FacebookUtil : dialogDidComplete");
}

- (void)dealloc
{
	//[facebook release];
	[super dealloc];
    
    NSLog(@"FacebookUtil : dealloc");
}

@end