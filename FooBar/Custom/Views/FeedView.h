#import <UIKit/UIKit.h>
#import "TMQuiltViewCell.h"
#import "AsyncImageView.h"
#import "FeedObject.h"

@interface FeedView : TMQuiltViewCell<AsyncImageDelegate>
{
    AsyncImageView *photoView;
    UIImageView *heart;
    UILabel *likesCountLabel;
    AsyncImageView *profilePicView;
    UILabel *usernameLabel;
}

-(void)updateWithfeedObject:(FeedObject*)feedObject;

@end