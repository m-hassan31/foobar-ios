#import "ShareViewController.h"
#import "FooBarUtils.h"
#import "EndPointsKeys.h"
#import "CustomCellBGView.h"
#import "SocialUser.h"
#import "FooBarConstants.h"
#import "PlaceHolderTextView.h"
#import <QuartzCore/QuartzCore.h>

#define FB_ACTION_SHEET              1001
#define TW_ACTION_SHEET              1002

@interface ShareViewController()
{
    BOOL fbShareResposeRecieved;
    BOOL twitterShareResponseReceived;
    
    UITextView *captionTextViewPointer;
    UISwitch *facebookSwitch;
    UISwitch *twitterSwitch;
}

- (void) sharePhoto;
- (void) shareOnFaceBook;
- (void) shareOnTwitter;
- (void) handleShareResponses;
- (void) dismiss;

-(void)showHUDwithText:(NSString*)text;
-(void)hideHud;

@end

@implementation ShareViewController
@synthesize shareTableView, captionText, feedObject, image;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    
    shareTableView.separatorColor = [UIColor colorWithRed:238.0/255.0 green:225.0/255.0 blue:123.0/255.0 alpha:1.0];
    
    UIButton *backButton = [FooBarUtils backButton];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside ];
    
    UIBarButtonItem * customLeftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = customLeftBarButtonItem;
    [customLeftBarButtonItem release];
    
    twitterUtil= (TwitterUtil*)[[TwitterUtil alloc] initWithDelegate:self];
    facebookUtil = [FacebookUtil getSharedFacebookUtil];
}

-(void)backButtonPressed:(id)sender 
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)shareButtonPresed:(id)sender
{
    if(captionTextViewPointer)
        [captionTextViewPointer resignFirstResponder];
    
    [self sharePhoto];
}

#pragma mark -
#pragma mark Button actions

