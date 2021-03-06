#import "PhotoDetailsViewController.h"
#import "CommentsViewCell.h"
#import "CommentObject.h"
#import "FooBarUtils.h"
#import "EndPoints.h"
#import "Parser.h"
#import <QuartzCore/QuartzCore.h>
#import "NSData+Base64.h"
#import "ShareViewController.h"
#import "UserProfileViewController.h"

#define PHOTO_SHEET     1001
#define UNLIKE_SHEET    1002

@interface PhotoDetailsViewController()
{
    NSInteger deleteCommentIndex;
    BOOL hasLiked;
}

-(void)beginComment;
-(void)dismissComment;
-(void)postComment;
-(void)shareAction;
-(void)sendViaEmail;
-(void)displayMailComposerSheet;

@end

@implementation PhotoDetailsViewController
@synthesize userInfoHolderView, profilePicView, usernameButton, commentsCountLabel, commentsTableView, 
commentFieldHolder, commentProfilePicView, commentField, scrollView, likeHolderView, likeButton,
imageView, feedObject, commentsHeightArray;

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
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO];
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
    
    deleteCommentIndex = -1; // default
    scrollView.frame = CGRectMake(0, -49, 320, 367);
    
    imageView.delegate = self;
    imageView.userInteractionEnabled = YES;
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
    
    [usernameButton setTitle:feedObject.foobarUser.firstname forState:UIControlStateNormal];
    
    FooBarUser *currentUser = [FooBarUser currentUser];
    hasLiked = [feedObject.likedUsersArray containsObject:currentUser.userId];
    [likeButton setImage:[UIImage imageNamed:hasLiked?@"Liked.png":@"Like.png"] forState:UIControlStateNormal];
    
    likeHolderView.frame = CGRectMake(0, imageView.frame.size.height-likeHolderView.frame.size.height, 320.0f, 40.0f);
    
    userInfoHolderView.frame = CGRectMake(0, imageView.frame.size.height, 320.0f, 48.0f);
    userInfoHolderView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    userInfoHolderView.layer.borderWidth = 1.0;
    NSUInteger commentsCount = feedObject.commentsArray.count;
    commentsCountLabel.text = [NSString stringWithFormat:@"    %d Comment%@", commentsCount , commentsCount==1?@"":@"s"];
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
    
    FooBarUser *defaultsFoobarUser = [FooBarUser currentUser];
    if(!defaultsFoobarUser)
    {
        [manager getProfile];        
    }
}

#pragma mark - Other Actions

-(void)backButtonPressed:(id)senser
{ 
    [self.navigationController popViewControllerAnimated:YES];
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
    
    CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
    [self.scrollView setContentOffset:bottomOffset animated:YES];
}

-(void)dismissComment
{
    CGSize scrollSize = scrollView.contentSize;
    scrollSize.height -= 168;
    scrollView.contentSize = scrollSize;
    
    CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
    [self.scrollView setContentOffset:bottomOffset animated:YES];
}

-(void)postComment
{
    [manager comment:commentField.text onPost:feedObject.feedId];
    CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
    [self.scrollView setContentOffset:bottomOffset animated:YES];
}

-(IBAction)likeButtonPressed:(id)sender
{
    if(hasLiked)
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:@"Are you sure?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Unlike" otherButtonTitles:nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [actionSheet showInView:self.view];
        actionSheet.tag = UNLIKE_SHEET;
        [actionSheet release];
    }
    else
    {
        [commentField resignFirstResponder];
        [manager likePost:feedObject.feedId];
    }
}

-(IBAction)usernameButtonPressed:(id)sender
{
    [commentField resignFirstResponder];
    UserProfileViewController *userProfileVC = [[UserProfileViewController alloc] initWithNibName:@"UserProfileViewController" bundle:nil];
    userProfileVC.userId = feedObject.foobarUser.userId;
    [self.navigationController pushViewController:userProfileVC animated:YES];
    [userProfileVC release];
}

#pragma mark - AsynImageDelegate

-(void) handleTap
{
    [commentField resignFirstResponder];
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share", @"Email", @"Save to Album", @"Copy Url", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
    actionSheet.tag = PHOTO_SHEET;
    [actionSheet release];
}

#pragma mark - Action Sheet Delegates

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == PHOTO_SHEET)
    {
        switch (buttonIndex) 
        {
            case 0:
            {
                [self shareAction];
            }
                break;
            case 1:
            {
                [self sendViaEmail];
            }
                break;
            case 2:
            {
                UIImageWriteToSavedPhotosAlbum(imageView.image,nil, nil, nil);
            }
                break;
            case 3:
            {
                [UIPasteboard generalPasteboard].string = feedObject.foobarPhoto.url;
            }
                break;
                
            default:
                break;
        }
    }
    else if(actionSheet.tag == UNLIKE_SHEET)
    {
        if(buttonIndex == actionSheet.destructiveButtonIndex)
        {
            [commentField resignFirstResponder];
            [manager unlikePost:feedObject.feedId];
        }
    }
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
    [cell setDelegate:self];
    
    CommentObject *commentObject = (CommentObject*)[feedObject.commentsArray objectAtIndex:indexPath.row];
    NSNumber *height = [commentsHeightArray objectAtIndex:indexPath.row];
    [cell setRowWithCommentObject:commentObject delegate:self labelHeight:[height floatValue]];
    return cell;
}

