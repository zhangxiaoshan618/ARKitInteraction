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

/*
 根据相对于`cameraTransform`提供的位置设置对象的位置。 如果`smoothMovement`为真，则新位置将与先前位置平均以避免大跳跃。
   - 标签：VirtualObjectSetPosition
 */
- (void)setTransform:(simd_float4x4)newTransform relativeTo:(simd_float4x4)cameraTransform smoothMovement:(BOOL)smoothMovement alignment:(ARPlaneAnchorAlignment)alignment allowAnimation:(BOOL)allowAnimation;

- (BOOL)isPlacementValidOn:(ARPlaneAnchor *)planeAnchor;

- (void)reset;

@end
