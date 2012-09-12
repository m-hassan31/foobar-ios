//
//  EditImageViewController.h
//  foobar1
//
//  Created by Pramati technologies on 8/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditImageViewController : UIViewController
<UIGestureRecognizerDelegate> 
{
	CGFloat lastScale;
	CGFloat lastRotation;
	
	CGFloat firstX;
	CGFloat firstY;	

    CGFloat maxX;
    CGFloat maxY;
    
    IBOutlet UIImageView* imageView;
}

@property(nonatomic, retain) UIImage *image;

@end