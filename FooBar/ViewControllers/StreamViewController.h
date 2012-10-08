#import <UIKit/UIKit.h>
#import "ConnectionManager.h"
#import "TMQuiltView.h"

@interface StreamViewController : UIViewController
<ConnectionManagerDelegate, TMQuiltViewDataSource, TMQuiltViewDelegate>
{
    TMQuiltView *quiltView;
    ConnectionManager *manager;
    
    NSMutableArray *feedsArray;
}

@property(nonatomic, retain) NSMutableArray *feedsArray;

@end
