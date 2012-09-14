#import <UIKit/UIKit.h>

@interface EditImageViewController : UIViewController
<UIGestureRecognizerDelegate> 
{
	CGFloat lastScale;
	CGFloat lastRotation;
	
	CGFloat firstX;
	CGFloat firstY;	

    CGFloat maxX;
    CGFloat maxY;
    
    IBOutlet UIImageView* imageView;
}

@property(nonatomic, retain) UIImage *image;

@end