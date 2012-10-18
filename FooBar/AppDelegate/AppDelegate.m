#import "AppDelegate.h"
#import "SignInViewController.h"
#import "CustomTabBarController.h"
#import "FooBarUtils.h"
#import "ProfileViewController.h"
#import "StreamViewController.h"
#import "CaptureViewController.h"
#import "SocialUser.h"
#import "FooBarConstants.h"
#import "FacebookUtil.h"

@interface AppDelegate()
- (NSDictionary*) parseURLParams:(NSString *)query;
- (BOOL) isValidFBAccessTokenReceived:(NSURL *)url;
@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize signInNavController = _signInNavController;
@synthesize tabBarController = _tabBarController;

- (void)dealloc
{
    [_window release];
    [_signInNavController release];
    [_tabBarController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[FooBarBackground alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    
    SocialUser *socialUser = [SocialUser currentUser];
    if(socialUser && [socialUser authenticated])
    {
        // check if the configured twitter account still exists in iOS 5 Settings
        if(socialUser.socialAccountType == TwitterAccount)
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
                                    if ([anAccount.username isEqualToString:previousUserName] )
                                    {
                                        account = anAccount;
                                        break;
                                    }
                                }
                            }
                            //previous account was deleted if a userName match was not found
                            //show the picker or just pick the first account.
                            if (account == nil)
                            {
                                [self performSelectorOnMainThread:@selector(cleanDefaultsAndShowSignInPage) withObject:nil waitUntilDone:NO];
                            }
                            else
                            {
                                // twitter account still exists.. continue with feeds
                                [self addTabBarController];
                            }
                        }
                    }
                }];
            }
            else
            {
                // no twitter accounts available
                [self cleanDefaultsAndShowSignInPage];
            }
        }
        else if(socialUser.socialAccountType == FacebookAccount)
        {
            NSDate *fbExpDate = [FacebookUtil fbExpirationDate];
            if(NSOrderedDescending == [fbExpDate compare:[NSDate date]])
            {
                [self addTabBarController];
            }
            else
            {
                // facebook access token is expired ..
                [self cleanDefaultsAndShowSignInPage];
            }
        }
        else
        {
            [self addTabBarController];
        }
    }
    else
    {
        [self addSignInViewController];
    }
    
    [self.window makeKeyAndVisible];
    return YES;
}

-(void)addSignInViewController
{
    SignInViewController *signInVC = [[SignInViewController alloc] initWithNibName:@"SignInViewController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:signInVC];
    [navController.navigationBar setBackgroundImage:[UIImage imageNamed:@"TopBar.png"]
                                      forBarMetrics:UIBarMetricsDefault];
    [signInVC release];
    self.signInNavController = navController;
    [navController release];
    
    self.signInNavController.view.alpha = 0;
    [self.window addSubview:self.signInNavController.view];
    
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1.0];
    self.signInNavController.view.alpha = 1.0;
    [UIView commitAnimations];
    
    [self removeTabBarController];
}

-(void)removeSignInViewController
{
    [_signInNavController.view removeFromSuperview];
    [_signInNavController release];
    _signInNavController = nil;
}

-(void)addTabBarController
{
    CustomTabBarController *customTabBarController = [[CustomTabBarController alloc] init];
    UIImage *navBarBG = [UIImage imageNamed:@"TopBar.png"];
    
    ProfileViewController *profileViewController  = [[ProfileViewController alloc]init];
    UINavigationController *profileNavController = [[UINavigationController alloc]initWithRootViewController:profileViewController];
    [profileNavController.navigationBar setBackgroundImage:navBarBG
                                             forBarMetrics:UIBarMetricsDefault];
    profileNavController.navigationBar.barStyle = UIBarStyleBlack;
    [profileViewController release];
    
    CaptureViewController *captureViewController  = [[CaptureViewController alloc]init];
    UINavigationController *captureNavController = [[UINavigationController alloc]initWithRootViewController:captureViewController];
    [captureNavController.navigationBar setBackgroundImage:navBarBG
                                             forBarMetrics:UIBarMetricsDefault];
    captureNavController.navigationBarHidden = YES;
    captureNavController.navigationBar.barStyle = UIBarStyleBlack;
    [captureViewController release];
    
    StreamViewController *streamViewController  = [[StreamViewController alloc]init];
    UINavigationController *streamNavController = [[UINavigationController alloc]initWithRootViewController:streamViewController];
    [streamNavController.navigationBar setBackgroundImage:navBarBG
                                            forBarMetrics:UIBarMetricsDefault];
    streamNavController.navigationBar.barStyle = UIBarStyleBlack;
    [streamViewController release];
    
    NSMutableArray *viewControllersArray = [[NSMutableArray alloc] init];
    
    [viewControllersArray addObject: profileNavController];
    [viewControllersArray addObject: captureNavController];
    [viewControllersArray addObject: streamNavController];
    
    [profileNavController release];
    [captureNavController release];
    [streamNavController release];
    
    [customTabBarController setViewControllers:viewControllersArray animated:NO];
    [viewControllersArray release];
    [customTabBarController setSelectedIndex:2];
    
    navBarBG = nil;
    
    self.tabBarController = customTabBarController;
    [customTabBarController release];
    
    self.tabBarController.view.alpha = 0;
    [self.window addSubview:self.tabBarController.view];
    
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1.0];
    self.tabBarController.view.alpha = 1.0;
    [UIView commitAnimations];
    
    [self removeSignInViewController];
}

