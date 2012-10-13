/*
 * Copyright (c) 2012 Mario Negro Martín
 * 
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
 */

#import "MNMBottomPullToRefreshManager.h"
#import "MNMBottomPullToRefreshView.h"

@interface MNMBottomPullToRefreshManager()

/**
 * Returns the correct offset to apply to the pull-to-refresh view, depending on contentSize
 *
 * @return The offset
 * @private
 */
- (CGFloat)scrollOffset;

@end

@implementation MNMBottomPullToRefreshManager

#pragma mark -
#pragma mark Memory management

/**
 * Deallocates not used memory
 */
- (void)dealloc {
    [pullToRefreshView_ release];
    pullToRefreshView_ = nil;
    
    [scrollView_ release];
    scrollView_ = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark Instance initialization

/**
 * Implemented by subclasses to initialize a new object (the receiver) immediately after memory for it has been allocated.
 *
 * @return nil because that instance must be initialized with custom constructor
 */
- (id)init {
    return nil;
}

/*
 * Initializes the manager object with the information to link view and scroll
 */
- (id)initWithPullToRefreshViewHeight:(CGFloat)height scrollView:(UIScrollView *)scrollView withClient:(id<MNMBottomPullToRefreshManagerClient>)client {

    if (self = [super init]) {
        
        client_ = client;
        
        scrollView_ = [scrollView retain];
        
        pullToRefreshView_ = [[MNMBottomPullToRefreshView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(scrollView_.frame), height)];
    }
    
    return self;
}

#pragma mark -
#pragma mark Visuals

/*
 * Returns the correct offset to apply to the pull-to-refresh view, depending on contentSize
 */
- (CGFloat)scrollOffset {
    
    CGFloat offset = 0.0f;        
    
    if (scrollView_.contentSize.height < scrollView_.frame.size.height) {
        
        offset = -scrollView_.contentOffset.y;
        
    } else {
        
        offset = (scrollView_.contentSize.height - scrollView_.contentOffset.y) - scrollView_.frame.size.height;
    }
    
    return offset;
}

/*
 * Relocate pull-to-refresh view
 */
- (void)relocatePullToRefreshView {
    
    CGFloat yCoord = 0.0f;
    
    if (scrollView_.contentSize.height >= scrollView_.frame.size.height) {
        
        yCoord = scrollView_.contentSize.height;
        
    } else {
        
        yCoord = scrollView_.frame.size.height;
    }
    
    CGRect frame = pullToRefreshView_.frame;
    frame.origin.y = yCoord;
    pullToRefreshView_.frame = frame;
    
    [scrollView_ addSubview:pullToRefreshView_];
}

/*
 * Sets the pull-to-refresh view visible or not. Visible by default
 */
- (void)setPullToRefreshViewVisible:(BOOL)visible {
    pullToRefreshView_.hidden = !visible;
}

#pragma mark -
#pragma mark scroll view scroll management

/*
 * Checks state of control depending on scrollView scroll offset
 */
- (void)scrollViewScrolled {
    
    if (!pullToRefreshView_.hidden && !pullToRefreshView_.isLoading) {
        
        CGFloat offset = [self scrollOffset];
        CGFloat height = -CGRectGetHeight(pullToRefreshView_.frame);
        
        if (offset <= 0.0f && offset >= height) {
                
            [pullToRefreshView_ changeStateOfControl:MNMBottomPullToRefreshViewStatePull withOffset:offset];
            
        } else {
            
            [pullToRefreshView_ changeStateOfControl:MNMBottomPullToRefreshViewStateRelease withOffset:CGFLOAT_MAX];
        }
    }
}

/*
 * Checks releasing of the scrollView
 */
- (void)scrollViewReleased {
    
    if (!pullToRefreshView_.hidden && !pullToRefreshView_.isLoading) {
        
        CGFloat offset = [self scrollOffset];
        CGFloat height = -CGRectGetHeight(pullToRefreshView_.frame);
        
        if (offset <= 0.0f && offset < height) {
            
            [client_ MNMBottomPullToRefreshManagerClientReloadTable];
            
            [pullToRefreshView_ changeStateOfControl:MNMBottomPullToRefreshViewStateLoading withOffset:CGFLOAT_MAX];
            
            [UIView animateWithDuration:0.2f animations:^{
                
                if (scrollView_.contentSize.height >= scrollView_.frame.size.height) {
                
                    scrollView_.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, -height, 0.0f);
                    
                } else {
                    
                    scrollView_.contentInset = UIEdgeInsetsMake(height, 0.0f, 0.0f, 0.0f);
                }
            }];
        }
    }
}

/*
 * The reload of the scroll is completed
 */
- (void)scrollViewReloadFinished {
    
    scrollView_.contentInset = UIEdgeInsetsZero;
    
    [self relocatePullToRefreshView];
        
    [pullToRefreshView_ changeStateOfControl:MNMBottomPullToRefreshViewStateIdle withOffset:CGFLOAT_MAX];
}

@end