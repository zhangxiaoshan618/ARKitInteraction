//
//  VirtualObjectInteraction.h
//  ARKitInteraction
//
//  Created by 张晓珊 on 2018/9/15.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class VirtualObject;

@interface VirtualObjectInteraction : NSObject

/**
 最近与之发生冲突的对象。
 可以使用轻击手势随时移动`selectedObject`。
 */
@property (nonatomic, strong) VirtualObject *selectedObject;

- (void)translateWith:(VirtualObject *)object basedOn:(CGPoint)screenPos infinitePlane:(BOOL)infinitePlane allowAnimation:(BOOL)allowAnimation;

@end

///扩展`UIGestureRecognizer`以提供多次触摸产生的中心点。
@interface UIGestureRecognizer (Center)

- (CGPoint)centerIn:(UIView *)view;

@end

