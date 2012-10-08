#import <Foundation/Foundation.h>

#import "FooBarUser.h"

@interface Parser : NSObject

+(FooBarUser*)parseUserResponse:(NSDictionary*)responseDict;
+(NSArray*)parseFeedsResponse:(NSString*)response;

@end
