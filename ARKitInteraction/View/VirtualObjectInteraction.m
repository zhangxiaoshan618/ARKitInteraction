//
//  VirtualObjectInteraction.m
//  ARKitInteraction
//
//  Created by 张晓珊 on 2018/9/15.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import "VirtualObjectInteraction.h"
#import "VirtualObjectARView.h"
#import "ThresholdPanGesture.h"
#import "VirtualObject.h"

@interface VirtualObjectInteraction () <UIGestureRecognizerDelegate>

///开发人员设置转换，假设检测到的平面无限延伸。
@property (nonatomic, assign) BOOL translateAssumingInfinitePlane;

///在移动虚拟内容时进行测试的场景视图。
@property (nonatomic, strong) VirtualObjectARView *sceneView;

///由平移和旋转手势跟踪使用的对象。
@property (nonatomic, strong) VirtualObject *trackedObject;

///用于在`updateObjectToCurrentTrackingPosition（）`中更新`trackedObject`位置的跟踪屏幕位置。
@property (nonatomic, assign) CGPoint currentTrackingPosition;

@end

@implementation VirtualObjectInteraction

- (instancetype)initWithSceneView:(VirtualObjectARView *)sceneView
{
    self = [super init];
    if (self) {
        self.sceneView = sceneView;
        
        ThresholdPanGesture *panGesture = [[ThresholdPanGesture alloc] initWithTarget:self action:@selector(didPanWith:)];
        panGesture.delegate = self;
        
        UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(didRotateWith:)];
        rotationGesture.delegate = self;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapWith:)];
        
        [sceneView addGestureRecognizer:panGesture];
        [sceneView addGestureRecognizer:rotationGesture];
        [sceneView addGestureRecognizer:tapGesture];
        
    }
    return self;
}

#pragma mark - Gesture Actions

- (void)didPanWith:(ThresholdPanGesture *)gesture {
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            // 检查与新对象的交互
            VirtualObject *object = [self objectInteractingWith:gesture in:self.sceneView];
            if (object != nil) {
                self.trackedObject = object;
            }
        } break;
            
        case UIGestureRecognizerStateChanged: {
            if (gesture.isThresholdExceeded && self.trackedObject != nil) {
                CGPoint translation = [gesture translationInView:self.sceneView];
                CGPoint currentPosition = self.currentTrackingPosition;
                
                //`currentTrackingPosition`用于更新`updateObjectToCurrentTrackingPosition（）`中的`selectedObject`。
                self.currentTrackingPosition = CGPointMake(currentPosition.x + translation.x, currentPosition.y + translation.y);
                [gesture setTranslation:CGPointZero inView:self.sceneView];
            } //忽略对平移手势的更改，直到超出置换阈值。
        } break;
            
        case UIGestureRecognizerStateEnded:
            if (self.trackedObject != nil) {
                [self.sceneView addOrUpdateAnchorFor:self.trackedObject];
            }
            
        default:
            // Clear the current position tracking.
            self.currentTrackingPosition = CGPointZero;
            self.trackedObject = nil;
            break;
    }
}

/**
 如果正在进行拖动手势，请更新跟踪对象的位置
 将屏幕上的2D触摸位置（`currentTrackingPosition`）转换为3D世界空间。
 每帧调用此方法（通过`SCNSceneRendererDelegate`回调），允许拖动手势移动虚拟对象，无论是否一个在屏幕上拖动手指或通过空间移动设备。
 - 标签：updateObjectToCurrentTrackingPosition
 */
- (void)updateObjectToCurrentTrackingPosition {
    if (self.trackedObject == nil || (self.currentTrackingPosition.x == 0 && self.currentTrackingPosition.y == 0)) {
        return;
    }
    
    [self translateWith:self.trackedObject basedOn:self.currentTrackingPosition infinitePlane:self.translateAssumingInfinitePlane allowAnimation:YES];
}

- (void)didRotateWith:(UIRotationGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateChanged) {
        return;
    }
    /*
     - 注意：
     为了俯视对象（占所有用例的99％），我们需要减去角度。
     当从下面看对象时，使旋转也能正常工作
     根据物体是在相机上方还是下方，翻转角度的符号......
     */
    self.trackedObject.objectRotation -= gesture.rotation;
    gesture.rotation = 0;
}

