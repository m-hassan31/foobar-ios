#import <Foundation/Foundation.h>
#import "FooBarUser.h"

@interface CommentObject : NSObject

@property(nonatomic, retain) NSString *commentId;
@property(nonatomic, retain) NSString *commentText;
@property(nonatomic, retain) NSString *created_dt;
@property(nonatomic, retain) NSString *updated_dt;
@property(nonatomic, retain) FooBarUser *foobarUser;

-(NSString*)formattedCommentText;

@end