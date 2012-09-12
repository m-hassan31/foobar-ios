//
//  PhotoDetailsViewController.m
//  FooBar
//
//  Created by Pramati technologies on 9/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoDetailsViewController.h"
#import "CommentsViewCell.h"
#import "CommentObject.h"
#import "FooBarUtils.h"
#import <QuartzCore/QuartzCore.h>

@interface PhotoDetailsViewController()

-(void)beginComment;
-(void)dismissComment;

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
@synthesize imageView, image;

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
    
    scrollView.frame = CGRectMake(0, -47, 320, 367);
    
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    
    if(imageWidth>320)
    {
        CGFloat height = (imageHeight*320)/imageWidth ;
        imageView.frame = CGRectMake(0, 0, 320, height);
    }
    else
    {
        imageView.frame = CGRectMake((320-imageWidth)/2, 0, imageWidth, imageHeight);        
    }
    imageView.image = image;
    
    likeHolderView.frame = CGRectMake(0, imageView.frame.size.height-likeHolderView.frame.size.height, 320.0f, 40.0f);
    
    userInfoHolderView.frame = CGRectMake(0, imageView.frame.size.height, 320.0f, 48.0f);
    userInfoHolderView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    userInfoHolderView.layer.borderWidth = 1.0;
    
    commentsCountLabel.frame = CGRectMake(0, imageView.frame.size.height+userInfoHolderView.frame.size.height, 320.0f, 30.0f);
    
    commentsTableView.frame = CGRectMake(0, imageView.frame.size.height+userInfoHolderView.frame.size.height+commentsCountLabel.frame.size.height, 320.0f, 10*[CommentsViewCell heightForCellWithText:@"@DarkKnight - FooBar is rolling down the mountain. #FooBar"]);
    
    commentFieldHolder.frame = CGRectMake(0, imageView.frame.size.height+userInfoHolderView.frame.size.height+commentsCountLabel.frame.size.height+commentsTableView.frame.size.height, 320.0f, 44.0f);
    
    scrollView.contentSize = CGSizeMake(320, commentFieldHolder.frame.origin.y + commentFieldHolder.frame.size.height);
}

-(void)backButtonPressed:(id)senser
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark tableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{	
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CommentsCellIdentifier = @"CommentsViewCell";
    
    CommentsViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CommentsCellIdentifier];
    
    if(cell == nil) 
        cell = [[[CommentsViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CommentsCellIdentifier] autorelease];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    CommentObject *commentObject = [[CommentObject alloc] initWithCommentId:@"123" userName:@"Knight" userId:@"12345" userPicURL:@"http://cdn1.iconfinder.com/data/icons/iDroid_icons/People.png" commentText:@"@DarkKnight - FooBar is rolling down the mountain. #FooBar" created_dt:@"3 Hrs ago"];
    
    [cell setRowWithCommentObject:commentObject withTextHeight:[CommentsViewCell heightForCellWithText:@"@DarkKnight - FooBar is rolling down the mountain. #FooBar"] delegate:self];
    [commentObject release];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    return [CommentsViewCell heightForCellWithText:@"@DarkKnight - FooBar is rolling down the mountain. #FooBar"];
}


#pragma mark - TextField delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{	
    [textField setText:@""];
    [textField resignFirstResponder];
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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [imageView release];
    [image release];
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
    [super dealloc];
}
@end
