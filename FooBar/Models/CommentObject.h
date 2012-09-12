//
//  CommentObject.h
//  Fontli
//
//  Created by Pramati technologies on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentObject : NSObject
{
    NSString *commentId;
    NSString *username;
    NSString *user_id;
    NSString *userPicURL;
    NSString *commentText;
    NSString *created_dt;
}

@property(nonatomic, retain) NSString *commentId;
@property(nonatomic, retain) NSString *username;
@property(nonatomic, retain) NSString *user_id;
@property(nonatomic, retain) NSString *userPicURL;
@property(nonatomic, retain) NSString *commentText;
@property(nonatomic, retain) NSString *created_dt;

- (id)initWithCommentId:(NSString*)_id
               userName:(NSString*)_userName
                 userId:(NSString*)_userId
             userPicURL:(NSString*)_userPicURL
            commentText:(NSString*)_commentText
             created_dt:(NSString*)_created_dt;

-(NSString*)formattedCommentText;

@end