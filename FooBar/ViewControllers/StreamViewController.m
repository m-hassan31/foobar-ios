#import "StreamViewController.h"
#import "UserProfileViewController.h"
#import "FooBarUtils.h"
#import "FooBarConstants.h"
#import "PhotoDetailsViewController.h"
#import "EndPoints.h"
#import "Parser.h"
#import "FeedObject.h"

@interface StreamViewController()
{
    NSUInteger feedsPageToLoad;
    BOOL bReloadingFeeds;
}

@end

@implementation StreamViewController
@synthesize feedsArray;

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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO];
    
    [quiltView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFeeds:) name:kUpdateFeedsOnUpload object:nil];
    
    feedsPageToLoad = 1;
    
    NSMutableArray *fArray = [[NSMutableArray alloc] init];
    self.feedsArray = fArray;;
    [fArray release];
    
    // pinterest like feeds view
    quiltView = [[TMQuiltView alloc] initWithFrame:CGRectMake(0, 0, 320, 326)];
    quiltView.delegate = self;
    quiltView.dataSource = self;
    quiltView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:quiltView];
    [quiltView release];
    
    // top pull to refresh control - for reloading feeds
    refreshControl = [[ODRefreshControl alloc] initInScrollView:quiltView];
    refreshControl.tintColor = [UIColor colorWithRed:182.0/255.0 green:49.0/255.0 blue:37.0/255.0 alpha:1.0];
    [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    
    // bottom pull to refresh control - for loading more feeds
    pullToRefreshManager_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:80.0f scrollView:quiltView withClient:self];
    
    manager = [[ConnectionManager alloc] init];
    manager.delegate = self;
    [manager getFeedsAtPage:1 count:10];
    
    FooBarUser *defaultsFoobarUser = [FooBarUser currentUser];
    if(!defaultsFoobarUser)
    {
        [manager getProfile];        
    }
}

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)_refreshControl
{
    bReloadingFeeds = YES;
    [manager getFeedsAtPage:1 count:10];
}

-(void)updateFeeds:(NSNotification*)notification
{
    id anObject = notification.object;
    if(anObject && ![anObject isKindOfClass:[NSNull class]] && [anObject isKindOfClass:[FeedObject class]])
    {
        FeedObject *uploadedFeedObject = (FeedObject*)anObject;
        [self.feedsArray insertObject:uploadedFeedObject atIndex:0];
        [quiltView reloadData];
        [pullToRefreshManager_ relocatePullToRefreshView];
    }
}

#pragma mark - QuiltViewControllerDataSource

- (NSInteger)quiltViewNumberOfCells:(TMQuiltView *)_quiltView
{
    return feedsArray.count;
}

- (TMQuiltViewCell *)quiltView:(TMQuiltView *)_quiltView cellAtIndexPath:(NSIndexPath *)indexPath
{
    FeedView *aFeed = (FeedView *)[_quiltView dequeueReusableCellWithReuseIdentifier:@"FeedElement"];
    if (!aFeed) {
        aFeed = [[[FeedView alloc] initWithReuseIdentifier:@"FeedElement"] autorelease];
    }
    aFeed.delegate =self;
    FeedObject *feedObject = [feedsArray objectAtIndex:indexPath.row];
    [aFeed updateWithfeedObject:feedObject];
    return aFeed;
}

#pragma mark - TMQuiltViewDelegate

- (void)quiltView:(TMQuiltView *)_quiltView didSelectCellAtIndexPath:(NSIndexPath *)indexPath
{
    FeedObject *feedObject = [feedsArray objectAtIndex:indexPath.row];
    
    PhotoDetailsViewController *photoDetailsVC = [[PhotoDetailsViewController alloc] initWithNibName:@"PhotoDetailsViewController" bundle:nil];
    photoDetailsVC.feedObject = feedObject;
    [self.navigationController pushViewController:photoDetailsVC animated:YES];
    [photoDetailsVC release];
}

- (NSInteger)quiltViewNumberOfColumns:(TMQuiltView *)_quiltView
{
    return 2;
}

- (CGFloat)quiltView:(TMQuiltView *)_quiltView heightForCellAtIndexPath:(NSIndexPath *)indexPath
{
    FeedObject *feedObject = [feedsArray objectAtIndex:indexPath.row];
    
    CGFloat imageWidth = feedObject.foobarPhoto.width;
    CGFloat imageHeight = feedObject.foobarPhoto.height;
    
    CGFloat height = imageHeight;
    
    if(imageWidth>145)
    {
        height = (imageHeight*145)/imageWidth ;
    }
    
    return height+40.0f; // include height of user name bar
}

#pragma mark - FeedView delegates

-(void)openFeed:(FeedObject *)aFeed
{
    PhotoDetailsViewController *photoDetailsVC = [[PhotoDetailsViewController alloc] initWithNibName:@"PhotoDetailsViewController" bundle:nil];
    photoDetailsVC.feedObject = aFeed;
    [self.navigationController pushViewController:photoDetailsVC animated:YES];
    [photoDetailsVC release];
}

