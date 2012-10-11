#import <UIKit/UIKit.h>
#import "ConnectionManager.h"
#import "TMQuiltView.h"
#import "ODRefreshControl.h"

@interface StreamViewController : UIViewController
<ConnectionManagerDelegate, TMQuiltViewDataSource, TMQuiltViewDelegate>
{
    TMQuiltView *quiltView;
    ConnectionManager *manager;
    ODRefreshControl *refreshControl;
}

@property(nonatomic, retain) NSMutableArray *feedsArray;

@end
