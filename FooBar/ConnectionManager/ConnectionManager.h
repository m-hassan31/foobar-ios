#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"
#import <MapKit/MapKit.h>
#import <CoreData/CoreData.h>
#import "SAProgressHUD.h"

@protocol ConnectionManagerDelegate;

@interface ConnectionManager : NSObject
<NSURLConnectionDelegate, NSURLConnectionDataDelegate, SAProgressHUDDelegate>
{	
	id<ConnectionManagerDelegate> delegate;
	SAProgressHUD* hud;
}

@property (nonatomic, assign) id<ConnectionManagerDelegate> delegate;

- (void)loginWithUsername:(NSString*)name withPassword:(NSString*)pass;
- (void)signOut;

@end

@protocol ConnectionManagerDelegate<NSObject>

- (void)httpRequestFinished:(ASIHTTPRequest *)request;
- (void)httpRequestFailed:(ASIHTTPRequest *)request;

@end
