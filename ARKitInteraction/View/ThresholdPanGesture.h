//
//  ThresholdPanGesture.h
//  ARKitInteraction
//
//  Created by 张晓珊 on 2018/9/14.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
   一个自定义的“UIPanGestureRecognizer”，用于跟踪何时超出转换阈值并开始平移。
  
   - 标签：ThresholdPanGesture
 */

@interface ThresholdPanGesture : UIPanGestureRecognizer

///指示当前活动的手势是否超过阈值。
@property (nonatomic, assign, readonly) BOOL isThresholdExceeded;

@end
