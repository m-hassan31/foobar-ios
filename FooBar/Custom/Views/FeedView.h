#import <UIKit/UIKit.h>
#import "TMQuiltViewCell.h"
#import "AsyncImageView.h"

@interface FeedView : TMQuiltViewCell<AsyncImageDelegate>

@property (nonatomic, retain) AsyncImageView *photoView;
@property (nonatomic, retain) UIImageView *heart;
@property (nonatomic, retain) UILabel *likesCountLabel;
@property (nonatomic, retain) AsyncImageView *profilePicView;
@property (nonatomic, retain) UILabel *usernameLabel;

@end