-(void)removeTabBarController
{
    [_tabBarController.view removeFromSuperview];
    [_tabBarController release];
    _tabBarController = nil;
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    FacebookUtil *fbUtil = [FacebookUtil getSharedFacebookUtil];
    
    if([self isValidFBAccessTokenReceived:url])
        return [fbUtil handleOpenURL:url];
    else
    {
        [fbUtil logout:self];
        return YES;
    }
}

-(BOOL) isValidFBAccessTokenReceived:(NSURL *)url
{    
    NSString *query = [url fragment];
    
    // Version 3.2.3 of the Facebook app encodes the parameters in the query but
    // version 3.3 and above encode the parameters in the fragment. To support
    // both versions of the Facebook app, we try to parse the query if
    // the fragment is missing.
    
    if(!query)
        query = [url query];
    
    NSDictionary *params = [self parseURLParams:query];
    NSString *accessToken = [params valueForKey:@"access_token"];
    
    // If the URL doesn't contain the access token, an error has occurred.
    if(!accessToken)
    {
        NSString *errorReason = [params valueForKey:@"error"];
        
        // If the error response indicates that we should try the authorization flow
        // in an inline dialog, return true.
        
        if(errorReason && [errorReason isEqualToString:@"service_disabled"])
            return NO;
    }
    return YES;
}

/**
 * A function for parsing URL parameters.
 */

-(NSDictionary*)parseURLParams:(NSString *)query
{
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
	NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
    
	for(NSString *pair in pairs)
    {
		NSArray *kv = [pair componentsSeparatedByString:@"="];
		NSString *val =
        [[kv objectAtIndex:1]
         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		[params setObject:val forKey:[kv objectAtIndex:0]];
	}
    
    return params;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    
    SocialUser *socialUser = [SocialUser currentUser];
    if(socialUser && [socialUser authenticated])
    {
        // check if the configured twitter account still exists in iOS 5 Settings
        if(socialUser.socialAccountType == TwitterAccount)
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
                                    if ([anAccount.username isEqualToString:previousUserName] )
                                    {
                                        account = anAccount;
                                        break;
                                    }
                                }
                            }
                            //previous account was deleted if a userName match was not found
                            //show the picker or just pick the first account.
                            if (account == nil)
                            {
                                [self performSelectorOnMainThread:@selector(cleanDefaultsAndShowSignInPage) withObject:nil waitUntilDone:NO];
                            }
                        }
                    }
                }];
            }
            else
            {
                // no twitter accounts available
                [self cleanDefaultsAndShowSignInPage];
            }
        }
        else if(socialUser.socialAccountType == FacebookAccount)
        {
            NSDate *fbExpDate = [FacebookUtil fbExpirationDate];
            if(NSOrderedDescending != [fbExpDate compare:[NSDate date]])
            {
                // facebook access token is expired ..
                [self cleanDefaultsAndShowSignInPage];
            }
        }
    }
}

-(void)cleanDefaultsAndShowSignInPage
{
    // clear tokens and defaults cache
    [FooBarUser clearCurrentUser];
    [SocialUser clearCurrentUser];
    // show signin view controller again
    [self addSignInViewController];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
