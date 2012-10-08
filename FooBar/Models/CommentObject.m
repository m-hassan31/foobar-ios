#import "CommentObject.h"

@implementation CommentObject

@synthesize commentId, commentText, created_dt, updated_dt, foobarUser;

-(NSString*)formattedCommentText
{
    return [NSString stringWithFormat:@"%@", self.commentText];
}

-(void) dealloc
{
    NSLog(@"CommentObject : dealloc");
    
    [commentId release];
    [commentText release];
    [created_dt release];
    [updated_dt release];
    [foobarUser release];
    
	[super dealloc];
}

@end
