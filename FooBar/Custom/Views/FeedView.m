#import "FeedView.h"
#import "FooBarUtils.h"
#import <QuartzCore/QuartzCore.h>

const CGFloat kFeedViewMargin = 0;

@implementation FeedView

@synthesize delegate, feedObject;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier 
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        photoView = [[AsyncImageView alloc] init];
        photoView.userInteractionEnabled = YES;
        photoView.delegate = self;
        photoView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:photoView];
        [photoView release];

        heart = [[UIImageView alloc] init];
        heart.image = [UIImage imageNamed:@"Heart.png"];
        heart.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:heart];
        [heart release];
        
        likesCountLabel = [[UILabel alloc] init];
        likesCountLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        likesCountLabel.textColor = [UIColor whiteColor];
        likesCountLabel.textAlignment = UITextAlignmentLeft;
        likesCountLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        [self addSubview:likesCountLabel];
        [likesCountLabel release];
        
        profilePicView = [[AsyncImageView alloc] init];
        [self addSubview:profilePicView];
        [profilePicView release];
        
        userNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        userNameButton.frame = CGRectMake(53, 11, 200, 15);
        [userNameButton setTitleColor:[UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [userNameButton setTitleColor:[UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:0.5f] forState:UIControlStateHighlighted];
        userNameButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        userNameButton.titleLabel.textAlignment = UITextAlignmentLeft;
        [userNameButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [userNameButton addTarget:self action:@selector(goToProfile) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:userNameButton];
    }
    return self;
}

-(void) goToProfile
{
    if(delegate && [delegate respondsToSelector:@selector(goToProfile:)])
    {
        [delegate goToProfile:feedObject.foobarUser.userId];
    }
}

- (void)layoutSubviews 
{
    CGRect photoFrame = self.bounds;
    photoFrame.size.height -= 40.0f;
    
    CGRect imageFrame = CGRectInset(photoFrame, kFeedViewMargin, kFeedViewMargin);
    photoView.frame = CGRectInset(imageFrame, kFeedViewMargin, kFeedViewMargin);
    
    likesCountLabel.frame = CGRectMake(kFeedViewMargin, photoFrame.size.height - 20 - kFeedViewMargin,
                                        photoFrame.size.width - 2 * kFeedViewMargin, 20);
    
    heart.frame = CGRectMake(kFeedViewMargin+5.0f, photoFrame.size.height - 20 - kFeedViewMargin+5.0f, 12.0f, 12.0f);
    
    profilePicView.frame = CGRectMake(5.0f, photoFrame.size.height+6.0f, 28.0f, 28.0f);
    
    userNameButton.frame = CGRectMake(38.0f, photoFrame.size.height+6.0f, photoFrame.size.width-43.0f, 28.0f);
}

-(void)updateWithfeedObject:(FeedObject*)aFeedObject
{
    self.feedObject = aFeedObject;
    photoView.image = nil;
    photoView.imageUrl = feedObject.foobarPhoto.url;
    likesCountLabel.text = [NSString stringWithFormat:@"      %d", feedObject.likesCount];
    
    // set user image
    NSString* imageUrl = feedObject.foobarUser.photoUrl;
    [profilePicView setImage:[UIImage imageNamed:@"DefaultUser.png"]];
    if (imageUrl && ![imageUrl isEqualToString:@""])
        [profilePicView setImageUrl:imageUrl];
    
    [userNameButton setTitle:feedObject.foobarUser.firstname forState:UIControlStateNormal];
}

#pragma mark - AsyncImageDelegate

-(void)didFinishLoadingImage:(UIImage *)image fromCache:(BOOL)cache
{
    [photoView.layer removeAnimationForKey:@"AsyncImageAnim"];
    
    if(!cache)
    {
        CATransition *transition = [CATransition animation];
        transition.duration = 0.2f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        transition.type = kCATransitionFade;
        [photoView.layer addAnimation:transition forKey:@"AsyncImageAnim"];
    }
}

-(void)handleTap
{
    if(self.feedObject)
    {
        if(delegate && [delegate respondsToSelector:@selector(openFeed:)])
        {
            [delegate openFeed:self.feedObject];
        }
    }
}

#pragma mark - Memory Management

- (void)dealloc
{
    [feedObject release];
    self.delegate = nil;
    [photoView setDelegate:nil];    
    [super dealloc];
}

@end