#import <UIKit/UIKit.h>
#import "SAProgressHUD.h"
#import "FacebookUtil.h"
#import "TwitterUtil.h"
#import "TwitterAccountPickerController.h"
#import "FriendsListTableViewCell.h"

typedef enum INVITE_SOCIAL_NETWORK
{
	INVITE_FB = 1,
	INVITE_TW,
    
}SocialNetwork;

@interface FriendsListViewController : UIViewController  <TwitterDelegate, FriendsListTVCellDelegate, UIActionSheetDelegate>
{
    SAProgressHUD *hud;
    
    FacebookUtil *facebookUtil;
    TwitterUtil *twitterUtil;
    NSMutableArray *friendsArray;
}

@property (nonatomic, retain) IBOutlet UITableView *friendsTableView;
@property (nonatomic, assign) SocialNetwork network;

@end