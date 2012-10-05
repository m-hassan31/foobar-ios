#import "ConnectionManager.h"
#import "ASIHTTPRequest.h"
#import "EndPoints.h"
#import "SocialUser.h"

@interface ConnectionManager()
{
    NSMutableArray *activeRequests;
}
- (void)showHUDwithText:(NSString *)text;
@end

@implementation ConnectionManager

@synthesize delegate;

#pragma mark -
#pragma mark  

- (id)init
{
	NSLog(@"ConnectionManager : init");
	
    self = [super init];
	
    if(!self)
	{
		return nil;
	} 
    
    activeRequests = [[NSMutableArray alloc] init];
	return self;
}

- (void)signin
{
    [self showHUDwithText:@"Signing in"];
    
    SocialUser *socialUser = [SocialUser currentUser];
    
    // Instantiate an HTTP request.
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",UsersUrl]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
	[request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"X-foobar-username" value:socialUser.socialId];
    [request addRequestHeader:@"X-foobar-access-token" value:socialUser.accessToken];
    
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                            (socialUser.socialAccountType==FacebookAccount)?@"facebook":@"twitter", @"account_type",
                            socialUser.firstname, @"first_name",
                            socialUser.photoUrl, @"photo_url", nil];
    [request appendPostData:[FooBarUtils jsonFromDictionary:params]];
    [params release];
    
    request.delegate = self;
    // Send the request.
    [request startAsynchronous];
}

-(void)getFeedsAtPage:(NSUInteger)_pageNum count:(NSUInteger)_count
{
    [self showHUDwithText:@"Signing in"];
    
    // Instantiate an HTTP request.
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",UsersUrl]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
	[request addRequestHeader:@"Content-Type" value:@"application/json"];
    //[request addRequestHeader:@"X-foobar-username" value:_username];
    //[request addRequestHeader:@"X-foobar-access-token" value:_password];
    
    request.delegate = self;
    // Send the request.
    [request startAsynchronous];
}

- (void)signOut
{	
    [self showHUDwithText:@"Signing out"];
    
    // Instantiate an HTTP request.
    NSURL *url = [NSURL URLWithString:@"https://asms.cloudfoundry.com/logout"];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.delegate = self;
    [request setAuthenticationScheme:(NSString *)kCFHTTPAuthenticationSchemeBasic];
    [request setRequestMethod:@"POST"];
    [request setShouldPresentCredentialsBeforeChallenge:NO];
    
    // Send the request.
    [request startAsynchronous];
}

#pragma mark -
#pragma mark SAProgressHUD delegate function

- (void)hudWasHidden 
{
	NSLog(@"ConnectionManager : hudWasHidden");
	// Remove HUD from screen when the HUD was hidded
	if(hud)
	{
		[hud removeFromSuperview];
        hud.delegate = nil;
		[hud release];
		hud = nil;
	}	
}

- (void)showHUDwithText:(NSString *)text
{
	if(!hud)
	{
		UIWindow *window = [UIApplication sharedApplication].keyWindow;
		hud = [[SAProgressHUD alloc] initWithWindow:window];
		// Add HUD to screen
		[window addSubview:hud];
		
		// Register for HUD callbacks so we can remove it from the window at the right time
		hud.delegate = self;
		
		// Show the HUD while the provided method executes in a new thread
		[hud show:YES];
		hud.labelText = text;
	}
}

#pragma mark -
#pragma mark ASIHTTPRequest functions

- (void)requestFinished:(ASIHTTPRequest *)request
{
	NSLog(@"Connection Manager : requestFinished");
	
    if(hud)
    [hud hide:YES];
            
	if(delegate!=nil && [delegate respondsToSelector:@selector(httpRequestFinished:)])
    [delegate httpRequestFinished:request];
            
    if([activeRequests containsObject:request])
    [activeRequests removeObject:request];

    request.delegate = nil;
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	NSLog(@"Connection Manager : requestFailed");
	
	if(hud)
    [hud hide:YES];
	
    if(delegate!=nil && [delegate respondsToSelector:@selector(httpRequestFailed:)])
    [delegate httpRequestFailed:request];        
    
    if([activeRequests containsObject:request]) 
    [activeRequests removeObject:request];

    request.delegate = nil;
}

#pragma mark -
#pragma mark DEALLOC

- (void)dealloc
{
	NSLog(@"Connection Manager : dealloc");
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    for(ASIHTTPRequest *request in activeRequests)
    {
         NSLog(@"Active Request Cancelling");
        [request clearDelegatesAndCancel];
    }
    
    [activeRequests release];
     activeRequests = nil;
    
    if(hud != nil) 
    hud.delegate = nil;
    
    self.delegate=nil;
        
	[super dealloc];
}

@end