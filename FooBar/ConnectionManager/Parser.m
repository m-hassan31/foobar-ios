#import "Parser.h"
#import "SBJSON.h"
#import "EndPoints.h"
#import "EndPointsKeys.h"
#import "FooBarProduct.h"

@implementation Parser

+(FooBarUser*)parseUserResponse:(id)responseData
{
    NSDictionary *userDict = nil;
    
    if(responseData && ![responseData isKindOfClass:[NSNull class]] && [responseData isKindOfClass:[NSDictionary class]])
    {
        // used while feeds parsing
        NSDictionary *parsedDict = (NSDictionary*)responseData;
        id creatorData = [parsedDict objectForKey:kCreator];
        if(creatorData && ![creatorData isKindOfClass:[NSNull class]] && [creatorData isKindOfClass:[NSDictionary class]])
        {
            userDict = (NSDictionary*)creatorData;
        }
        else
        {
            return nil;
        }
    }
    else if(responseData && ![responseData isKindOfClass:[NSNull class]] && [responseData isKindOfClass:[NSString class]])
    {
        //used directly while getting profile
        NSString *responseString = (NSString*)responseData;
        SBJSON *sbJSON = [SBJSON new];
        id parsedData = [sbJSON objectWithString:responseString];
        [sbJSON release];
        if(parsedData && ![parsedData isKindOfClass:[NSNull class]] && [parsedData isKindOfClass:[NSDictionary class]])
        {
            userDict = (NSDictionary*)parsedData;
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
    
    // Parse User info
    FooBarUser *foobarUser = [[[FooBarUser alloc] init] autorelease];
    foobarUser.userId = (NSString*)[userDict objectForKey:kId];
    foobarUser.username = (NSString*)[userDict objectForKey:kUsername];
    foobarUser.firstname =  (NSString*)[userDict objectForKey:kFirstname];
    
    NSString *imageUrl = (NSString*)[userDict objectForKey:kPhotoUrl];
    foobarUser.photoUrl = imageUrl?imageUrl:@"";
    
    foobarUser.accountType = [(NSString*)[userDict objectForKey:kAccountType] isEqualToString:@"facebook"]?FacebookAccount:TwitterAccount;
    foobarUser.created_dt = (NSString*)[userDict objectForKey:kCreatedDate];
    foobarUser.updated_dt = (NSString*)[userDict objectForKey:kUpdatedDate];
    return foobarUser;
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
                [sbJSON release];
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
            [sbJSON release];
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
                
                // Parse Likes Info
                id parsedLikesData = (NSArray*)[parsedDict objectForKey:kFeeds_LikedBy];
                if(parsedLikesData && ![parsedLikesData isKindOfClass:[NSNull class]] && [parsedLikesData isKindOfClass:[NSArray class]])
                {
                    NSMutableArray *likesArray = [[NSMutableArray alloc] initWithArray:(NSArray*)parsedLikesData];
                    feedObject.likedUsersArray = likesArray;
                    [likesArray release];
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

+(FeedObject*)parseUploadResponse:(NSString*)response
{
    SBJSON *sbJSON = [SBJSON new];
    id parsedDict = [sbJSON objectWithString:response];
            [sbJSON release];
    if(parsedDict && ![parsedDict isKindOfClass:[NSNull class]] && [parsedDict isKindOfClass:[NSDictionary class]])
    {       
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
        feedObject.likesCount = [(NSString*)[parsedDict objectForKey:kFeeds_LikesCount] integerValue];
        
        // Parse Photo info
        id photoData = [parsedDict objectForKey:kFeeds_Photo];
        if(photoData && ![photoData isKindOfClass:[NSNull class]] && [photoData isKindOfClass:[NSDictionary class]])
        {
            FooBarPhoto *foobarPhoto = [[[FooBarPhoto alloc] init] autorelease];
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
            return  feedObject;
        }
    }
    return nil;
}

+(NSArray*)parseProductsresponse:(NSString*)response
{
    NSMutableArray *productsArray = [[[NSMutableArray alloc] init] autorelease];
    SBJSON *sbJSON = [SBJSON new];
    id parsedData = [sbJSON objectWithString:response];
            [sbJSON release];
    if(parsedData && ![parsedData isKindOfClass:[NSNull class]] && [parsedData isKindOfClass:[NSArray class]])
    {
        NSArray *parsedArray = (NSArray*)parsedData;
        for(id anObj in parsedArray)
        {
            if(anObj && ![anObj isKindOfClass:[NSNull class]] && [anObj isKindOfClass:[NSDictionary class]])
            {
                NSDictionary *parsedDict = (NSDictionary*)anObj;
                
                FooBarProduct *foobarProduct = [[[FooBarProduct alloc] init] autorelease];
                
                // Parse Product info
                foobarProduct.productId = [[parsedDict objectForKey:kProductsId] stringValue];
                foobarProduct.name = (NSString*)[parsedDict objectForKey:kProductsName];
                foobarProduct.description = (NSString*)[parsedDict objectForKey:kProductsDescription];
                
                [productsArray addObject:foobarProduct];
            }
        }
        return productsArray;
    }
                
    return nil;
}

@end
