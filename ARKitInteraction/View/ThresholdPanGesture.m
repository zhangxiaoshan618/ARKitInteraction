//
//  ThresholdPanGesture.m
//  ARKitInteraction
//
//  Created by 张晓珊 on 2018/9/14.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import "PositionTranslation.h"
#import "ThresholdPanGesture.h"

@interface ThresholdPanGesture ()

@property (nonatomic, assign) BOOL isThresholdExceeded;

@end


@implementation ThresholdPanGesture

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isThresholdExceeded = NO;
    }
    return self;
}

- (void)setState:(UIGestureRecognizerState)state {
    [super setState:state];
    
    switch (state) {
        case UIGestureRecognizerStateBegan:
            
            break;
        case UIGestureRecognizerStateChanged:
            
            break;
            
        default:
            self.isThresholdExceeded = NO;
            break;
    }
}

// 返回应根据触摸次数使用的阈值。
+ (CGFloat)thresholdForTouchCount:(NSInteger)count {
    NSInteger threshold = 0;
    switch (count) {
        case 1:
            threshold = 30;
            break;
            
        default:
            threshold = 60;
            break;
    }
    return threshold;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    CGFloat translationMagnitude = [PositionPoint getLengthWithPoint:[self translationInView:self.view]];
    
    //根据使用的触摸次数调整阈值。
    NSInteger threshold = [ThresholdPanGesture thresholdForTouchCount: touches.count];
    
    if (!self.isThresholdExceeded && translationMagnitude > threshold) {
        self.isThresholdExceeded = YES;
        [self setTranslation:CGPointZero inView:self.view];
    }
}

@end
