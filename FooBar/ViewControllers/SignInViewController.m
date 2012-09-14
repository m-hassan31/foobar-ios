#import "SignInViewController.h"
#import "StreamViewController.h"
#import "AppDelegate.h"
#import "FooBarUtils.h"
#import <QuartzCore/QuartzCore.h>

@interface SignInViewController()

-(IBAction)facebookButtonPressed:(id)sender;
-(IBAction)twitterButtonPressed:(id)sender;
-(IBAction)signInButtonPressed:(id)sender;
-(IBAction)forgotPasswordButtonPressed:(id)sender;

-(void)moveControlsUp;
-(void)moveControlsDown;

@end

@implementation SignInViewController

@synthesize facebookButton;
@synthesize twitterButton;
@synthesize orImage;
@synthesize emailTextField;
@synthesize passwordTextField;
@synthesize signInButton;
@synthesize forgotPasswordButton;

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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void)keyboardWillShow
{
    [self moveControlsUp];
}

-(void)keyboardWillHide
{
    [self moveControlsDown];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Button Actions

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
        [manager loginWithUsername:@"108306655859825" withPassword:facebookUtil.facebook.accessToken];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Facebook"
                              message: @"Sorry Login failed. Please retry."
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

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
    NSLog(@"SignupViewController: twitterAccountSelected");
    
    /*if(twitterUtil) 
     {
     [self showHUDwithText:@""];
     NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
     [twitterUtil getTwitterInfo:[defaults objectForKey:kTwitterUsername]];
     }*/
    [manager loginWithUsername:@"108306655859825" withPassword:facebookUtil.facebook.accessToken];    
}

-(IBAction)signInButtonPressed:(id)sender
{
    if(emailTextField.text.length == 0)
    {
        [FooBarUtils showAlertMessage:@"Check you Email!"];
        return;
    }
    else if(![FooBarUtils isEmailFormatValid:emailTextField.text])
    {
        [FooBarUtils showAlertMessage:@"Email not valid!"];
        return;
    }
    else if(passwordTextField.text.length == 0)
    {
        [FooBarUtils showAlertMessage:@"Check you Password!"];
        return;
    }
    else
    {
        // continue with login
    }
    
    [self.view endEditing:YES];
    [manager loginWithUsername:emailTextField.text withPassword:passwordTextField.text];
    [emailTextField setText:@""];
    [passwordTextField setText:@""];
}

-(IBAction)forgotPasswordButtonPressed:(id)sender
{
    
}

-(void)moveControlsUp
{
    [UIView animateWithDuration:0.25 
                     animations:^{
                         facebookButton.alpha = 0;
                         twitterButton.alpha = 0;
                         orImage.alpha = 0;
                         
                         facebookButton.transform = CGAffineTransformMakeScale(0.8, 0.8);
                         twitterButton.transform = CGAffineTransformMakeScale(0.8, 0.8);
                         orImage.transform = CGAffineTransformMakeScale(0.8, 0.8);                   
                     }];
    
    
    [UIView animateWithDuration:0.25
                          delay:0.06
                        options:UIViewAnimationOptionAllowAnimatedContent
                     animations:^{
                         emailTextField.frame = CGRectOffset(emailTextField.frame, 0, -155);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.15 
                                          animations:^{
                                              emailTextField.frame = CGRectOffset(emailTextField.frame, 0, 5);
                                          }];
                     }];
    
    [UIView animateWithDuration:0.25
                          delay:0.12
                        options:UIViewAnimationOptionAllowAnimatedContent
                     animations:^{
                         passwordTextField.frame = CGRectOffset(passwordTextField.frame, 0, -155);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.15 
                                          animations:^{
                                              passwordTextField.frame = CGRectOffset(passwordTextField.frame, 0, 5);
                                          }];
                     }];
    
    [UIView animateWithDuration:0.25
                          delay:0.18
                        options:UIViewAnimationOptionAllowAnimatedContent
                     animations:^{
                         signInButton.frame = CGRectOffset(signInButton.frame, 0, -155);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.15 
                                          animations:^{
                                              signInButton.frame = CGRectOffset(signInButton.frame, 0, 5);
                                          }];
                     }];
    
    [UIView animateWithDuration:0.25
                          delay:0.24
                        options:UIViewAnimationOptionAllowAnimatedContent
                     animations:^{
                         forgotPasswordButton.frame = CGRectOffset(forgotPasswordButton.frame, 0, -155);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.15 
                                          animations:^{
                                              forgotPasswordButton.frame = CGRectOffset(forgotPasswordButton.frame, 0, 5);
                                          }];
                     }];
}

