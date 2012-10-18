#ifndef FooBar_EndPoints_h
#define FooBar_EndPoints_h

#pragma mark - Node Server Endpoints

#define Server              @"http://foobarnode.cloudfoundry.com/"

#define UsersUrl            Server @"users/"
#define AccessTokenUrl      UsersUrl @"me/"
#define MyProfileUrl        UsersUrl @"me/"
#define FeedsUrl            Server @"feeds/"
#define PhotosUrl           Server @"photoposts/"
#define CommentsUrl         Server @"comments/"
#define LikesUrl            Server @"likes/"
#define UnlikeUrl           Server @"likes/photoposts/"
#define ProductsUrl         Server @"products/"

#endif
