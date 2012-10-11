#import "TwitterAccountPickerController.h"
#import "TwitterUtil.h"
#import "FooBarUtils.h"

@implementation TwitterAccountPickerController

@synthesize twitterAccountsArray, twitterAccountPickerView, toolBar;

#ifdef __IPHONE_5_0
@synthesize phoneTwitterAccount;
#endif

@synthesize delegate;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    NSLog(@"TwitterAccountPickerController : viewDidLoad");
    
    [super viewDidLoad];
    
    // create the array to hold the buttons, which then gets added to the toolbar
    NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:3];
    
    // create a standard "add" button
    UIBarButtonItem* bi = [[UIBarButtonItem alloc]
                           initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    bi.style = UIBarButtonItemStyleBordered;
    [buttons addObject:bi];
    [bi release];
    
    // create a spacer
    bi = [[UIBarButtonItem alloc]
          initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [buttons addObject:bi];
    [bi release];
    
    // create a standard "refresh" button
    bi = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStyleDone target:self action:@selector(selectButtonPressed:)];
    bi.style = UIBarButtonItemStyleBordered;
    [buttons addObject:bi];
    [bi release];
    
    // stick the buttons in the toolbar
    [toolBar setItems:buttons animated:NO];
    
    [buttons release];
}

-(void)fetchTwitterAccountsAndConfigure
{
    if([FooBarUtils isDeviceOS5])
    {
#ifdef __IPHONE_5_0
		
        // clear previously saved twitter account (if any)
        NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
        [defaults setObject:nil forKey:@"PhoneTwitterAccount"];
        
        if([TWTweetComposeViewController canSendTweet])
        {
            store = [[ACAccountStore alloc] init];
            ACAccountType *twitterType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
            
            //[self showHUDwithText:@""];
			
            [store requestAccessToAccountsWithType:twitterType withCompletionHandler:^(BOOL granted, NSError *error)
             {
                 BOOL bConfigured = FALSE;
                 
                 if(granted)
                 {
                     //accessgranted
                     [self setTwitterAccountsArray : [store accountsWithAccountType:twitterType]];
                     selectedRow = 0;
                     
                     if(twitterAccountsArray != nil)
                     {
                         if(twitterAccountsArray.count >= 1)
                         {
                             [self performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
                             [twitterAccountPickerView performSelectorOnMainThread:@selector(reloadAllComponents) withObject:nil waitUntilDone:NO];
							 bConfigured = TRUE;
                         }
                         else
                         {
                             bConfigured =  FALSE;
                         }
                     }
                     else
                     {
                         bConfigured = FALSE;
                     }
                     if(!bConfigured)
                     {
                         //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ENABLE_ACCOUNTPICKER_CANCEL object:nil];
                         [FooBarUtils showAlertMessage:@"No Twitter account configured."];
                     }
                 }
				 
             }]; // if(granted)
            
            if(hud)
            {
                [hud hide:YES];
            }
        }
        else
        {
            //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ENABLE_ACCOUNTPICKER_CANCEL object:nil];
            [FooBarUtils showAlertMessage:@"No Twitter account configured."];
        }
#endif
    }
}

-(void)pickedTwitterAccount
{
#ifdef __IPHONE_5_0
    ACAccount *pickedAccount = [twitterAccountsArray objectAtIndex:0];
	[self setPhoneTwitterAccount:pickedAccount];
	
	NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
	NSLog(@"Twitter Account - %@", [phoneTwitterAccount username]);
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:phoneTwitterAccount];
	[defaults setObject:data forKey:@"PhoneTwitterAccount"];
	
	if(delegate)
	{
		if ([delegate respondsToSelector:@selector(twitterAccountSelected)])
        {
			TwitterUtil* twUtil = (TwitterUtil*)[[TwitterUtil alloc] initWithDelegate:nil];
			[twUtil setTwitterEnabled:YES];
            [twUtil setTwitterUsername:pickedAccount.username];
			[twUtil release];
			[delegate twitterAccountSelected];
		}
	}
#endif
}

