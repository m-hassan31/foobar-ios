#import "CustomTabBarController.h"
#import "FooBarUtils.h"
#import "FooBarConstants.h"
#import "ProfileViewController.h"
#import "StreamViewController.h"
#import "CaptureViewController.h"

@interface CustomTabBarController()
{
    NSInteger lastSelectedIndex;
}
-(void)hideTab;
-(void)showTab;
@end

@implementation CustomTabBarController

- (void)viewDidLoad
{
    NSLog(@"CustomTabBarController viewDidLoad");
    
    [super viewDidLoad];
    [self setDelegate:self];
    [self hideTab];
    [self addCustomElements];
}

// Method implementations
- (void)hideTab
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    
    for(UIView *view in self.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            [view setFrame:CGRectMake(view.frame.origin.x, 480, view.frame.size.width, view.frame.size.height)];
        } 
        else 
        {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 480)];
        }
    }
    
    [UIView commitAnimations];   
}

- (void)showTab
{       
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    for(UIView *view in self.view.subviews)
    {
        NSLog(@"%@", view);
        
        if([view isKindOfClass:[UITabBar class]])
        {
            [view setFrame:CGRectMake(view.frame.origin.x, 431, view.frame.size.width, view.frame.size.height)];
            
        } 
        else 
        {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 431)];
        }
    }
    
    [UIView commitAnimations]; 
}

-(void) hideTabBar
{
    tabBarBG.hidden = YES;
    profileTabButton.hidden = YES;
    captureTabButton.hidden = YES;
    streamTabButton.hidden = YES;
}

-(void) showTabBar
{
    tabBarBG.hidden = NO;
    profileTabButton.hidden = NO;
    captureTabButton.hidden = NO;
    streamTabButton.hidden = NO;    
}

-(void)initViewControllers
{
    UIImage *navBarBG = [UIImage imageNamed:@"TopBar.png"];
    
    ProfileViewController *profileViewController  = [[ProfileViewController alloc]init];
    UINavigationController *profileNavController = [[UINavigationController alloc]initWithRootViewController:profileViewController];
    if([FooBarUtils isDeviceOS5])
    {
        [profileNavController.navigationBar setBackgroundImage:navBarBG
                                                 forBarMetrics:UIBarMetricsDefault];
    }
    profileNavController.navigationBarHidden = YES;
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
    streamNavController.navigationBarHidden = YES;
    streamNavController.navigationBar.barStyle = UIBarStyleBlack;
    [streamViewController release];
    
    NSMutableArray *viewControllersArray = [[NSMutableArray alloc] init];
    
    [viewControllersArray addObject: profileNavController];
    [viewControllersArray addObject: captureNavController];
    [viewControllersArray addObject: streamNavController];
    
    [profileNavController release];
    [captureNavController release];
    [streamNavController release];
    
    [self setViewControllers:viewControllersArray animated:NO];
    [viewControllersArray release];
    [self setSelectedIndex:2];
    
    navBarBG = nil;
}

-(void)addCustomElements
{
    tabBarBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 430, 320, 50)];
    tabBarBG.image = [UIImage imageNamed:@"BottomBar.png"];
    [self.view addSubview:tabBarBG];
    [tabBarBG release];
    
    profileTabButton = [UIButton buttonWithType:UIButtonTypeCustom];
	profileTabButton.frame = CGRectMake(9, 437, 28, 37);
	[profileTabButton setImage:[UIImage imageNamed:@"Profile.png"] forState:UIControlStateNormal];
	[profileTabButton setImage:[UIImage imageNamed:@"Profile.png"] forState:UIControlStateSelected];
	[profileTabButton setTag:PROFILE_TAB];
	[profileTabButton setSelected:true];
    
    captureTabButton = [UIButton buttonWithType:UIButtonTypeCustom];
	captureTabButton.frame = CGRectMake(141, 441, 39, 28);
	[captureTabButton setImage:[UIImage imageNamed:@"Camera.png"] forState:UIControlStateNormal];
	[captureTabButton setImage:[UIImage imageNamed:@"Camera.png"] forState:UIControlStateSelected];
	[captureTabButton setTag:CAPTURE_TAB];
	[captureTabButton setSelected:true];
    
    streamTabButton = [UIButton buttonWithType:UIButtonTypeCustom];
	streamTabButton.frame = CGRectMake(266, 441, 45, 28);
	[streamTabButton setImage:[UIImage imageNamed:@"Gallery.png"] forState:UIControlStateNormal];
	[streamTabButton setImage:[UIImage imageNamed:@"Gallery.png"] forState:UIControlStateSelected];
	[streamTabButton setTag:STREAM_TAB];
	[streamTabButton setSelected:true];
	
	[self.view addSubview:profileTabButton];
	[self.view addSubview:captureTabButton];
	[self.view addSubview:streamTabButton];
	
	[profileTabButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[captureTabButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[streamTabButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)buttonClicked:(id)sender
{
	int tagNum = [sender tag];
    [self selectTab:tagNum];
}

-(void) selectLastTab
{
    [self selectTab:lastSelectedIndex];
}

- (void)selectTab:(int)tabIndex
{   
    // hide tab during camera capture
    (tabIndex == CAPTURE_TAB)?[self hideTabBar]:[self showTabBar];
    
    lastSelectedIndex = tabIndex;
    
    [profileTabButton setSelected:(tabIndex==PROFILE_TAB)];
    [captureTabButton setSelected:(tabIndex==CAPTURE_TAB)];    
    [streamTabButton setSelected:(tabIndex==STREAM_TAB)];
    
	[self setSelectedIndex:tabIndex];
}

#pragma mark - Memory Management

-(void)didReceiveMemoryWarning
{    
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{    
    [super viewDidUnload];
}

-(void) dealloc
{   
    [super dealloc];
}

@end