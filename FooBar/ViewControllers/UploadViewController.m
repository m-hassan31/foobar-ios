#import "UploadViewController.h"
#import "FooBarUtils.h"
#import "FooBarConstants.h"
#import "EndPoints.h"
#import "CustomCellBGView.h"
#import "FeedObject.h"
#import "FooBarProduct.h"
#import "Parser.h"
#import "CustomTabBarController.h"
#import "PlaceHolderTextView.h"
#import <QuartzCore/QuartzCore.h>

@interface UploadViewController()
{
    NSInteger selectedFooBarProductIndex;
    UITextView *captionTextViewPointer;
}

-(void)showHUDwithText:(NSString*)text;
-(void)hideHud;

@end

@implementation UploadViewController
@synthesize productsToolbar;
@synthesize uploadTableView, foobarProductPicker, foobarProductsArray, image, captionText;

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

#pragma mark - View lifecycle

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    uploadTableView.separatorColor = [UIColor colorWithRed:238.0/255.0 green:225.0/255.0 blue:123.0/255.0 alpha:1.0];
    
    UIButton *backButton = [FooBarUtils backButton];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem * customLeftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = customLeftBarButtonItem;
    [customLeftBarButtonItem release];
    
    foobarProductsArray = [[NSMutableArray alloc] init];
    selectedFooBarProductIndex = -1;
    
    UILabel *selectTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(97, 0, 127, 44)];
    [selectTitleLabel setBackgroundColor:[UIColor clearColor]];
    [selectTitleLabel setTextColor:[UIColor whiteColor]];
    [selectTitleLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
    [selectTitleLabel setText:@"Select Product"];
    [productsToolbar addSubview:selectTitleLabel];
    [selectTitleLabel release];

    // create the array to hold the buttons, which then gets added to the toolbar
    NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:3];
    
    // create a standard "cancel" button
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc]
                           initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
    cancelButton.style = UIBarButtonItemStyleBordered;
    [buttons addObject:cancelButton];
    [cancelButton release];
    
    // create a spacer
    UIBarButtonItem* flexiSpace = [[UIBarButtonItem alloc]
          initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [buttons addObject:flexiSpace];
    [flexiSpace release];
    
    // create a standard "select" button
    UIBarButtonItem* selectButton = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStyleDone target:self action:@selector(selectButtonPressed)];
    selectButton.style = UIBarButtonItemStyleBordered;
    [buttons addObject:selectButton];
    [selectButton release];
    
    // stick the buttons in the toolbar
    [productsToolbar setItems:buttons animated:NO];
    
    [buttons release];
        
    manager = [[ConnectionManager alloc] init];
    manager.delegate = self;
    
    [manager getFooBarProducts];
}

-(void)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)uploadButtonPressed:(id)sender
{
    if(selectedFooBarProductIndex != -1 && selectedFooBarProductIndex < foobarProductsArray.count)
    {
        [self showHUDwithText:@"Uploading.."];
        FooBarProduct *foobarProduct = [foobarProductsArray objectAtIndex:selectedFooBarProductIndex];
        NSString *productId = foobarProduct.productId;
        [manager uploadPhoto:self.image withProductId:productId];
    }
    else
    {
        [FooBarUtils showAlertMessage:@"Please select a Foobar product"];
    }
}