-(BOOL)hasAccountWithUsername:(NSString*)username
{
    BOOL hasAccount = NO;
    
    if([TWTweetComposeViewController canSendTweet])
    {
        ACAccountStore *_store = [[ACAccountStore alloc] init];
        ACAccountType *type = [_store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        NSArray *accounts = [_store accountsWithAccountType:type];
        
        for(int i = 0; i < accounts.count; i ++)
        {
            ACAccount *pickedAccount = [accounts objectAtIndex:i];
            if([pickedAccount.username isEqualToString:username])
            {
                hasAccount = YES;
                break;
            }
        }
        
        [_store release];
    }
    
    return hasAccount;
}


//selector for donePickingButton on the picker view

- (void)selectButtonPressed:(id)sender
{
	NSLog(@"TwitterAccountPickerController : selectButtonPressed");
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ENABLE_ACCOUNTPICKER_CANCEL object: nil];
    
    if(![FooBarUtils isConnectedToInternet])
    {
        [self hide];
        [FooBarUtils showAlertMessage:@"No Network!"];
        return;
    }
    
#ifdef __IPHONE_5_0
    
    selectedRow = [twitterAccountPickerView selectedRowInComponent:0];
    
    if(selectedRow < twitterAccountsArray.count)
    {
        [self setPhoneTwitterAccount:[twitterAccountsArray objectAtIndex:selectedRow]];
        
        NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
        NSLog(@"Twitter Account - %@", [phoneTwitterAccount username]);
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:phoneTwitterAccount];
        [defaults setObject:data forKey:@"PhoneTwitterAccount"];
        
        if(delegate)
        {
            if([delegate respondsToSelector:@selector(twitterAccountSelected)])
            {
                TwitterUtil* twUtil = (TwitterUtil*)[[TwitterUtil alloc] initWithDelegate:nil];
                [twUtil setTwitterEnabled:YES];
                [twUtil setTwitterUsername:phoneTwitterAccount.username];
                [twUtil release];
                [delegate twitterAccountSelected];
            }
        }
        [self hide];
    }
    else
    {
        [FooBarUtils showAlertMessage:@"Please select a Twitter Account."];
    }
    
#endif
}

- (void) cancelButtonPressed:(id)sender
{
    NSLog(@"TwitterAccountPickerController : cancelButtonPressed");
    
    if(delegate && [delegate respondsToSelector:@selector(twitterPickerCancelled)])
    {
        [delegate twitterAccountCancelled];
    }
    [self hide];
}

-(void)show
{
    NSLog(@"TwitterAccountPickerController : show");
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    CGFloat yPos = self.view.frame.origin.y;
    [self.view setFrame:CGRectMake(0, yPos-260, 320, 260)];
    [UIView commitAnimations];
    
}

-(void)hide
{
    NSLog(@"TwitterAccountPickerController : hide");
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    CGFloat yPos = self.view.frame.origin.y;
    [self.view setFrame:CGRectMake(0, yPos+260, 320, 260)];
    [UIView commitAnimations];
}

#pragma mark -
#pragma mark UIPickerView data source functions
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
	NSLog(@"TwitterAccountPickerController : numberOfComponentsInPickerView");
	return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
	
	NSLog(@"TwitterAccountPickerController : numberOfRowsInComponent");
    if(twitterAccountsArray)
    {
        return [twitterAccountsArray count];
    }
	return 1;
}

#pragma mark -
#pragma mark UIPickerView delegate functions
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSLog(@"TwitterAccountPickerController : pickerView titleForRow");
    NSString *twitterAccount = @"";
    if(twitterAccountsArray)
    {
#ifdef __IPHONE_5_0
		ACAccount* account = [twitterAccountsArray objectAtIndex:row];
        twitterAccount =  [account username];
#endif
    }
    else
        twitterAccount = @"";
	
	return twitterAccount;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
	
	NSLog(@"TwitterAccountPickerController : pickerView didSelectRow");
    
    selectedRow = row;
}

#pragma mark -
#pragma mark Hud Related Methods

-(void)showHUDwithText:(NSString *)text{
	NSLog(@"InviteFriendsTableViewController: showHUDwithText");
	if(!hud)
	{
		UIWindow *window = [UIApplication sharedApplication].keyWindow;
		hud = [[SAProgressHUD alloc] initWithWindow:window];
		// Add HUD to screen
		[window addSubview:hud];
		
		// Regisete for HUD callbacks so we can remove it from the window at the right time
		hud.delegate = self;
		
		// Show the HUD while the provided method executes in a new thread
		[hud show:YES];
		hud.labelText = text;
	}
}

#pragma mark -
#pragma mark SAProgressHUD delegate function
- (void)hudWasHidden
{
	NSLog(@"TwitterAccountPickerController: hudWasHidden");
	// Remove HUD from screen when the HUD was hidded
	if(hud)
	{
        hud.delegate = nil;
		[hud removeFromSuperview];
		[hud release];
		hud = nil;
	}
}

#pragma mark -
#pragma mark Auto Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark memory Management
-(void)dealloc
{
    NSLog(@"TwitterAccountPickerController : dealloc");
    
    if(hud)
	{
        hud.delegate = nil;
		[hud removeFromSuperview];
		[hud release];
		hud = nil;
	}
    
    self.delegate = nil;
    
	[twitterAccountsArray release];
#ifdef __IPHONE_5_0
	
	[phoneTwitterAccount release];
    [store release];
	
#endif
    
    [twitterAccountPickerView release];
    [toolBar release];
    
    [super dealloc];
}

@end
