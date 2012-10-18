#import <UIKit/UIKit.h>
#import "FooBarBackground.h"

@class CustomTabBarController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) FooBarBackground *window;
@property (strong, nonatomic) UINavigationController *signInNavController;
@property (strong, nonatomic) CustomTabBarController *tabBarController;

-(void)addSignInViewController;
-(void)removeSignInViewController;
-(void)addTabBarController;
-(void)removeTabBarController;
-(void)cleanDefaultsAndShowSignInPage;

@end
