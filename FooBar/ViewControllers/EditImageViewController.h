#import <UIKit/UIKit.h>
#import "ConnectionManager.h"

@interface EditImageViewController : UIViewController
<UIGestureRecognizerDelegate, ConnectionManagerDelegate> 
{
	CGFloat lastScale;
	CGFloat lastRotation;
	
	CGFloat firstX;
	CGFloat firstY;	

    CGFloat maxX;
    CGFloat maxY;
    
    IBOutlet UIImageView* imageView;
    
    ConnectionManager *manager;
}

@property(nonatomic, retain) UIImage *image;

@end