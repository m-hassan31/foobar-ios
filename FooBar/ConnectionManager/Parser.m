#import "Parser.h"
#import "SBJSON.h"
#import "EndPoints.h"
#import "EndPointsKeys.h"
#import "FeedObject.h"

@implementation Parser

+(FooBarUser*)parseUserResponse:(NSDictionary*)responseDict
{
    // Parse User info
    id userData = [responseDict objectForKey:kCreator];
    if(userData && ![userData isKindOfClass:[NSNull class]] && [userData isKindOfClass:[NSDictionary class]])
    {
        FooBarUser *foobarUser = [[[FooBarUser alloc] init] autorelease];
        NSDictionary *userDict = (NSDictionary*)userData;
        foobarUser.userId = (NSString*)[userDict objectForKey:kId];
        foobarUser.username = (NSString*)[userDict objectForKey:kUsername];
        foobarUser.lastname =  (NSString*)[userDict objectForKey:kLastname];
        
        NSString *imageUrl = (NSString*)[userDict objectForKey:kPhotoUrl];
        foobarUser.photoUrl = imageUrl?imageUrl:@"";
        
        foobarUser.accountType = [(NSString*)[userDict objectForKey:kAccountType] isEqualToString:@"facebook"]?FacebookAccount:TwitterAccount;
        foobarUser.created_dt = (NSString*)[userDict objectForKey:kCreatedDate];
        foobarUser.updated_dt = (NSString*)[userDict objectForKey:kUpdatedDate];
        return foobarUser;
    }
    
    return nil;
}

+(CommentObject*)parseCommentResponse:(id)responseData
{
    NSDictionary *commentDict = nil;
    
    if(responseData && ![responseData isKindOfClass:[NSNull class]] && [responseData isKindOfClass:[NSDictionary class]])
    {
        // used while feeds parsing
        commentDict = (NSDictionary*)responseData;                            
    }
    else if(responseData && ![responseData isKindOfClass:[NSNull class]] && [responseData isKindOfClass:[NSString class]])
    {
        //used directly during comment action
        NSString *responseString = (NSString*)responseData;
        SBJSON *sbJSON = [SBJSON new];
        id parsedData = [sbJSON objectWithString:responseString];
        if(parsedData && ![parsedData isKindOfClass:[NSNull class]] && [parsedData isKindOfClass:[NSDictionary class]])
        {
            commentDict = (NSDictionary*)parsedData;
        }
        else
        {
            return nil;
        }
    }
    else
    {
        return nil;
    }
    
    CommentObject *commentObject = [[[CommentObject alloc] init] autorelease];
    commentObject.commentId = (NSString*)[commentDict objectForKey:kId];
    commentObject.commentText = (NSString*)[commentDict objectForKey:kComments_Text];
    //commentObject.postId = feedObject.feedId;
    commentObject.created_dt = (NSString*)[commentDict objectForKey:kCreatedDate];
    commentObject.updated_dt = (NSString*)[commentDict objectForKey:kUpdatedDate];
    
    // Parse User info
    FooBarUser *foobaruser = [Parser parseUserResponse:commentDict];
    if(foobaruser)
    {
        commentObject.foobarUser = foobaruser;
        return commentObject;
    }
    return nil;
}

