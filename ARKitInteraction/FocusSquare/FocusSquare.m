//
//  FocusSquare.m
//  ARKitInteraction
//
//  Created by 张晓珊 on 2018/9/9.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import "FocusSquare.h"
#import "PositionTranslation.h"
#import "Segment.h"

@interface FocusSquare ()

@property (nonatomic, strong) ARHitTestResult *stateHitTestResult;
@property (nonatomic, strong) ARCamera *stateCamera;
@property (nonatomic, strong) UIColor *primaryColor;
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, strong) ARPlaneAnchor *currentPlaneAnchor;

@property (nonatomic, assign) BOOL isOpen;
@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, assign) BOOL isChangingAlignment;
@property (nonatomic, assign) ARPlaneAnchorAlignment currentAlignment;
@property (nonatomic, strong) NSMutableArray<ARHitTestResult *> *recentFocusSquarePositions;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *recentFocusSquareAlignments;
@property (nonatomic, strong) NSMutableSet<ARAnchor *> *anchorsOfVisitedPlanes;

@property (nonatomic, strong) NSMutableArray<Segment *> *segments;


@property (nonatomic, strong, readonly) SCNNode *positioningNode;
@property (nonatomic, strong) SCNNode *fillPlane;

@end

@implementation FocusSquare

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.opacity = 0.0;

        Segment *s1 = [[Segment alloc] initWithName:@"s1" corner:CornerTopLeft alignment:AlignmentHorizontal];
        Segment *s2 = [[Segment alloc] initWithName:@"s2" corner:CornerTopRight alignment:AlignmentHorizontal];
        Segment *s3 = [[Segment alloc] initWithName:@"s3" corner:CornerTopLeft alignment:AlignmentVertical];
        Segment *s4 = [[Segment alloc] initWithName:@"s4" corner:CornerTopRight alignment:AlignmentVertical];
        Segment *s5 = [[Segment alloc] initWithName:@"s5" corner:CornerBottomLeft alignment:AlignmentVertical];
        Segment *s6 = [[Segment alloc] initWithName:@"s6" corner:CornerBottomRight alignment:AlignmentVertical];
        Segment *s7 = [[Segment alloc] initWithName:@"s7" corner:CornerBottomLeft alignment:AlignmentHorizontal];
        Segment *s8 = [[Segment alloc] initWithName:@"s8" corner:CornerBottomRight alignment:AlignmentHorizontal];
        self.segments = [NSMutableArray<Segment *> arrayWithObjects:s1, s2, s3, s4, s5, s6, s7, s8, nil];

        CGFloat sl = 0.5;
        CGFloat c = FocusSquare.thickness / 2;
        s1.simdPosition += simd_make_float3(-(sl / 2 - c), -(sl - c), 0);
        s2.simdPosition += simd_make_float3(sl / 2 - c, -(sl - c), 0);
        s3.simdPosition += simd_make_float3(-sl, -sl / 2, 0);
        s4.simdPosition += simd_make_float3(sl, -sl / 2, 0);
        s5.simdPosition += simd_make_float3(-sl, sl / 2, 0);
        s6.simdPosition += simd_make_float3(sl, sl / 2, 0);
        s7.simdPosition += simd_make_float3(-(sl / 2 - c), sl - c, 0);
        s8.simdPosition += simd_make_float3(sl / 2 - c, sl - c, 0);
        
        SCNNode *node = [SCNNode new];
        node.eulerAngles = SCNVector3Make(M_PI_2, node.eulerAngles.y, node.eulerAngles.z);
        node.simdScale = simd_make_float3(FocusSquare.size * FocusSquare.scaleForClosedSquare);
        for (Segment *segment in self.segments) {
            [node addChildNode:segment];
        }
        [node addChildNode:self.fillPlane];
         _positioningNode = node;
        
        [self displayNodeHierarchyOnTop:YES];
        
        [self addChildNode:node];
        
        [self displayAsBillBoard];
       
    }
    return self;
}

- (void)hide {
    if ([self actionForKey:@"hide"] == nil) {
        [self displayNodeHierarchyOnTop:NO];
        [self runAction:[SCNAction fadeOutWithDuration:0.5] forKey:@"hide"];
    }
}

- (void)unhide {
    if ([self actionForKey:@"unhide"] == nil) {
        [self displayNodeHierarchyOnTop:YES];
        [self runAction:[SCNAction fadeInWithDuration:0.5] forKey:@"unhide"];
    }
}

