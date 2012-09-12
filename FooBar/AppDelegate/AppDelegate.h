//
//  AppDelegate.h
//  FooBar
//
//  Created by Pramati technologies on 8/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomTabBarController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *signInNavController;
@property (strong, nonatomic) CustomTabBarController *tabBarController;

-(void)addSignInViewController;
-(void)removeSignInViewController;
-(void)addTabBarController;
-(void)removeTabBarController;

@end
