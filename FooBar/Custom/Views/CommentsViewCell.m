//
//  CommentsViewCell.m
//  Fontli
//
//  Created by Pramati technologies on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CommentsViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "FooBarUtils.h"

#define PROFILE_PIC_BORDER_FRAME   CGRectMake(0,0,40,40)

static CGFloat const kSummaryTextFontSize = 14;
static CGFloat const kAttributedLabelVerticalOffset = 30.0f;
static CGFloat const kCellBottomPadding = 5.0;

static NSRegularExpression *__mentionNameRegularExpression;
static inline NSRegularExpression * MentionNameRegularExpression() {
    if (!__mentionNameRegularExpression) {
        __mentionNameRegularExpression = [[NSRegularExpression alloc] initWithPattern:@"(?<!\\w)@([\\w\\._-]+)?" options:NSRegularExpressionCaseInsensitive error:nil];
    }
    
    return __mentionNameRegularExpression;
}

static NSRegularExpression *__searchTagRegularExpression;
static inline NSRegularExpression * SearchTagRegularExpression() {
    if (!__searchTagRegularExpression) {
        __searchTagRegularExpression = [[NSRegularExpression alloc] initWithPattern:@"(?<!\\w)#([\\w\\._-]+[&]*[\\w\\.-_]*)?" options:NSRegularExpressionCaseInsensitive error:nil];
    }
    
    return __searchTagRegularExpression;
}

@implementation CommentsViewCell

@synthesize summaryText = _summaryText;
@synthesize summaryLabel = _summaryLabel;
@synthesize commentObject, delegate;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(!self)
        return nil;
    
    NSLog(@"CommentsViewCell : alloc & initWithStyle");
    
    userNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
    userNameButton.frame = CGRectMake(53, 11, 200, 15);
    [userNameButton setTitleColor:[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [userNameButton setTitleColor:[UIColor colorWithRed:48.0/255.0 green:78.0/255.0 blue:107.0/255.0 alpha:0.5] forState:UIControlStateHighlighted];
    userNameButton.titleLabel.font = [UIFont boldSystemFontOfSize:kSummaryTextFontSize];
    userNameButton.titleLabel.textAlignment = UITextAlignmentLeft;
    [userNameButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [userNameButton addTarget:self action:@selector(goToProfile) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:userNameButton];
    
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleUserNameLongPress:)];
    [userNameButton addGestureRecognizer:longPressRecognizer];
    [longPressRecognizer release];
    
    //init the imageview
    
    CGRect contentRect = self.contentView.bounds;
	CGFloat boundsX = contentRect.origin.x;
	CGFloat boundsY = contentRect.origin.y;
	CGRect frame;
	frame= CGRectMake(boundsX+6 ,boundsY+10, 40, 40 );
    profilePicBorder.frame = frame;
    
    cellImageView= [[AsyncImageView alloc] initWithFrame:frame];
    cellImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:cellImageView];
    [cellImageView release];
    
    profilePicBorder = [[UIImageView alloc]initWithFrame:CGRectMake(boundsX+2, boundsY+7, 48, 48)];
    profilePicBorder.image = [UIImage imageNamed:@"posterring-white.png"];
    profilePicBorder.userInteractionEnabled = YES;
    UITapGestureRecognizer* tapProfilePic = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToProfile)];
    [profilePicBorder addGestureRecognizer:tapProfilePic];
    [tapProfilePic release];  
    [self.contentView addSubview:profilePicBorder];
    [profilePicBorder release];
    
    /*// Initialization code
    timeLabel = [[UILabel alloc] init];
    timeLabel.frame = CGRectMake(287, 13, 25, 15);
    timeLabel.textColor = [UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:1.0];
    timeLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    timeLabel.textAlignment = UITextAlignmentRight;
    [self addSubview:timeLabel];
    [timeLabel release];*/
    
    frame = CGRectMake(53, 28, 270, 20);
    self.summaryLabel = [[[TTTAttributedLabel alloc] initWithFrame:frame] autorelease];
    self.summaryLabel.font = [UIFont systemFontOfSize:kSummaryTextFontSize];
    self.summaryLabel.textColor = [UIColor darkGrayColor];
    self.summaryLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.summaryLabel.numberOfLines = 0;
    self.summaryLabel.backgroundColor = [UIColor clearColor];
    self.summaryLabel.linkAttributes = [NSDictionary dictionaryWithObject:(id)[[UIColor colorWithRed:48.0/255.0 green:78.0/255.0 blue:107.0/255.0 alpha:1.0] CGColor] forKey: (NSString*)kCTForegroundColorAttributeName];
    self.summaryLabel.highlightedTextColor = [UIColor whiteColor];
    self.summaryLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
    self.summaryLabel.text = _summaryText;
    [self.contentView addSubview:self.summaryLabel];
    
    return self;
}