- (void)displayAsBillBoard {
    self.simdTransform = matrix_identity_float4x4;
    self.eulerAngles = SCNVector3Make(M_PI / 2, self.eulerAngles.y, self.eulerAngles.z);
    self.simdPosition = simd_make_float3(0, 0, -0.8);
    [self unhide];
    [self performOpenAnimation];
}

/// 当探测到一个平面的时候会调用这个方法
- (void)displayAsOpenFor:(ARHitTestResult *)hitTestResult camera:(ARCamera *)camera {
    [self performOpenAnimation];
    simd_float3 position = [PositionTranslation getTranslationWithMatrixFloat4x4:hitTestResult.worldTransform];
    if (hitTestResult) {
        [self.recentFocusSquarePositions addObject:hitTestResult];
    }
    [self updateTransformFor:position hitTestResult:hitTestResult camera:camera];
    
}

/// Called when a plane has been detected.
- (void)displayAsClosedFor:(ARHitTestResult *)hitTestResult planeAnchor:(ARPlaneAnchor *)planeAnchor camera:(ARCamera *)camera {
    [self performCloseAnimationFlash:![self.anchorsOfVisitedPlanes containsObject:planeAnchor]];
    [self.anchorsOfVisitedPlanes addObject:planeAnchor];
    simd_float3 position = [PositionTranslation getTranslationWithMatrixFloat4x4:hitTestResult.worldTransform];
    [self.recentFocusSquarePositions addObject:hitTestResult];
    [self updateTransformFor:position hitTestResult:hitTestResult camera:camera];
}


#pragma mark - Helper Methods

// 更新焦点指示器方块的变换以与相机对齐
- (void)updateTransformFor:(simd_float3)position hitTestResult:(ARHitTestResult *)hitTestResult camera:(ARCamera *)camera {
    
    // 平均使用几个最近的位置
    NSUInteger count = self.recentFocusSquarePositions.count;
    
    if (count <= 0) {
        return;
    }
    
    if (count > 10) {
        [self.recentFocusSquarePositions removeObjectsInRange:NSMakeRange(0, count - 10)];
    }
    
    // 移动到近期位置的平均值以避免抖动
    simd_float3 positionCount = simd_make_float3(0, 0, 0);
    for (ARHitTestResult *hitTestResult in self.recentFocusSquarePositions) {
        simd_float3 translation = [PositionTranslation getTranslationWithMatrixFloat4x4:hitTestResult.worldTransform];
        positionCount += translation;
    }
    simd_float3 average = positionCount / self.recentFocusSquarePositions.count;
    self.simdPosition = average;
    self.simdScale = (simd_float3)[self scaleBasedOnDistanceCamera:camera];
    
    // 纠正相机方形的y旋转
    if (camera == nil) {
        return;
    }

    CGFloat tilt = fabsf(camera.eulerAngles.x);
    CGFloat threshold1 = M_PI_2 * 0.65;
    CGFloat threshold2 = M_PI_2 * 0.75;
    CGFloat yaw = atan2f((camera.transform.columns[0]).x, (camera.transform.columns[1]).x);
    CGFloat angle = 0;
    
    if (tilt >= 0 && tilt < threshold1) {
        angle = camera.eulerAngles.y;
    }else if (tilt >= threshold1 && tilt < threshold2) {
        CGFloat relativeInRange = fabs((tilt - threshold1) / (threshold2 - threshold1));
        CGFloat normalizedY = [self normalizeAngle:camera.eulerAngles.y forMinimalRotationTo:yaw];
        angle = normalizedY * (1 - relativeInRange) + yaw * relativeInRange;
    }else {
        angle = yaw;
    }
    
    if (self.state != FocusSquareStateInitializing) {
        [self updateAlignmentFor:hitTestResult yRotationAngle:angle];
    }
}

