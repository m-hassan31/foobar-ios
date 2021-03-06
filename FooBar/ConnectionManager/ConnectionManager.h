#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"
#import <MapKit/MapKit.h>
#import <CoreData/CoreData.h>
#import "SAProgressHUD.h"
#import "FooBarUtils.h"

@protocol ConnectionManagerDelegate;

@interface ConnectionManager : NSObject
<NSURLConnectionDelegate, NSURLConnectionDataDelegate, SAProgressHUDDelegate>
{	
	id<ConnectionManagerDelegate> delegate;
	SAProgressHUD* hud;
}

@property (nonatomic, assign) id<ConnectionManagerDelegate> delegate;

-(ASIHTTPRequest*)getRequestWithAuthHeader:(NSURL*)url;

-(void)signin;
-(void)getProfile;
-(void)getProfile:(BOOL)showHud;
-(void)getUserProfile:(NSString*)profileId;
-(void)getFeedsAtPage:(NSUInteger)_pageNum count:(NSUInteger)_count;
-(void)getFooBarProducts;
-(void)uploadPhoto:(UIImage*)image withProductId:(NSString*)productId;
-(void)updatePost:(NSString*)postId withCaption:(NSString*)caption;
-(void)comment:(NSString*)text onPost:(NSString*)postId;
-(void)deleteComment:(NSString*)commentId;
-(void)likePost:(NSString*)postId;
-(void)unlikePost:(NSString*)postId;

@end

@protocol ConnectionManagerDelegate<NSObject>

- (void)httpRequestFinished:(ASIHTTPRequest *)request;
- (void)httpRequestFailed:(ASIHTTPRequest *)request;

@end