-(void) goToProfile
{
    if(delegate && [delegate respondsToSelector:@selector(goToProfile:)])
    {
        /*if(![[Utils getUsername] isEqualToString:commentObject.username])
         [delegate goToProfile:commentObject.user_id];
         else*/
        [delegate goToProfile:nil];
    }
}

- (void)handleUserNameLongPress:(UILongPressGestureRecognizer *)gestureRecognizer 
{
    if([gestureRecognizer state] != UIGestureRecognizerStateBegan)
        return;
    
    if(delegate)
    {  
        if([delegate respondsToSelector:@selector(longPressAction:)])
            [delegate longPressAction:commentObject.username];
    }
}

-(void)layoutSubviews
{
	[super layoutSubviews];    
}

-(void) cleanUpCellBeforeNextWrite
{
    [userNameButton setTitle:@"" forState:UIControlStateNormal];
    self.summaryText = @"";
    cellImageView.image = nil;
    //timeLabel.text = @"";
}
-(void)setRowWithCommentObject:(CommentObject*)commentObj withTextHeight:(CGFloat)height delegate:(id)_delegate
{
    self.commentObject = commentObj;
    self.delegate = _delegate;
    
    [userNameButton setTitle:commentObject.username forState:UIControlStateNormal];
    self.summaryText = [commentObject formattedCommentText];
    self.summaryLabel.delegate = _delegate;
    height -= kAttributedLabelVerticalOffset + kCellBottomPadding;
    
    CGRect frame = self.summaryLabel.frame;
    frame.size.height = height;
    self.summaryLabel.frame = frame;
    
    NSString* imageUrl = commentObject.userPicURL;
    
    if (imageUrl != nil)
        [cellImageView setImageUrl:imageUrl];
    else
        [cellImageView setImage:[UIImage imageNamed:@"defaultprofile.png"]];//defaultContactImage
    
    timeLabel.text = commentObj.created_dt;
}

+ (CGFloat)heightForCellWithText:(NSString *)text 
{
    CGFloat height = kAttributedLabelVerticalOffset;
    height += ceilf([text sizeWithFont:[UIFont systemFontOfSize:kSummaryTextFontSize] constrainedToSize:CGSizeMake(270.0f, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap].height);
    height += kCellBottomPadding; // end padding
    return height;
}

- (void)setSummaryText:(NSString *)text
{
    [self willChangeValueForKey:@"summaryText"];
    [_summaryText release];
    _summaryText = [text copy];
    [self didChangeValueForKey:@"summaryText"];
    
    // Text Formatting
    [self.summaryLabel setText:self.summaryText afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange stringRange = NSMakeRange(0, [mutableAttributedString length]);
        
        NSRegularExpression *regexp = MentionNameRegularExpression();
        [regexp enumerateMatchesInString:[mutableAttributedString string] options:0 range:stringRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            [mutableAttributedString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[[UIColor colorWithRed:52.0/255.0 green:123.0/255.0 blue:195.0/255.0 alpha:1.0] CGColor] range:result.range];
        }];
        
        regexp = SearchTagRegularExpression();
        [regexp enumerateMatchesInString:[mutableAttributedString string] options:0 range:stringRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {       
            [mutableAttributedString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[[UIColor colorWithRed:52.0/255.0 green:123.0/255.0 blue:195.0/255.0 alpha:1.0] CGColor] range:result.range];
        }];
        
        return mutableAttributedString;
    }];
    
    /////////////// Add link to username ///////////////////    
    NSRange stringRange = NSMakeRange(0, [self.summaryText length]);
    
    /////////////// Add links to all mentioned names ///////////////////    
    NSRegularExpression *mentionRegExp = MentionNameRegularExpression();
    [mentionRegExp enumerateMatchesInString:self.summaryText options:0 range:stringRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        
        NSURL *mentionURL = [NSURL URLWithString:[NSString stringWithFormat:@"MentionName://%@", [self.summaryText substringWithRange:result.range]]];
        [self.summaryLabel addLinkToURL:mentionURL withRange:result.range];
    }];
    
    /////////////// Add links to all Search tags ///////////////////    
    NSRegularExpression *searchRegExp = SearchTagRegularExpression();
    [searchRegExp enumerateMatchesInString:self.summaryText options:0 range:stringRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        
        NSURL *searchURL = [NSURL URLWithString:[NSString stringWithFormat:@"SearchFontli://%@", [self.summaryText substringWithRange:result.range]]];
        [self.summaryLabel addLinkToURL:searchURL withRange:result.range];
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark -
#pragma mark memory management

- (void)dealloc 
{
    NSLog(@"CommentsViewCell : dealloc");
    
    self.delegate = nil;
    self.summaryLabel.delegate = nil;
    
    [_summaryLabel release];
    [_summaryText release];
    
    [commentObject release];
    
    cellImageView.image = nil;
    
    [super dealloc];
}

@end
