#import "ConnectionManager.h"
#import "FacebookUtil.h"
#import "TwitterUtil.h"
#import "TwitterAccountPickerController.h"
#import "SocialUser.h"
#import "SAProgressHUD.h"

@interface SignInViewController : UIViewController
<FacebookUtilDelegate, ConnectionManagerDelegate, TwitterAccountPickerDelegate>
{
    FacebookUtil *facebookUtil;
    TwitterUtil *twitterUtil;
    TwitterAccountPickerController* twitterAccountPicker;
    ConnectionManager *manager;
    SocialUser *currentLoggedinUser;
    SAProgressHUD* hud;
}

@property (retain, nonatomic) IBOutlet UIButton *facebookButton;
@property (retain, nonatomic) IBOutlet UIButton *twitterButton;

@end
