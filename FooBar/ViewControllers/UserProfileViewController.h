#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import "FooBarUser.h"
#import "ConnectionManager.h"

@interface UserProfileViewController : UIViewController<ConnectionManagerDelegate>
{
    ConnectionManager *manager;
}

@property (retain, nonatomic) IBOutlet AsyncImageView *profileImageView;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) NSString *userId;
@property (retain, nonatomic) FooBarUser *foobarUser;

@end
