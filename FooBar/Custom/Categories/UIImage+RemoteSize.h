#import <UIKit/UIKit.h>

@interface UIImage (RemoteSize)

typedef void (^UIImageSizeRequestCompleted) (NSURL* imgURL, CGSize size);

+ (void) requestSizeFor: (NSURL*) imgURL completion: (UIImageSizeRequestCompleted) completion;

@end
