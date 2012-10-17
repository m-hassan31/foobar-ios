#import <UIKit/UIKit.h>
#import "ConnectionManager.h"

@interface EditImageViewController : UIViewController<UIGestureRecognizerDelegate> 

@property(nonatomic, retain) IBOutlet UIImageView* imageView;
@property(nonatomic, retain) UIImage *image;

@end