// Override to support conditional editing of the table view.

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath 
{
    FooBarUser *foobarUser = [FooBarUser currentUser];
    CommentObject *commentObject = (CommentObject*)[feedObject.commentsArray objectAtIndex:indexPath.row];
    if([commentObject.foobarUser.userId isEqualToString:foobarUser.userId]) //only owned comments can be deleted
        return YES;
    
    return NO;
}

// Override to support editing the table view.

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete) 
    {
        CommentObject *commentObject = (CommentObject*)[feedObject.commentsArray objectAtIndex:indexPath.row];
        [manager deleteComment:commentObject.commentId];
        deleteCommentIndex = indexPath.row;
    }    
}

#pragma mark - CommentsViewCell delegates

-(void)goToProfile:(NSString*)userId
{
    if(userId && ![userId isEqualToString:@""])
    {
        [commentField resignFirstResponder];
        UserProfileViewController *userProfileVC = [[UserProfileViewController alloc] initWithNibName:@"UserProfileViewController" bundle:nil];
        userProfileVC.userId = userId;
        [self.navigationController pushViewController:userProfileVC animated:YES];
        [userProfileVC release];
    }
}

#pragma mark - TextField delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{	
    [textField resignFirstResponder];
    [self postComment];
    return YES;
}

#pragma mark -
#pragma mark Share

-(void)shareAction
{
    ShareViewController *shareVC = [[ShareViewController alloc] initWithNibName:@"ShareViewController" bundle:nil];
    shareVC.image = imageView.image;
    shareVC.feedObject = self.feedObject;
    [self.navigationController pushViewController:shareVC animated:YES];
    [shareVC release];
}

#pragma mark -
#pragma mark Email

- (void)sendViaEmail
{
    // We display an email composition interface if MFMailComposeViewController exists and the device can send emails.
    // We launch the Mail application on the device, otherwise.
    
    BOOL bCanSendEmail = FALSE;
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    
    if(mailClass != nil)
    {
        // We must always check whether the current device is configured for sending emails
        if([mailClass canSendMail])
        {
            bCanSendEmail = TRUE;			
        }
        else
        {
            bCanSendEmail = FALSE;
        }
    }
    else
    {
        bCanSendEmail = FALSE;
    }
    
    if(bCanSendEmail)
    {
        [self displayMailComposerSheet];
    }
    else 
    {
        [FooBarUtils showAlertMessage:@"Check Your Email Configuration"];
    }	
}

