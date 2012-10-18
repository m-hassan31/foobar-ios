#import "SocialUser.h"
#import "FooBarConstants.h"
#import "EndPoints.h"
#import "EndPointsKeys.h"

@implementation SocialUser

@synthesize socialAccountType, socialId, username, firstname, photoUrl, accessToken;

+(void)saveCurrentUser:(SocialUser*)user
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSData *myEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:user];
    [prefs setObject:myEncodedObject forKey:kCurrentLoggedinSocialuser];
}

+(SocialUser*)currentUser
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSData *myEncodedObject = [prefs objectForKey:kCurrentLoggedinSocialuser];
    SocialUser *user = (SocialUser*)[NSKeyedUnarchiver unarchiveObjectWithData:myEncodedObject];
    return user;
}

+(void)clearCurrentUser
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:kCurrentLoggedinSocialuser];
}

/* This code has been added to support encoding and decoding my objecst */
-(id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if ( self != nil )
    {
        //decode the properties
        self.socialAccountType = [[decoder decodeObjectForKey:@"socialAccountType"] integerValue];
        self.socialId = [decoder decodeObjectForKey:@"socialId"];
        self.username = [decoder decodeObjectForKey:kUsername];
        self.firstname = [decoder decodeObjectForKey:@"firstname"];
        self.photoUrl = [decoder decodeObjectForKey:kPhotoUrl];
        self.accessToken = [decoder decodeObjectForKey:kAccessToken];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder
{
    //Encode the properties of the object
    [encoder encodeObject:[NSNumber numberWithUnsignedInt:self.socialAccountType] forKey:@"socialAccountType"];
    [encoder encodeObject:self.socialId forKey:@"socialId"];
    [encoder encodeObject:self.username forKey:kUsername];
    if(self.firstname)
        [encoder encodeObject:self.firstname forKey:@"firstname"];
    [encoder encodeObject:self.photoUrl forKey:kPhotoUrl];
    if(self.accessToken)
        [encoder encodeObject:self.accessToken forKey:kAccessToken];
}

-(BOOL)authenticated
{
    return (![self.socialId isEqualToString:@""] && ![self.accessToken isEqualToString:@""]);
}

-(void)dealloc
{
    [socialId release];
    [username release];
    [firstname release];
    [photoUrl release];
    [accessToken release];
    [super dealloc];
}

@end
