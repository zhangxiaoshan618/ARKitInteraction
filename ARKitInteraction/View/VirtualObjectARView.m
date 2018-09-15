//
//  VirtualObjectARView.m
//  ARKitInteraction
//
//  Created by 张晓珊 on 2018/9/14.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import "VirtualObjectARView.h"
#import "VirtualObject.h"
#import "PositionTranslation.h"

@implementation VirtualObjectARView

- (VirtualObject *)virtualObjectAt:(CGPoint)point {
    NSDictionary<SCNHitTestOption, id>  *hitTestOptions = @{SCNHitTestOptionBoundingBoxOnly: @1};
    NSArray<SCNHitTestResult *> *hitTestResults = [self hitTest:point options:hitTestOptions];
    __block VirtualObject *virtual = nil;
    [hitTestResults enumerateObjectsUsingBlock:^(SCNHitTestResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        VirtualObject *object = [VirtualObject existingObjectContainingNode:obj.node];
        if (object != nil) {
            virtual = object;
            *stop = YES;
        }
    }];
    return virtual;
}

- (ARHitTestResult *)smartHitTest:(CGPoint)point infinitePlane:(BOOL)infinitePlane objectPosition:(simd_float3 *)objectPosition allowedAlignments:(NSArray<NSNumber *> *)allowedAlignments {
    // 准备探测
    NSArray<ARHitTestResult *> *results = [self hitTest:point types:ARHitTestResultTypeExistingPlaneUsingGeometry | ARHitTestResultTypeEstimatedVerticalPlane | ARHitTestResultTypeEstimatedHorizontalPlane];
    
    // 1、使用几何体检查现有平面上的结果。
    __block ARHitTestResult *result = nil;
    [results enumerateObjectsUsingBlock:^(ARHitTestResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.type == ARHitTestResultTypeExistingPlaneUsingGeometry) {
            result = obj;
            *stop = YES;
        }
    }];
    
    ARAnchor *planeAnchor = result.anchor;
    
    if (result != nil && [planeAnchor isKindOfClass:ARPlaneAnchor.class] && [allowedAlignments containsObject:[NSNumber numberWithInteger:((ARPlaneAnchor *)planeAnchor).alignment]]) {
        return result;
    }
    
    // 2.检查现有平面上的结果，假设其尺寸无限大。 循环遍历无限现有平面的所有命中，并返回最近的一个（垂直平面）或返回距离对象位置5厘米范围内的最近一个平面。
    if (infinitePlane) {
        NSArray<ARHitTestResult *> *infinitePlaneResults = [self hitTest:point types:ARHitTestResultTypeExistingPlane];
        for (ARHitTestResult *infinitePlaneResult in infinitePlaneResults) {
            ARAnchor *planeAnchor = infinitePlaneResult.anchor;
            if ([planeAnchor isKindOfClass:ARPlaneAnchor.class] && [allowedAlignments containsObject:[NSNumber numberWithInteger:((ARPlaneAnchor *)planeAnchor).alignment]]) {
                if (((ARPlaneAnchor *)planeAnchor).alignment == ARPlaneAnchorAlignmentVertical) {
                    // 返回第一个垂直平面命中测试结果。
                    return infinitePlaneResult;
                }
            }else {
                //对于水平平面，我们只想返回一个命中测试结果，如果它接近当前对象的位置。
                if (objectPosition != nil) {
                    CGFloat objectY = objectPosition->y;
                    CGFloat planeY = [PositionTranslation getTranslationWithMatrixFloat4x4:infinitePlaneResult.worldTransform].y;
                    if (objectY > planeY - 0.05 && objectY < planeY + 0.05) {
                        return infinitePlaneResult;
                    }
                }else {
                    return infinitePlaneResult;
                }
            }

        }
    }
    
    // 3.作为最终后备，检查估计飞机上的结果。
    __block ARHitTestResult *vResult = nil;
    [results enumerateObjectsUsingBlock:^(ARHitTestResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.type == ARHitTestResultTypeEstimatedVerticalPlane) {
            vResult = obj;
            *stop = YES;
        }
    }];
    
    __block ARHitTestResult *hResult = nil;
    [results enumerateObjectsUsingBlock:^(ARHitTestResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.type == ARHitTestResultTypeEstimatedHorizontalPlane) {
            vResult = obj;
            *stop = YES;
        }
    }];
    
    BOOL isHorizontal = [allowedAlignments containsObject:[NSNumber numberWithInteger:ARPlaneAnchorAlignmentHorizontal]];
    BOOL isVertical = [allowedAlignments containsObject:[NSNumber numberWithInteger:ARPlaneAnchorAlignmentVertical]];
    
    if (isHorizontal && !isVertical) {
        return hResult;
    }else if (!isHorizontal && isVertical) {
        return vResult != nil ? vResult : hResult;
    }else if (isHorizontal && isVertical) {
        if (hResult != nil && vResult != nil) {
            return  hResult.distance < vResult.distance ? hResult : vResult;
        }else {
            return hResult != nil ? hResult : vResult;
        }
    }else {
        return nil;
    }
}

#pragma mark - 对象锚点

/// 标签：AddOrUpdateAnchor
- (void)addOrUpdateAnchorFor:(VirtualObject *)object {
    //如果锚点不是nil，请将其从会话中删除。
    if (object.anchor != nil) {
        [self.session removeAnchor:object.anchor];
    }
    
    //使用对象的当前变换创建一个新锚点并将其添加到会话中
    ARAnchor *newAnchor = [[ARAnchor alloc] initWithTransform:object.simdWorldTransform];
    object.anchor = newAnchor;
    [self.session addAnchor:newAnchor];
}

#pragma mark - 灯光

- (SCNNode *)lightingRootNode {
    return [self.scene.rootNode childNodeWithName:@"lightingRootNode" recursively:YES];
}

- (void)setupDirectionalLighting:(dispatch_queue_t)queue {
    if (self.lightingRootNode != nil) {
        return;
    }
    
    //除了基于环境的照明外，还为动态高光添加定向照明。
    SCNScene *lightingScene = [SCNScene sceneNamed:@"lighting.scn" inDirectory:@"Models.scnassets" options:nil];
    if (lightingScene == nil) {
        NSLog(@"Error setting up directional lights: Could not find lighting scene in resources.");
        return;
    }
    
    SCNNode *lightingRootNode = [SCNNode new];
    lightingRootNode.name = @"lightingRootNode";
    
    for (SCNNode *node in lightingScene.rootNode.childNodes) {
        if (node.light != nil) {
            [lightingRootNode addChildNode:node];
        }
    }
    
    dispatch_sync(queue, ^{
        [self.scene.rootNode addChildNode:lightingRootNode];
    });
}

- (void)updateDirectionalLighting:(CGFloat)intensity queue:(dispatch_queue_t)queue {
    if (self.lightingRootNode == nil) {
        return;
    }
    
    dispatch_sync(queue, ^{
        for (SCNNode *node in self.lightingRootNode.childNodes) {
            node.light.intensity = intensity;
        }
    });
}

@end

@implementation SCNView (Wrapper)
// 为原始`unprojectPoint（_ :)`方法键入转换包装器。
// 用于坚持SIMD float3类型有用的上下文中。
- (simd_float3)unprojectPointWith:(simd_float3)point {
    SCNVector3 vector3 = SCNVector3Make(point.x, point.y, point.z);
    SCNVector3 vector = [self unprojectPoint:vector3];
    return simd_make_float3(vector.x, vector.y, vector.z);
}

@end


