//
//  VirtualObject.h
//  ARKitInteraction
//
//  Created by 张晓珊 on 2018/9/13.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>

@interface VirtualObject : SCNReferenceNode

// 模型名称读取自 “referenceURL”
@property (nonatomic, copy, readonly) NSString *modelName;

/**
 虚拟对象允许的对齐方式
 */
@property (nonatomic, copy, readonly) NSArray<NSNumber *> *allowedAlignments;

/**
 虚拟物品当前的对齐方式
 */
@property (nonatomic, assign) ARPlaneAnchorAlignment currentAlignment;

/**
 虚拟物品的旋转角度
 */
@property (nonatomic, assign) CGFloat objectRotation;

/**
 记录水平对齐的最后一次旋转角度
 */
@property (nonatomic, assign) CGFloat rotationWhenAlignedHorizontally;

/**
 对象对应的锚点
 */
@property (nonatomic, strong) ARAnchor *anchor;

@property (nonatomic, copy, readonly, class) NSArray<VirtualObject *> *availableObjects;

+ (VirtualObject *)existingObjectContainingNode:(SCNNode *)node;

@end
