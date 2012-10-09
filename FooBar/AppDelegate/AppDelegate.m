#import "AppDelegate.h"
#import "SignInViewController.h"
#import "CustomTabBarController.h"
#import "FooBarUtils.h"
#import "ProfileViewController.h"
#import "StreamViewController.h"
#import "CaptureViewController.h"
#import "SocialUser.h"

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
    if(socialUser)
    {
        [self addTabBarController];        
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
    if([FooBarUtils isDeviceOS5])
    {
        [navController.navigationBar setBackgroundImage:[UIImage imageNamed:@"TopBar.png"]
                                                 forBarMetrics:UIBarMetricsDefault];
    }
    [signInVC release];
    self.signInNavController = navController;
    [navController release];
    
    //self.window.rootViewController = signInViewController;
    [self.window addSubview:self.signInNavController.view];
    
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
    if([FooBarUtils isDeviceOS5])
    {
        [profileNavController.navigationBar setBackgroundImage:navBarBG
                                                 forBarMetrics:UIBarMetricsDefault];
    }
    profileNavController.navigationBar.barStyle = UIBarStyleBlack;
    [profileViewController release];
    
    CaptureViewController *captureViewController  = [[CaptureViewController alloc]init];
    UINavigationController *captureNavController = [[UINavigationController alloc]initWithRootViewController:captureViewController];
    if([FooBarUtils isDeviceOS5])
    {
        [captureNavController.navigationBar setBackgroundImage:navBarBG
                                                 forBarMetrics:UIBarMetricsDefault];
    }
    captureNavController.navigationBarHidden = YES;
    captureNavController.navigationBar.barStyle = UIBarStyleBlack;
    [captureViewController release];
    
    StreamViewController *streamViewController  = [[StreamViewController alloc]init];
    UINavigationController *streamNavController = [[UINavigationController alloc]initWithRootViewController:streamViewController];
    if([FooBarUtils isDeviceOS5])
    {
        [streamNavController.navigationBar setBackgroundImage:navBarBG
                                                forBarMetrics:UIBarMetricsDefault];
    }
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
    
    //self.window.rootViewController = signInViewController;
    [self.window addSubview:self.tabBarController.view];
    
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
    NSLog(@"AppDelegate: isGonnaBeInlineLogin");
    
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
    NSLog(@"AppDelegate: parseURLParams");
    
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
