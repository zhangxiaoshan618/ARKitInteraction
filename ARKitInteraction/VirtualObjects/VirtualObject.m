//
//  VirtualObject.m
//  ARKitInteraction
//
//  Created by 张晓珊 on 2018/9/13.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import "VirtualObject.h"
#import "PositionTranslation.h"
#import <CoreFoundation/CoreFoundation.h>

@interface VirtualObject ()

/**
 使用最近的虚拟对象距离的平均值来避免对象比例的快速变化
 */
@property (nonatomic, strong) NSMutableArray<NSNumber *> *recentVirtualObjectDistances;

/**
 对象当前是否正在更改对齐方式
 */
@property (nonatomic, assign) BOOL isChangingAlignment;



@end


@implementation VirtualObject

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.recentVirtualObjectDistances = [NSMutableArray<NSNumber *> array];
        self.currentAlignment = ARPlaneAnchorAlignmentHorizontal;
        self.isChangingAlignment = NO;
        self.rotationWhenAlignedHorizontally = 0;
    }
    return self;
}


/**
 充值对象的位置平滑
 */
- (void)reset {
    [self.recentVirtualObjectDistances removeAllObjects];
}


#pragma mark - 辅助方法，帮助确定支持的防治选项


/**
 放置在指定锚点是否有效

 @param planeAnchor 指定锚点
 @return 是否有效
 */
- (BOOL)isPlacementValidOn:(ARPlaneAnchor *)planeAnchor {
    if (planeAnchor != nil) {
        return [self.allowedAlignments containsObject:[NSNumber numberWithInteger:planeAnchor.alignment]];
    }
    return YES;
}

/*
 根据相对于`cameraTransform`提供的位置设置对象的位置。 如果`smoothMovement`为真，则新位置将与先前位置平均以避免大跳跃。
   - 标签：VirtualObjectSetPosition
 */

- (void)setTransform:(simd_float4x4)newTransform relativeTo:(simd_float4x4)cameraTransform smoothMovement:(BOOL)smoothMovement alignment:(ARPlaneAnchorAlignment)alignment allowAnimation:(BOOL)allowAnimation {
    simd_float3 cameraWorldPosition = [PositionTranslation getTranslationWithMatrixFloat4x4:cameraTransform];
    simd_float3 positionOffsetFromCamera = [PositionTranslation getTranslationWithMatrixFloat4x4:newTransform] - cameraWorldPosition;
    
    //将物体距离相机的距离限制在最大10米。
    if (simd_length(positionOffsetFromCamera) > 10) {
        positionOffsetFromCamera = simd_normalize(positionOffsetFromCamera);
        positionOffsetFromCamera *= 10;
    }
    
    /*
     计算过去十次更新中对象与相机的平均距离。 请注意，距离应用于从摄像机到内容的矢量，因此它仅影响到对象的距离。 平均确实_not_使内容“滞后”。
     */
    if (smoothMovement) {
        CGFloat hitTestResultDistance = simd_length(positionOffsetFromCamera);
        
        //添加最新位置并保持最近10个距离以平滑。
        [self.recentVirtualObjectDistances addObject:[NSNumber numberWithDouble:hitTestResultDistance]];
        NSUInteger count = self.recentVirtualObjectDistances.count;
        if (count > 10) {
            [self.recentVirtualObjectDistances removeObjectsInRange:NSMakeRange(0, count - 10)];
        }
        
        CGFloat reduce = 0;
        for (NSNumber *value in self.recentVirtualObjectDistances) {
            reduce += value.doubleValue;
        }
        CGFloat averageDistance = reduce / self.recentVirtualObjectDistances.count;
        
        simd_float3 averagedDistancePosition = simd_normalize(positionOffsetFromCamera) * averageDistance;
        self.simdPosition = cameraWorldPosition + averagedDistancePosition;
    }else {
        self.simdPosition = cameraWorldPosition + positionOffsetFromCamera;
    }
}


#pragma mark - 设置虚拟物品的对齐方式

- (void)updateAlignmentTo:(ARPlaneAnchorAlignment)newAlignment transform:(simd_float4x4)transform allowAnimation:(BOOL)isAllowAnimation {
    if (self.isChangingAlignment) {
        return;
    }
    
    // 仅在对齐方式发生改变时执行动画
    CGFloat animationDuration = newAlignment != self.currentAlignment && isAllowAnimation ? 0.5 : 0;
    CGFloat newObjectRotation;
    if (newAlignment == ARPlaneAnchorAlignmentHorizontal && newAlignment == self.currentAlignment) {
        return;
    }else if (newAlignment == ARPlaneAnchorAlignmentHorizontal && self.currentAlignment == ARPlaneAnchorAlignmentVertical) {
        newObjectRotation = self.rotationWhenAlignedHorizontally;
    }else {
        newObjectRotation = 0.0001;
    }
    
    self.currentAlignment = newAlignment;
    
    [SCNTransaction begin];
    SCNTransaction.animationDuration = animationDuration;
    SCNTransaction.completionBlock = ^{
        self.isChangingAlignment = NO;
    };
    
    self.isChangingAlignment = YES;
    
    // 使用过滤后的位置而不是变换中的精确位置
    simd_float4x4 mutableTransform = transform;
    [PositionTranslation setMatrixFloat4x4:&mutableTransform withTranslation:self.simdWorldPosition];
    self.simdTransform = mutableTransform;
    
    [self setObjectRotation:newObjectRotation];
    
    [SCNTransaction commit];
}

