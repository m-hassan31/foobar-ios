#import "EditImageViewController.h"
#import "FooBarUtils.h"
#import "EndPoints.h"
#import <QuartzCore/QuartzCore.h>
#import "UploadViewController.h"

#define FOOBAR_IMAGE_WIDTH  243
#define FOOBAR_IMAGE_HEIGHT 128

@interface EditImageViewController()
{
    CGFloat lastScale;
	CGFloat lastRotation;
}
@end

@implementation EditImageViewController

@synthesize imageView, image;

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
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.frame = CGRectMake(250, 7, 44, 30);
    [nextButton setImage:[UIImage imageNamed:@"Front.png"] forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(uploadButtonPressed:) forControlEvents:UIControlEventTouchUpInside ];
    
    UIBarButtonItem * customRightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:nextButton];
    self.navigationItem.rightBarButtonItem = customRightBarButtonItem;
    [customRightBarButtonItem release];
    
    imageView.image = image;
    
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    
    // fit the image in center.
    if(imageWidth>320)
    {
        CGFloat height = (imageHeight*320)/imageWidth;
        imageView.frame = CGRectMake(0, (436-height)/2, 320, height);
    }
    else if(imageHeight>436)
    {
        CGFloat width = (imageWidth*436)/imageHeight;
        imageView.frame = CGRectMake((320-width)/2, 0, width, 436);        
    }
    else
    {
        imageView.frame = CGRectMake((320-imageWidth)/2, (436-imageHeight)/2, imageWidth, imageHeight);        
    }
    imageView.center = CGPointMake(320/2, 436/2);
    UIImage *foobarImage = [UIImage imageNamed:@"Logo.png"];
    
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
    holderView.center = CGPointMake(imageView.frame.size.width/2, imageView.frame.size.height/2);
    [holderView release];
}

-(void)backButtonPressed:(id)sender 
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)uploadButtonPressed:(id)sender 
{
    UIGraphicsBeginImageContext(imageView.bounds.size);
    [imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *imageToSave = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    UIImageWriteToSavedPhotosAlbum(imageToSave,nil, nil, nil);
    
    UploadViewController *uploadVC = [[UploadViewController alloc] initWithNibName:@"UploadViewController" bundle:nil];
    uploadVC.image = imageToSave;
    [self.navigationController pushViewController:uploadVC animated:YES];
    [uploadVC release];
}

-(void)scale:(id)sender 
{	
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

-(void)rotate:(id)sender 
{	
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

-(void)move:(id)sender 
{	
    UIPanGestureRecognizer *pgr = (UIPanGestureRecognizer*)sender;
    if (pgr.state == UIGestureRecognizerStateChanged) 
    {
        UIView *logoView = pgr.view;
        CGPoint center = logoView.center;
        CGPoint translation = [pgr translationInView:logoView];
        center = CGPointMake(center.x + translation.x, 
                             center.y + translation.y);
        
        if(CGRectContainsPoint(imageView.bounds, center))
        {
            logoView.center = center;
            [pgr setTranslation:CGPointZero inView:pgr.view];
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer 
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer 
{
	return ![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]];
}

#pragma mark - Memory Management

- (void)viewDidUnload {
    [super viewDidUnload];
    self.imageView = nil;
}

-(void)dealloc {
    imageView.image = nil;
    [imageView release];
    [image release];

    [super dealloc];
}

@end