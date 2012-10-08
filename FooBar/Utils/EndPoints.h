#ifndef FooBar_EndPoints_h
#define FooBar_EndPoints_h

#pragma mark - Node Server Endpoints

#define Server              @"http://foobarnode.cloudfoundry.com/"

#define UsersUrl            Server @"users/"
#define FeedsUrl            Server @"feeds/"
#define PhotosUrl           Server @"photoposts/"
#define CommentsUrl         Server @"comments/"
#define LikesUrl            Server @"likes/"
#define ProductsUrl         Server @"products/"


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark Social Network Constants

//Facebook action constants
#define	kFBUsernameField						   @"username"
#define	kFBUserIdField							   @"id"
#define	kFBEmailField							   @"email"
#define	kFBAccessTokenField						   @"access_token"
#define	kFBFirstNameField						   @"first_name"
#define	kFBProfilePictureField					   @"profile_pic"
#define kFBProfilePictureURL					   @"https://graph.facebook.com/me/picture?type=normal&access_token=%@"

//twitter key values
#define kTWitterId                                 @"id"
#define kTWitterIdStr                              @"id_str"
#define kTwitterName                               @"name"
#define kTwitterProfileImgURL                      @"profile_image_url"
#define kTwitterWebsiteURL                         @"url"
#define kTwitterBio                                @"description"
#define kTwitterFollowersErrorMessage              @"Could not get you twitter friends' information. Try again."

#endif
