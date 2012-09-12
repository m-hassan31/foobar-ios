//
//  StreamViewController.m
//  FooBar
//
//  Created by Pramati technologies on 8/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StreamViewController.h"
#import "FeedView.h"
#import "CaptureViewController.h"
#import "FooBarUtils.h"
#import "PhotoDetailsViewController.h"
#import <QuartzCore/QuartzCore.h>

const NSInteger kNumberOfCells = 30;

@interface StreamViewController ()
@property (nonatomic, retain) NSArray *images;
@end

@implementation StreamViewController
@synthesize images = _images;

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
    [quiltView reloadData];
    
    [quiltView release];    
}

#pragma mark - QuiltViewControllerDataSource

- (NSArray *)images 
{
    if (!_images) {
        NSLog(@"getting source");
        NSMutableArray *imageNames = [NSMutableArray array];
        for(int i = 0; i < kNumberOfCells; i++) {
            [imageNames addObject:[NSString stringWithFormat:@"%d.jpg", i % 35 + 1]];
        }
        _images = [imageNames retain];
    }
    return _images;
}

- (UIImage *)imageAtIndexPath:(NSIndexPath *)indexPath 
{
    return [UIImage imageNamed:[self.images objectAtIndex:indexPath.row]];
}

- (NSInteger)quiltViewNumberOfCells:(TMQuiltView *)_quiltView 
{
    return [self.images count];
}

- (TMQuiltViewCell *)quiltView:(TMQuiltView *)_quiltView cellAtIndexPath:(NSIndexPath *)indexPath 
{
    FeedView *aFeed = (FeedView *)[_quiltView dequeueReusableCellWithReuseIdentifier:@"FeedElement"];
    if (!aFeed) {
        aFeed = [[[FeedView alloc] initWithReuseIdentifier:@"FeedElement"] autorelease];
    }
    
    aFeed.photoView.image = [self imageAtIndexPath:indexPath];
    aFeed.likesCountLabel.text = [NSString stringWithFormat:@"      25"];
    aFeed.profilePicView.image = [UIImage imageNamed:@"DefaultUser.png"];
    aFeed.usernameLabel.text = @"Dark Knight";
    return aFeed;
}

#pragma mark - TMQuiltViewDelegate

- (void)quiltView:(TMQuiltView *)_quiltView didSelectCellAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoDetailsViewController *photoDetailsVC = [[PhotoDetailsViewController alloc] initWithNibName:@"PhotoDetailsViewController" bundle:nil];
    photoDetailsVC.image = [self imageAtIndexPath:indexPath];
    [self.navigationController pushViewController:photoDetailsVC animated:YES];
    [photoDetailsVC release];  
}

- (NSInteger)quiltViewNumberOfColumns:(TMQuiltView *)_quiltView 
{    
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft 
        || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) 
    {
        return 3;
    } 
    else 
    {
        return 2;
    }
}

- (CGFloat)quiltView:(TMQuiltView *)_quiltView heightForCellAtIndexPath:(NSIndexPath *)indexPath 
{
    /*return ([self imageAtIndexPath:indexPath].size.height / [self quiltViewNumberOfColumns:_quiltView])+40.0f;*/
    
    UIImage *image = [self imageAtIndexPath:indexPath];
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    
    CGFloat height = image.size.height;
    
    if(imageWidth>145)
    {
        height = (imageHeight*145)/imageWidth ;
    }
    
    return height+40.0f; // include height of user name bar
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc 
{
    [_images release], _images = nil;
    [super dealloc];
}
@end
