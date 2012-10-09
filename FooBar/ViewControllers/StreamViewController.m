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
    
    manager = [[ConnectionManager alloc] init];
    manager.delegate = self;
    [manager getFeedsAtPage:1 count:10];
}

#pragma mark - QuiltViewControllerDataSource

- (NSInteger)quiltViewNumberOfCells:(TMQuiltView *)_quiltView 
{
    //return [self.images count];
    return feedsArray.count;
}

- (TMQuiltViewCell *)quiltView:(TMQuiltView *)_quiltView cellAtIndexPath:(NSIndexPath *)indexPath 
{
    FeedView *aFeed = (FeedView *)[_quiltView dequeueReusableCellWithReuseIdentifier:@"FeedElement"];
    if (!aFeed) {
        aFeed = [[[FeedView alloc] initWithReuseIdentifier:@"FeedElement"] autorelease];
    }
    
    FeedObject *feedObject = [feedsArray objectAtIndex:indexPath.row];
    aFeed.photoView.imageUrl = feedObject.foobarPhoto.url;
    aFeed.likesCountLabel.text = [NSString stringWithFormat:@"      25"];
    aFeed.profilePicView.imageUrl = feedObject.foobarUser.photoUrl;
    aFeed.usernameLabel.text = @"Dark Knight";
    return aFeed;
}

#pragma mark - TMQuiltViewDelegate

- (void)quiltView:(TMQuiltView *)_quiltView didSelectCellAtIndexPath:(NSIndexPath *)indexPath
{
    FeedObject *feedObject = [feedsArray objectAtIndex:indexPath.row];
    PhotoDetailsViewController *photoDetailsVC = [[PhotoDetailsViewController alloc] initWithNibName:@"PhotoDetailsViewController" bundle:nil];
    photoDetailsVC.foobarPhoto = feedObject.foobarPhoto;
    photoDetailsVC.profilePicUrl = feedObject.foobarUser.photoUrl;
    photoDetailsVC.commentsArray = [feedObject.commentsArray mutableCopy];
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
    
    if([urlString hasPrefix:FeedsUrl])
    {
        if(statusCode == 200)
        {
            self.feedsArray = [[Parser parseFeedsResponse:responseJSON] mutableCopy];
            [quiltView reloadData];
        }
        else if(statusCode == 403)
        {   
            
        }
    }
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