#import "CommentsViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "FooBarUtils.h"

static CGFloat const kCommentTextFontSize = 14;
static CGFloat const kAttributedLabelVerticalOffset = 30.0f;
static CGFloat const kCellBottomPadding = 10.0;

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

@synthesize commentText = _commentText;
@synthesize commentLabel = _commentLabel;
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
    userNameButton.titleLabel.font = [UIFont boldSystemFontOfSize:kCommentTextFontSize];
    userNameButton.titleLabel.textAlignment = UITextAlignmentLeft;
    [userNameButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [userNameButton addTarget:self action:@selector(goToProfile) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:userNameButton];
    
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleUserNameLongPress:)];
    [userNameButton addGestureRecognizer:longPressRecognizer];
    [longPressRecognizer release];
    
    CGRect contentRect = self.contentView.bounds;
	CGFloat boundsX = contentRect.origin.x;
	CGFloat boundsY = contentRect.origin.y;
	CGRect frame;
	frame= CGRectMake(boundsX+6 ,boundsY+5, 40, 40 );
    
    cellImageView= [[AsyncImageView alloc] initWithFrame:frame];
    [self.contentView addSubview:cellImageView];
    [cellImageView release];
    
    frame = CGRectMake(53, 28, 260, 20);
    self.commentLabel = [[[TTTAttributedLabel alloc] initWithFrame:frame] autorelease];
    self.commentLabel.font = [UIFont systemFontOfSize:kCommentTextFontSize];
    self.commentLabel.textColor = [UIColor blackColor];
    self.commentLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.commentLabel.numberOfLines = 0;
    self.commentLabel.backgroundColor = [UIColor clearColor];
    self.commentLabel.linkAttributes = [NSDictionary dictionaryWithObject:(id)[[UIColor colorWithRed:48.0/255.0 green:78.0/255.0 blue:107.0/255.0 alpha:1.0] CGColor] forKey: (NSString*)kCTForegroundColorAttributeName];
    self.commentLabel.highlightedTextColor = [UIColor whiteColor];
    self.commentLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
    self.commentLabel.text = _commentText;
    [self.contentView addSubview:self.commentLabel];
    
    return self;
}

-(void) goToProfile
{
    if(delegate && [delegate respondsToSelector:@selector(goToProfile:)])
    {
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
            [delegate longPressAction:commentObject.foobarUser.username];
    }
}

-(void)layoutSubviews
{
	[super layoutSubviews];    
}

-(void)setRowWithCommentObject:(CommentObject*)commentObj delegate:(id)_delegate labelHeight:(CGFloat)height
{
    self.commentObject = commentObj;
    self.delegate = _delegate;
    
    // set username
    if(commentObject.foobarUser.username && ![commentObject.foobarUser.username isEqualToString:@""])
        [userNameButton setTitle:commentObject.foobarUser.username forState:UIControlStateNormal];
        
    //set comment text
    self.commentText = [commentObject formattedCommentText];
    self.commentLabel.delegate = _delegate;
    
    // adjust frame for comment
    height -= kAttributedLabelVerticalOffset + kCellBottomPadding;
    
    CGRect frame = self.commentLabel.frame;
    frame.size.height = height;
    self.commentLabel.frame = frame;
    
    // set user image
    NSString* imageUrl = commentObject.foobarUser.photoUrl;
    if (imageUrl && ![imageUrl isEqualToString:@""])
        [cellImageView setImageUrl:imageUrl];
    else
        [cellImageView setImage:[UIImage imageNamed:@"DefaultUser.png"]];//defaultContactImage
}

+ (CGFloat)heightForCellWithText:(NSString *)text 
{
    CGFloat height = kAttributedLabelVerticalOffset;
    height += ceilf([text sizeWithFont:[UIFont systemFontOfSize:kCommentTextFontSize] constrainedToSize:CGSizeMake(260.0f, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap].height);
    height += kCellBottomPadding; // end padding
    return height;
}

- (void)setCommentText:(NSString *)text
{
    [self willChangeValueForKey:@"commentText"];
    [_commentText release];
    _commentText = [text copy];
    [self didChangeValueForKey:@"commentText"];
    
    // Text Formatting
    [self.commentLabel setText:self.commentText afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
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
    NSRange stringRange = NSMakeRange(0, [self.commentText length]);
    
    /////////////// Add links to all mentioned names ///////////////////    
    NSRegularExpression *mentionRegExp = MentionNameRegularExpression();
    [mentionRegExp enumerateMatchesInString:self.commentText options:0 range:stringRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        
        NSURL *mentionURL = [NSURL URLWithString:[NSString stringWithFormat:@"MentionName://%@", [self.commentText substringWithRange:result.range]]];
        [self.commentLabel addLinkToURL:mentionURL withRange:result.range];
    }];
    
    /////////////// Add links to all Search tags ///////////////////    
    NSRegularExpression *searchRegExp = SearchTagRegularExpression();
    [searchRegExp enumerateMatchesInString:self.commentText options:0 range:stringRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        
        NSURL *searchURL = [NSURL URLWithString:[NSString stringWithFormat:@"SearchFontli://%@", [self.commentText substringWithRange:result.range]]];
        [self.commentLabel addLinkToURL:searchURL withRange:result.range];
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
    self.commentLabel.delegate = nil;
    
    [_commentLabel release];
    [_commentText release];
    
    [commentObject release];
    
    cellImageView.image = nil;
    
    [super dealloc];
}

@end