#import "ImageZoomingViewController.h"

@implementation ImageZoomingViewController

@synthesize imageScrollView, imageView, image,animateFrame;

-(id) initWithImage:(UIImage*)imageToZoomAndPan
{
	NSLog(@"ImageZoomingViewController: initWithImage");
	self = [super init];
	if(self)
	{
		[self setImage:imageToZoomAndPan];
	}
	return self;
}

- (void)viewDidLoad 
{
	NSLog(@"ImageZoomingViewController: viewDidLoad");
	[super viewDidLoad];
	
	imageScrollView.bouncesZoom = YES;
	imageScrollView.delegate = self;
	imageScrollView.clipsToBounds = YES;
	imageScrollView.showsVerticalScrollIndicator = NO;
	imageScrollView.showsHorizontalScrollIndicator = NO;
	//imageScrollView.frame=CGRectMake(0, 0, 320, 460);
    
	imageView = [[UIImageView alloc] initWithImage:image];
	//imageView.frame = CGRectMake(0, 0, 320, 480);
	imageView.backgroundColor = [UIColor clearColor];
	imageView.userInteractionEnabled = YES;
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	imageView.autoresizingMask = UIViewAutoresizingNone;
	[imageScrollView addSubview:imageView];
	
	imageScrollView.contentSize =  image.size;
	
	// add gesture recognizers to the image view
	UITapGestureRecognizer *tapOnFullScreen = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];	
	[tapOnFullScreen setNumberOfTapsRequired:1];
	[imageView addGestureRecognizer:tapOnFullScreen];	
	[tapOnFullScreen release];
	
	// calculate minimum scale to perfectly fit image width, and begin at that scale
	float minimumScale = [imageScrollView frame].size.width  / [imageView frame].size.width;
	imageScrollView.maximumZoomScale = 3.0;
	imageScrollView.minimumZoomScale = minimumScale;
	imageScrollView.zoomScale = minimumScale;
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    CGRect rectToFit=[self getRectAfterFit];
    imageView.frame = animateFrame;
    [UIView animateWithDuration:0.35 animations:^{
        imageView.frame=rectToFit;
        
    }completion:^(BOOL finished){
        imageView.frame=imageScrollView.bounds;
        originalZoomScale=imageScrollView.zoomScale;
        NSLog(@"After anim zoomScale is %f", originalZoomScale);
	}];
	
}

-(void) popBack{
    if (imageScrollView.zoomScale>originalZoomScale) {
        [UIView animateWithDuration:0.2 animations:^{
            imageScrollView.zoomScale=originalZoomScale;
            
        }completion:^(BOOL finished){

        }];
        return ;
    }
    imageView.frame=[self getRectAfterFit];
    [UIView animateWithDuration:0.2 animations:^{
        imageView.frame=animateFrame;
        
    }completion:^(BOOL finished){
        [self dismissModalViewControllerAnimated:NO];
	}];
}

-(CGRect) getRectAfterFit{
    
    BOOL landscape=NO;
    if (image.size.width>image.size.height) {
        landscape=YES;
    }
    CGRect rectAfterFit=CGRectZero;
    CGFloat aspectRatio=image.size.height/image.size.width;
    
    if (landscape) {

        rectAfterFit.origin.x=0;
        rectAfterFit.size.width=imageScrollView.frame.size.width;
        rectAfterFit.size.height=rectAfterFit.size.width*aspectRatio;
        if (rectAfterFit.size.height>imageScrollView.frame.size.height) {
            rectAfterFit.size.height=imageScrollView.frame.size.height;
            rectAfterFit.size.width=rectAfterFit.size.height/aspectRatio;
        }
    }
    else{
        rectAfterFit.origin.y=0;
        rectAfterFit.size.height=imageScrollView.frame.size.height;
        rectAfterFit.size.width=rectAfterFit.size.height/aspectRatio;
        if (rectAfterFit.size.width>imageScrollView.frame.size.width) {
            rectAfterFit.size.width=imageScrollView.frame.size.width;
            rectAfterFit.size.height=rectAfterFit.size.width*aspectRatio;
        }
    }
    rectAfterFit.origin.x=(imageScrollView.frame.size.width-rectAfterFit.size.width)/2;
    rectAfterFit.origin.y=(imageScrollView.frame.size.height-rectAfterFit.size.height)/2;

    return rectAfterFit;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    NSLog(@"ImageZoomingViewController: initWithImage");
	// Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidUnload 
{
	NSLog(@"ImageZoomingViewController: viewDidUnload");
    if(imageScrollView)
    {
        imageScrollView.delegate= nil;
        imageScrollView = nil;
    }
}

#pragma mark UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView 
{
	NSLog(@"ImageZoomingViewController: viewForZoomingInScrollView");
	return imageView;
}

#pragma mark Tap methods

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer 
{
	NSLog(@"ImageZoomingViewController: handleDoubleTap");
    //[self dismissModalViewControllerAnimated:YES];
    [self popBack];
}

- (void)dealloc 
{
	NSLog(@"ImageZoomingViewController: dealloc");
    imageView.image=nil;
    [imageView release], imageView = nil;
    [image release], image = nil;
    
    if(imageScrollView)
    {
        imageScrollView.delegate= nil;
        imageScrollView = nil;
    }
    
    [super dealloc];
}

@end