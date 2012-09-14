#import <UIKit/UIKit.h>
#import "TMQuiltView.h"

@interface StreamViewController : UIViewController<TMQuiltViewDataSource, TMQuiltViewDelegate>
{
    TMQuiltView *quiltView;
}

@end
