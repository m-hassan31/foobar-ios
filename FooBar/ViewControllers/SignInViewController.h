//
//  SignInViewController.h
//  FooBar
//
//  Created by Pramati technologies on 8/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FacebookUtil.h"
#import "ConnectionManager.h"
#import "TwitterAccountPickerController.h"

@interface SignInViewController : UIViewController
<UITextFieldDelegate, FacebookUtilDelegate, ConnectionManagerDelegate, TwitterAccountPickerDelegate>
{
    FacebookUtil *facebookUtil;
    TwitterAccountPickerController* twitterAccountPicker;
    ConnectionManager *manager;
}

@property (retain, nonatomic) IBOutlet UIButton *facebookButton;
@property (retain, nonatomic) IBOutlet UIButton *twitterButton;
@property (retain, nonatomic) IBOutlet UILabel *orLabel;
@property (retain, nonatomic) IBOutlet UITextField *emailTextField;
@property (retain, nonatomic) IBOutlet UITextField *passwordTextField;
@property (retain, nonatomic) IBOutlet UIButton *signInButton;
@property (retain, nonatomic) IBOutlet UIButton *forgotPasswordButton;

@end
