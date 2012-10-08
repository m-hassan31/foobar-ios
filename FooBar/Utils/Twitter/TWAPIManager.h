#import <Foundation/Foundation.h>

//  The SLRequest and TWRequest share method signatures, so we can use this
//  protocol to hush any compiler warnings
@protocol GenericTwitterRequest

- (void)performRequestWithHandler:(TWRequestHandler)handler;
- (void)setAccount:(ACAccount *)account;

@end

@class ACAccount;

typedef void(^ReverseAuthResponseHandler)(NSData *responseData, NSError *error);

@interface TWAPIManager : NSObject

/**
 *  Obtains the access token and secret for |account| using either TWRequest or
 *  SLRequest.
 *
 *  There are two steps required for Reverse Auth:
 *
 *  The first sends a signed request that *you* must sign to Twitter to obtain
 *      an Authorization: header. You sign the request with your own OAuth keys,
 *      which have been granted the Reverse Auth privilege.
 *
 *  The second step uses TWRequest or SLRequest to sign and send the response to
 *      step 1 back to Twitter. The response to this request, if everything
 *      worked, will include an user's access token and secret which can then
 *      be used in conjunction with your consumer key and secret to make
 *      authenticated calls to Twitter.
 */
- (void)performReverseAuthForAccount:(ACAccount *)account
                         withHandler:(ReverseAuthResponseHandler)handler;

/**
 *  Returns an instance of either SLRequest or TWRequest, depending on runtime
 *  availability.
 */
- (id<GenericTwitterRequest>)requestWithUrl:(NSURL *)url
                                 parameters:(NSDictionary *)dict
                              requestMethod:(TWRequestMethod )requestMethod;

/**
 * Returns true if there are local Twitter accounts available.
 */
+ (BOOL)isLocalTwitterAccountAvailable;

@end
