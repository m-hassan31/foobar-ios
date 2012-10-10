#import <Foundation/Foundation.h>

#import "FeedObject.h"
#import "FooBarUser.h"
#import "CommentObject.h"

@interface Parser : NSObject

+(FooBarUser*)parseUserResponse:(NSDictionary*)responseDict;
+(CommentObject*)parseCommentResponse:(id)responseData;
+(NSArray*)parseFeedsResponse:(NSString*)response;
+(FeedObject*)parseUploadResponse:(NSString*)response;
+(NSArray*)parseProductsresponse:(NSString*)response;

@end
