//
//  TopPullToRefresh.m
//  TestTopRefresh
//
//  Created by Yannick Heinrich on 03/07/15.
//  Copyright (c) 2015 yageek. All rights reserved.
//

#import "TopRefreshView.h"
#import <CoreMotion/CoreMotion.h>

#define TOPVIEW_HEIGHT 100.0f


typedef NS_ENUM(NSUInteger, RefreshViewPosition) {
    RefreshViewPositionTop,
    RefreshViewPositionBottom
};

@interface TopRefreshView()<UIScrollViewDelegate>
@property(nonatomic, weak) UIScrollView* scrollView;
@property(nonatomic, strong) UIImageView * logoView;

@property(nonatomic, strong) NSLayoutConstraint * centerConstraint;
@property(nonatomic) BOOL topPullTriggered;
@property(nonatomic) BOOL bottomPullTriggered;
@property(nonatomic) CGFloat vel;
@property(nonatomic) CGFloat pos;

@property(nonatomic, assign) id target;
@property(nonatomic) SEL selector;

@property(nonatomic) RefreshViewPosition position;

- (id) initWithFrame:(CGRect)frame andPosition:(RefreshViewPosition) position;
@end

@implementation TopRefreshView

- (void) commonInit
{
    self.clipsToBounds = NO;
    self.backgroundColor = [UIColor redColor];
    
    self.logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    self.logoView.translatesAutoresizingMaskIntoConstraints = NO;
    self.logoView.contentMode = UIViewContentModeScaleAspectFit;
    self.logoView.layer.borderColor = [UIColor yellowColor].CGColor;
    self.logoView.layer.borderWidth = 2.0f;
    [self.logoView sizeToFit];
    [self addSubview:self.logoView];
    
    
    self.centerConstraint = [NSLayoutConstraint constraintWithItem:self.logoView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0f];
     [self addConstraint:self.centerConstraint];
    
    NSLayoutAttribute logoViewAttribute = self.position == RefreshViewPositionTop ? NSLayoutAttributeBottom : NSLayoutAttributeTop;
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.logoView attribute:logoViewAttribute relatedBy:NSLayoutRelationEqual toItem:self attribute:logoViewAttribute multiplier:1.0 constant:0.0f]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.logoView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:0.0 constant:TOPVIEW_HEIGHT]];


}
- (id) initWithFrame:(CGRect)frame andPosition:(RefreshViewPosition) position
{
    if (self = [super initWithFrame:frame])
    {
        self.position = position;
        [self commonInit];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        self.position = RefreshViewPositionTop;
        [self commonInit];
    }
    return self;
}

+ (TopRefreshView*)attachRefreshToScrollView:(UIScrollView *)scrollView
                                           position:(RefreshViewPosition) position
                                             target:(id)target
                                      refreshAction:(SEL)refreshAction
{
 
    CGRect refreshRect;
    if(position == RefreshViewPositionTop)
    {
        refreshRect = CGRectMake(0, 0, CGRectGetWidth(scrollView.bounds), 0.0f);
        
    }
    else
    {
        refreshRect = CGRectMake(0, scrollView.contentSize.height, CGRectGetWidth(scrollView.bounds), 0.0f);
    }
    
    TopRefreshView * refreshControl = [[TopRefreshView alloc] initWithFrame:refreshRect andPosition:position];
    
    refreshControl.target = target;
    refreshControl.selector = refreshAction;
    
    refreshControl.scrollView = scrollView;
    scrollView.delegate = refreshControl;
    
    [scrollView addObserver:refreshControl forKeyPath:NSStringFromSelector(@selector(contentOffset)) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    if(position == RefreshViewPositionBottom)
    {
        [scrollView addObserver:refreshControl forKeyPath:NSStringFromSelector(@selector(contentSize)) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];

    }
    [scrollView addSubview:refreshControl];
    [scrollView bringSubviewToFront:refreshControl];
    
    return refreshControl;

}

+ (TopRefreshView*)attachBottomRefreshToScrollView:(UIScrollView *)scrollView
                                             target:(id)target
                                      refreshAction:(SEL)refreshAction;
{
    return [self attachRefreshToScrollView:scrollView position:RefreshViewPositionBottom target:target refreshAction:refreshAction];
}
+ (TopRefreshView*)attachTopRefreshToScrollView:(UIScrollView *)scrollView
                                 target:(id)target
                          refreshAction:(SEL)refreshAction
{
    
    return [self attachRefreshToScrollView:scrollView position:RefreshViewPositionTop target:target refreshAction:refreshAction];

}


- (void)startRefreshing
{
    [self startUpdates];
}

- (void)endRefreshing
{
    [self stopUpdates];
    self.scrollView.contentInset = UIEdgeInsetsZero;
    self.topPullTriggered = NO;
    self.bottomPullTriggered = NO;
}


#pragma mark - 
#pragma mark - Delegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    if(self.topPullTriggered && !self.scrollView.dragging && scrollView.decelerating)
    {
        scrollView.contentInset = UIEdgeInsetsMake(TOPVIEW_HEIGHT, 0, 0, 0  );
        scrollView.contentOffset = CGPointMake(0, -TOPVIEW_HEIGHT);
        
        return;
    }
    
    if(self.bottomPullTriggered && !self.scrollView.dragging && scrollView.decelerating)
    {
        scrollView.contentInset = UIEdgeInsetsMake(0, 0, TOPVIEW_HEIGHT, 0  );
        scrollView.contentOffset = CGPointMake(0, TOPVIEW_HEIGHT);
        
        return;
    }

    
    CGFloat yOffset = scrollView.contentOffset.y;
    //Detect Top Refresh
    if(yOffset <= -1.0*TOPVIEW_HEIGHT && !self.topPullTriggered && !self.scrollView.dragging && self.position == RefreshViewPositionTop)
    {
        NSLog(@"Pull to refresh");
        self.topPullTriggered = YES;
        
        [self startRefreshing];
        
        [self.target performSelector:self.selector withObject:self];
    }
    
    CGFloat yPosition = MAX(self.scrollView.contentSize.height, CGRectGetHeight(self.scrollView.bounds));
    CGFloat height = yPosition - CGRectGetHeight(self.scrollView.bounds) + ABS(yOffset);
    NSLog(@"Height:%f", height);
    if (height >= TOPVIEW_HEIGHT && !self.scrollView.dragging && !self.bottomPullTriggered && self.position == RefreshViewPositionBottom)
    {
        NSLog(@"Scroll bottom");
        self.bottomPullTriggered = YES;
        
        [self startRefreshing];
        
        [self.target performSelector:self.selector withObject:self];
        

    }
}


