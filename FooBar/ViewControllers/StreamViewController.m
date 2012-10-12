#import "StreamViewController.h"
#import "FeedView.h"
#import "CaptureViewController.h"
#import "FooBarUtils.h"
#import "PhotoDetailsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+RemoteSize.h"
#import "EndPoints.h"
#import "Parser.h"
#import "FeedObject.h"

@interface StreamViewController ()
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
    
    quiltView = [[TMQuiltView alloc] initWithFrame:CGRectMake(0, 0, 320, 326)];
    quiltView.delegate = self;
    quiltView.dataSource = self;
    quiltView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:quiltView];    
    [quiltView release];       
    
    refreshControl = [[ODRefreshControl alloc] initInScrollView:quiltView];
    refreshControl.tintColor = [UIColor colorWithRed:182.0/255.0 green:49.0/255.0 blue:37.0/255.0 alpha:1.0];
    [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    
    manager = [[ConnectionManager alloc] init];
    manager.delegate = self;
    [manager getFeedsAtPage:1 count:10];
}

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    [manager getFeedsAtPage:1 count:10];
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
    
    FeedObject *feedObject = [feedsArray objectAtIndex:indexPath.row];
    aFeed.photoView.image = nil;
    aFeed.photoView.imageUrl = feedObject.foobarPhoto.url;
    aFeed.likesCountLabel.text = [NSString stringWithFormat:@"      %d", feedObject.likesCount];
    
    // set user image
    aFeed.profilePicView.image = nil;
    NSString* imageUrl = feedObject.foobarUser.photoUrl;
    if (imageUrl && ![imageUrl isEqualToString:@""])
        [aFeed.profilePicView setImageUrl:imageUrl];
    else
        [aFeed.profilePicView setImage:[UIImage imageNamed:@"DefaultUser.png"]];//defaultContactImage
    
    if(feedObject.foobarUser.username && ![feedObject.foobarUser.username isEqualToString:@""])
        aFeed.usernameLabel.text = feedObject.foobarUser.firstname;
    else
        aFeed.usernameLabel.text = @"username";
    
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
    
    /*FeedView *fView = (FeedView*)[quiltView cellAtIndexPath:indexPath];
    
    
    ImageZoomingViewController* imageZoomingViewController = [[ImageZoomingViewController alloc] initWithImage:fView.photoView.image];
    imageZoomingViewController.animateFrame= CGRectOffset(fView.photoView.frame,0,44);
    [self.navigationController pushViewController:imageZoomingViewController animated:NO];
    [imageZoomingViewController release];*/
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

#pragma mark - ConnectionManager delegate functions

-(void)httpRequestFailed:(ASIHTTPRequest *)request
{
	NSError *error= [request error];
	NSLog(@"%@",[error localizedDescription]);
    [refreshControl endRefreshing];
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
                self.feedsArray = [parsedFeedsArray mutableCopy];
                [quiltView reloadData];
                [refreshControl endRefreshing];
            }
            else
            {
                [FooBarUtils showAlertMessage:@"Feeds not available"];
            }
        }
        else if(statusCode == 403)
        {   
            
        }
    }
    
    [responseJSON release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    manager.delegate = nil;
    [manager release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc 
{
    manager.delegate = nil;
    [manager release];
    [feedsArray release];
    [super dealloc];
}

@end