- (void)updateAlignmentFor:(ARHitTestResult *)hitTestResult yRotationAngle:(CGFloat)angle {
    // 如果当前动画正在进行，则中止
    if (self.isChangingAlignment) {
        return;
    }
    
    BOOL shouldAnimateAlignmentChange = NO;
    
    SCNNode *tempNode = [SCNNode new];
    tempNode.simdRotation = simd_make_float4(0, 1, 0, angle);
    
    // 确定当前对齐
    ARPlaneAnchorAlignment alignment;
    if ([hitTestResult.anchor isKindOfClass:ARPlaneAnchor.class]) {
        alignment = ((ARPlaneAnchor *)hitTestResult.anchor).alignment;
    }else if (hitTestResult.type == ARHitTestResultTypeEstimatedHorizontalPlane) {
        alignment = ARPlaneAnchorAlignmentHorizontal;
    }else {
        alignment = ARPlaneAnchorAlignmentVertical;
    }
    [self.recentFocusSquareAlignments addObject:[NSNumber numberWithInteger:alignment]];
    
    // 添加最近的线路表
    NSUInteger count = self.recentFocusSquareAlignments.count;
    if (count > 20) {
        [self.recentFocusSquareAlignments removeObjectsInRange:NSMakeRange(0, count - 20)];
    }
    
    __block NSUInteger horizontalHistory = 0;
    __block NSUInteger verticalHistory = 0;
    [self.recentFocusSquareAlignments enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        switch (obj.integerValue) {
            case ARPlaneAnchorAlignmentHorizontal:
                horizontalHistory += 1;
                break;
                
            case ARPlaneAnchorAlignmentVertical:
                verticalHistory += 1;
                break;
        }
    }];
    
    // 对齐与大多数历史相同的话 - 改变它
    if ((alignment == ARPlaneAnchorAlignmentHorizontal && horizontalHistory > 15) || (alignment == ARPlaneAnchorAlignmentVertical && verticalHistory > 10) || ([hitTestResult.anchor isKindOfClass:ARPlaneAnchor.class])) {
        if (alignment != self.currentAlignment) {
            shouldAnimateAlignmentChange = YES;
            self.currentAlignment = alignment;
            [self.recentFocusSquareAlignments removeAllObjects];
        }
    }else {
        // 对齐与大多数历史不同的话 - 忽略它
        alignment = self.currentAlignment;
        return;
    }
    
    if (alignment == ARPlaneAnchorAlignmentVertical) {
        tempNode.simdOrientation = [PositionTranslation getOrientationWithMatrixFloat4x4:hitTestResult.worldTransform];
        shouldAnimateAlignmentChange = YES;
    }
    
    // 改变焦点方块的对齐方式
    if (shouldAnimateAlignmentChange) {
        [self performAlignmentAnimationTo:tempNode.simdOrientation];
    }else {
        self.simdOrientation = tempNode.simdOrientation;
    }
    
}

// 将角度标准化为90度，使得另一个角度的旋转最小
- (CGFloat)normalizeAngle:(CGFloat)angle forMinimalRotationTo:(CGFloat)ref {
    CGFloat normalized = angle;
    while (fabs(normalized - ref) > M_PI_4) {
        if (angle > ref) {
            normalized -= M_PI_2;
        }else {
            normalized += M_PI_2;
        }
    }
    return normalized;
}

/*
 通过在远处时关闭和向下放大来缩小视觉尺寸随距离的变化。
      
 对于0.7米或更小的距离（观察桌子时的估计距离），这些调整导致1.0x的比例，对于距离1.5米距离（观察地板时的估计距离），比例为1.2x。
 */

- (CGFloat)scaleBasedOnDistanceCamera:(ARCamera *)camera {
    if (camera == nil) {
        return 1.0;
    }
    
    CGFloat distanceFromCamera = simd_length(self.simdWorldPosition - [PositionTranslation getTranslationWithMatrixFloat4x4:camera.transform]);
    if (distanceFromCamera < 0.7) {
        return distanceFromCamera / 0.7;
    }else {
        return 0.25 * distanceFromCamera + 0.825;
    }
}

#pragma mark - Animations

- (void)performOpenAnimation {
    if (self.isOpen || self.isAnimating) {
        return;
    }
    
    self.isOpen = YES;
    self.isAnimating = YES;
    
    // 打开动画
    [SCNTransaction begin];
    SCNTransaction.animationTimingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    SCNTransaction.animationDuration = FocusSquare.animationDuration / 4;
    self.positioningNode.opacity = 1.0;
    for (Segment *segment in self.segments) {
        [segment open];
    }
    SCNTransaction.completionBlock = ^{
        [self.positioningNode runAction:[self pulseAction] forKey:@"pulse"];
        self.isAnimating = NO;
    };
    [SCNTransaction commit];
    
    // 添加 缩放/反弹 动画
    [SCNTransaction begin];
    SCNTransaction.animationTimingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    SCNTransaction.animationDuration = FocusSquare.animationDuration / 4;
    self.positioningNode.simdScale = FocusSquare.size;
    [SCNTransaction commit];
}

