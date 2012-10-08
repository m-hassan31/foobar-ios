#import "EditImageViewController.h"
#import "FooBarUtils.h"
#import "EndPoints.h"
#import <QuartzCore/QuartzCore.h>

#define FOOBAR_IMAGE_WIDTH  243
#define FOOBAR_IMAGE_HEIGHT 128

@implementation EditImageViewController

@synthesize image;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *backButton = [FooBarUtils backButton];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside ];
    
    UIBarButtonItem * customLeftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = customLeftBarButtonItem;
    [customLeftBarButtonItem release];
    
    UIButton *uploadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    uploadButton.frame = CGRectMake(250, 7, 44, 30);
    [uploadButton setTitle:@"Upload" forState:UIControlStateNormal];
    [uploadButton addTarget:self action:@selector(uploadButtonPressed:) forControlEvents:UIControlEventTouchUpInside ];
    
    UIBarButtonItem * customRightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:uploadButton];
    self.navigationItem.rightBarButtonItem = customRightBarButtonItem;
    [customRightBarButtonItem release];
    
    imageView.image = image;
    
    UIImage *foobarImage = [UIImage imageNamed:@"Logo.png"];
    
    maxX = imageView.frame.size.width - FOOBAR_IMAGE_WIDTH/4;
    maxY = imageView.frame.size.height - FOOBAR_IMAGE_WIDTH/4;
    
    UIView *holderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, foobarImage.size.width/2, foobarImage.size.height/2)];
	UIImageView *foobarImageview = [[UIImageView alloc] initWithFrame:[holderView frame]];
	[foobarImageview setImage:foobarImage];
	[holderView addSubview:foobarImageview];
    [foobarImageview release];
	
	UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)];
	[pinchRecognizer setDelegate:self];
	[holderView addGestureRecognizer:pinchRecognizer];
	
	UIRotationGestureRecognizer *rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)];
	[rotationRecognizer setDelegate:self];
	[holderView addGestureRecognizer:rotationRecognizer];
	
	UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
	[panRecognizer setMinimumNumberOfTouches:1];
	[panRecognizer setMaximumNumberOfTouches:1];
	[panRecognizer setDelegate:self];
	[holderView addGestureRecognizer:panRecognizer];
	
	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
	[tapRecognizer setNumberOfTapsRequired:1];
	[tapRecognizer setDelegate:self];
	[holderView addGestureRecognizer:tapRecognizer];
	
	[imageView addSubview:holderView];
    [holderView release];
    
    manager = [[ConnectionManager alloc] init];
    manager.delegate = self;
    
    [manager getFooBarProducts];
}

-(void)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)uploadButtonPressed:(id)sender {
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *imageToSave = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [manager uploadPhoto:imageToSave withProductId:[NSString stringWithFormat:@"%d",(arc4random()%5)+1]];
}

-(void)saveImageAction:(id)sender {
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *imageToSave = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageWriteToSavedPhotosAlbum(imageToSave,nil, nil, nil);
}

-(void)scale:(id)sender {
	
	[self.view bringSubviewToFront:[(UIPinchGestureRecognizer*)sender view]];
	
	if([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
		
		lastScale = 1.0;
		return;
	}
	
	CGFloat scale = 1.0 - (lastScale - [(UIPinchGestureRecognizer*)sender scale]);
	
	CGAffineTransform currentTransform = [(UIPinchGestureRecognizer*)sender view].transform;
	CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
	
	[[(UIPinchGestureRecognizer*)sender view] setTransform:newTransform];
	
	lastScale = [(UIPinchGestureRecognizer*)sender scale];
}

-(void)rotate:(id)sender {
	
	[self.view bringSubviewToFront:[(UIRotationGestureRecognizer*)sender view]];
	
	if([(UIRotationGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
		
		lastRotation = 0.0;
		return;
	}
	
	CGFloat rotation = 0.0 - (lastRotation - [(UIRotationGestureRecognizer*)sender rotation]);
	
	CGAffineTransform currentTransform = [(UIPinchGestureRecognizer*)sender view].transform;
	CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform,rotation);
	
	[[(UIRotationGestureRecognizer*)sender view] setTransform:newTransform];
	
	lastRotation = [(UIRotationGestureRecognizer*)sender rotation];
}

-(void)move:(id)sender {
	
	[[[(UITapGestureRecognizer*)sender view] layer] removeAllAnimations];
	
	[self.view bringSubviewToFront:[(UIPanGestureRecognizer*)sender view]];
	CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
	
	if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
		
		firstX = [[sender view] center].x;
		firstY = [[sender view] center].y;
	}
	
	translatedPoint = CGPointMake(firstX+translatedPoint.x, firstY+translatedPoint.y);
	
	[[sender view] setCenter:translatedPoint];
	
	if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
		
		CGFloat finalX = translatedPoint.x + (.35*[(UIPanGestureRecognizer*)sender velocityInView:self.view].x);
		CGFloat finalY = translatedPoint.y + (.35*[(UIPanGestureRecognizer*)sender velocityInView:self.view].y);
		
		if(UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation])) {
			
			if(finalX < FOOBAR_IMAGE_WIDTH/4) {
				
				finalX = FOOBAR_IMAGE_WIDTH/4;
			}
			
			else if(finalX > maxX) {
				
				finalX = maxX;
			}
			
			if(finalY < FOOBAR_IMAGE_HEIGHT/4) {
				
				finalY = FOOBAR_IMAGE_HEIGHT/4;
			}
			
			else if(finalY > maxY) {
				
				finalY = maxY;
			}
		}
		
		else {
			
			if(finalX < FOOBAR_IMAGE_WIDTH/4) {
				
				finalX = FOOBAR_IMAGE_WIDTH/4;
			}
			
			else if(finalX > maxY) {
				
				finalX = maxX;
			}
			
			if(finalY < FOOBAR_IMAGE_HEIGHT/4) {
				
				finalY = FOOBAR_IMAGE_HEIGHT/4;
			}
			
			else if(finalY > maxX) {
				
				finalY = maxY
                ;
			}
		}
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:.35];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[[sender view] setCenter:CGPointMake(finalX, finalY)];
		[UIView commitAnimations];
	}
}

-(void)tapped:(id)sender {
	
	[[[(UITapGestureRecognizer*)sender view] layer] removeAllAnimations];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	
	return ![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]];
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
    
    if([urlString hasPrefix:PhotosUrl])
    {
        if(statusCode == 200)
        {
        }
        else if(statusCode == 403)
        {   
        }
    }
}

#pragma mark - Memory Management

- (void)viewDidUnload {
    [super viewDidUnload];

    manager.delegate = nil;
    [manager release];
}

-(void)dealloc {
    imageView.image = nil;
    [image release];
    manager.delegate = nil;
    [manager release];

    [super dealloc];
}

@end