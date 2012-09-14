#import "CommentObject.h"

@implementation CommentObject

@synthesize commentId;
@synthesize username;
@synthesize user_id;
@synthesize userPicURL;
@synthesize commentText;
@synthesize created_dt;

- (id)initWithCommentId:(NSString*)_id
              userName:(NSString*)_userName
                userId:(NSString*)_userId
            userPicURL:(NSString*)_userPicURL
           commentText:(NSString*)_commentText
            created_dt:(NSString*)_created_dt
{
    self = [super init];
    
    if (!self)
    {
        return nil;
    }
    
    NSLog(@"CommentObject : initWithCommentId");

    // Custom initialization
    self.commentId = _id;
    self.username = _userName;
    self.user_id = _userId;
    self.userPicURL = _userPicURL;
    self.commentText = _commentText;
    self.created_dt = _created_dt;
        
    return self;
}

-(NSString*)formattedCommentText
{
    return [NSString stringWithFormat:@"%@", self.commentText];
}

-(void) dealloc
{
    NSLog(@"CommentObject : dealloc");
    
    [commentId release];
    [username release];
    [user_id release];
    [userPicURL release];
    [commentText release];
    [created_dt release];
    
	[super dealloc];
}

@end
