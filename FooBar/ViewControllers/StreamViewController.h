#import <UIKit/UIKit.h>
#import "ConnectionManager.h"
#import "TMQuiltView.h"
#import "ODRefreshControl.h"
#import "MNMBottomPullToRefreshManager.h"

@interface StreamViewController : UIViewController
<ConnectionManagerDelegate, TMQuiltViewDataSource, TMQuiltViewDelegate, MNMBottomPullToRefreshManagerClient, UIScrollViewDelegate>
{
    TMQuiltView *quiltView;
    ConnectionManager *manager;
    ODRefreshControl *refreshControl;
    
    MNMBottomPullToRefreshManager *pullToRefreshManager_;
}

@property(nonatomic, retain) NSMutableArray *feedsArray;

@end
