#import <UIKit/UIKit.h>

@interface ImageZoomingViewController : UIViewController <UIScrollViewDelegate>{
    
    CGRect animateFrame;
    CGFloat originalZoomScale;
}
@property (nonatomic, assign) CGRect animateFrame;
@property (nonatomic, retain) IBOutlet UIScrollView *imageScrollView;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIImage* image;

-(id)initWithImage:(UIImage*)imageToZoomAndPan;
-(CGRect) getRectAfterFit;
-(void) popBack;
@end

