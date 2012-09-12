#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface CustomTabBarController : UITabBarController<UITabBarControllerDelegate>
{
    UIImageView *tabBarBG;
    UIButton *profileTabButton;
	UIButton *captureTabButton;
	UIButton *streamTabButton;
}

-(void) initViewControllers;
-(void) addCustomElements;
-(void) selectTab:(int)tabIndex;
-(void) hideTabBar;
-(void) showTabBar;
-(void) selectLastTab;

@end