-(void)moveControlsDown
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         forgotPasswordButton.frame = CGRectOffset(forgotPasswordButton.frame, 0, 155);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.15 
                                          animations:^{
                                              forgotPasswordButton.frame = CGRectOffset(forgotPasswordButton.frame, 0, -5);
                                          }];
                     }];
    
    [UIView animateWithDuration:0.25
                          delay:0.06
                        options:UIViewAnimationOptionAllowAnimatedContent
                     animations:^{
                         signInButton.frame = CGRectOffset(signInButton.frame, 0, 155);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.15 
                                          animations:^{
                                              signInButton.frame = CGRectOffset(signInButton.frame, 0, -5);
                                          }];
                     }];
    
    [UIView animateWithDuration:0.25
                          delay:0.12
                        options:UIViewAnimationOptionAllowAnimatedContent
                     animations:^{
                         passwordTextField.frame = CGRectOffset(passwordTextField.frame, 0, 155);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.15 
                                          animations:^{
                                              passwordTextField.frame = CGRectOffset(passwordTextField.frame, 0, -5);
                                          }];
                     }];
    
    [UIView animateWithDuration:0.25
                          delay:0.18
                        options:UIViewAnimationOptionAllowAnimatedContent
                     animations:^{
                         emailTextField.frame = CGRectOffset(emailTextField.frame, 0, 155);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.15 
                                          animations:^{
                                              emailTextField.frame = CGRectOffset(emailTextField.frame, 0, -5);
                                          }];
                     }];
    
    [UIView animateWithDuration:0.25
                          delay:0.18
                        options:UIViewAnimationOptionAllowAnimatedContent
                     animations:^{
                         facebookButton.alpha = 1.0f;
                         twitterButton.alpha = 1.0f;
                         orImage.alpha = 1.0f;
                         
                         facebookButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         twitterButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         orImage.transform = CGAffineTransformMakeScale(1.0, 1.0);                   
                     } completion:^(BOOL finished) {
                     }];
}

#pragma mark - TextField delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{	
    [textField resignFirstResponder];
	return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if(textField.text.length > 0)
    {
        textField.font = [UIFont systemFontOfSize:14.0f];
    }
    else
    {
        textField.font = [UIFont italicSystemFontOfSize:14.0f];
    }
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField.text.length > 0)
    {
        textField.font = [UIFont systemFontOfSize:14.0f];
    }
    else
    {
        textField.font = [UIFont italicSystemFontOfSize:14.0f];
    }
    
    return YES;
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
	//NSString *urlString= [[request url] absoluteString];
    int statusCode = [request responseStatusCode];
    NSString *statusMessage = [request responseStatusMessage];
    
    NSLog(@"Status Code - %d\nStatus Message - %@\nResponse:\n%@", statusCode, statusMessage, responseJSON);
    
    [responseJSON release];
    
    if(statusCode == 200)
    {
        [self.view endEditing:YES];        
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate addTabBarController];
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
    [self setOrImage:nil];
    [self setEmailTextField:nil];
    [self setPasswordTextField:nil];
    [self setSignInButton:nil];
    [self setForgotPasswordButton:nil];
}

- (void)dealloc 
{
    if(twitterAccountPicker)
    {
        [twitterAccountPicker release];
        twitterAccountPicker = nil;
    }
    
    manager.delegate = nil;
    [manager release];
    [facebookButton release];
    [twitterButton release];
    [orImage release];
    [emailTextField release];
    [passwordTextField release];
    [signInButton release];
    [forgotPasswordButton release];
    
    [super dealloc];
}

@end