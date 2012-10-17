#import <UIKit/UIKit.h>
#import "TMQuiltViewCell.h"
#import "AsyncImageView.h"
#import "FeedObject.h"

@protocol FeedViewDelegate <NSObject>

@optional

-(void)openFeed:(FeedObject*)aFeed;
-(void)goToProfile:(NSString*)userId;

@end

@interface FeedView : TMQuiltViewCell<AsyncImageDelegate>
{
    AsyncImageView *photoView;
    UIImageView *heart;
    UILabel *likesCountLabel;
    AsyncImageView *profilePicView;
    UIButton *userNameButton;
    
    id<FeedViewDelegate> delegate;
}

@property(nonatomic, assign) id<FeedViewDelegate> delegate;
@property(nonatomic, retain) FeedObject *feedObject;

-(void)updateWithfeedObject:(FeedObject*)aFeedObject;

@end