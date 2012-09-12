//
//  CommentsViewCell.h
//  Fontli
//
//  Created by Pramati technologies on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import "TTTAttributedLabel.h"
#import "CommentObject.h"

@protocol CommentsViewCellDelegate <NSObject>

@optional

-(void)goToProfile:(NSString*)profileId;
-(void)longPressAction:(NSString*)text;

@end

@interface CommentsViewCell : UITableViewCell
{
    AsyncImageView *cellImageView;
    UIImageView *profilePicBorder;
    UIButton *userNameButton;
    UILabel *timeLabel;
    TTTAttributedLabel *_summaryLabel;
    
    NSString *_summaryText;
    CommentObject* commentObject;
    id<CommentsViewCellDelegate> delegate;
}

@property(nonatomic, assign) id<CommentsViewCellDelegate> delegate;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@property (nonatomic, retain) CommentObject* commentObject;
@property (nonatomic, retain) NSString *summaryText;
@property (nonatomic, retain) TTTAttributedLabel *summaryLabel;

+(CGFloat)heightForCellWithText:(NSString *)text;
-(void)cleanUpCellBeforeNextWrite;
-(void)setRowWithCommentObject:(CommentObject*)commentObj withTextHeight:(CGFloat)height delegate:(id)_delegate;

@end
