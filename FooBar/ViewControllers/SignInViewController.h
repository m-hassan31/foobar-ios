#import "FacebookUtil.h"
#import "ConnectionManager.h"
#import "TwitterAccountPickerController.h"

@interface SignInViewController : UIViewController
<UITextFieldDelegate, FacebookUtilDelegate, ConnectionManagerDelegate, TwitterAccountPickerDelegate>
{
    FacebookUtil *facebookUtil;
    TwitterAccountPickerController* twitterAccountPicker;
    ConnectionManager *manager;
}

@property (retain, nonatomic) IBOutlet UIButton *facebookButton;
@property (retain, nonatomic) IBOutlet UIButton *twitterButton;
@property (retain, nonatomic) IBOutlet UIImageView *orImage;
@property (retain, nonatomic) IBOutlet UITextField *emailTextField;
@property (retain, nonatomic) IBOutlet UITextField *passwordTextField;
@property (retain, nonatomic) IBOutlet UIButton *signInButton;
@property (retain, nonatomic) IBOutlet UIButton *forgotPasswordButton;

@end
