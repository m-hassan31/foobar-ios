#import "FeedObject.h"

@implementation FeedObject

@synthesize foobarUser, feedId, created_dt, updated_dt, productId, photoCaption, foobarPhoto, commentsArray, likesCount;

-(void)dealloc
{
    [foobarUser release];
    [feedId release];
    [created_dt release];
    [updated_dt release];
    [photoCaption release];
    [foobarPhoto release];
    [commentsArray release];
    
    [super dealloc];
}

@end
