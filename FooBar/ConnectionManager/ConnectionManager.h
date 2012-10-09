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
-(void)getFeedsAtPage:(NSUInteger)_pageNum count:(NSUInteger)_count;
-(void)getFooBarProducts;
-(void)uploadPhoto:(UIImage*)image withProductId:(NSString*)productId;

@end

@protocol ConnectionManagerDelegate<NSObject>

- (void)httpRequestFinished:(ASIHTTPRequest *)request;
- (void)httpRequestFailed:(ASIHTTPRequest *)request;

@end
