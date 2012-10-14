#import "InviteFriendsViewController.h"
#import "FooBarUtils.h"
#import "EndPointsKeys.h"
#import "CustomCellBGView.h"
#import "SocialUser.h"
#import "FooBarConstants.h"
#import "PlaceHolderTextView.h"
#import "FriendsListViewController.h"
#import <QuartzCore/QuartzCore.h>

#define FB_ACTION_SHEET              1001
#define TW_ACTION_SHEET              1002

@interface InviteFriendsViewController()
{
}

-(void)showHUDwithText:(NSString*)text;
-(void)hideHud;

@end

@implementation InviteFriendsViewController
@synthesize inviteTableView, captionText, feedObject, image;

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
    
    inviteTableView.separatorColor = [UIColor colorWithRed:238.0/255.0 green:225.0/255.0 blue:123.0/255.0 alpha:1.0];
    
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

#pragma mark -
#pragma mark  tableView delegate functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Invite Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    
    cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0];

    UILabel *configureLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, 190, 44)];
    configureLabel.font = [UIFont systemFontOfSize:16.0f];
    configureLabel.backgroundColor = [UIColor clearColor];
    configureLabel.textAlignment = UITextAlignmentRight;
    configureLabel.textColor = [UIColor colorWithRed:48.0/255.0 green:78.0/255.0 blue:107.0/255.0 alpha:1.0];
    configureLabel.highlightedTextColor = [UIColor whiteColor];
    [cell.contentView addSubview:configureLabel];
    [configureLabel release];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    SocialUser *socialUser = [SocialUser currentUser];
    
    switch([indexPath row])
    {
        case 0:
        {
            cell.textLabel.text = @"Facebook";
            configureLabel.text = [facebookUtil isFacebookConfigured]?@"":@"Configure";
            
            if(socialUser.socialAccountType == FacebookAccount)
            {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        }
            break;
        case 1:
        {
            cell.textLabel.text = @"Twitter";
            configureLabel.text = [twitterUtil isTwitterConfigured]?@"":@"Configure";
            
            if(socialUser.socialAccountType == TwitterAccount)
            {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        }
            break;
        default:
            break;
    }
    
    if(cell.selectionStyle != UITableViewCellSelectionStyleNone)
    {
        CustomCellBGView *cellSelectionView =
        [[[CustomCellBGView alloc] initSelected:YES grouped:YES] autorelease];
        cell.selectedBackgroundView = cellSelectionView;
        
        CustomCellGroupPosition position = [CustomCellBGView positionForIndexPath:indexPath inTableView:inviteTableView];
        ((CustomCellBGView *)cell.selectedBackgroundView).position = position;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SocialUser *socialUser = [SocialUser currentUser];
    
    switch (indexPath.row) {
        case 0:
        {
            if(socialUser.socialAccountType == FacebookAccount)
            {
                // user is signed up via Facebook - unlinking/configuring facebook from here is not possible
                
                FriendsListViewController *friendsListVC = [[FriendsListViewController alloc] initWithNibName:@"FriendsListViewController" bundle:nil];
                friendsListVC.network = INVITE_FB;
                [self.navigationController pushViewController:friendsListVC animated:YES];
                [friendsListVC release];
            }
            else
            {
                if([facebookUtil isFacebookConfigured])
                {
                    UIActionSheet *fbActionSheet = [[UIActionSheet alloc] initWithTitle:@"Unlink your Facebook account?"
                                                                               delegate:self
                                                                      cancelButtonTitle:@"Cancel"
                                                                 destructiveButtonTitle:@"Unlink"
                                                                      otherButtonTitles:@"Show Friends", nil];
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
        case 1:
        {
            if(socialUser.socialAccountType == TwitterAccount)
            {
                // user is signed up via Twitter - unlinking/configuring twitter from here is not possible
                
                FriendsListViewController *friendsListVC = [[FriendsListViewController alloc] initWithNibName:@"FriendsListViewController" bundle:nil];
                friendsListVC.network = INVITE_TW;
                [self.navigationController pushViewController:friendsListVC animated:YES];
                [friendsListVC release];
            }
            else
            {
                if([twitterUtil isTwitterConfigured] && socialUser.socialAccountType != TwitterAccount)
                {
                    UIActionSheet *fbActionSheet = [[UIActionSheet alloc] initWithTitle:@"Unlink your Twitter account?"
                                                                               delegate:self
                                                                      cancelButtonTitle:@"Cancel"
                                                                 destructiveButtonTitle:@"Unlink"
                                                                      otherButtonTitles:@"Show Friends", nil];
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
                    
                    self.inviteTableView.userInteractionEnabled = NO;
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
    label.text = @"Invite Friends";
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
                NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
                [inviteTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationNone];
            }
            else if(buttonIndex == 1) // show Friends
            {
                FriendsListViewController *friendsListVC = [[FriendsListViewController alloc] initWithNibName:@"FriendsListViewController" bundle:nil];
                friendsListVC.network = INVITE_FB;
                [self.navigationController pushViewController:friendsListVC animated:YES];
                [friendsListVC release];
            }
        }
            break;
            
        case TW_ACTION_SHEET:
        {
            if(buttonIndex == 0) // unlink
            {
                [twitterUtil setTwitterConfigured:NO];
                [twitterUtil setTwitterEnabled:NO];
                NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:0];
                [inviteTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationNone];
            }
            else if(buttonIndex == 1) // show Friends
            {
                FriendsListViewController *friendsListVC = [[FriendsListViewController alloc] initWithNibName:@"FriendsListViewController" bundle:nil];
                friendsListVC.network = INVITE_TW;
                [self.navigationController pushViewController:friendsListVC animated:YES];
                [friendsListVC release];
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark FacebookUtil delegate functions

- (void)onFacebookAuthorized:(BOOL)status
{
    NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:0];
    [inviteTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - TwitterAccountPickerDelegate delegate functions

- (void)twitterAccountSelected
{
    self.inviteTableView.userInteractionEnabled = YES;
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:0];
    [inviteTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationNone];
}

-(void)twitterPickerCancelled
{
    self.inviteTableView.userInteractionEnabled = YES;
}

#pragma mark -
#pragma mark TwitterUtil functions


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
    [self setInviteTableView:nil];
    
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
    [inviteTableView release];
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