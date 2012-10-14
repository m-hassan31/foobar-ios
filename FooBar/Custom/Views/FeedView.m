#import "FeedView.h"
#import "FooBarUtils.h"
#import <QuartzCore/QuartzCore.h>

const CGFloat kFeedViewMargin = 0;

@implementation FeedView

@synthesize photoView = _photoView;
@synthesize heart = _heart;
@synthesize likesCountLabel = _likesCountLabel;
@synthesize profilePicView = _profilePicView;
@synthesize usernameLabel = _usernameLabel;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (AsyncImageView *)photoView {
    if (!_photoView) {
        _photoView = [[AsyncImageView alloc] init];
        _photoView.delegate = self;
        _photoView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_photoView];
    }
    return _photoView;
}

- (UIImageView *)heart {
    if (!_heart) {
        _heart = [[UIImageView alloc] init];
        _heart.image = [UIImage imageNamed:@"Heart.png"];
        _heart.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_heart];
    }
    return _heart;
}

- (UILabel *)likesCountLabel {
    if (!_likesCountLabel) {
        _likesCountLabel = [[UILabel alloc] init];
        _likesCountLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        _likesCountLabel.textColor = [UIColor whiteColor];
        _likesCountLabel.textAlignment = UITextAlignmentLeft;
        _likesCountLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        [self addSubview:_likesCountLabel];
    }
    return _likesCountLabel;
}

- (AsyncImageView *)profilePicView {
    if (!_profilePicView) {
        _profilePicView = [[AsyncImageView alloc] init];
        _profilePicView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_profilePicView];
    }
    return _profilePicView;
}

- (UILabel *)usernameLabel {
    if (!_usernameLabel) {
        _usernameLabel = [[UILabel alloc] init];
        _usernameLabel.backgroundColor = [UIColor clearColor];
        _usernameLabel.textColor = [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
        _usernameLabel.textAlignment = UITextAlignmentLeft;
        _usernameLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        [self addSubview:_usernameLabel];
    }
    return _usernameLabel;
}

- (void)layoutSubviews {
    CGRect photoFrame = self.bounds;
    photoFrame.size.height -= 40.0f;
    
    CGRect imageFrame = CGRectInset(photoFrame, kFeedViewMargin, kFeedViewMargin);
    self.photoView.frame = CGRectInset(imageFrame, kFeedViewMargin, kFeedViewMargin);
    
    self.likesCountLabel.frame = CGRectMake(kFeedViewMargin, photoFrame.size.height - 20 - kFeedViewMargin,
                                            photoFrame.size.width - 2 * kFeedViewMargin, 20);
    
    self.heart.frame = CGRectMake(kFeedViewMargin+5.0f, photoFrame.size.height - 20 - kFeedViewMargin+5.0f, 12.0f, 12.0f);
    
    self.profilePicView.frame = CGRectMake(5.0f, photoFrame.size.height+6.0f, 28.0f, 28.0f);
    
    self.usernameLabel.frame = CGRectMake(38.0f, photoFrame.size.height+6.0f, photoFrame.size.width-43.0f, 28.0f);
}

#pragma mark - AsyncImageDelegate

-(void)didFinishLoadingImage:(UIImage *)image fromCache:(BOOL)cache
{
    [self.layer removeAnimationForKey:@"AsyncImageAnim"];
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.2f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    transition.type = kCATransitionFade;
    transition.removedOnCompletion = YES;
    [self.photoView.layer addAnimation:transition forKey:@"AsyncImageAnim"];
}

#pragma mark - Memory Management

- (void)dealloc
{
    [_photoView setDelegate:nil], [_photoView release], _photoView = nil;
    [_heart release], _heart = nil;
    [_likesCountLabel release], _likesCountLabel = nil;
    [_profilePicView release], _profilePicView = nil;
    [_usernameLabel release], _usernameLabel = nil;
    
    [super dealloc];
}

@end