#import <Foundation/Foundation.h>
#import "FooBarPhoto.h"
#import "FooBarUser.h"

@interface FeedObject : NSObject

@property(nonatomic, retain) FooBarUser *foobarUser;
@property(nonatomic, retain) NSString *feedId;
@property(nonatomic, retain) NSString *created_dt;
@property(nonatomic, retain) NSString *updated_dt;
@property(nonatomic, retain) NSString *productId;
@property(nonatomic, retain) NSString *photoCaption;
@property(nonatomic, retain) FooBarPhoto *foobarPhoto;
@property(nonatomic, retain) NSMutableArray *commentsArray;
@property(nonatomic, assign) NSUInteger likesCount;

@end
