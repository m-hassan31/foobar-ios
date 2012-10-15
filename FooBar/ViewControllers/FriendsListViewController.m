#import "FriendsListViewController.h"
#import "FooBarUtils.h"
#import <QuartzCore/QuartzCore.h>
#import "FriendsListTableViewCell.h"
#import "FooBarConstants.h"
#import "EndPointsKeys.h"
#import "Parser.h"
#import "FriendInfo.h"

#define VIEW_HEIGHT                 460
#define RESULTS_TABLE_FRAME         CGRectMake(0, 44, 320, 371)
#define SECTION_HEADER_HEIGHT       35
#define TITLE_MORE                  @"More"
#define TITLE_COMPLETED             @"Completed!"

@interface FriendsListViewController()

-(void)hideHud;
-(void)showHUDwithText:(NSString *)text;
-(void)inviteTwitterFriendWithId:(NSString*)extuid;
-(void)inviteFacebookFriendWithId:(NSString*)extuid;

@end

@implementation FriendsListViewController

@synthesize friendsTableView, network;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self)
    {
        // Custom initialization
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    NSLog(@"FriendsListViewController : viewDidLoad");
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    friendsTableView.separatorColor = [UIColor colorWithRed:238.0/255.0 green:225.0/255.0 blue:123.0/255.0 alpha:1.0];
    
    UIButton *backButton = [FooBarUtils backButton];
    [backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside ];
    
    UIBarButtonItem * customLeftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = customLeftBarButtonItem;
    [customLeftBarButtonItem release];
    
    friendsArray = [[NSMutableArray alloc]init];
    
    facebookUtil = [FacebookUtil getSharedFacebookUtil];
    twitterUtil = (TwitterUtil*)[[TwitterUtil alloc] initWithDelegate:self];
    
    if(network == INVITE_FB)
    {
        [facebookUtil getFacebookFriendsWithDelegate:self];
    }
    else if(network == INVITE_TW)
    {
        [twitterUtil getTwitterFollowers];
    }
}

