#import <Foundation/Foundation.h>

#import "FooBarUser.h"
#import "CommentObject.h"

@interface Parser : NSObject

+(FooBarUser*)parseUserResponse:(NSDictionary*)responseDict;
+(CommentObject*)parseCommentResponse:(id)responseData;
+(NSArray*)parseFeedsResponse:(NSString*)response;

@end