- (void)performCloseAnimationFlash:(BOOL)flash {
    if (!self.isOpen || self.isAnimating) {
        return;
    }
    self.isOpen = NO;
    self.isAnimating = YES;
    
    [self.positioningNode removeActionForKey:@"pulse"];
    self.positioningNode.opacity = 1.0;
    
    // 关闭动画
    [SCNTransaction begin];
    SCNTransaction.animationTimingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    SCNTransaction.animationDuration = FocusSquare.animationDuration / 2;
    self.positioningNode.opacity = 0.99;
    SCNTransaction.completionBlock = ^{
        [SCNTransaction begin];
        SCNTransaction.animationTimingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        SCNTransaction.animationDuration = FocusSquare.animationDuration / 4;
        for (Segment *segment in self.segments) {
            [segment close];
        }
        SCNTransaction.completionBlock = ^{
            self.isAnimating = NO;
        };
        [SCNTransaction commit];
    };
    [SCNTransaction commit];
    
    // 缩放 动画
    [self.positioningNode addAnimation:[self scaleAnimationFor:@"transform.scale.x"] forKey:@"transform.scale.x"];
    [self.positioningNode addAnimation:[self scaleAnimationFor:@"transform.scale.y"] forKey:@"transform.scale.y"];
    [self.positioningNode addAnimation:[self scaleAnimationFor:@"transform.scale.z"] forKey:@"transform.scale.z"];
    
    if (flash) {
        SCNAction *waitAction = [SCNAction waitForDuration:FocusSquare.animationDuration * 0.75];
        SCNAction *fadeInAction = [SCNAction fadeOpacityTo:0.25 duration:FocusSquare.animationDuration * 0.125];
        SCNAction *fadeOutAction = [SCNAction fadeOpacityTo:0.0 duration:FocusSquare.animationDuration * 0.125];
        [self.fillPlane runAction:[SCNAction sequence:@[waitAction, fadeInAction, fadeOutAction]]];
        
        SCNAction *flashSquareAction = [self flashAnimationDuration:(FocusSquare.animationDuration * 0.25)];
        for (Segment *segment in self.segments) {
            [segment runAction:[SCNAction sequence:@[waitAction, flashSquareAction]]];
        }
    }
}

- (void)performAlignmentAnimationTo:(simd_quatf)newOrientation  {
    self.isChangingAlignment = YES;
    [SCNTransaction begin];
    SCNTransaction.completionBlock = ^{
        self.isChangingAlignment = NO;
    };
    SCNTransaction.animationDuration = 0.5;
    SCNTransaction.animationTimingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    self.simdOrientation = newOrientation;
    [SCNTransaction commit];
}


#pragma mark - Animations and Actions


- (SCNAction*) pulseAction {
    SCNAction *pulseOutAction = [SCNAction fadeOpacityTo:0.4 duration:0.5];
    SCNAction *pulseInAction = [SCNAction fadeOpacityTo:1.0 duration:0.5];
    pulseOutAction.timingMode = SCNActionTimingModeEaseInEaseOut;
    pulseInAction.timingMode = SCNActionTimingModeEaseInEaseOut;
    
    return [SCNAction repeatActionForever:[SCNAction sequence:[NSArray<SCNAction *> arrayWithObjects:pulseOutAction, pulseInAction, nil]]];
}

- (SCNAction*) flashAnimationDuration:(NSTimeInterval) duration {
    SCNAction *action = [SCNAction customActionWithDuration:duration actionBlock:^(SCNNode * _Nonnull node, CGFloat elapsedTime) {
        // 动画颜色从 HSB 48/100/100 到 48/30/100 然后在回复
        CGFloat elapsedTimePercentage = elapsedTime / duration;
        CGFloat saturation = 2.8 * (elapsedTimePercentage - 0.5) * (elapsedTimePercentage - 0.5) + 0.3;
        SCNMaterial *material = node.geometry.firstMaterial;
        if (material != nil) {
            material.diffuse.contents = [UIColor colorWithHue:0.1333 saturation:saturation brightness:1.0 alpha:1.0];
        }
    }];
    return action;
}


#pragma mark - Convenience Methods