-(void)goToProfile:(NSString*)userId
{
    if(userId && ![userId isEqualToString:@""])
    {
        UserProfileViewController *userProfileVC = [[UserProfileViewController alloc] initWithNibName:@"UserProfileViewController" bundle:nil];
        userProfileVC.userId = userId;
        [self.navigationController pushViewController:userProfileVC animated:YES];
        [userProfileVC release];
    }
}

#pragma mark -
#pragma mark MNMBottomPullToRefreshManagerClient

/**
 * This is the same delegate method as UIScrollView but requiered on MNMBottomPullToRefreshManagerClient protocol
 * to warn about its implementation. Here you have to call [MNMBottomPullToRefreshManager tableViewScrolled]
 *
 * Tells the delegate when the user scrolls the content view within the receiver.
 *
 * @param scrollView: The scroll-view object in which the scrolling occurred.
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [pullToRefreshManager_ scrollViewScrolled];
}

/**
 * This is the same delegate method as UIScrollView but requiered on MNMBottomPullToRefreshClient protocol
 * to warn about its implementation. Here you have to call [MNMBottomPullToRefreshManager tableViewReleased]
 *
 * Tells the delegate when dragging ended in the scroll view.
 *
 * @param scrollView: The scroll-view object that finished scrolling the content view.
 * @param decelerate: YES if the scrolling movement will continue, but decelerate, after a touch-up gesture during a dragging operation.
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [pullToRefreshManager_ scrollViewReleased];
}

/**
 * Tells client that can reload table.
 * After reloading is completed must call [pullToRefreshMediator_ tableViewReloadFinished]
 */
- (void)MNMBottomPullToRefreshManagerClientReloadTable {
    
    // Test loading
    bReloadingFeeds = NO;
    [manager getFeedsAtPage:feedsPageToLoad count:10];
    [pullToRefreshManager_ scrollViewReloadFinished];
}

#pragma mark - ConnectionManager delegate functions

-(void)httpRequestFailed:(ASIHTTPRequest *)request
{
	NSError *error= [request error];
	NSLog(@"%@",[error localizedDescription]);
    [refreshControl endRefreshing];
    [pullToRefreshManager_ scrollViewReloadFinished];
}

-(void)httpRequestFinished:(ASIHTTPRequest *)request
{
	NSString *responseJSON = [[request responseString] retain];
	NSString *urlString= [[request url] absoluteString];
    int statusCode = [request responseStatusCode];
    NSString *statusMessage = [request responseStatusMessage];
    
    NSLog(@"Status Code - %d\nStatus Message - %@\nResponse:\n%@", statusCode, statusMessage, responseJSON);
    
    if([urlString hasPrefix:FeedsUrl])
    {
        if(statusCode == 200)
        {
            NSArray *parsedFeedsArray = [Parser parseFeedsResponse:responseJSON];
            if(parsedFeedsArray)
            {
                if(bReloadingFeeds)
                {
                    if(parsedFeedsArray.count > 0)
                    {
                        [self.feedsArray removeAllObjects];
                        [self.feedsArray addObjectsFromArray:parsedFeedsArray];
                        feedsPageToLoad = 2;
                        [quiltView reloadData];
                    }
                }
                else
                {
                    if(parsedFeedsArray.count > 0)
                    {
                        [self.feedsArray addObjectsFromArray:parsedFeedsArray];
                        feedsPageToLoad++;
                        [quiltView reloadData];
                    }
                }
                
                // no more feeds available
                if(parsedFeedsArray.count < 10)
                {
                    [pullToRefreshManager_ setPullToRefreshViewVisible:NO];
                }
                else
                {
                    [pullToRefreshManager_ setPullToRefreshViewVisible:YES];
                }
            }
            else
            {
                [FooBarUtils showAlertMessage:@"Feeds not available"];
            }
        }
        else if(statusCode == 403)
        {
            
        }
        [refreshControl endRefreshing];
        [pullToRefreshManager_ scrollViewReloadFinished];
    }
    else if([urlString hasPrefix:MyProfileUrl])
    {
        if(statusCode == 200)
        {
            FooBarUser *currentLoggedInUser = [Parser parseUserResponse:responseJSON];
            if(currentLoggedInUser)
            {
                FooBarUser *foobarUser = currentLoggedInUser;
                [FooBarUser saveCurrentUser:foobarUser];
            }
        }
    }
    
    [responseJSON release];
}

#pragma mark - Memory Management

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    manager.delegate = nil;
    [manager release];
    
    [pullToRefreshManager_ release];
    pullToRefreshManager_ = nil;
}

- (void)dealloc
{
    manager.delegate = nil;
    [manager release];
    [feedsArray release];
    
    [pullToRefreshManager_ release];
    pullToRefreshManager_ = nil;
    
    [super dealloc];
}

@end