#import <UIKit/UIKit.h>
#import "FacebookUtil.h"
#import "TwitterUtil.h"
#import "SAProgressHUD.h"
#import "TwitterAccountPickerController.h"
#import "FeedObject.h"

@interface InviteFriendsViewController : UIViewController
<FBDialogDelegate,FBSessionDelegate,FBRequestDelegate,FacebookUtilDelegate, TwitterAccountPickerDelegate, 
TwitterDelegate, UITextViewDelegate, UIActionSheetDelegate>
{
    FacebookUtil *facebookUtil;
	TwitterUtil *twitterUtil;
    TwitterAccountPickerController* twitterAccountPicker;
    SAProgressHUD* hud;
}

@property (retain, nonatomic) IBOutlet UITableView *inviteTableView;
@property (retain, nonatomic) FeedObject *feedObject;
@property (retain, nonatomic) UIImage *image;
@property (retain, nonatomic) NSString *captionText;

@end
