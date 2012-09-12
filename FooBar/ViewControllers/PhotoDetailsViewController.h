//
//  PhotoDetailsViewController.h
//  FooBar
//
//  Created by Pramati technologies on 9/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoDetailsViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIView *likeHolderView;
@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@property (retain, nonatomic) UIImage *image;
@property (retain, nonatomic) IBOutlet UIView *userInfoHolderView;
@property (retain, nonatomic) IBOutlet UIImageView *profilePicView;
@property (retain, nonatomic) IBOutlet UILabel *usernameLabel;
@property (retain, nonatomic) IBOutlet UILabel *commentsCountLabel;
@property (retain, nonatomic) IBOutlet UITableView *commentsTableView;
@property (retain, nonatomic) IBOutlet UIView *commentFieldHolder;
@property (retain, nonatomic) IBOutlet UIImageView *commentProfilePicView;
@property (retain, nonatomic) IBOutlet UITextField *commentField;
@end
