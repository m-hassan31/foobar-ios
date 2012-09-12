//
//  StreamViewController.h
//  FooBar
//
//  Created by Pramati technologies on 8/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMQuiltView.h"

@interface StreamViewController : UIViewController<TMQuiltViewDataSource, TMQuiltViewDelegate>
{
    TMQuiltView *quiltView;
}

@end
