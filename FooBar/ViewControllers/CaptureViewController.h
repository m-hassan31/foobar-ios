//
//  CaptureViewController.h
//  FooBar
//
//  Created by Pramati technologies on 9/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CaptureSessionManager.h"

@interface CaptureViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (retain) CaptureSessionManager *captureManager;

@end
