#import <Foundation/Foundation.h>

@interface FriendInfo : NSObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *photoUrl;
@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, assign) BOOL bInvited;

@end
