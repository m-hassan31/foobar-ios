#import <UIKit/UIKit.h>
#import "ImageDownloader.h"
@protocol AsyncImageDelegate;

@interface AsyncImageView : UIImageView<ImageDownloaderDelegate>
{
    NSString *imageUrl;
    id<AsyncImageDelegate> delegate;

@private
    ImageDownloader *imageDownloader;
}

/*!
 @property      imageUrl
 @brief         setting this property will set the imageUrl string and the instance will attempt to load the image from the given url. On download the image will be set.
 */
@property(nonatomic,retain)NSString *imageUrl;
@property(nonatomic,assign) id<AsyncImageDelegate> delegate;

-(void)setImageUrl:(NSString *)imageUrl_ useCache:(BOOL)useCache;

@end

@protocol AsyncImageDelegate <NSObject>

@optional
-(void) didFinishLoadingImage:(UIImage *)image fromCache:(BOOL)cache;
-(void) handleTap;
@end