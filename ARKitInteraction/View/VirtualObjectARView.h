//
//  VirtualObjectARView.h
//  ARKitInteraction
//
//  Created by 张晓珊 on 2018/9/14.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import <ARKit/ARKit.h>

@class VirtualObject;

@interface VirtualObjectARView : ARSCNView

@property (nonatomic, strong, readonly) SCNNode *lightingRootNode;

- (VirtualObject *)virtualObjectAt:(CGPoint)point;
- (ARHitTestResult *)smartHitTest:(CGPoint)point infinitePlane:(BOOL)infinitePlane objectPosition:(simd_float3 *)objectPosition allowedAlignments:(NSArray<NSNumber *> *)allowedAlignments;

/// 标签：AddOrUpdateAnchor
- (void)addOrUpdateAnchorFor:(VirtualObject *)object;

- (void)setupDirectionalLighting:(dispatch_queue_t)queue;
- (void)updateDirectionalLighting:(CGFloat)intensity queue:(dispatch_queue_t)queue;

@end

@interface SCNView (Wrapper)

- (simd_float3)unprojectPointWith:(simd_float3)point;

@end

