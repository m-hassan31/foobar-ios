#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import "FeedObject.h"
#import "ConnectionManager.h"
#import "CommentsViewCell.h"
#import <MessageUI/MessageUI.h>

@interface PhotoDetailsViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, ConnectionManagerDelegate, 
AsyncImageDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, CommentsViewCellDelegate>
{
    ConnectionManager *manager;
}

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIView *likeHolderView;
@property (retain, nonatomic) IBOutlet AsyncImageView *imageView;
@property (retain, nonatomic) IBOutlet UIView *userInfoHolderView;
@property (retain, nonatomic) IBOutlet AsyncImageView *profilePicView;
@property (retain, nonatomic) IBOutlet UIButton *usernameButton;
@property (retain, nonatomic) IBOutlet UILabel *commentsCountLabel;
@property (retain, nonatomic) IBOutlet UITableView *commentsTableView;
@property (retain, nonatomic) IBOutlet UIView *commentFieldHolder;
@property (retain, nonatomic) IBOutlet AsyncImageView *commentProfilePicView;
@property (retain, nonatomic) IBOutlet UITextField *commentField;

@property (retain, nonatomic) FeedObject *feedObject;
@property (retain, nonatomic) NSMutableArray *commentsHeightArray;

@end
