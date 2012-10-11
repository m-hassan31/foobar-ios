#import <Foundation/Foundation.h>

enum TWSignedRequestMethod {
    TWSignedRequestMethodGET,
    TWSignedRequestMethodPOST,
    TWSignedRequestMethodDELETE
};

typedef enum TWSignedRequestMethod TWSignedRequestMethod;

typedef
void(^TWSignedRequestHandler)
(NSData *data, NSURLResponse *response, NSError *error);

@interface TWSignedRequest : NSObject

@property (nonatomic, copy) NSString *authToken;
@property (nonatomic, copy) NSString *authTokenSecret;

// Creates a new request
- (id)initWithURL:(NSURL *)url
       parameters:(NSDictionary *)parameters
    requestMethod:(TWSignedRequestMethod)requestMethod;

// Perform the request, and notify handler of results
- (void)performRequestWithHandler:(TWSignedRequestHandler)handler;

// You should ensure that you obfuscate your keys before shipping
+ (NSString *)consumerKey;
+ (NSString *)consumerSecret;


@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSDictionary *parameters;
@property (nonatomic, assign) TWSignedRequestMethod signedRequestMethod;

@end
