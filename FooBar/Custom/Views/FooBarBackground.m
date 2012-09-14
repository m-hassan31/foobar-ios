//
//  FooBarBackground.m
//  FooBar
//
//  Created by Manigandan Parthasarathi on 14/09/12.
//
//

#import "FooBarBackground.h"

@implementation FooBarBackground

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        image = [UIImage imageNamed:@"Background.png"];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [image drawInRect:rect];
}

@end
