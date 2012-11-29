#ifndef FooBar_EndPointsKeys_h
#define FooBar_EndPointsKeys_h

// General Request/Status Keys
#define kRequestKey                         @"request"
#define kResponseKey                        @"response"
#define kStatusKey                          @"status"
#define kErrorKey                           @"error"

// General Response Keys
#define kId                                 @"_id"
#define kAccessToken                        @"access_token"
#define kCreatedDate                        @"createdAt"
#define kUpdatedDate                        @"updatedAt"
#define kUrl                                @"url"

// User Response keys
#define kCreator                            @"creator"
#define kUsername                           @"username"
#define kFirstname                          @"first_name"
#define kPhotoUrl                           @"photo_url"
#define kAccountType                        @"account_type"
#define kSocialId                           @"account_id"

// FeedsUrl Response Keys
#define kFeeds_ProductId                    @"product_id"
#define kFeeds_Comments                     @"comments"
#define kFeeds_CommentsCount                @"comments_cnt"
#define kFeeds_LikedBy                      @"liked_by"
#define kFeeds_LikesCount                   @"likes_cnt"
#define kFeeds_PhotoCaption                 @"photo_caption"
#define kFeeds_Photo                        @"photo"
#define kFeeds_Width                        @"width"
#define kFeeds_Height                       @"height"
#define kFeeds_Filename                     @"filename"

// Comments Response keys
#define kComments_Text                      @"text"

// FooBar Products Keys
#define kProductsId                         @"id"
#define kProductsName                       @"name"
#define kProductsDescription                @"desc"

#pragma mark - Social Network Constants

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
