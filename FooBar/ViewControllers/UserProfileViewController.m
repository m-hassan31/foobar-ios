#import "UserProfileViewController.h"
#import "EndPoints.h"
#import "Parser.h"
#import "FooBarUtils.h"

@implementation UserProfileViewController
@synthesize profileImageView, nameLabel, userId, foobarUser;

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
    
    UIButton *backButton = [FooBarUtils backButton];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside ];
    
    UIBarButtonItem * customLeftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = customLeftBarButtonItem;
    [customLeftBarButtonItem release];
    
    manager = [[ConnectionManager alloc] init];
    manager.delegate = self;
    [manager getUserProfile:userId];
}

-(void)backButtonPressed:(id)sender 
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ConnectionManager delegate functions

-(void)httpRequestFailed:(ASIHTTPRequest *)request
{
	NSError *error= [request error];
	NSLog(@"%@",[error localizedDescription]);
    [FooBarUtils showAlertMessage:@"Profile not available."];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)httpRequestFinished:(ASIHTTPRequest *)request
{
	NSString *responseJSON = [[request responseString] retain];
	NSString *urlString= [[request url] absoluteString];
    int statusCode = [request responseStatusCode];
    NSString *statusMessage = [request responseStatusMessage];
    
    NSLog(@"Status Code - %d\nStatus Message - %@\nResponse:\n%@", statusCode, statusMessage, responseJSON);
    
    [responseJSON release];
    
    if([urlString hasPrefix:UsersUrl])
    {
        if([request.requestMethod isEqualToString:@"GET"])
        {
            if(statusCode == 200)
            {
                FooBarUser *currentLoggedInUser = [Parser parseUserResponse:responseJSON];
                if(currentLoggedInUser)
                {
                    self.foobarUser = currentLoggedInUser;
                    [profileImageView setImageUrl:self.foobarUser.photoUrl];
                    [nameLabel setText:self.foobarUser.firstname];
                }
                else
                {
                    [FooBarUtils showAlertMessage:@"Profile not available."];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
            else
            {
                [FooBarUtils showAlertMessage:@"Profile not available."];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
}

#pragma mark - Memory Management

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self setProfileImageView:nil];
    [self setNameLabel:nil];
}

- (void)dealloc 
{
    [profileImageView release];
    [nameLabel release];
    [userId release];
    [foobarUser release];
    [super dealloc];
}
@end