- (CAKeyframeAnimation *)scaleAnimationFor:(NSString *)keyPath {
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:keyPath];
    
    CAMediaTimingFunction *easeOut = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    CAMediaTimingFunction *easeInOut = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    CAMediaTimingFunction *linear = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    CGFloat size = FocusSquare.size;
    CGFloat ts = FocusSquare.size * FocusSquare.scaleForClosedSquare;
    NSArray<NSNumber *> *values = @[[NSNumber numberWithFloat:size], [NSNumber numberWithFloat:size * 1.15], [NSNumber numberWithFloat:size * 1.15], [NSNumber numberWithFloat:ts * 0.97], [NSNumber numberWithFloat:ts]];
    NSArray<NSNumber *> *keyTimes = @[@0.00, @0.25, @0.50, @0.75, @1.00];
    NSArray<CAMediaTimingFunction *> *timingFunctions = @[easeOut, linear, easeOut, easeInOut];
    
    scaleAnimation.values = values;
    scaleAnimation.keyTimes = keyTimes;
    scaleAnimation.timingFunctions = timingFunctions;
    scaleAnimation.duration = FocusSquare.animationDuration;
    
    return scaleAnimation;
}

- (void)displayNodeHierarchyOnTop:(BOOL)isOnTop {
    [self updateRenderOrderForNode:self.positioningNode withIsOnTop:isOnTop];
}

- (void)updateRenderOrderForNode:(SCNNode *)node withIsOnTop:(BOOL)isOnTop {
    node.renderingOrder = isOnTop ? 2 : 0;
    SCNGeometry *geometry = node.geometry;
    if (geometry != nil) {
        for (SCNMaterial *material in geometry.materials) {
            material.readsFromDepthBuffer = !isOnTop;
        }
    }
    
    for (SCNNode *childNode in node.childNodes) {
        [self updateRenderOrderForNode:childNode withIsOnTop:isOnTop];
    }
}


#pragma mark - getter/setter

- (NSMutableSet<ARAnchor *> *)anchorsOfVisitedPlanes {
    if (!_anchorsOfVisitedPlanes) {
        _anchorsOfVisitedPlanes = [NSMutableSet<ARAnchor *> set];
    }
    return _anchorsOfVisitedPlanes;
}

- (NSMutableArray<NSNumber *> *)recentFocusSquareAlignments {
    if (!_recentFocusSquareAlignments) {
        _recentFocusSquareAlignments = [NSMutableArray<NSNumber *> array];
    }
    return _recentFocusSquareAlignments;
}

- (NSMutableArray<ARHitTestResult *> *)recentFocusSquarePositions {
    if (!_recentFocusSquarePositions) {
        _recentFocusSquarePositions = [NSMutableArray<ARHitTestResult *> array];
    }
    return _recentFocusSquarePositions;
}

- (simd_float3)lastPosition {
    return [PositionTranslation getTranslationWithMatrixFloat4x4:self.stateHitTestResult.worldTransform];
}

- (void)setState:(FocusSquareState)state forHitTestResult:(ARHitTestResult *)hitTestResult camera:(ARCamera *)camera {
    if (self.state != state) {
        self.state = state;
        switch (state) {
            case FocusSquareStateInitializing:
                [self displayAsBillBoard];
                break;
                
            case FocusSquareStateDetecting:
                [self displayAsOpenFor:hitTestResult camera:camera];
                self.currentPlaneAnchor = nil;
                break;
        }
    }
}



- (SCNNode *)fillPlane {
    
    CGFloat correctionFactor = FocusSquare.thickness / 2;
    CGFloat length = 1.0 - FocusSquare.thickness * 2 + correctionFactor;
    
    SCNPlane *plane = [SCNPlane planeWithWidth:length height:length];
    SCNNode *node = [SCNNode nodeWithGeometry:plane];
    node.name = @"fillPlane";
    node.opacity = 0.0;
    
    SCNMaterial *material = plane.firstMaterial;
    material.diffuse.contents = FocusSquare.fillColor;
    material.doubleSided = YES;
    material.ambient.contents = [UIColor blackColor];
    material.lightingModelName = SCNLightingModelConstant;
    material.emission.contents = FocusSquare.fillColor;
    
    return node;
}

+ (UIColor *)primaryColor {
    return [UIColor colorWithRed:1 green:0.8 blue:0 alpha:1];
}

+ (UIColor *)fillColor {
    return [UIColor colorWithRed:0 green:0.9 blue:0.4 alpha:1];
}

+ (CGFloat)size {
    return 0.17;
}

+ (CGFloat)thickness {
    return 0.018;
}

+ (CGFloat)scaleForClosedSquare {
    return 0.97;
}

+ (CGFloat)sideLengthForOpenSegments {
    return 0.2;
}

+ (CGFloat)animationDuration {
    return 0.7;
}

@end

