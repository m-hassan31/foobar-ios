#import "ConnectionManager.h"
#import "ASIHTTPRequest.h"
#import "EndPoints.h"
#import "SocialUser.h"
#import "FooBarUser.h"

@interface ConnectionManager()
{
    NSMutableArray *activeRequests;
}
- (void)showHUDwithText:(NSString *)text;
@end

@implementation ConnectionManager

@synthesize delegate;

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

-(ASIHTTPRequest*)getRequestWithAuthHeader:(NSURL*)url
{
    FooBarUser *foobarUser = [FooBarUser currentUser];
    if(!foobarUser)
        return nil;
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request addRequestHeader:@"X-foobar-username" value:foobarUser.username];
    [request addRequestHeader:@"X-foobar-access-token" value:foobarUser.accessToken];
    return request;
}

- (void)signin
{
    // Instantiate an HTTP request.
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",UsersUrl]];
    
    SocialUser *socialUser = [SocialUser currentUser];
    if(!socialUser)
        return;
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request addRequestHeader:@"X-foobar-username" value:socialUser.socialId];
    [request addRequestHeader:@"X-foobar-access-token" value:socialUser.accessToken];    
    if(!request)
        return;

    [request setRequestMethod:@"POST"];
	[request addRequestHeader:@"Content-Type" value:@"application/json"];
    
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                            socialUser.username, @"username",
                            socialUser.accessToken, @"access_token",
                            (socialUser.socialAccountType==FacebookAccount)?@"facebook":@"twitter", @"account_type",
                            socialUser.firstname, @"first_name",
                            socialUser.socialId, @"account_id",
                            socialUser.photoUrl, @"photo_url", nil];
    [request appendPostData:[FooBarUtils jsonFromDictionary:params]];
    [params release];
    
    request.delegate = self;
    // Send the request.
    [request startAsynchronous];
}

-(void)getProfile
{
    [self getProfile:NO];
}

-(void)getProfile:(BOOL)showHud
{
    if(showHud)
        [self showHUDwithText:@"Getting Info"];
    // Instantiate an HTTP request.
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", MyProfileUrl]];
    ASIHTTPRequest *request = [self getRequestWithAuthHeader:url];    
    request.delegate = self;
    // Send the request.
    [request startAsynchronous];
}

-(void)getUserProfile:(NSString*)profileId
{
    [self showHUDwithText:@"Getting Info"];
    // Instantiate an HTTP request.
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", UsersUrl, profileId]];
    ASIHTTPRequest *request = [self getRequestWithAuthHeader:url];    
    request.delegate = self;
    // Send the request.
    [request startAsynchronous];
}

-(void)getFeedsAtPage:(NSUInteger)_pageNum count:(NSUInteger)_count
{
    [self showHUDwithText:@"Getting Feeds"];
    // Instantiate an HTTP request.
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%d/%d",FeedsUrl, _pageNum, _count]];
    ASIHTTPRequest *request = [self getRequestWithAuthHeader:url];    
    request.delegate = self;
    // Send the request.
    [request startAsynchronous];
}

-(void)getFooBarProducts
{
    [self showHUDwithText:@"Getting Products"];
    // Instantiate an HTTP request.
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",ProductsUrl]];
    ASIHTTPRequest *request = [self getRequestWithAuthHeader:url];        
    request.delegate = self;
    // Send the request.
    [request startAsynchronous];
}

-(void)uploadPhoto:(UIImage*)image withProductId:(NSString*)productId
{
    FooBarUser *foobarUser = [FooBarUser currentUser];
    
    // Instantiate an HTTP request.
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?enctype=multipart/form-data",PhotosUrl]];
    
    ASIFormDataRequest *request= [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"X-foobar-username" value:foobarUser.username];
    [request addRequestHeader:@"X-foobar-access-token" value:foobarUser.accessToken];
    [request addRequestHeader:@"X-foobar-product-id" value:productId];
    
    [request setData:UIImageJPEGRepresentation(image, 1.0) forKey:@"pic"];
    
    request.delegate = self;
    // Send the request.
    [request startAsynchronous];
}

-(void)updatePost:(NSString*)postId withCaption:(NSString*)caption
{
    // Instantiate an HTTP request.
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",PhotosUrl, postId]];
    ASIHTTPRequest *request = [self getRequestWithAuthHeader:url];
    [request setRequestMethod:@"PUT"];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    request.delegate = self;
    
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                            caption, @"photo_caption", nil];
    [request appendPostData:[FooBarUtils jsonFromDictionary:params]];
    [params release];
    
    // Send the request.
    [request startAsynchronous];
}

-(void)comment:(NSString*)text onPost:(NSString*)postId
{
    [self showHUDwithText:@"Posting"];
    // Instantiate an HTTP request.
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",CommentsUrl]];
    ASIHTTPRequest *request = [self getRequestWithAuthHeader:url];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    request.delegate = self;
    
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                            postId, @"post_id",
                            text, @"text", nil];
    [request appendPostData:[FooBarUtils jsonFromDictionary:params]];
    [params release];
    
    // Send the request.
    [request startAsynchronous];
}

-(void)deleteComment:(NSString*)commentId
{
    [self showHUDwithText:@"Deleting"];
    // Instantiate an HTTP request.
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",CommentsUrl, commentId]];
    ASIHTTPRequest *request = [self getRequestWithAuthHeader:url];
    [request setRequestMethod:@"DELETE"];
    request.delegate = self;
    
    // Send the request.
    [request startAsynchronous];
}

-(void)likePost:(NSString*)postId
{
    [self showHUDwithText:@""];
    // Instantiate an HTTP request.
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",LikesUrl]];
    ASIHTTPRequest *request = [self getRequestWithAuthHeader:url];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    request.delegate = self;
    
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                            postId, @"post_id", nil];
    [request appendPostData:[FooBarUtils jsonFromDictionary:params]];
    [params release];
    
    // Send the request.
    [request startAsynchronous];
}

-(void)unlikePost:(NSString*)postId
{
    [self showHUDwithText:@""];
    // Instantiate an HTTP request.
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",UnlikeUrl, postId]];
    ASIHTTPRequest *request = [self getRequestWithAuthHeader:url];
    [request setRequestMethod:@"DELETE"];
    request.delegate = self;
    
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