- (void)didTapWith:(UITapGestureRecognizer *)gesture {
    CGPoint touchLocation = [gesture locationInView:self.sceneView];
    
    VirtualObject *tappedObject = [self.sceneView virtualObjectAt:touchLocation];
    if (tappedObject != nil) {
        self.selectedObject = tappedObject;
    }else if (self.selectedObject != nil) {
        //将对象传送到用户触摸屏幕的位置。
        [self translateWith:self.selectedObject basedOn:touchLocation infinitePlane:NO allowAnimation:NO];
        [self.sceneView addOrUpdateAnchorFor:self.selectedObject];
    }
}

#pragma mark - UIGestureRecognizerDelegate

//允许同时翻译和旋转对象。
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
     return YES;
}


///一个辅助方法，用于返回在提供的`gesture`s触摸位置下找到的第一个对象。
/// - 标签：TouchTesting
- (VirtualObject *)objectInteractingWith:(UIGestureRecognizer *)gesture in:(ARSCNView *)view {
    NSUInteger count = gesture.numberOfTouches;
    for (NSUInteger index = 0; index < count; index++) {
        CGPoint touchLocation = [gesture locationOfTouch:index inView:view];
        
        //直接在`touchLocation`下查找对象。
        VirtualObject *object = [self.sceneView virtualObjectAt:touchLocation];
        if (object != nil) {
            return object;
        }
    }
    
    //作为最后的手段，寻找触摸中心下的物体。
    return [self.sceneView virtualObjectAt:[gesture centerIn:view]];
}

#pragma mark - 更新对象的点
/// 拖拽虚拟对象
- (void)translateWith:(VirtualObject *)object basedOn:(CGPoint)screenPos infinitePlane:(BOOL)infinitePlane allowAnimation:(BOOL)allowAnimation {
    ARFrame *frame = self.sceneView.session.currentFrame;
    if (frame == nil) {
        return;
    }
    
    simd_float4x4 cameraTransform = frame.camera.transform;
    simd_float3 position = object.simdWorldPosition;
    ARHitTestResult *result = [self.sceneView smartHitTest:screenPos infinitePlane:infinitePlane objectPosition:&position allowedAlignments:object.allowedAlignments];
    if (result == nil) {
        return;
    }
    
    ARPlaneAnchorAlignment planeAlignment;
    if ([result.anchor isKindOfClass:ARPlaneAnchor.class]) {
        planeAlignment = ((ARPlaneAnchor *)result.anchor).alignment;
    }else if (result.type == ARHitTestResultTypeEstimatedHorizontalPlane) {
        planeAlignment = ARPlaneAnchorAlignmentHorizontal;
    }else if (result.type == ARHitTestResultTypeEstimatedVerticalPlane) {
        planeAlignment = ARPlaneAnchorAlignmentVertical;
    }else {
        return;
    }
    
    /*
     飞机撞击测试结果一般是平滑的。 如果我们没有击中飞机，请平滑运动以防止大跳跃。
     */
    simd_float4x4 transform = result.worldTransform;
    BOOL isOnPlane = [result.anchor isKindOfClass:ARPlaneAnchor.class];
    [object setTransform:transform relativeTo:cameraTransform smoothMovement:!isOnPlane alignment:planeAlignment allowAnimation:allowAnimation];
}


#pragma mark - setter/getter

- (void)setTrackedObject:(VirtualObject *)trackedObject {
    _trackedObject = trackedObject;
    if (_trackedObject != nil) {
        self.selectedObject = trackedObject;
    }
}

@end


@implementation UIGestureRecognizer (Center)

- (CGPoint)centerIn:(UIView *)view {
    CGPoint origin = [self locationOfTouch:0 inView:view];
    CGRect first = CGRectMake(origin.x, origin.y, 0, 0);
    for (NSUInteger index = 1; index < self.numberOfTouches; index++) {
         CGPoint origin = [self locationOfTouch:index inView:view];
        first = CGRectUnion(first, CGRectMake(origin.x, origin.y, 0, 0));
    }
    return CGPointMake(CGRectGetMidX(first), CGRectGetMidY(first));
}

@end