/**
 调整到平面锚点
 */
- (void)adjustOntoPlaneAnchor:(ARPlaneAnchor *)anchor usingNode:(SCNNode *)node {
    // 测试平面的对齐是否与对象的允许放置兼容
    if (![self.allowedAlignments containsObject:[NSNumber numberWithInteger:anchor.alignment]]) {
        return;
    }
    // 获取对象在平面坐标系中的位置。
    SCNVector3 planePosition = [node convertPosition:self.position fromNode:self.parentNode];
    
    // 检查对象是否不允许放置在当前平面
    if (planePosition.y == 0) {
        return;
    }
    
    // 在平面的角上增加10%的公差
    CGFloat tolerance = 0.1;
    
    CGFloat minX = anchor.center.x - anchor.extent.x / 2 - anchor.extent.x * tolerance;
    CGFloat maxX = anchor.center.x + anchor.extent.x / 2 + anchor.extent.x * tolerance;
    CGFloat minZ = anchor.center.z - anchor.extent.z / 2 - anchor.extent.z * tolerance;
    CGFloat maxZ = anchor.center.z + anchor.extent.z / 2 + anchor.extent.z * tolerance;
    
    if (!(planePosition.x >= minX && planePosition.x <= maxX) || !(planePosition.z >= minZ && planePosition.z <= maxZ)) {
        return;
    }
    
    //如果它靠近它（在5厘米内），则移动到飞机上。
    CGFloat verticalAllowance = 0.05;
    CGFloat epsilon = 0.001; // 如果差异小于1mm,请勿更新
    CGFloat distanceToPlane = fabs(planePosition.y);
    if (distanceToPlane > epsilon && distanceToPlane < verticalAllowance) {
        [SCNTransaction begin];
        SCNTransaction.animationDuration = (CGFloat)distanceToPlane * 500; // 每秒移动2mm
        SCNTransaction.animationTimingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        self.position = SCNVector3Make(self.position.x, anchor.transform.columns[3].y, self.position.z);
        [self updateAlignmentTo:anchor.alignment transform:self.simdWorldTransform allowAnimation:NO];
        [SCNTransaction commit];
    }
}

#pragma mark - Class Properties and Methods

+ (NSArray<VirtualObject *> *)availableObjects {
    NSURL *url = [NSBundle.mainBundle URLForResource:@"art.scnassets" withExtension:nil];//pathForResource:@"art.scnassets" ofType:nil];
    NSDirectoryEnumerator<NSURL *> *files = [[NSFileManager defaultManager] enumeratorAtURL:url includingPropertiesForKeys:nil options:0 errorHandler:nil];
    
    NSMutableArray<VirtualObject *> *array = [NSMutableArray<VirtualObject *> array];
    [files.allObjects enumerateObjectsUsingBlock:^(NSURL * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.pathExtension isEqualToString:@"scn"] && ![obj.path containsString:@"lighting"]) {
            [array addObject:[VirtualObject referenceNodeWithURL:obj]];
        }
    }];
    return array.copy;
}

/// Returns a `VirtualObject` if one exists as an ancestor to the provided node.
+ (VirtualObject *)existingObjectContainingNode:(SCNNode *)node {
    if ([node isKindOfClass:VirtualObject.class]) {
        return (VirtualObject *)node;
    }
    if (node.parentNode != nil) {
        return [self existingObjectContainingNode:node.parentNode];
    }
    return nil;
}


#pragma mark - getter/setter

- (NSString *)modelName {
    return [self.referenceURL.lastPathComponent stringByReplacingOccurrencesOfString:@".scn" withString:@""];
}

- (NSArray<NSNumber *> *)allowedAlignments {
    if ([self.modelName isEqualToString:@"sticky note"]) {
        return @[[NSNumber numberWithInteger:ARPlaneAnchorAlignmentHorizontal], [NSNumber numberWithInteger:ARPlaneAnchorAlignmentVertical]];
    } else if ([self.modelName isEqualToString:@"painting"]) {
        return @[[NSNumber numberWithInteger:ARPlaneAnchorAlignmentVertical]];
    } else {
        return @[[NSNumber numberWithInteger:ARPlaneAnchorAlignmentHorizontal]];
    }
}

/**
 要在水平和垂直曲面上正确旋转，请绕着局部y而不是世界y旋转。 因此，旋转第一个子而不是自己。

 @param objectRotation 旋转角度
 */
- (void)setObjectRotation:(CGFloat)objectRotation {
    CGFloat normalized = fmod(objectRotation, 2 * M_PI);
    normalized = fmod((normalized + 2 * M_PI), 2 * M_PI);
    if (normalized > M_PI) {
        normalized -= 2 * M_PI;
    }
    SCNVector3 eulerAngles = self.childNodes.firstObject.eulerAngles;
    self.childNodes.firstObject.eulerAngles = SCNVector3Make(eulerAngles.x, normalized, eulerAngles.z);
    if (self.currentAlignment == ARPlaneAnchorAlignmentHorizontal) {
        self.rotationWhenAlignedHorizontally = normalized;
    }
}

- (CGFloat)objectRotation {
    return self.childNodes.firstObject.eulerAngles.y;
}

@end
