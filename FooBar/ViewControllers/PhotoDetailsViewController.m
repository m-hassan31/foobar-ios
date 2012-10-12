#import "PhotoDetailsViewController.h"
#import "CommentsViewCell.h"
#import "CommentObject.h"
#import "FooBarUtils.h"
#import "EndPoints.h"
#import "Parser.h"
#import <QuartzCore/QuartzCore.h>

@interface PhotoDetailsViewController()

-(void)beginComment;
-(void)dismissComment;
-(void)postComment;

@end

@implementation PhotoDetailsViewController
@synthesize userInfoHolderView;
@synthesize profilePicView;
@synthesize usernameLabel;
@synthesize commentsCountLabel;
@synthesize commentsTableView;
@synthesize commentFieldHolder;
@synthesize commentProfilePicView;
@synthesize commentField;
@synthesize scrollView;
@synthesize likeHolderView;
@synthesize imageView;
@synthesize feedObject;
@synthesize commentsHeightArray;

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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - View lifecycle

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIButton *backButton = [FooBarUtils backButton];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside ];
    
    UIBarButtonItem * customLeftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = customLeftBarButtonItem;
    [customLeftBarButtonItem release];
    
    scrollView.frame = CGRectMake(0, -49, 320, 367);
    
    CGFloat imageWidth = feedObject.foobarPhoto.width;
    CGFloat imageHeight = feedObject.foobarPhoto.height;
    
    if(imageWidth>320)
    {
        CGFloat height = (imageHeight*320)/imageWidth ;
        imageView.frame = CGRectMake(0, 0, 320, height);
    }
    else
    {
        imageView.frame = CGRectMake((320-imageWidth)/2, 0, imageWidth, imageHeight);        
    }
    
    imageView.imageUrl = feedObject.foobarPhoto.url;
    profilePicView.imageUrl = feedObject.foobarUser.photoUrl;
    commentProfilePicView.imageUrl = feedObject.foobarUser.photoUrl;
    
    usernameLabel.text = feedObject.foobarUser.firstname;
    
    likeHolderView.frame = CGRectMake(0, imageView.frame.size.height-likeHolderView.frame.size.height, 320.0f, 40.0f);
    
    userInfoHolderView.frame = CGRectMake(0, imageView.frame.size.height, 320.0f, 48.0f);
    userInfoHolderView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    userInfoHolderView.layer.borderWidth = 1.0;
    
    commentsCountLabel.text = [NSString stringWithFormat:@"    %d Comments", feedObject.commentsCount];
    commentsCountLabel.frame = CGRectMake(0, imageView.frame.size.height+userInfoHolderView.frame.size.height, 320.0f, 30.0f);
    
    NSMutableArray *heightsArray = [[NSMutableArray alloc] init];
    self.commentsHeightArray = heightsArray;
    [heightsArray release];
    
    CGFloat tableHeight = 0;
    for(CommentObject *commentObject in feedObject.commentsArray)
    {
        CGFloat textheight = [CommentsViewCell heightForCellWithText:commentObject.commentText];
        [commentsHeightArray addObject:[NSNumber numberWithFloat:textheight]];
        tableHeight += textheight;
    }
    commentsTableView.frame = CGRectMake(0, imageView.frame.size.height+userInfoHolderView.frame.size.height+commentsCountLabel.frame.size.height, 320.0f, tableHeight);
    
    commentFieldHolder.frame = CGRectMake(0, imageView.frame.size.height+userInfoHolderView.frame.size.height+commentsCountLabel.frame.size.height+commentsTableView.frame.size.height, 320.0f, 44.0f);
    
    scrollView.contentSize = CGSizeMake(320, commentFieldHolder.frame.origin.y + commentFieldHolder.frame.size.height);
    
    manager = [[ConnectionManager alloc] init];
    manager.delegate = self;
}

-(void)backButtonPressed:(id)senser
{ 
    CATransition* transition = [CATransition animation];
    transition.duration = 0.3;
    transition.type = kCATransitionFade;
    transition.subtype = kCATransitionFromLeft;
    
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [self.navigationController popViewControllerAnimated:NO];
}

-(void)keyboardWillShow
{
    [self beginComment];
}

-(void)keyboardWillHide
{
    [self dismissComment];
}

-(void)beginComment
{
    CGSize scrollSize = scrollView.contentSize;
    scrollSize.height += 168;
    scrollView.contentSize = scrollSize;
    
    [UIView animateWithDuration:0.25 
                     animations:^{
                         CGPoint offset = scrollView.contentOffset;
                         offset.y += 168;
                         scrollView.contentOffset = offset;
                     }];
}