- (void)displayMailComposerSheet
{	
    //Create a string with HTML formatting for the email body
    NSMutableString *emailBody = [[NSMutableString alloc] initWithString:@"<html><body>"];
    //Add some text to it however you want
    //[emailBody appendString:@"<p>Check out this FooBar photo...</p>"];
    //Pick an image to insert
    //This example would come from the main bundle, but your source can be elsewhere
    UIImage *emailImage = imageView.image;
    //Convert the image into data
    NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(emailImage)];
    //Create a base64 string representation of the data using NSData+Base64
    NSString *base64String = [imageData base64EncodedString];
    //Add the encoded string to the emailBody string
    //Don't forget the "<b>" tags are required, the "<p>" tags are optional
    [emailBody appendString:[NSString stringWithFormat:@"<p><b><img src='data:image/png;base64,%@'></b></p>",base64String]];
    //You could repeat here with more text or images, otherwise
    //close the HTML formatting
    [emailBody appendString:@"</body></html>"];
    
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    controller.navigationBar.tintColor=[UIColor blackColor];
    [controller setSubject:@"Check out this FooBar photo..."];
    //NSString* shareBody =[NSString stringWithFormat:@"Check out this FooBar photo %@", feedObject.foobarPhoto.url];
    [controller setMessageBody:emailBody isHTML:YES];
    [emailBody release];
    if (controller) [self presentModalViewController:controller animated:YES];
    [controller release];
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{	
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
        {
            [FooBarUtils showAlertMessage:@"Your Email is sent successfully"];
        }
            break;
        case MFMailComposeResultFailed:
        {
            [FooBarUtils showAlertMessage:@"Error sending Email.. Try Again"];
        }
            break;
        default:
            break;
    }
    
    [controller dismissModalViewControllerAnimated:YES];
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
        if([request.requestMethod isEqualToString:@"POST"])
        {
            if(statusCode == 200)
            {
                CommentObject *commentObject = [Parser parseCommentResponse:responseJSON];
                if(commentObject)
                {
                    [commentField setText:@""];
                    [feedObject.commentsArray addObject:commentObject];
                    CGFloat height = [CommentsViewCell heightForCellWithText:commentObject.commentText];
                    [commentsHeightArray addObject:[NSNumber numberWithFloat:height]];
                    NSUInteger commentsCount = feedObject.commentsArray.count;
                    commentsCountLabel.text = [NSString stringWithFormat:@"    %d Comment%@", commentsCount , commentsCount==1?@"":@"s"];
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
                else
                {
                    [FooBarUtils showAlertMessage:@"Can't comment now. Try again."];
                    CGPoint bottomOffset = CGPointMake(0, 0);
                    [self.scrollView setContentOffset:bottomOffset animated:YES];
                }
            }
            else
            {   
                [FooBarUtils showAlertMessage:@"Can't comment now. Try again."];
                CGPoint bottomOffset = CGPointMake(0, 0);
                [self.scrollView setContentOffset:bottomOffset animated:YES];
            }
        }
        else
        {
            if(statusCode == 200)
            {
                if(deleteCommentIndex != -1)
                {
                    [feedObject.commentsArray removeObjectAtIndex:deleteCommentIndex];
                    CGFloat height = [[commentsHeightArray objectAtIndex:deleteCommentIndex] floatValue];
                    [commentsHeightArray removeObjectAtIndex:deleteCommentIndex];
                    NSUInteger commentsCount = feedObject.commentsArray.count;
                    commentsCountLabel.text = [NSString stringWithFormat:@"    %d Comment%@", commentsCount , commentsCount==1?@"":@"s"];
                    
                    NSIndexPath *path = [NSIndexPath indexPathForRow:deleteCommentIndex inSection:0];
                    [commentsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationLeft];
                    
                    [UIView animateWithDuration:0.2 
                                     animations:^{
                                         commentsTableView.frame = CGRectMake(0, imageView.frame.size.height+userInfoHolderView.frame.size.height+commentsCountLabel.frame.size.height, 320.0f, commentsTableView.frame.size.height-height);
                                         
                                         commentFieldHolder.frame = CGRectMake(0, imageView.frame.size.height+userInfoHolderView.frame.size.height+commentsCountLabel.frame.size.height+commentsTableView.frame.size.height, 320.0f, 44.0f);
                                         
                                         self.scrollView.contentSize = CGSizeMake(320, commentFieldHolder.frame.origin.y + commentFieldHolder.frame.size.height);
                                         
                                         CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
                                         [self.scrollView setContentOffset:bottomOffset animated:YES];
                                     }
                                     completion:^(BOOL finished) {
                                     }];
                }
            }
            else
            {   
                [FooBarUtils showAlertMessage:@"Can't delete comment now."];
            }
            
            deleteCommentIndex = -1;
        }
    }
    else if([urlString hasPrefix:UnlikeUrl])
    {
        if(statusCode == 200)
        {
            feedObject.likesCount--;
            hasLiked = NO;
            [likeButton setImage:[UIImage imageNamed:@"Like.png"] forState:UIControlStateNormal];
            FooBarUser *currentUser = [FooBarUser currentUser];
            [feedObject.likedUsersArray removeObject:currentUser.userId];
        }
        else
        {
            [FooBarUtils showAlertMessage:@"Cant unlike photo now."];
        }
    }
    else if([urlString hasPrefix:LikesUrl])
    {
        if(statusCode == 200)
        {
            feedObject.likesCount++;
            hasLiked = YES;
            [likeButton setImage:[UIImage imageNamed:@"Liked.png"] forState:UIControlStateNormal];
            FooBarUser *currentUser = [FooBarUser currentUser];
            [feedObject.likedUsersArray addObject:currentUser.userId];
        }
        else if(statusCode == 403)
        {
            [FooBarUtils showAlertMessage:@"You've already liked it."];
        }
    }
    else if([urlString hasPrefix:MyProfileUrl])
    {
        if(statusCode == 200)
        {
            FooBarUser *currentLoggedInUser = [Parser parseUserResponse:responseJSON];
            if(currentLoggedInUser)
            {
                FooBarUser *foobarUser = currentLoggedInUser;
                [FooBarUser saveCurrentUser:foobarUser];
            }
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
    [self setLikeButton:nil];
    [self setUserInfoHolderView:nil];
    [self setProfilePicView:nil];
    [self setUsernameButton:nil];
    [self setCommentsTableView:nil];
    
    manager.delegate = nil;
    [manager release];
}

- (void)dealloc 
{
    imageView.delegate = nil;
    [feedObject release];
    [commentsHeightArray release];
    [imageView release];
    [likeHolderView release];
    [likeButton release];
    [userInfoHolderView release];
    [profilePicView release];
    [usernameButton release];
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
