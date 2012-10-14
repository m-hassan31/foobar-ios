#import "ProfileViewController.h"
#import "AsyncImageView.h"
#import "CustomCellBGView.h"
#import "AppDelegate.h"
#import "SocialUser.h"
#import "EndPoints.h"
#import "Parser.h"
#import "InviteFriendsViewController.h"

@interface ProfileViewController()

-(void)showHUDwithText:(NSString*)text;
-(void)hideHud;
-(void)signOutAction;

@end

@implementation ProfileViewController
@synthesize accountsTableView, foobarUser;

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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    accountsTableView.separatorColor = [UIColor colorWithRed:238.0/255.0 green:225.0/255.0 blue:123.0/255.0 alpha:1.0];
    manager = [[ConnectionManager alloc] init];
    manager.delegate = self;
    FooBarUser *defaultsFoobarUser = [FooBarUser currentUser];
    if(defaultsFoobarUser)
    {
        self.foobarUser = defaultsFoobarUser;    
    }
    else
    {
        [manager getProfile];        
    }
}

#pragma mark -
#pragma mark  tableView delegate functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
        return 2;
    else if(section == 1)
        return 2;
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if((indexPath.section == 0) && (indexPath.row == 0))
    {
        UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        
        UILabel *fullName = [[UILabel alloc] init];
        fullName.frame = CGRectMake(10, 18, 220, 18);
        fullName.backgroundColor = [UIColor clearColor];
        fullName.font = [UIFont boldSystemFontOfSize:16.0];
        fullName.textColor = [UIColor blackColor];
        fullName.highlightedTextColor = [UIColor whiteColor];
        [cell.contentView addSubview:fullName];
        [fullName release];
        
        AsyncImageView *profilePic = [[AsyncImageView alloc]initWithFrame:CGRectMake(235, 7, 40, 40)];
        profilePic.contentMode = UIViewContentModeScaleAspectFit;
        [profilePic setImage:[UIImage imageNamed:@"DefaultUser.png"]];
        [cell.contentView addSubview:profilePic];
        [profilePic release];
        
        if(foobarUser)
        {
            fullName.text = [NSString stringWithFormat:@"%@ %@", foobarUser.firstname, foobarUser.lastname?foobarUser.lastname:@""];
            
            // set user image
            profilePic.image = nil;
            NSString* imageUrl = foobarUser.photoUrl;
            if (imageUrl && ![imageUrl isEqualToString:@""])
                [profilePic setImageUrl:imageUrl];
            else
                [profilePic setImage:[UIImage imageNamed:@"DefaultUser.png"]];//defaultContactImage
        }
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else
    {
        static NSString *CellIdentifier = @"Accounts Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        if(indexPath.section == 0)
        {
            switch([indexPath row])
            {
                case 1:
                    cell.textLabel.text = @"Edit Profile";
                    break;
                    
                default:
                    break;
            }
        }
        else
        {
            switch([indexPath row])
            {
                case 0:
                    cell.textLabel.text = @"Invite Friends";
                    break;
                    
                case 1:
                    cell.textLabel.text = @"Sign Out";
                    break;
                    
                default:
                    break;
            }
        }
        
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
        
        if(indexPath.section == 1 && indexPath.row == 4)
            cell.accessoryType = UITableViewCellAccessoryNone;
        else
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        CustomCellBGView *cellSelectionView =
        [[[CustomCellBGView alloc] initSelected:YES grouped:YES] autorelease];
        cell.selectedBackgroundView = cellSelectionView;
        
        CustomCellGroupPosition position = [CustomCellBGView positionForIndexPath:indexPath inTableView:accountsTableView];
        ((CustomCellBGView *)cell.selectedBackgroundView).position = position;
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 1 && indexPath.row == 1)
    {
        UIActionSheet *signOutActionSheet = [[UIActionSheet alloc]
                                             initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Sign Out", nil];
        signOutActionSheet.destructiveButtonIndex = 0;
        signOutActionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [signOutActionSheet showInView:self.view];
        [signOutActionSheet release];
    }
    else if(indexPath.section == 1 && indexPath.row == 0)
    {
        InviteFriendsViewController *inviteFriendsVC = [[InviteFriendsViewController alloc] initWithNibName:@"InviteFriendsViewController" bundle:nil];
        [self.navigationController pushViewController:inviteFriendsVC animated:YES];
        [inviteFriendsVC release];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35.0f;
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
    
    switch (section)
    {
        case 0:
        {
            label.text = @"Personal";
        }
            break;
        case 1:
        {
            label.text = @"More";
        }
            break;
        default:
            break;
    }
    
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if((indexPath.section == 0) && (indexPath.row == 0))
        return 54.0;
    else
        return 44.0;
}

#pragma mark - Action Sheet Delegates

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [self showHUDwithText:@"Signing Out"];
        [self performSelector:@selector(signOutAction) withObject:nil afterDelay:1.0];
    }
}

-(void)signOutAction
{
    [self hideHud];
    [FooBarUser clearCurrentUser];
    [SocialUser clearCurrentUser];
    [FooBarUtils showAlertMessage:@"You have successfully signed out"];
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate addSignInViewController];
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
	NSString *urlString= [[request url] absoluteString];
    int statusCode = [request responseStatusCode];
    NSString *statusMessage = [request responseStatusMessage];
    
    NSLog(@"Status Code - %d\nStatus Message - %@\nResponse:\n%@", statusCode, statusMessage, responseJSON);
    
    [responseJSON release];
    
    if([urlString hasPrefix:MyProfileUrl])
    {
        if(statusCode == 200)
        {
            FooBarUser *currentLoggedInUser = [Parser parseUserResponse:responseJSON];
            if(currentLoggedInUser)
            {
                self.foobarUser = currentLoggedInUser;
                [self.accountsTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                [FooBarUser saveCurrentUser:self.foobarUser];
            }
            else
                [FooBarUtils showAlertMessage:@"Profile not available."];
        }
        else if(statusCode == 403)
        {
            
        }
    }
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
    manager.delegate = nil;
    [manager release];
    [self setAccountsTableView:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    manager.delegate = nil;
    [manager release];
    [accountsTableView release];
    [foobarUser release];
    [super dealloc];
}

@end