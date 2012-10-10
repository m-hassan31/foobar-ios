#import <UIKit/UIKit.h>
#import "SAProgressHUD.h"

@interface ProfileViewController : UIViewController<UIActionSheetDelegate>
{
    SAProgressHUD* hud;
}

@property (retain, nonatomic) IBOutlet UITableView *accountsTableView;
@end
