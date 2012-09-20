#import "ProfileViewController.h"
#import "AsyncImageView.h"
#import "CustomCellBGView.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@implementation ProfileViewController
@synthesize accountsTableView;

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
        return 4;
    else if(section == 1)
        return 5;
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if((indexPath.section == 0) && (indexPath.row == 0))
    {
        UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        
        UILabel *fullName = [[UILabel alloc] init];
        fullName.frame = CGRectMake(10, 10, 220, 18);
        fullName.backgroundColor = [UIColor clearColor];
        fullName.font = [UIFont boldSystemFontOfSize:16.0];
        fullName.textColor = [UIColor blackColor];
        fullName.highlightedTextColor = [UIColor whiteColor];
        [cell.contentView addSubview:fullName];
        [fullName release];
        
        UILabel *screenName = [[UILabel alloc] init];
        screenName.backgroundColor = [UIColor clearColor];
        screenName.frame = CGRectMake(10, 30, 220, 16);
        screenName.font = [UIFont systemFontOfSize:14.0];
        screenName.textColor = [UIColor colorWithRed:182.0/255.0 green:49.0/255.0 blue:37.0/255.0 alpha:1.0];
        screenName.highlightedTextColor = [UIColor whiteColor];
        [cell.contentView addSubview:screenName];
        [screenName release];
        
        AsyncImageView *profilePic = [[AsyncImageView alloc]initWithFrame:CGRectMake(235, 7, 40, 40)];
        profilePic.layer.cornerRadius = 5.0f;
        profilePic.layer.masksToBounds = YES;
        profilePic.layer.borderWidth = 0.2;
        profilePic.layer.borderColor = [UIColor blackColor].CGColor;
        [cell.contentView addSubview:profilePic];
        [profilePic release];
        
        fullName.text = @"Robin Van Persie";
        screenName.text = [NSString stringWithFormat:@"@%@",@"rvp"];
        [profilePic setImageUrl:@"http://mancunianmatters.co.uk/files/mancunianmatters/imagecache/full_image/robin%20van%20persie%20manchester%20united_0.jpg"];        
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
                    
                case 2:
                    cell.textLabel.text = @"Change Profile Pic";
                    break;
                    
                case 3:
                    cell.textLabel.text = @"Change Password";
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
                    cell.textLabel.text = @"Search Users";
                    break;
                    
                case 2:
                    cell.textLabel.text = @"Search HashTags";
                    break;
                    
                case 3:
                    cell.textLabel.text = @"About";
                    break;
                    
                case 4:
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

    if(indexPath.section == 1 && indexPath.row == 4)
    {
        UIActionSheet *signOutActionSheet = [[UIActionSheet alloc]
                                             initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Sign Out", nil];
        signOutActionSheet.destructiveButtonIndex = 0;
        signOutActionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [signOutActionSheet showInView:self.view];
        [signOutActionSheet release];
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
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate addSignInViewController];
    }
}

#pragma mark - Memory Management

- (void)viewDidUnload
{
    [self setAccountsTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [accountsTableView release];
    [super dealloc];
}
@end
