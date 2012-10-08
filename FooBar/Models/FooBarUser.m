#import "FooBarUser.h"

@implementation FooBarUser

@synthesize userId, username, lastname, photoUrl, accountType, created_dt, updated_dt;

-(void)dealloc
{
    [userId release];
    [username release];
    [lastname release];
    [photoUrl release];
    [created_dt release];
    [updated_dt release];
        
    [super dealloc];
}

@end