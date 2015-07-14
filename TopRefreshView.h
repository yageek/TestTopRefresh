//
//  TopPullToRefresh.h
//  TestTopRefresh
//
//  Created by Yannick Heinrich on 03/07/15.
//  Copyright (c) 2015 yageek. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface TopRefreshView : UIView


+ (TopRefreshView*)attachTopRefreshToScrollView:(UIScrollView *)scrollView
                                       target:(id)target
                                refreshAction:(SEL)refreshAction;

+ (TopRefreshView*)attachBottomRefreshToScrollView:(UIScrollView *)scrollView
                                          target:(id)target
                                   refreshAction:(SEL)refreshAction;

- (void)startRefreshing;

- (void)endRefreshing;
@end
