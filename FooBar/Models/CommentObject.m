#import "CommentObject.h"

@implementation CommentObject

@synthesize commentId, commentText, postId, created_dt, updated_dt, foobarUser;

-(void) dealloc
{
    NSLog(@"CommentObject : dealloc");
    
    [commentId release];
    [commentText release];
    [postId release];
    [created_dt release];
    [updated_dt release];
    [foobarUser release];
    
	[super dealloc];
}

@end
