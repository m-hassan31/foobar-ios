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

-(void)signinWithUsername:(NSString*)_username
                 password:(NSString*)_password
              accountType:(enum Account_Type)acc_type
                firstname:(NSString*)firstName
                 photoUrl:(NSString*)photoUrl;
- (void)signOut;

-(void)getFeedsAtPage:(NSUInteger)_pageNum count:(NSUInteger)_count;

@end

@protocol ConnectionManagerDelegate<NSObject>

- (void)httpRequestFinished:(ASIHTTPRequest *)request;
- (void)httpRequestFailed:(ASIHTTPRequest *)request;

@end