#pragma mark -
#pragma mark  tableView delegate functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if((indexPath.section == 0) && (indexPath.row == 0))
    {
        UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        
        //Caption text View
        PlaceHolderTextView *captionTextView = [[PlaceHolderTextView alloc] initWithFrame:CGRectMake(10, 5, 280, 65)];
        captionTextView.backgroundColor = [UIColor clearColor];
        captionTextView.layer.cornerRadius = 7.0f;
        [captionTextView setFont:[UIFont systemFontOfSize:14.0]];
        captionTextView.placeholder = @"Add a caption..";
        captionTextView.placeholderColor = [UIColor darkGrayColor];
        captionTextView.delegate = self;
        captionTextView.returnKeyType = UIReturnKeyDone;
        [cell.contentView addSubview:captionTextView];
        [captionTextView release];
        
        captionTextViewPointer = captionTextView;
        
        //cell.textLabel.text = @"Caption";
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
        
    }
    else
    {
        UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        
        UILabel *foobarProductLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 9, 190, 27)];
        foobarProductLabel.font = [UIFont systemFontOfSize:16.0f];
        foobarProductLabel.backgroundColor = [UIColor clearColor];
        foobarProductLabel.textAlignment = UITextAlignmentRight;
        foobarProductLabel.textColor = [UIColor colorWithRed:48.0/255.0 green:78.0/255.0 blue:107.0/255.0 alpha:1.0];
        foobarProductLabel.highlightedTextColor = [UIColor whiteColor];
        if(foobarProductsArray && selectedFooBarProductIndex != -1)
        {
            FooBarProduct *foobarProduct = [foobarProductsArray objectAtIndex:selectedFooBarProductIndex];
            foobarProductLabel.text = foobarProduct.name;
        }
        else
        {
            foobarProductLabel.text = @"";
        }
        
        [cell.contentView addSubview:foobarProductLabel];
        [foobarProductLabel release];
        
        cell.textLabel.text = @"FooBar Product";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        CustomCellBGView *cellSelectionView =
        [[[CustomCellBGView alloc] initSelected:YES grouped:YES] autorelease];
        cell.selectedBackgroundView = cellSelectionView;
        
        CustomCellGroupPosition position = [CustomCellBGView positionForIndexPath:indexPath inTableView:tableView];
        ((CustomCellBGView *)cell.selectedBackgroundView).position = position;
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(captionTextViewPointer)
        [captionTextViewPointer resignFirstResponder];
    [UIView animateWithDuration:0.25
                     animations:^{
                         productsToolbar.frame = CGRectMake(0, 178, 320, 44);
                         foobarProductPicker.frame = CGRectMake(0, 222, 320, 216);
                     }];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if((indexPath.section == 0) && (indexPath.row == 0))
        return 75.0;
    else
        return 45.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section 
{    
    UILabel *label = [[[UILabel alloc] init] autorelease];
    label.frame = CGRectMake(30, 6, 300, 30);
    label.font = [UIFont boldSystemFontOfSize:16.0];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = UITextAlignmentCenter;
    label.shadowColor = [UIColor lightGrayColor];
    label.shadowOffset = CGSizeMake(0, 1.0);
    label.textColor = [UIColor colorWithRed:182.0/255.0 green:49.0/255.0 blue:37.0/255.0 alpha:1.0];
    label.text = @"Upload";
    return label;
}

#pragma mark -
#pragma mark UIPickerView data source functions
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
	
    if(foobarProductsArray)
    {
        return [foobarProductsArray count];
    }
	return 1;
}

#pragma mark -
#pragma mark UIPickerView delegate functions
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    FooBarProduct *product = [foobarProductsArray objectAtIndex:row];
	return product.name;
}

#pragma mark -
#pragma mark Products Toolbar actions

- (void)selectButtonPressed
{
    selectedFooBarProductIndex = [foobarProductPicker selectedRowInComponent:0];
    NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:0];
    NSArray *indexArray = [NSArray arrayWithObjects:path,nil];
    [uploadTableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationFade];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         productsToolbar.frame = CGRectMake(0, 436, 320, 44);
                         foobarProductPicker.frame = CGRectMake(0, 480, 320, 216);
                     }];
}

- (void)cancelButtonPressed
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         productsToolbar.frame = CGRectMake(0, 436, 320, 44);
                         foobarProductPicker.frame = CGRectMake(0, 480, 320, 216);
                     }];
}

