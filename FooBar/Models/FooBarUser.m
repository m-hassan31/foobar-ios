#import "FooBarUser.h"
#import "FooBarConstants.h"
#import "EndPointsKeys.h"

@implementation FooBarUser

@synthesize userId, username, firstname, photoUrl, socialAccountType, created_dt, updated_dt, socialId, accessToken;

+(void)saveCurrentUser:(FooBarUser*)user
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSData *myEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:user];
    [prefs setObject:myEncodedObject forKey:kCurrentLoggedinFooBaruser];
}

+(FooBarUser*)currentUser
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSData *myEncodedObject = [prefs objectForKey:kCurrentLoggedinFooBaruser];
    FooBarUser *user = (FooBarUser*)[NSKeyedUnarchiver unarchiveObjectWithData:myEncodedObject];
    return user;
}

+(void)clearCurrentUser
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:kCurrentLoggedinFooBaruser];
}

/* This code has been added to support encoding and decoding my objecst */
-(id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if ( self != nil )
    {
        //decode the properties
        self.userId = [decoder decodeObjectForKey:kId];
        self.username = [decoder decodeObjectForKey:kUsername];
        self.firstname = [decoder decodeObjectForKey:kFirstname];
        self.photoUrl = [decoder decodeObjectForKey:kPhotoUrl];
        self.socialAccountType = [[decoder decodeObjectForKey:kAccountType] integerValue];
        self.socialId = [decoder decodeObjectForKey:kSocialId];
        self.accessToken = [decoder decodeObjectForKey:kAccessToken];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder
{
    //Encode the properties of the object
    [encoder encodeObject:self.userId forKey:kId];
    [encoder encodeObject:self.username forKey:kUsername];
    if(self.firstname)
    [encoder encodeObject:self.firstname forKey:kFirstname];
    [encoder encodeObject:self.photoUrl forKey:kPhotoUrl];
    [encoder encodeObject:[NSNumber numberWithUnsignedInt:self.socialAccountType] forKey:kAccountType];
    [encoder encodeObject:self.socialId forKey:kSocialId];
    [encoder encodeObject:self.accessToken forKey:kAccessToken];
}

-(BOOL)authenticated
{
    return (![self.socialId isEqualToString:@""] && ![self.accessToken isEqualToString:@""]);
}

-(void)dealloc
{
    [userId release];
    [username release];
    [firstname release];
    [photoUrl release];
    [socialId release];
    [accessToken release];
    [super dealloc];
}

@end