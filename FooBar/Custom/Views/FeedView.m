#import "FeedView.h"
#import "FooBarUtils.h"
#import <QuartzCore/QuartzCore.h>

const CGFloat kFeedViewMargin = 0;

@implementation FeedView

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        photoView = [[AsyncImageView alloc] init];
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
        profilePicView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:profilePicView];
        [profilePicView release];
        
        usernameLabel = [[UILabel alloc] init];
        usernameLabel.backgroundColor = [UIColor clearColor];
        usernameLabel.textColor = [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
        usernameLabel.textAlignment = UITextAlignmentLeft;
        usernameLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        [self addSubview:usernameLabel];
        [usernameLabel release];
    }
    return self;
}

/*- (AsyncImageView *)photoView {
    if (!photoView) {
        photoView = [[AsyncImageView alloc] init];
        photoView.delegate = self;
        photoView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:photoView];
    }
    return photoView;
}

- (UIImageView *)heart {
    if (!heart) {
        heart = [[UIImageView alloc] init];
        heart.image = [UIImage imageNamed:@"Heart.png"];
        heart.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:heart];
    }
    return heart;
}

- (UILabel *)likesCountLabel {
    if (!likesCountLabel) {
        likesCountLabel = [[UILabel alloc] init];
        likesCountLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        likesCountLabel.textColor = [UIColor whiteColor];
        likesCountLabel.textAlignment = UITextAlignmentLeft;
        likesCountLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        [self addSubview:likesCountLabel];
    }
    return likesCountLabel;
}

- (AsyncImageView *)profilePicView {
    if (!profilePicView) {
        profilePicView = [[AsyncImageView alloc] init];
        profilePicView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:profilePicView];
    }
    return profilePicView;
}

- (UILabel *)usernameLabel {
    if (!usernameLabel) {
        usernameLabel = [[UILabel alloc] init];
        usernameLabel.backgroundColor = [UIColor clearColor];
        usernameLabel.textColor = [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
        usernameLabel.textAlignment = UITextAlignmentLeft;
        usernameLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        [self addSubview:usernameLabel];
    }
    return usernameLabel;
}*/

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
    
    usernameLabel.frame = CGRectMake(38.0f, photoFrame.size.height+6.0f, photoFrame.size.width-43.0f, 28.0f);
}

-(void)updateWithfeedObject:(FeedObject*)feedObject
{
    photoView.image = nil;
    photoView.imageUrl = feedObject.foobarPhoto.url;
    likesCountLabel.text = [NSString stringWithFormat:@"      %d", feedObject.likesCount];
    
    // set user image
    NSString* imageUrl = feedObject.foobarUser.photoUrl;
    [profilePicView setImage:[UIImage imageNamed:@"DefaultUser.png"]];
    if (imageUrl && ![imageUrl isEqualToString:@""])
        [profilePicView setImageUrl:imageUrl];
    
    if(feedObject.foobarUser.username && ![feedObject.foobarUser.username isEqualToString:@""])
        usernameLabel.text = feedObject.foobarUser.firstname;
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

#pragma mark - Memory Management

- (void)dealloc
{
    [photoView setDelegate:nil];    
    [super dealloc];
}

@end