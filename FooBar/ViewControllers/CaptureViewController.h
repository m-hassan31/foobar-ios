#import <UIKit/UIKit.h>
#import "CaptureSessionManager.h"

@interface CaptureViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (retain) CaptureSessionManager *captureManager;

@end
