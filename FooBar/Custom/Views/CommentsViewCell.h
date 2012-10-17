#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import "TTTAttributedLabel.h"
#import "CommentObject.h"

@protocol CommentsViewCellDelegate <NSObject>

@optional

-(void)goToProfile:(NSString*)userId;

@end

@interface CommentsViewCell : UITableViewCell
{
    AsyncImageView *cellImageView;
    UIButton *userNameButton;
    TTTAttributedLabel *_commentLabel;
    
    NSString *_commentText;
    CommentObject* commentObject;
    id<CommentsViewCellDelegate> delegate;
}

@property(nonatomic, assign) id<CommentsViewCellDelegate> delegate;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@property (nonatomic, retain) CommentObject* commentObject;
@property (nonatomic, retain) NSString *commentText;
@property (nonatomic, retain) TTTAttributedLabel *commentLabel;

+(CGFloat)heightForCellWithText:(NSString *)text;
-(void)setRowWithCommentObject:(CommentObject*)commentObj delegate:(id)_delegate labelHeight:(CGFloat)height;

@end
