#import "UploadViewController.h"
#import "FooBarUtils.h"
#import "FooBarConstants.h"
#import "EndPoints.h"
#import "CustomCellBGView.h"
#import "FeedObject.h"
#import "FooBarProduct.h"
#import "Parser.h"
#import "CustomTabBarController.h"
#import <QuartzCore/QuartzCore.h>

@interface UploadViewController()
{
    NSInteger selectedFooBarProductIndex;
    NSString *captionText;
}

@end

@implementation UploadViewController
@synthesize uploadTableView, foobarProductPicker, foobarProductsArray, image;

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
    
    manager = [[ConnectionManager alloc] init];
    manager.delegate = self;
    
    [manager getFooBarProducts];
}

-(void)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)uploadButtonPressed:(id)sender 
{    
    [manager uploadPhoto:self.image withProductId:[NSString stringWithFormat:@"%d",(arc4random()%5)+1]];
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
        UITextView *captionTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 5, 280, 65)];
        captionTextView.backgroundColor = [UIColor clearColor];
        captionTextView.layer.cornerRadius = 7.0f;
        [captionTextView setFont:[UIFont systemFontOfSize:14.0]];
        captionTextView.text = @"Add a caption..";
        captionTextView.delegate = self;
        captionTextView.returnKeyType = UIReturnKeyDone;
        [cell.contentView addSubview:captionTextView];
        [captionTextView release];
        
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
    [UIView animateWithDuration:0.25
                     animations:^{
                         foobarProductPicker.frame = CGRectOffset(foobarProductPicker.frame, 0, -220);
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

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{	
    selectedFooBarProductIndex = row;
    NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:0];                
    NSArray *indexArray = [NSArray arrayWithObjects:path,nil];
    [uploadTableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationFade];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         foobarProductPicker.frame = CGRectOffset(foobarProductPicker.frame, 0, 220);
                     }];
}

#pragma mark -
#pragma mark UITextView delegate functions
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"]) 
    {
        if([[textView.text stringByReplacingOccurrencesOfString:@" " withString:@""] length] == 0)
            textView.text = @"Add a caption..";
        [textView resignFirstResponder];
        return NO;
    }
    
    return TRUE;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return TRUE;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if([[textView.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@"Addacaption"])
        textView.text = @"";
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    captionText = textView.text;
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
            if([request.requestMethod isEqualToString:@"POST"])
            {
                FeedObject *feedObject = [Parser parseUploadResponse:responseJSON];
                [manager updatePost:feedObject.feedId withCaption:captionText];                
            }
            else if([request.requestMethod isEqualToString:@"PUT"])
            {
                [self.navigationController popToRootViewControllerAnimated:NO];
                CustomTabBarController *customTabBar = (CustomTabBarController*)self.tabBarController;
                [customTabBar selectTab:STREAM_TAB];            
            }
        }
        else if(statusCode == 403)
        {
            [FooBarUtils showAlertMessage:@"Sorry! Upload Failed."];
            [self.navigationController popToRootViewControllerAnimated:NO];
            CustomTabBarController *customTabBar = (CustomTabBarController*)self.tabBarController;
            [customTabBar selectTab:STREAM_TAB];
        }
    }
    else if([urlString hasPrefix:ProductsUrl])
    {
        if(statusCode == 200)
        {
            NSArray *productsArray = [Parser parseProductsresponse:responseJSON];
            if(productsArray)
            {
                [foobarProductsArray removeAllObjects];
                [foobarProductsArray addObjectsFromArray:productsArray];
                [foobarProductPicker reloadAllComponents];
            }
        }
        else if(statusCode == 403)
        {
            
        }
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
    [super dealloc];
}
@end
