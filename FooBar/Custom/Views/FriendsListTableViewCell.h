#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import "FriendInfo.h"

@protocol FriendsListTVCellDelegate <NSObject>

@optional
- (void)inviteFriendAtIndex:(NSInteger)index;
@end

@interface FriendsListTableViewCell : UITableViewCell
{
	AsyncImageView *cellImageView;
	UILabel *cellLabel;
    UIButton *inviteButton;
    NSInteger index;
    
    id <FriendsListTVCellDelegate> delegate;
}

@property(nonatomic, assign) id <FriendsListTVCellDelegate> delegate;

-(void)setRowForIndex:(int)row withFriendInfo:(FriendInfo*)friendInfo;

@end