- (void)sharePhoto
{    
    NSString* checkString = [self.captionText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
	if ([checkString isEqualToString:@""] || checkString == nil ) 
	{
        [FooBarUtils showAlertMessage:@"Please enter your message"];
        if(captionTextViewPointer)
            [captionTextViewPointer setText:@""];
	}	
	else
	{	
        if(facebookSwitch.isOn || twitterSwitch.isOn)
        {
            [self showHUDwithText:@"Sharing"]; 
            
            if(facebookSwitch.isOn)
                [self shareOnFaceBook];
            
            if(twitterSwitch.isOn)
                [self shareOnTwitter];	
            
            if(captionTextViewPointer)
                [captionTextViewPointer resignFirstResponder];            
        }
        else
            [FooBarUtils showAlertMessage:@"Configure/Turn-On Share options."];        
	}
}

#pragma mark -
#pragma mark Facebook Sharing

- (void) shareOnFaceBook
{    
	if([facebookUtil  isFacebookConfigured] && [facebookUtil isFacebookSessionValid] /*Facebook is configured*/)
	{   
        NSString *shareText = captionTextViewPointer.text;           
        NSString *trimmedText = [shareText stringByTrimmingCharactersInSet:
                                 [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if([trimmedText isEqualToString:@""])
        {
            shareText = @"Check out this photo";
        }
        
        NSString *fbMsg = ([shareText isEqualToString:@""]) ? @"Check out this photo" : shareText;
        
        [facebookUtil sharePhotoOnFacebook:feedObject.foobarPhoto.url
                           previewImageURL:@""
                                 withTitle:@"FooBar" 
                           withDescription:fbMsg
                              fromDelegate:self];
	}
	else 
	{
		[FooBarUtils showAlertMessage:@"Please Configure Facebook"];
    }
}

#pragma mark -
#pragma mark Twitter Sharing

- (void) shareOnTwitter
{    	
	if([twitterUtil isTwitterConfigured])
	{		
        NSString *shareText = captionTextViewPointer.text;          
        NSString *trimmedText = [shareText stringByTrimmingCharactersInSet:
                                 [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if([trimmedText isEqualToString:@""])
        {
            shareText = @"Check out this #FooBar photo";
        }
        NSString *tweetMsg = ([shareText isEqualToString:@""]) ? @"Check out this #FooBar photo" : shareText;
        NSString* tweet = [NSString stringWithFormat:@"%@ %@", tweetMsg, feedObject.foobarPhoto.url]; 
		[twitterUtil sendUpdate:tweet];
	}
	else
	{
		[FooBarUtils showAlertMessage:@"Please Configure Twitter"];
	}
}

#pragma mark -
#pragma mark  tableView delegate functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if((indexPath.section == 0) && (indexPath.row == 0))
        return 75.0;
    else
        return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Share Cell";
        
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    
    if((indexPath.section == 0) && (indexPath.row == 0))
    {
        UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        
        //Caption text View         
        PlaceHolderTextView *captionTextView = [[PlaceHolderTextView alloc] initWithFrame:CGRectMake(10, 5, 280, 65)];
        captionTextView.backgroundColor = [UIColor clearColor];
        captionTextView.layer.cornerRadius = 7.0f;
        [captionTextView setFont:[UIFont systemFontOfSize:14.0]];
        captionTextView.placeholder = @"Add your message..";
        captionTextView.placeholderColor = [UIColor darkGrayColor];
        captionTextView.delegate = self;
        captionTextView.returnKeyType = UIReturnKeyDone;
        [cell.contentView addSubview:captionTextView];
        
        captionTextViewPointer = captionTextView;
        
        [captionTextView release];        
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    else
    {
        switch([indexPath row])
        {
            case 1:
            {
                cell.textLabel.text = @"Facebook";
                
                if([facebookUtil isFacebookConfigured])
                {
                    UISwitch *toggleSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(215, 8, 79, 27)];
                    [toggleSwitch setOn:YES];
                    [cell.contentView addSubview:toggleSwitch];        
                    
                    facebookSwitch = toggleSwitch;
                    
                    [toggleSwitch release];
                    
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    
                    SocialUser *socialUser = [SocialUser currentUser];
                    if(socialUser.socialAccountType == FacebookAccount)
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    else
                        cell.selectionStyle = UITableViewCellSelectionStyleGray;
                }
                else
                {
                    UILabel *configureLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, 190, 44)];
                    configureLabel.font = [UIFont systemFontOfSize:16.0f];
                    configureLabel.backgroundColor = [UIColor clearColor];
                    configureLabel.textAlignment = UITextAlignmentRight;
                    configureLabel.textColor = [UIColor colorWithRed:48.0/255.0 green:78.0/255.0 blue:107.0/255.0 alpha:1.0];
                    configureLabel.highlightedTextColor = [UIColor whiteColor];
                    configureLabel.text = @"Configure";
                    [cell.contentView addSubview:configureLabel];
                    [configureLabel release];
                    
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                
                CustomCellBGView *cellSelectionView =
                [[[CustomCellBGView alloc] initSelected:YES grouped:YES] autorelease];
                cell.selectedBackgroundView = cellSelectionView;
                
                CustomCellGroupPosition position = [CustomCellBGView positionForIndexPath:indexPath inTableView:shareTableView];
                ((CustomCellBGView *)cell.selectedBackgroundView).position = position;
            }
                break;
                
            case 2:
            {
                cell.textLabel.text = @"Twitter";
                
                if([twitterUtil isTwitterConfigured])
                {
                    UISwitch *toggleSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(215, 8, 79, 27)];
                    [toggleSwitch setOn:YES];
                    [cell.contentView addSubview:toggleSwitch];   
                    
                    twitterSwitch = toggleSwitch;
                    
                    [toggleSwitch release];
                    
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    SocialUser *socialUser = [SocialUser currentUser];
                    
                    if(socialUser.socialAccountType == TwitterAccount)
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    else
                        cell.selectionStyle = UITableViewCellSelectionStyleGray;                
                }
                else
                {
                    UILabel *configureLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, 190, 44)];
                    configureLabel.font = [UIFont systemFontOfSize:16.0f];
                    configureLabel.backgroundColor = [UIColor clearColor];
                    configureLabel.textAlignment = UITextAlignmentRight;
                    configureLabel.textColor = [UIColor colorWithRed:48.0/255.0 green:78.0/255.0 blue:107.0/255.0 alpha:1.0];
                    configureLabel.highlightedTextColor = [UIColor whiteColor];
                    configureLabel.text = @"Configure";
                    [cell.contentView addSubview:configureLabel];
                    [configureLabel release];
                    
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
            }
                break;            
            default:
                break;
        }
        
        CustomCellBGView *cellSelectionView =
        [[[CustomCellBGView alloc] initSelected:YES grouped:YES] autorelease];
        cell.selectedBackgroundView = cellSelectionView;
        
        CustomCellGroupPosition position = [CustomCellBGView positionForIndexPath:indexPath inTableView:shareTableView];
        ((CustomCellBGView *)cell.selectedBackgroundView).position = position;
    }
    
    cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0];    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SocialUser *socialUser = [SocialUser currentUser];

    switch (indexPath.row) {
        case 1:
        {
            if(socialUser.socialAccountType == FacebookAccount)
            {
                // user is signed up via Facebook - unlinking/configuring facebook from here is not possible
            }
            else
            {
                if([facebookUtil isFacebookConfigured])
                {                
                    UIActionSheet *fbActionSheet = [[UIActionSheet alloc] initWithTitle:@"Unlink your Facebook account?"
                                                                               delegate:self
                                                                      cancelButtonTitle:@"Cancel"
                                                                 destructiveButtonTitle:@"Unlink"
                                                                      otherButtonTitles:nil];
                    fbActionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
                    fbActionSheet.tag = FB_ACTION_SHEET;
                    [fbActionSheet showInView:self.view];
                    [fbActionSheet release];
                }
                else
                {
                    [facebookUtil authorize:self];
                }
            }
        }
            break;
        case 2:
        {
            if(socialUser.socialAccountType == TwitterAccount)
            {
                // user is signed up via Twitter - unlinking/configuring twitter from here is not possible
            }
            else
            {
                if([twitterUtil isTwitterConfigured] && socialUser.socialAccountType != TwitterAccount)
                {
                    UIActionSheet *fbActionSheet = [[UIActionSheet alloc] initWithTitle:@"Unlink your Twitter account?"
                                                                               delegate:self
                                                                      cancelButtonTitle:@"Cancel"
                                                                 destructiveButtonTitle:@"Unlink"
                                                                      otherButtonTitles:nil];
                    fbActionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
                    fbActionSheet.tag = TW_ACTION_SHEET;
                    [fbActionSheet showInView:self.view];
                    [fbActionSheet release];
                }
                else
                {
                    if(!twitterAccountPicker)
                    {
                        twitterAccountPicker = [[TwitterAccountPickerController alloc]init];
                        twitterAccountPicker.view.frame = CGRectMake(0, 480, 320, 260);
                        twitterAccountPicker.delegate = self;
                        [self.tabBarController.view addSubview:twitterAccountPicker.view];
                    }
                    
                    self.shareTableView.userInteractionEnabled = NO;
                    [twitterAccountPicker fetchTwitterAccountsAndConfigure];
                }
            }
        }
            break;
        default:
            break;
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section 
{    
    UILabel *label = [[[UILabel alloc] init] autorelease];
    label.frame = CGRectMake(30, 6, 300, 30);
    label.font = [UIFont boldSystemFontOfSize:16.0];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = UITextAlignmentCenter;
    label.shadowColor = [UIColor lightGrayColor];
    label.shadowOffset = CGSizeMake(0, 1.0);
    label.textColor = [UIColor colorWithRed:182.0/255.0 green:49.0/255.0 blue:37.0/255.0 alpha:1.0];
    label.text = @"Share";
    return label;
}

#pragma mark -
#pragma mark ActionSheet delegate functions

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{   
    switch (actionSheet.tag)
    {
        case FB_ACTION_SHEET:
        {
            if(buttonIndex == 0) // unlink
            {
                [facebookUtil logout:self];
                [facebookUtil setFacebookConfigured:NO];
                [facebookUtil setFacebookEnabled:NO];
                NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:0];
                [shareTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationNone];
            }
        }break;
            
        case TW_ACTION_SHEET:
        {
            if(buttonIndex == 0) // unlink
            {
                [twitterUtil setTwitterConfigured:NO];
                [twitterUtil setTwitterEnabled:NO];
                NSIndexPath *path = [NSIndexPath indexPathForRow:2 inSection:0];
                [shareTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationNone];
            }
        }break;
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark FacebookUtil delegate functions

- (void)onFacebookAuthorized:(BOOL)status
{
    NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:0];
    [shareTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)onFacebookPostResponse:(BOOL)status
{
    NSLog(@"ShareViewController : onFacebookPostResponse");
    
    fbShareResposeRecieved = YES;
    [self handleShareResponses];
}

#pragma mark - TwitterAccountPickerDelegate delegate functions

- (void)twitterAccountSelected
{
    self.shareTableView.userInteractionEnabled = YES;
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:2 inSection:0];
    [shareTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationNone];
}

-(void)twitterPickerCancelled
{
    self.shareTableView.userInteractionEnabled = YES;
}

#pragma mark -
#pragma mark TwitterUtil functions

- (void)onTweetResponseReceived:(BOOL)status
{
    NSLog(@"ShareViewController : onTweetResponseReceived");
    
    twitterShareResponseReceived = YES;
    [self handleShareResponses];
}

#pragma mark - Share Handler

- (void)handleShareResponses
{
    NSLog(@"PublishViewController : handleShareResponses");
    
    if(facebookSwitch.isOn && !twitterSwitch.isOn)
    {
        if(fbShareResposeRecieved)
            [self dismiss];
    }
    else if(twitterSwitch.isOn && !facebookSwitch.isOn)
    {
        if(twitterShareResponseReceived)
            [self dismiss];
    }
    else if(facebookSwitch.isOn && twitterSwitch.isOn)
    {
        if(fbShareResposeRecieved && twitterShareResponseReceived)
            [self dismiss];
    }
}

- (void)dismiss
{
    [self hideHud];    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UITextView delegate functions
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"]) 
    {
        [textView resignFirstResponder];
        return NO;
    }
    
    return TRUE;
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    self.captionText = textView.text;
}

#pragma mark -
#pragma mark SAProgressHUD functions

- (void)hideHud
{
	// Remove HUD from screen when the HUD was hidded
    if(hud)
    {
        hud.delegate = nil;
		[hud removeFromSuperview];
		[hud release];
		hud = nil;
    }
}

-(void)showHUDwithText:(NSString *)text
{
	if(!hud)
    {
		UIWindow *window = [UIApplication sharedApplication].keyWindow;
		hud = [[SAProgressHUD alloc] initWithWindow:window];
		// Add HUD to screen
		[window addSubview:hud];
		
		// Regisete for HUD callbacks so we can remove it from the window at the right time
        hud.delegate = nil; /* Setting hud delegate to nil to handle this manually*/
		
		// Show the HUD while the provided method executes in a new thread
		[hud show:YES];
		hud.labelText = text;
    }
}

#pragma mark - Memory Management

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self setShareTableView:nil];
    
    if(twitterUtil)
    {
        twitterUtil.delegate = nil;
        [twitterUtil release];
        twitterUtil = nil;
    }
    
    twitterAccountPicker = nil;
}

-(void)dealloc
{
    [shareTableView release];
    [captionText release];
    
    if(twitterUtil)
    {
        twitterUtil.delegate = nil;
        [twitterUtil release];
        twitterUtil = nil;
    }
    
    twitterAccountPicker = nil;
    
    [feedObject release];
    [image release];
    [super dealloc];
}

@end