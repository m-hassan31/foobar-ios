//
//  CaptureViewController.m
//  FooBar
//
//  Created by Pramati technologies on 9/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CaptureViewController.h"
#import "EditImageViewController.h"
#import "CustomTabBarController.h"
#import "FooBarConstants.h"

@interface CaptureViewController ()
-(IBAction)captureButtonPressed:(id)sender;
-(IBAction)cancelButtonPressed:(id)sender;
-(IBAction)galleryButtonPressed:(id)sender;
@end

@implementation CaptureViewController

@synthesize captureManager;

#pragma mark -
#pragma mark Initialization

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

- (void)viewDidLoad
{
    //intialize the capture session manager
    [self setCaptureManager:[[[CaptureSessionManager alloc] init] autorelease]];
	[[self captureManager] addVideoInputFrontCamera:NO]; // set to YES for Front Camera, No for Back camera
    [[self captureManager] addStillImageOutput];    
	[[self captureManager] addVideoPreviewLayer];
    
	CGRect layerRect = CGRectMake(0, 0, 320, 430);
    [[[self captureManager] previewLayer] setBounds:layerRect];
    [[[self captureManager] previewLayer] setPosition:CGPointMake(CGRectGetMidX(layerRect),CGRectGetMidY(layerRect))];
	[[[self view] layer] addSublayer:[[self captureManager] previewLayer]];
    
    UIImageView *overlayImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Scope.png"]];
    [overlayImageView setFrame:CGRectMake(96, 141, 128, 128)];
    [[self view] addSubview:overlayImageView];
    [overlayImageView release];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageCaptured) name:kImageCapturedSuccessfully object:nil];
    
	//[[captureManager captureSession] startRunning];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.navigationController setNavigationBarHidden:YES];
    
    [[captureManager captureSession] startRunning];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[captureManager captureSession] stopRunning];
}

-(IBAction)captureButtonPressed:(id)sender
{
    [[self captureManager] captureStillImage];
}

- (void)imageCaptured 
{    
    EditImageViewController *editImageVC = [[EditImageViewController alloc] initWithNibName:@"EditImageViewController" bundle:nil];
    editImageVC.image = [[self captureManager] stillImage];
    [self.navigationController pushViewController:editImageVC animated:YES];
    [editImageVC release];
}

-(IBAction)galleryButtonPressed:(id)sender
{
    UIImagePickerController *imagePickController=[[UIImagePickerController alloc]init];
    //You can use isSourceTypeAvailable to check
    imagePickController.sourceType=UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePickController.delegate=self;
    imagePickController.allowsEditing=NO;
    [self presentModalViewController:imagePickController animated:YES];
    [imagePickController release];
}

-(IBAction)cancelButtonPressed:(id)sender
{
    CustomTabBarController *customTabBar = (CustomTabBarController*)self.tabBarController;
    [customTabBar selectTab:STREAM_TAB];
}

#pragma mark - When Finish Shoot
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    //Show OriginalImage size
    NSLog(@"OriginalImage width:%f height:%f",originalImage.size.width,originalImage.size.height);
    
    EditImageViewController *editImageVC = [[EditImageViewController alloc] init];
    editImageVC.image = originalImage;
    [self.navigationController pushViewController:editImageVC animated:YES];
    [editImageVC release];
    [picker dismissModalViewControllerAnimated:YES];
}

#pragma mark - When Tap Cancel

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker 
{
    [picker dismissModalViewControllerAnimated:YES]; 
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)dealloc
{
    [captureManager release], captureManager = nil;
    [super dealloc];
}

@end