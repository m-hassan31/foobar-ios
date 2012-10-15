#import "FriendInfo.h"

@implementation FriendInfo

@synthesize name, photoUrl, identifier, bInvited;

- (NSComparisonResult) compareContactNameWith:(FriendInfo*)otherFriendInfo
{
	return [self.name caseInsensitiveCompare: otherFriendInfo.name];
}

-(void) dealloc
{
    NSLog(@"FriendInfo : dealloc");
    
    [name release];
    [photoUrl release];
    [identifier release];
    
	[super dealloc];
}

@end