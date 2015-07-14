//
//  PullRefreshImageView.m
//  TestTopRefresh
//
//  Created by Yannick Heinrich on 03/07/15.
//  Copyright (c) 2015 yageek. All rights reserved.
//

#import "PullRefreshImageView.h"

@interface PullRefreshImageView()

@property(nonatomic, strong) UIImageView* logoImageView;
@end

@implementation PullRefreshImageView


- (void) commonInit
{
    self.backgroundColor = [UIColor redColor];
    
    UIImage * logoImage = [UIImage imageNamed:@"logo"];
    self.logoImageView = [[UIImageView alloc] initWithImage:logoImage];

    
    self.logoImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:self.logoImageView];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.logoImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.logoImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0f]];
}

- (id) initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        [self commonInit];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        [self commonInit];
    }
    return self;
}

- (void) prepareForInterfaceBuilder
{
    [self commonInit];
}
@end
