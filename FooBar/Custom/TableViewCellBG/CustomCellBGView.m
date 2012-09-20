//
//  PageCellBackground.m
//  TableDesignRevisited
//
//  Created by Matt Gallagher on 27/04/09.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  This software is provided 'as-is', without any express or implied
//  warranty. In no event will the authors be held liable for any damages
//  arising from the use of this software. Permission is granted to anyone to
//  use this software for any purpose, including commercial applications, and to
//  alter it and redistribute it freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation would be
//     appreciated but is not required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source
//     distribution.
//

#import "CustomCellBGView.h"
#import "RoundRect.h"
#import <QuartzCore/QuartzCore.h>

static CGGradientRef PageCellBackgroundGradient(BOOL selected)
{
	static CGGradientRef backgroundGradient = NULL;
	static CGGradientRef selectedBackgroundGradient = NULL;
	
	if ((!selected && !backgroundGradient) ||
		(selected && !selectedBackgroundGradient))
	{
		UIColor *contentColorTop;
		UIColor *contentColorBottom;
		if (selected)
		{
			contentColorTop = [UIColor colorWithRed:182.0/255.0 green:49.0/255.0 blue:37.0/255.0 alpha:1.0];
			contentColorBottom = [UIColor colorWithRed:182.0/255.0 green:49.0/255.0 blue:37.0/255.0 alpha:1.0];
		}
		else
		{
			contentColorTop = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
			contentColorBottom = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0];
		}

		CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
		CGFloat backgroundColorComponents[3][4];
		memcpy(
			backgroundColorComponents[0],
			CGColorGetComponents(contentColorTop.CGColor),
			sizeof(CGFloat) * 4);
		memcpy(
			backgroundColorComponents[1],
			CGColorGetComponents(contentColorTop.CGColor),
			sizeof(CGFloat) * 4);
		memcpy(
			backgroundColorComponents[2],
			CGColorGetComponents(contentColorBottom.CGColor),
			sizeof(CGFloat) * 4);
		
		const CGFloat endpointLocations[3] = {0.0, 0.35, 1.0};
		CGGradientRef gradient =
			CGGradientCreateWithColorComponents(
				colorspace,
				(const CGFloat *)backgroundColorComponents,
				endpointLocations,
				3);
		CFRelease(colorspace);
		
		if (selected)
		{
			selectedBackgroundGradient = gradient;
		}
		else
		{
			backgroundGradient = gradient;
		}
	}
	
	if (selected)
	{
		return selectedBackgroundGradient;
	}
	
	return backgroundGradient;
}

@implementation CustomCellBGView

@synthesize position;
@synthesize strokeColor;

//
// positionForIndexPath:inTableView:
//
// Parameters:
//    anIndexPath - the indexPath of a cell
//    aTableView; - the table view for the cell
//
// returns the CustomCellGroupPosition for the indexPath in the table view
//
+ (CustomCellGroupPosition)positionForIndexPath:(NSIndexPath *)anIndexPath
	inTableView:(UITableView *)aTableView;
{
	CustomCellGroupPosition result;

	if ([anIndexPath row] != 0)
	{
		result = CustomCellGroupPositionMiddle;
	}
	else
	{
		result = CustomCellGroupPositionTop;
	}
	
	UITableViewController *pageViewController =
		(UITableViewController *)[aTableView delegate];	
	if ([anIndexPath row] ==
		[pageViewController tableView:aTableView numberOfRowsInSection:anIndexPath.section] - 1)
	{
		if (result == CustomCellGroupPositionTop)
		{
			result = CustomCellGroupPositionTopAndBottom;
		}
		else
		{
			result = CustomCellGroupPositionBottom;
		}
	}
	return result;
}

//
// init
//
// Init method for the object.
//
- (id)initSelected:(BOOL)isSelected grouped:(BOOL)isGrouped
{
	self = [super init];
	if (self != nil)
	{
		selected = isSelected;
		groupBackground = isGrouped;
		self.strokeColor = [UIColor lightGrayColor];
		self.backgroundColor = [UIColor clearColor];
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	}
	return self;
}

//
// layoutSubviews
//
// On rotation/resize/rescale, we need to redraw.
//
- (void)layoutSubviews
{
	[super layoutSubviews];
	
	[self setNeedsDisplay];
}

//
// setPosition:
//
// Makes certain the view gets redisplayed when the position changes
//
// Parameters:
//    aPosition - the new position
//
- (void)setPosition:(CustomCellGroupPosition)aPosition
{
	if (position != aPosition)
	{
		position = aPosition;
		[self setNeedsDisplay];
	}
}

//
// drawRect:
//
// Draw the view.
//
- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	const CGFloat PageCellBackgroundRadius = 10.0;
	if (groupBackground)
	{
		if (position != CustomCellGroupPositionTop &&
			position != CustomCellGroupPositionTopAndBottom)
		{
			rect.origin.y -= PageCellBackgroundRadius;
			rect.size.height += PageCellBackgroundRadius;
		}
		
		if (position != CustomCellGroupPositionBottom && position != CustomCellGroupPositionTopAndBottom)
		{
			rect.size.height += PageCellBackgroundRadius;
		}
	}
	
	rect = CGRectInset(rect, 0.5, 0.5);
	
	CGPathRef roundRectPath;
	
	if (groupBackground)
	{
		roundRectPath = NewPathWithRoundRect(rect, PageCellBackgroundRadius);
		
		CGContextSaveGState(context);
		CGContextAddPath(context, roundRectPath);
		CGContextClip(context);
	}
	
	CGFloat visibleWidth = rect.size.width;
	CGContextDrawLinearGradient(
		context,
		PageCellBackgroundGradient(selected),
		CGPointMake(0.25 * visibleWidth, -0.25 * visibleWidth),
		CGPointMake(rect.size.width - 0.25 * visibleWidth, rect.size.height + 0.25 * visibleWidth),
		0);
	
	if (groupBackground)
	{
		CGContextRestoreGState(context);

		CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
		CGContextAddPath(context, roundRectPath);
		CGContextSetLineWidth(context, 0.1);
		CGContextStrokePath(context);
		
		CGPathRelease(roundRectPath);
	
		if (position != CustomCellGroupPositionTop && position != CustomCellGroupPositionTopAndBottom)
		{
			rect.origin.y += PageCellBackgroundRadius;
			rect.size.height -= PageCellBackgroundRadius;

			CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
			CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y);
			CGContextStrokePath(context);
		}
	}
	else
	{
		CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
		CGContextSetLineWidth(context, 1.0);
		CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + rect.size.height);
		CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
		CGContextStrokePath(context);
	}
}

//
// dealloc
//
// Releases instance memory.
//
- (void)dealloc
{
	[strokeColor release];

	[super dealloc];
}

@end





