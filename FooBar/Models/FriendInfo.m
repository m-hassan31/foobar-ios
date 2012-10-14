#import "FriendInfo.h"

@implementation FriendInfo

@synthesize name, photoUrl, identifier, bInvited;

-(void) dealloc
{
    NSLog(@"FriendInfo : dealloc");
    
    [name release];
    [photoUrl release];
    [identifier release];
    
	[super dealloc];
}


@end