-(void)backButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)loadMorePressed:(id)sender
{
    [self showHUDwithText:@"Loading"];
    [sender setTitle:@"Loading..." forState:UIControlStateNormal];
    ++twitterUtil.twitterFollowersCurrentPageIndex;
    [twitterUtil getTwitterFollowersInfo];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark InviteFriendsTVCellDelegate delegate functions

- (void)inviteFriendAtIndex:(NSInteger)index
{
    NSLog(@"FriendsListViewController : inviteFriendAtIndex");
    
    FriendInfo *data = [friendsArray objectAtIndex:index];
    
    if(network == INVITE_TW)
    {
        [self inviteTwitterFriendWithId:data.identifier];
    }
    else if(network == INVITE_FB)
    {
        [self inviteFacebookFriendWithId:data.identifier];
    }
}

#pragma mark -
#pragma mark TwitterUtil response

- (void)inviteTwitterFriendWithId:(NSString*)extuid
{
	NSLog(@"FriendsListViewController : inviteSelectedTwitterFriends");
    
    [self showHUDwithText:@"Inviting"];
    [twitterUtil sendDirectMessage:@"Check out FooBar!" to:extuid];
}

- (void)onTwitterFriendsReceived:(NSArray *)friendsInfoArray
{
	NSLog(@"FriendsListViewController : onTwitterFriendsReceived");
    
    [self hideHud];
    
    if(friendsInfoArray && [friendsInfoArray isKindOfClass:[NSArray class]])
    {
        for(NSDictionary *friendInfoDict in friendsInfoArray)
        {
            FriendInfo* friendInfo = [[FriendInfo alloc] init];
            friendInfo.name = [friendInfoDict objectForKey:@"name"];
            friendInfo.identifier = [friendInfoDict objectForKey:kTWitterIdStr];
            friendInfo.photoUrl = [friendInfoDict objectForKey:@"profile_image_url"];
            [friendsArray addObject:friendInfo];
            [friendInfo release];
        }
    }
    else
    {
        // error getting followers
        [FooBarUtils showAlertMessage:kTwitterFollowersErrorMessage];
    }
    
    [friendsTableView reloadData];
}

- (void)onTwitterFriendsFailedWithErrorMessage:(NSString*)message
{
    NSLog(@"FriendsListViewController : onTwitterFollowersFailedWithErrorMessage");
    
    if([FooBarUtils isDeviceOS5])
        [self hideHud];
    
    [FooBarUtils showAlertMessage:message];
}

- (void)onTwitterInvitationResponse:(BOOL)status identifier:(NSString*)userId
{
	/*NSLog(@"FriendsListViewController : onTwitterInvitationResponse");
     
     if(status)
     {
     FriendInfo *fDetail;
     
     if(bInSearchMode)
     {
     fDetail = [searchResults objectForKey:[NSString stringWithFormat:@"%d", selectedIndex]];
     fDetail.invitationStatus = STATUS_INVITED;
     [searchResults setObject:fDetail forKey:[NSString stringWithFormat:@"%d",selectedIndex]];
     }
     else
     {
     fDetail = [friendsArray objectAtIndex:selectedIndex];
     fDetail.invitationStatus = STATUS_INVITED;
     [friendsArray replaceObjectAtIndex:selectedIndex withObject:fDetail];
     }
     
     NSIndexPath *path = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
     [friendsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationNone];
     
     NSMutableDictionary *dictionary = [[[NSMutableDictionary alloc]init] autorelease];
     [dictionary setObject:fDetail.name forKey:kNSingupSocialFullName];
     [dictionary setObject:fDetail.identifier forKey:kNSignupSocialIdGETValue];
     [dictionary setObject:kSignupAccountTypeTwitter forKey:kNSignupSocialAccountType];
     [manager inviteFriends:dictionary];
     }
     else
     {
     if([FooBarUtils isDeviceOS5])
     [self hideHud];
     
     [FooBarUtils showAlertMessage:@"Twitter is daydreaming. Let's try after sometime."];
     }*/
}

#pragma mark -
#pragma mark FacebookUtil response

- (void)inviteFacebookFriendWithId:(NSString*)extuid
{
	NSLog(@"FriendsListViewController : inviteFacebookFriendWithId");
    
    [self showHUDwithText:@"Inviting"];
    [facebookUtil inviteUser:extuid fromDelegate:self];
}

- (void)onFacebookFriendsReceived:(NSDictionary *)friendsDictionary status:(BOOL)status
{
	NSLog(@"FriendsListViewController : onFacebookFriendsReceived");
    
	if(status)
	{
        if(friendsDictionary != nil)
        {
            NSArray *friendsInfo = [friendsDictionary objectForKey:@"data"];
            
            for(NSDictionary* dict in friendsInfo)
            {
                NSString *extuid = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
                NSString* name = [dict objectForKey:@"name"];
                NSString* imgURLString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",extuid];
                
                FriendInfo* friendInfo = [[FriendInfo alloc] init];
                friendInfo.name = name;
                friendInfo.identifier = extuid;
                friendInfo.photoUrl = imgURLString;
                [friendsArray addObject:friendInfo];
                [friendInfo release];
            }
            
            if(friendsArray.count > 1)
            {
                NSArray *tempArr=[friendsArray sortedArrayUsingSelector:@selector(compareContactNameWith:)];
                [friendsArray removeAllObjects];
                [friendsArray addObjectsFromArray:tempArr];
            }
            
            [friendsTableView reloadData];
        }
	}
    
    [self hideHud];
}

- (void)onFacebookInvitationResponse:(BOOL)status identifier:(NSString*)userId
{
    /*NSLog(@"FriendsListViewController : onFacebookInvitationResponse");
     
     if(status)
     {
     FriendInfo *fDetail;
     
     if(bInSearchMode)
     {
     fDetail = [searchResults objectForKey:[NSString stringWithFormat:@"%d", selectedIndex]];
     fDetail.invitationStatus = STATUS_INVITED;
     [searchResults setObject:fDetail forKey:[NSString stringWithFormat:@"%d", selectedIndex]];
     }
     else
     {
     fDetail = [friendsArray objectAtIndex:selectedIndex];
     fDetail.invitationStatus = STATUS_INVITED;
     [friendsArray replaceObjectAtIndex:selectedIndex withObject:fDetail];
     }
     
     NSIndexPath *path = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
     [friendsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationNone];
     NSMutableDictionary *dictionary = [[[NSMutableDictionary alloc]init] autorelease];
     [dictionary setObject:fDetail.name forKey:kNSingupSocialFullName];
     [dictionary setObject:fDetail.identifier forKey:kNSignupSocialIdGETValue];
     [dictionary setObject:kSignupAccountTypeFB forKey:kNSignupSocialAccountType];
     [manager inviteFriends:dictionary];
     }
     else
     {
     [self hideHud];
     [FooBarUtils showAlertMessage:@"Facebook is daydreaming. Let's try again after sometime."];
     }*/
}

#pragma mark -
#pragma mark tableView delegate functions

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(network == INVITE_FB)
    {
        return friendsArray.count;
    }
    else if(network == INVITE_TW)
    {
        return friendsArray.count+1;
    }
    else
    {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    FriendsListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil)
        cell = [[[FriendsListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if([indexPath row] == [friendsArray count])
    {
        CGRect frame = CGRectMake(110, 7, 100, 30);
        UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIButton *loadMore = [UIButton buttonWithType:UIButtonTypeCustom];
        [loadMore setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [loadMore setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        loadMore.frame = frame;
        [loadMore setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        loadMore.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [loadMore addTarget:self action:@selector(loadMorePressed:) forControlEvents:UIControlEventTouchUpInside];
        UIImage *bgimage=[UIImage imageNamed:@"headerbubble.png"];
        bgimage=[bgimage stretchableImageWithLeftCapWidth:bgimage.size.width/2 topCapHeight:bgimage.size.height/2];
        [loadMore setBackgroundImage:bgimage forState:UIControlStateNormal];
        [cell.contentView addSubview:loadMore];
        
        if(twitterUtil.twitterFollowersCurrentPageIndex == twitterUtil.twitterFollowersPagesCount)
        {
            loadMore.userInteractionEnabled = NO;
            [loadMore setTitle:TITLE_COMPLETED forState:UIControlStateNormal];
        }
        else
        {
            [loadMore setTitle:TITLE_MORE forState:UIControlStateNormal];
        }
        
        return cell;
    }
    
    FriendInfo *friendInfo = [friendsArray objectAtIndex:indexPath.row];
    friendInfo.bInvited = ((indexPath.row%2)==0)?YES:NO;
    [cell setRowForIndex:indexPath.row withFriendInfo:friendInfo];
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return SECTION_HEADER_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[[UILabel alloc] init] autorelease];
    label.frame = CGRectMake(30, 6, 300, 30);
    label.font = [UIFont boldSystemFontOfSize:16.0];
    label.backgroundColor = [UIColor colorWithRed:182.0/255.0 green:49.0/255.0 blue:37.0/255.0 alpha:1.0];
    label.textAlignment = UITextAlignmentCenter;
    label.shadowColor = [UIColor blackColor];
    label.shadowOffset = CGSizeMake(0, 1.0);
    label.textColor = [UIColor whiteColor];
    
    if(network == INVITE_FB)
        label.text = @"Facebook Friends";
    else if(network == INVITE_TW)
        label.text = @"Twitter Followers";
    
    return label;
}

#pragma mark -
#pragma mark SAProgressHUD delegate function

- (void)hideHud
{
    NSLog(@"FriendsListViewController : hideHud");
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
    NSLog(@"FriendsListViewController : showHUDwithText");
    
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

- (void)didReceiveMemoryWarning
{
    NSLog(@"FriendsListViewController: didReceiveMemoryWarning");
    
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    NSLog(@"FriendsListViewController : viewDidUnload");
    
    [super viewDidUnload];
    
    if(twitterUtil)
    {
        twitterUtil.delegate = nil;
        [twitterUtil release];
    }
    
    facebookUtil.delegate = nil;
    
    [friendsArray release];
    self.friendsTableView = nil;
}

-(void) dealloc
{
    NSLog(@"FriendsListViewController : dealloc");
    
    if(twitterUtil)
    {
        twitterUtil.delegate = nil;
        [twitterUtil release];
    }
    
    facebookUtil.delegate = nil;
    [friendsArray release];
    [friendsTableView release];
    
    [super dealloc];
}

@end