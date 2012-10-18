#import "AsyncImageView.h"
#import <QuartzCore/QuartzCore.h>

@implementation AsyncImageView
@synthesize imageUrl, delegate;

-(void)setImage:(UIImage *)image
{
    // cancel the previous request otherwise when request is finished the downloaded image will be set
    // For example: First imageUrl was set, so the image is being downloaded. While the image is being downloaded
    // if someone sets the new image, it should show the new image and not the downloaded image, hence previous request should be cancelled.
    if (imageDownloader!= nil) {
        imageDownloader.delegate = nil;
        [imageDownloader release];
        imageDownloader = nil;
    }
    [super setImage:image];
}
-(void)setImageUrl:(NSString *)imageUrl_{
    
	[self setImageUrl:imageUrl_ useCache:YES];
}

-(void)setImageUrl:(NSString *)imageUrl_ useCache:(BOOL)useCache
{
    if(imageUrl_ == nil)
    {
        [imageUrl release];
        imageUrl = nil;
        return;
    }
    
    if(imageUrl != imageUrl_)
    {
        NSString *temp = imageUrl;
        imageUrl = [imageUrl_ retain];
        [temp release];
    }
    
    //start the image download
    if(imageDownloader == nil)
        imageDownloader = [[ImageDownloader alloc] initWithImageUrl:imageUrl delegate:self];
    
    [imageDownloader startLoadingImageFromUrl:imageUrl_ useCache:useCache];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(delegate && [delegate respondsToSelector:@selector(handleTap)])
        [delegate handleTap];
}

#pragma ImageDownloader delegate
-(void)imageDownloader:(ImageDownloader*)downloader retrievedImage:(UIImage*)image fromCache:(BOOL)cache
{    
    if(delegate!=nil && [delegate respondsToSelector:@selector(didFinishLoadingImage:fromCache:)])
        [delegate didFinishLoadingImage:self.image fromCache:cache];
    
    self.image = image;
}

-(void)dealloc
{
    NSLog(@"AsyncImageView : dealloc");
    
    self.delegate=nil;
    
    if(imageDownloader != nil)
    {
        imageDownloader.delegate = nil;
        [imageDownloader release];
        imageDownloader = nil;
    }
    
    [imageUrl release];
    [super dealloc];
}
@end
