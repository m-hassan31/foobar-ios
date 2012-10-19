#import "OAuthCore.h"
#import "TWSignedRequest.h"

#define TW_HTTP_METHOD_GET @"GET"
#define TW_HTTP_METHOD_POST @"POST"
#define TW_HTTP_METHOD_DELETE @"DELETE"
#define TW_HTTP_HEADER_AUTHORIZATION @"Authorization"

#warning TODO this is sample app's info change it to FooBar Twitter App
#define kTWConsumerKey @"6qhWWt8XWQOrwg5AwI6UA"
#define kTWConsumerSecret @"rht37DCZSpPThkSCC65QohT8qZ8Sn10RohpRsjefs"


//#define kTWConsumerKey @"Ha7UYF50eYNporZlKZ0fQ"
//#define kTWConsumerSecret @"JXHrNdSHlqfSCkyXzm4OJ9S1HVC0PKtzpImWU2lgCk"

@interface TWSignedRequest()

- (NSURLRequest *)_buildRequest;

@end

@implementation TWSignedRequest
@synthesize authToken = _authToken;
@synthesize authTokenSecret = _authTokenSecret;
@synthesize url;
@synthesize parameters;
@synthesize signedRequestMethod;

- (id)initWithURL:(NSURL *)aUrl
       parameters:(NSDictionary *)params
    requestMethod:(TWSignedRequestMethod)reqMethod;
{
    self = [super init];
    if (self) {
        self.url = aUrl;
        self.parameters = params;
        self.signedRequestMethod = reqMethod;
    }
    return self;
}

- (NSURLRequest *)_buildRequest
{
    NSString *method;
    
    switch (self.signedRequestMethod) {
        case TWSignedRequestMethodPOST:
            method = TW_HTTP_METHOD_POST;
            break;
        case TWSignedRequestMethodDELETE:
            method = TW_HTTP_METHOD_DELETE;
            break;
        case TWSignedRequestMethodGET:
        default:
            method = TW_HTTP_METHOD_GET;
    }
    
    //  Build our parameter string
    NSMutableString *paramsAsString = [[NSMutableString alloc] init];
    [self.parameters enumerateKeysAndObjectsUsingBlock:
     ^(id key, id obj, BOOL *stop) {
         [paramsAsString appendFormat:@"%@=%@&", key, obj];
     }];
    
    //  Create the authorization header and attach to our request
    NSData *bodyData = [paramsAsString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authorizationHeader = OAuthorizationHeader(self.url,
                                                         method,
                                                         bodyData,
                                                         [TWSignedRequest
                                                          consumerKey],
                                                         [TWSignedRequest
                                                          consumerSecret],
                                                         _authToken,
                                                         _authTokenSecret);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:self.url];
    [request setHTTPMethod:method];
    [request setValue:authorizationHeader
   forHTTPHeaderField:TW_HTTP_HEADER_AUTHORIZATION];
    [request setHTTPBody:bodyData];
    
    return request;
}

- (void)performRequestWithHandler:(TWSignedRequestHandler)handler
{
    dispatch_async(dispatch_get_global_queue
                   (DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                       NSURLResponse *response;
                       NSError *error;
                       NSData *data = [NSURLConnection
                                       sendSynchronousRequest:
                                       [self _buildRequest]
                                       returningResponse:&response
                                       error:&error];
                       handler(data, response, error);
                   });
}

// OBFUSCATE YOUR KEYS!
+ (NSString *)consumerKey
{
    NSAssert([kTWConsumerKey length] > 0,
             @"You must enter your consumer key in Build Settings.");
    return kTWConsumerKey;
}

// OBFUSCATE YOUR KEYS!
+ (NSString *)consumerSecret
{
    NSAssert([kTWConsumerSecret length] > 0,
             @"You must enter your consumer secret in Build Settings.");
    return kTWConsumerSecret;
}

-(void)dealloc
{    
    [_authToken release];
    [_authTokenSecret release];
    [url release];
    [parameters release];
    
    [super dealloc];
}

@end