+(NSArray*)parseFeedsResponse:(NSString*)response
{
    NSMutableArray *feedsArray = [[[NSMutableArray alloc] init] autorelease];
    SBJSON *sbJSON = [SBJSON new];
    id parsedData = [sbJSON objectWithString:response];
    if(parsedData && ![parsedData isKindOfClass:[NSNull class]] && [parsedData isKindOfClass:[NSArray class]])
    {
        NSArray *parsedArray = (NSArray*)parsedData;
        for(id anObj in parsedArray)
        {
            if(anObj && ![anObj isKindOfClass:[NSNull class]] && [anObj isKindOfClass:[NSDictionary class]])
            {
                NSDictionary *parsedDict = (NSDictionary*)anObj;
                
                FeedObject *feedObject = [[[FeedObject alloc] init] autorelease];
                
                // Parse User info
                FooBarUser *foobaruser = [Parser parseUserResponse:parsedDict];
                if(foobaruser)
                {
                    feedObject.foobarUser = foobaruser;
                }
                else
                {
                    return nil;
                }
                
                // Parse Feed info
                feedObject.feedId = (NSString*)[parsedDict objectForKey:kId];
                feedObject.created_dt = (NSString*)[parsedDict objectForKey:kCreatedDate];
                feedObject.updated_dt = (NSString*)[parsedDict objectForKey:kUpdatedDate];
                feedObject.productId = (NSString*)[parsedDict objectForKey:kFeeds_ProductId];
                feedObject.photoCaption = (NSString*)[parsedDict objectForKey:kFeeds_PhotoCaption];
                feedObject.commentsCount = [(NSString*)[parsedDict objectForKey:kFeeds_CommentsCount] integerValue];
                feedObject.likesCount = [(NSString*)[parsedDict objectForKey:kFeeds_LikesCount] integerValue];
                
                // Parse Photo info
                id photoData = [parsedDict objectForKey:kFeeds_Photo];
                if(photoData && ![photoData isKindOfClass:[NSNull class]] && [photoData isKindOfClass:[NSDictionary class]])
                {
                    FooBarPhoto *foobarPhoto = [[FooBarPhoto alloc] init];
                    NSDictionary *photoDict = (NSDictionary*)photoData;                    
                    foobarPhoto.photoId = (NSString*)[photoDict objectForKey:kId];
                    
                    NSString *imageUrl = (NSString*)[photoDict objectForKey:kUrl];
                    if(imageUrl)
                        foobarPhoto.url = [NSString stringWithFormat:@"http://foobarnode.cloudfoundry.com%@", imageUrl];
                    else
                        foobarPhoto.url = @"";
                    
                    foobarPhoto.width =  [(NSString*)[photoDict objectForKey:kFeeds_Width] integerValue];
                    foobarPhoto.height =  [(NSString*)[photoDict objectForKey:kFeeds_Height] integerValue];
                    foobarPhoto.filename = (NSString*)[photoDict objectForKey:kFeeds_Filename];
                    feedObject.foobarPhoto = foobarPhoto;
                    [foobarPhoto release];
                }
                else
                {
                    return nil;
                }
                
                // Parse Comments Info
                id parsedCommentsData = (NSArray*)[parsedDict objectForKey:kFeeds_Comments];
                if(parsedCommentsData && ![parsedCommentsData isKindOfClass:[NSNull class]] && [parsedCommentsData isKindOfClass:[NSArray class]])
                {
                    NSMutableArray *commentsArray = [[[NSMutableArray alloc] init] autorelease];
                    NSArray *parsedCommentsArray = (NSArray*)parsedCommentsData;
                    for(id anObj in parsedCommentsArray)
                    {
                        /*if(anObj && ![anObj isKindOfClass:[NSNull class]] && [anObj isKindOfClass:[NSDictionary class]])
                        {
                            NSDictionary *commentDict = (NSDictionary*)anObj;                            
                            CommentObject *commentObject = [[CommentObject alloc] init];
                            commentObject.commentId = (NSString*)[commentDict objectForKey:kId];
                            commentObject.commentText = (NSString*)[commentDict objectForKey:kComments_Text];
                            commentObject.postId = feedObject.feedId;
                            commentObject.created_dt = (NSString*)[commentDict objectForKey:kCreatedDate];
                            commentObject.updated_dt = (NSString*)[commentDict objectForKey:kUpdatedDate];
                            
                            // Parse User info
                            FooBarUser *foobaruser = [Parser parseUserResponse:commentDict];
                            if(foobaruser)
                            {
                                commentObject.foobarUser = foobaruser;
                            }
                            else
                            {
                                return nil;
                            }
                            
                            [commentsArray addObject:commentObject];
                            [commentObject release];
                        }
                        else
                        {
                            return nil;
                        }*/
                        
                        CommentObject *commentObject = [Parser parseCommentResponse:anObj];
                        if(commentObject)
                        {
                            [commentsArray addObject:commentObject];
                        }
                        else
                        {
                            return nil;
                        }
                    }
                    feedObject.commentsArray = commentsArray;
                }
                else
                {
                    return nil;
                }
                
                [feedsArray addObject:feedObject];
            }
            else
            {
                return nil;
            }
        }
    }
    
    return feedsArray;
}

@end