-(void)dismissComment
{
    CGSize scrollSize = scrollView.contentSize;
    scrollSize.height -= 168;
    scrollView.contentSize = scrollSize;
    
    [UIView animateWithDuration:0.25 
                     animations:^{
                         CGPoint offset = scrollView.contentOffset;
                         offset.y -= 168;
                         scrollView.contentOffset = offset;
                     }];
}

-(void)postComment
{
    [manager comment:commentField.text onPost:feedObject.feedId];
}

-(IBAction)likeButtonPressed:(id)sender
{
    [manager likePost:feedObject.feedId];
}

#pragma mark -
#pragma mark tableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{	
    return feedObject.commentsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    NSNumber *height = [commentsHeightArray objectAtIndex:indexPath.row];
    return [height floatValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CommentsCellIdentifier = @"CommentsViewCell";
    
    CommentsViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CommentsCellIdentifier];
    
    if(cell == nil) 
        cell = [[[CommentsViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CommentsCellIdentifier] autorelease];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    CommentObject *commentObject = (CommentObject*)[feedObject.commentsArray objectAtIndex:indexPath.row];
    NSNumber *height = [commentsHeightArray objectAtIndex:indexPath.row];
    [cell setRowWithCommentObject:commentObject delegate:self labelHeight:[height floatValue]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - TextField delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{	
    [textField resignFirstResponder];
    [self postComment];
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if(textField.text.length > 0)
    {
        textField.font = [UIFont systemFontOfSize:14.0f];
    }
    else
    {
        textField.font = [UIFont italicSystemFontOfSize:14.0f];
    }
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField.text.length > 0)
    {
        textField.font = [UIFont systemFontOfSize:14.0f];
    }
    else
    {
        textField.font = [UIFont italicSystemFontOfSize:14.0f];
    }
    
    return YES;
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
    
    if([urlString hasPrefix:CommentsUrl])
    {
        if(statusCode == 200)
        {
            CommentObject *commentObject = [Parser parseCommentResponse:responseJSON];
            if(commentObject)
            {
                [commentField setText:@""];
                [feedObject.commentsArray addObject:commentObject];
                feedObject.commentsCount = feedObject.commentsArray.count;
                CGFloat height = [CommentsViewCell heightForCellWithText:commentObject.commentText];
                [commentsHeightArray addObject:[NSNumber numberWithFloat:height]];
                commentsCountLabel.text = [NSString stringWithFormat:@"    %d Comments", feedObject.commentsCount];
                [UIView animateWithDuration:0.2 
                                 animations:^{
                                     commentsTableView.frame = CGRectMake(0, imageView.frame.size.height+userInfoHolderView.frame.size.height+commentsCountLabel.frame.size.height, 320.0f, commentsTableView.frame.size.height+height);
                                     
                                     commentFieldHolder.frame = CGRectMake(0, imageView.frame.size.height+userInfoHolderView.frame.size.height+commentsCountLabel.frame.size.height+commentsTableView.frame.size.height, 320.0f, 44.0f);
                                     
                                     self.scrollView.contentSize = CGSizeMake(320, commentFieldHolder.frame.origin.y + commentFieldHolder.frame.size.height);
                                     
                                     CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
                                     [self.scrollView setContentOffset:bottomOffset animated:YES];
                                 }
                                 completion:^(BOOL finished) {
                                     NSIndexPath *path = [NSIndexPath indexPathForRow:feedObject.commentsArray.count-1 inSection:0];                
                                     NSArray *indexArray = [NSArray arrayWithObjects:path,nil];
                                     [commentsTableView insertRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationBottom];
                                 }];
            }
        }
        else if(statusCode == 403)
        {   
            
        }
    }
    else if([urlString hasPrefix:CommentsUrl])
    {
        if(statusCode == 200)
        {
            feedObject.likesCount++;
        }
    } 
    
    [responseJSON release];
}

#pragma mark - Memory Management

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self setCommentsCountLabel:nil];
    [self setScrollView:nil];
    [self setCommentFieldHolder:nil];
    [self setCommentProfilePicView:nil];
    [self setCommentField:nil];
    [self setImageView:nil];
    [self setLikeHolderView:nil];
    [self setUserInfoHolderView:nil];
    [self setProfilePicView:nil];
    [self setUsernameLabel:nil];
    [self setCommentsTableView:nil];
    
    manager.delegate = nil;
    [manager release];
}

- (void)dealloc 
{
    [feedObject release];
    [commentsHeightArray release];
    [imageView release];
    [likeHolderView release];
    [userInfoHolderView release];
    [profilePicView release];
    [usernameLabel release];
    [commentsTableView release];
    [commentsCountLabel release];
    [scrollView release];
    [commentFieldHolder release];
    [commentProfilePicView release];
    [commentField release];
    
    manager.delegate = nil;
    [manager release];
    
    [super dealloc];
}
@end
