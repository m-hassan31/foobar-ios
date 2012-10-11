#import <UIKit/UIKit.h>
#import "SAProgressHUD.h"
#import "ConnectionManager.h"
#import "FooBarUser.h"

@interface ProfileViewController : UIViewController
<UIActionSheetDelegate, ConnectionManagerDelegate>
{
    SAProgressHUD* hud;
    ConnectionManager *manager;
}

@property (retain, nonatomic) IBOutlet UITableView *accountsTableView;
@property (retain, nonatomic) FooBarUser *foobarUser;

@end
