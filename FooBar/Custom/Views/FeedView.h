//
//  FeedView.h
//  FooBar
//
//  Created by Pramati technologies on 9/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMQuiltViewCell.h"

@interface FeedView : TMQuiltViewCell

@property (nonatomic, retain) UIImageView *photoView;
@property (nonatomic, retain) UIImageView *heart;
@property (nonatomic, retain) UILabel *likesCountLabel;
@property (nonatomic, retain) UIImageView *profilePicView;
@property (nonatomic, retain) UILabel *usernameLabel;

@end