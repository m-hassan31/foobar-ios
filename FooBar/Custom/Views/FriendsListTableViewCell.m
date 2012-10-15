#import "FriendsListTableViewCell.h"

@implementation FriendsListTableViewCell

@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
	NSLog(@"InviteFriendsTableViewCell: initWithStyle:reuseIdentifier");
	
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self)
    {
        self.contentView.backgroundColor = [UIColor clearColor];
        
        cellImageView= [[AsyncImageView alloc] init];
        [self.contentView addSubview:cellImageView];
        [cellImageView release];
        
        cellLabel=[[UILabel alloc] init];
        [cellLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [cellLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:cellLabel];
        [cellLabel release];
        
        inviteButton =  [UIButton buttonWithType:UIButtonTypeCustom];
        inviteButton.frame = CGRectMake (235, 6, 75, 26);
        [inviteButton addTarget:self action:@selector(invitePressed) forControlEvents:UIControlEventTouchUpInside];
        [inviteButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
        [inviteButton setBackgroundImage:[UIImage imageNamed:@"Invite.png"] forState:UIControlStateNormal];
        [inviteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [inviteButton setTitle:@"Invite" forState:UIControlStateNormal];
        [inviteButton setBackgroundImage:[UIImage imageNamed:@"Invited.png"] forState:UIControlStateDisabled];
        [inviteButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        [inviteButton setTitle:@"Invited" forState:UIControlStateDisabled];
        [self.contentView addSubview:inviteButton];
    }
    
    return self;
}

-(void)invitePressed
{
    NSLog(@"InviteFriendsTableViewCell: invitePressed");
    
    if(delegate && [delegate respondsToSelector:@selector(inviteFriendAtIndex:)])
        [delegate inviteFriendAtIndex:index];
}

-(void)layoutSubviews
{
	[super layoutSubviews];
	
	CGRect contentRect = self.contentView.bounds;
	CGFloat boundsX = contentRect.origin.x;
	CGFloat boundsY = contentRect.origin.y;
	CGFloat contentHeight=self.contentView.frame.size.height;
	CGFloat contentWidth=self.contentView.frame.size.width;
	CGRect frame;
	frame= CGRectMake(boundsX+6, boundsY+6, 32, 32);
	cellImageView.frame=frame;
	frame=CGRectMake(contentHeight, boundsY, contentWidth-(contentHeight+15+80), 20);
	cellLabel.frame=frame;
	CGPoint center=cellLabel.center;
	center.y=self.contentView.center.y;
	cellLabel.center=center;
}

-(void)setRowForIndex:(int)row withFriendInfo:(FriendInfo*)friendInfo
{
    index = row;
	cellLabel.text= friendInfo.name;
    [cellImageView setImage:[UIImage imageNamed:@"DefaultUser.png"]];//defaultProfileImage
    if(friendInfo.photoUrl != nil)
        [cellImageView setImageUrl:friendInfo.photoUrl];
    [inviteButton setEnabled:!friendInfo.bInvited];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

#pragma mark -
#pragma mark memory management

- (void)dealloc
{
    NSLog(@"InviteFriendsTableViewCell: dealloc");
    
    self.delegate = nil;
    cellImageView.image = nil;
    cellLabel = nil;
    [super dealloc];
}

@end