#pragma mark -
#pragma mark UITextView delegate functions
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    
    return TRUE;
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         foobarProductPicker.frame = CGRectMake(0, 436, 320, 216);
                     }];
    return YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    self.captionText = textView.text;
}

#pragma mark - ConnectionManager delegate functions

-(void)httpRequestFailed:(ASIHTTPRequest *)request
{
	NSError *error= [request error];
	NSLog(@"%@",[error localizedDescription]);
    
    [self hideHud];
    
    [FooBarUtils showAlertMessage:@"Sorry! Upload Failed."];
    CustomTabBarController *customTabBar = (CustomTabBarController*)self.tabBarController;
    [customTabBar selectTab:STREAM_TAB];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    [self.navigationController popToRootViewControllerAnimated:NO];
}

-(void)httpRequestFinished:(ASIHTTPRequest *)request
{
	NSString *responseJSON = [[request responseString] retain];
	NSString *urlString= [[request url] absoluteString];
    int statusCode = [request responseStatusCode];
    
    if([urlString hasPrefix:PhotosUrl])
    {
        if(statusCode == 200)
        {
            if([request.requestMethod isEqualToString:@"POST"])
            {
                if(self.captionText && ![self.captionText isEqualToString:@""])
                {
                    FeedObject *feedObject = [Parser parseUploadResponse:responseJSON];
                    [manager updatePost:feedObject.feedId withCaption:self.captionText];
                }
                else
                {
                    [self hideHud];
                    
                    CustomTabBarController *customTabBar = (CustomTabBarController*)self.tabBarController;
                    [customTabBar selectTab:STREAM_TAB];
                    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
                    
                    FeedObject *feedObject = [Parser parseUploadResponse:responseJSON];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateFeedsOnUpload object:feedObject];
                    [self.navigationController popToRootViewControllerAnimated:NO];
                }
            }
            else if([request.requestMethod isEqualToString:@"PUT"])
            {
                [self hideHud];
                
                CustomTabBarController *customTabBar = (CustomTabBarController*)self.tabBarController;
                [customTabBar selectTab:STREAM_TAB];
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];

                FeedObject *feedObject = [Parser parseUploadResponse:responseJSON];
                [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateFeedsOnUpload object:feedObject];
                [self.navigationController popToRootViewControllerAnimated:NO];
            }
        }
        else
        {
            [self hideHud];
            [FooBarUtils showAlertMessage:@"Sorry! Upload failed."];
            CustomTabBarController *customTabBar = (CustomTabBarController*)self.tabBarController;
            [customTabBar selectTab:STREAM_TAB];
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
            [self.navigationController popToRootViewControllerAnimated:NO];
        }
    }
    else if([urlString hasPrefix:ProductsUrl])
    {
        if(statusCode == 200)
        {
            NSArray *productsArray = [Parser parseProductsresponse:responseJSON];
            if(productsArray && productsArray.count > 0)
            {
                [foobarProductsArray removeAllObjects];
                [foobarProductsArray addObjectsFromArray:productsArray];
                [foobarProductPicker reloadAllComponents];
            }
            else
            {
                [FooBarUtils showAlertMessage:@"Sorry! Can't upload now."];
                
                CustomTabBarController *customTabBar = (CustomTabBarController*)self.tabBarController;
                [customTabBar selectTab:STREAM_TAB];
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
                [self.navigationController popToRootViewControllerAnimated:NO];
            }
        }
    }
    
    [responseJSON release];
}

#pragma mark -
#pragma mark SAProgressHUD functions

- (void)hideHud
{
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
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self setUploadTableView:nil];
    [self setFoobarProductPicker:nil];
    [self setProductsToolbar:nil];
    
    manager.delegate = nil;
    [manager release];
}

- (void)dealloc
{
    manager.delegate = nil;
    [manager release];
    
    [uploadTableView release];
    [foobarProductPicker release];
    [foobarProductsArray release];
    [captionText release];
    [image release];
    [productsToolbar release];
    [super dealloc];
}
@end
