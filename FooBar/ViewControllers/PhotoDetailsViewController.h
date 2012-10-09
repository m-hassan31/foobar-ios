#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import "FooBarPhoto.h"

@interface PhotoDetailsViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIView *likeHolderView;
@property (retain, nonatomic) IBOutlet AsyncImageView *imageView;
@property (retain, nonatomic) IBOutlet UIView *userInfoHolderView;
@property (retain, nonatomic) IBOutlet AsyncImageView *profilePicView;
@property (retain, nonatomic) IBOutlet UILabel *usernameLabel;
@property (retain, nonatomic) IBOutlet UILabel *commentsCountLabel;
@property (retain, nonatomic) IBOutlet UITableView *commentsTableView;
@property (retain, nonatomic) IBOutlet UIView *commentFieldHolder;
@property (retain, nonatomic) IBOutlet AsyncImageView *commentProfilePicView;
@property (retain, nonatomic) IBOutlet UITextField *commentField;

@property (retain, nonatomic) NSMutableArray *commentsArray;
@property (retain, nonatomic) FooBarPhoto *foobarPhoto;
@property (retain, nonatomic) NSString *profilePicUrl;

@end