#pragma mark -
#pragma mark - KVO

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:NSStringFromSelector(@selector(contentOffset))])
    {
        if(self.position == RefreshViewPositionTop)
        {
            CGFloat height = self.scrollView.contentOffset.y;
            CGRect newFrame =CGRectMake(0, 0, CGRectGetWidth(self.scrollView.bounds), height);
            [self setFrame:newFrame];
            [self setNeedsUpdateConstraints];
        }
        else
        {
            CGFloat yPosition = MAX(self.scrollView.contentSize.height, CGRectGetHeight(self.scrollView.bounds));
            CGFloat height = yPosition - CGRectGetHeight(self.scrollView.bounds) + ABS(self.scrollView.contentOffset.y);
            CGRect newFrame = CGRectMake(0, yPosition, CGRectGetWidth(self.scrollView.bounds), height);
            [self setFrame:newFrame];
            [self setNeedsUpdateConstraints];

        }

    }
    else if ([keyPath isEqualToString:NSStringFromSelector(@selector(contentSize))])
    {
        CGFloat yPosition = MAX(self.scrollView.contentSize.height, CGRectGetHeight(self.scrollView.bounds));
        CGRect newFrame = CGRectMake(0, yPosition, CGRectGetWidth(self.scrollView.bounds), 0.0f);
        [self setFrame:newFrame];
        [self setNeedsUpdateConstraints];
        [self.scrollView bringSubviewToFront:self];
    }
}

#pragma mark -
#pragma mark - Core Motion


+ (CMMotionManager*) motionManager
{
    static CMMotionManager * motionManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        motionManager = [[CMMotionManager alloc] init];
    });
    
    
    return motionManager;
}
- (void)startUpdates
{
    // Create a CMMotionManager
    CMMotionManager *mManager = [[self class] motionManager];
    
    // Check whether the accelerometer is available
    if ([mManager isAccelerometerAvailable] == YES) {
        // Assign the update interval to the motion manager
        
        static CGFloat interval = 1/300.0f;
        
        [mManager setAccelerometerUpdateInterval:interval];
        [mManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {


            float deceleration = 0.1f, sensitivity = 8.0f, maxVelocity = 150;
            // adjust velocity based on current accelerometer acceleration
            CMAcceleration acceleration = accelerometerData.acceleration;
            
            self.vel = self.vel * deceleration + acceleration.x * sensitivity;
            
            //limit the maximum velocity of the player sprite, in both directions (positive & negative values)
            self.vel = fmaxf(fminf(self.vel, maxVelocity), -maxVelocity);
            
            
            CGPoint pos = self.logoView.layer.position;
          //  NSLog(@"Pos:%f", pos.x);
            pos.x += self.vel;
            
            CGFloat leftBorder = CGRectGetWidth(self.logoView.bounds)/2.0f;
            CGFloat rightBorder = CGRectGetMaxX(self.logoView.bounds);
          
             if(pos.x < leftBorder)
             {
                 pos.x = leftBorder;
                 self.vel = 0;
             }
            else if (pos.x > rightBorder)
            {
                pos.x = rightBorder;
                self.vel = 0;
            }
        
            self.logoView.layer.position = pos;
            
            
        }];
    }

}


- (void)stopUpdates {
    CMMotionManager *mManager = [[self class] motionManager];
    if ([mManager isAccelerometerActive] == YES) {
        [mManager stopAccelerometerUpdates];
    }
}

@end
