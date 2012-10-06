#import "SignInViewController.h"
#import "StreamViewController.h"
#import "AppDelegate.h"
#import "FooBarUtils.h"
#import "FooBarConstants.h"
#import "EndPoints.h"
#import "SAProgressHUD.h"
#import <QuartzCore/QuartzCore.h>

@interface SignInViewController()

-(void)showHUDwithText:(NSString*)text;
-(void)hideHud;

@end

@implementation SignInViewController

@synthesize facebookButton;
@synthesize twitterButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    facebookUtil = [FacebookUtil getSharedFacebookUtil];
    manager = [[ConnectionManager alloc] init];
    manager.delegate = self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Facebook Actions

-(IBAction)facebookButtonPressed:(id)sende
{
    [facebookUtil authorize:self];
}

#pragma mark -
#pragma mark FacebookUtil delegate functions

- (void)onFacebookAuthorized:(BOOL)status
{
    if(status==YES)
    {
        [self showHUDwithText:@"Getting Facebook Info"];
		[facebookUtil getMyFacebookProfile:self];
    }
    else
        [FooBarUtils showAlertMessage:@"Could not connect to Facebook. Try again."];
}

- (void)onFacebookProfileRecieved:(NSDictionary *)userInfo
{
    if(!userInfo)
    {
        [self hideHud];
        [FooBarUtils showAlertMessage:@"Could not connect to Facebook. Try again."];
    }
    
    if(!currentLoggedinUser)
        currentLoggedinUser = [[SocialUser alloc] init];
    
    currentLoggedinUser.accessToken = facebookUtil.facebook.accessToken;
    currentLoggedinUser.socialAccountType = FacebookAccount;
    currentLoggedinUser.socialId = (NSString*)[userInfo objectForKey:kFBUserIdField];
	currentLoggedinUser.username = (NSString*)[userInfo objectForKey:kFBUsernameField];
	currentLoggedinUser.firstname = (NSString*)[userInfo objectForKey:kFBFirstNameField];
    
    currentLoggedinUser.photoUrl = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", currentLoggedinUser.socialId];
    
    if(currentLoggedinUser.username == nil)
        currentLoggedinUser.username = currentLoggedinUser.firstname;
    
    [SocialUser saveCurrentUser:currentLoggedinUser];
    [self hideHud];
    [manager signin];
}

#pragma mark - Twitter Actions

-(IBAction)twitterButtonPressed:(id)sender
{
    if(!twitterAccountPicker)
    {
        twitterAccountPicker = [[TwitterAccountPickerController alloc]init];
        twitterAccountPicker.view.frame = CGRectMake(0, 480, 320, 260);
        twitterAccountPicker.delegate = self;
        [self.view addSubview:twitterAccountPicker.view];
    }
    
    [twitterAccountPicker fetchTwitterAccountsAndConfigure];
}

#pragma mark - TwitterAccountPickerDelegate delegate functions

- (void)twitterAccountSelected
{
    
    if(!twitterUtil)
        twitterUtil= [[TwitterUtil alloc] initWithDelegate:self];
    
    if(twitterUtil)
    {
        [self showHUDwithText:@"Getting Twitter Info"];
        NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
        [twitterUtil getTwitterInfo:[defaults objectForKey:kTwitterUsername]];
    }
}

#pragma mark -
#pragma mark TwitterUtil Delegates

- (void)twitterProfileInfo:(NSDictionary *)userInfo status:(BOOL)status
{
    [userInfo retain];
    if(!status)
    {
        [self hideHud];
        [FooBarUtils showAlertMessage:@"Could not connect to Twitter. Try again."];
    }
    
    if(!currentLoggedinUser)
        currentLoggedinUser = [[SocialUser alloc] init];
    
    currentLoggedinUser.accessToken = facebookUtil.facebook.accessToken;
    currentLoggedinUser.socialAccountType = TwitterAccount;
    
    id _socialId = [userInfo objectForKey:kNSignupSocialIdGETValue];
    if(![_socialId isKindOfClass:[NSNull class]])
        currentLoggedinUser.socialId = [userInfo objectForKey:kNSignupSocialIdGETValue];
    
    NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
    currentLoggedinUser.username = [defaults objectForKey:kTwitterUsername];
    
    id _firstname = [userInfo objectForKey:kNSignupUserNameGETValue];
    if(![_firstname isKindOfClass:[NSNull class]])
        currentLoggedinUser.firstname = [userInfo objectForKey:kNSignupUserNameGETValue];
    
    id _photoUrl = [userInfo objectForKey:kNSignupProfilePicGETValue];
    if(![_photoUrl isKindOfClass:[NSNull class]])
    {
        NSString *profilePicUrl = [userInfo objectForKey:kNSignupProfilePicGETValue];
        currentLoggedinUser.photoUrl = [profilePicUrl stringByReplacingOccurrencesOfString:@"_normal." withString:@"_bigger."];;
    }
    
    if(currentLoggedinUser.username == nil)
        currentLoggedinUser.username = currentLoggedinUser.firstname;
    
    [SocialUser saveCurrentUser:currentLoggedinUser];
    [userInfo release];
    [self hideHud];
    
    [twitterUtil getAccessToken];
//    [manager signin];
}


#pragma mark -
#pragma mark SAProgressHUD functions

- (void)hideHud
{
	// Remove HUD from screen when the HUD was hidded
    if(hud)
    {
        hud.delegate = nil;
		[hud removeFromSuperview];
		[hud release];
		hud = nil;
    }
}

-(void)showHUDwithText:(NSString *)text
{
	if(!hud)
    {
		UIWindow *window = [UIApplication sharedApplication].keyWindow;
		hud = [[SAProgressHUD alloc] initWithWindow:window];
		// Add HUD to screen
		[window addSubview:hud];
		
		// Regisete for HUD callbacks so we can remove it from the window at the right time
        hud.delegate = nil; /* Setting hud delegate to nil to handle this manually*/
		
		// Show the HUD while the provided method executes in a new thread
		[hud show:YES];
		hud.labelText = text;
    }
}

#pragma mark - ConnectionManager delegate functions

-(void)httpRequestFailed:(ASIHTTPRequest *)request
{
	NSError *error= [request error];
	NSLog(@"%@",[error localizedDescription]);
}

-(void)httpRequestFinished:(ASIHTTPRequest *)request
{
	NSString *responseJSON = [[request responseString] retain];
	NSString *urlString= [[request url] absoluteString];
    int statusCode = [request responseStatusCode];
    NSString *statusMessage = [request responseStatusMessage];
    
    NSLog(@"Status Code - %d\nStatus Message - %@\nResponse:\n%@", statusCode, statusMessage, responseJSON);
    
    [responseJSON release];
    
    if([urlString hasPrefix:UsersUrl])
    {
        if(statusCode == 200)
        {
            // user created
            AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            [appDelegate addTabBarController];
        }
        else if(statusCode == 403)
        {
            // user already existing
            AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            [appDelegate addTabBarController];
            
        }
    }
}

#pragma mark - Memory Management

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    manager.delegate = nil;
    [manager release];
    
    if(twitterAccountPicker)
    {
        [twitterAccountPicker release];
        twitterAccountPicker = nil;
    }
    
    [self setFacebookButton:nil];
    [self setTwitterButton:nil];
}

- (void)dealloc
{
    [currentLoggedinUser release];
    
    if(twitterAccountPicker)
    {
        [twitterAccountPicker release];
        twitterAccountPicker = nil;
    }
    
    manager.delegate = nil;
    [manager release];
    [facebookButton release];
    [twitterButton release];
    
    [super dealloc];
}

@end