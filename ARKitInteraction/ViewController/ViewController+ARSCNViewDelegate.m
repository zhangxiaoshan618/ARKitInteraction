//
//  ViewController+ARSCNViewDelegate.m
//  ARKitInteraction
//
//  Created by 张晓珊 on 2018/9/15.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import "ViewController+ARSCNViewDelegate.h"
#import <ARKit/ARError.h>
#import "PositionTranslation.h"
#import "VirtualObjectInteraction.h"

@implementation ViewController (ARSCNViewDelegate)

- (void)renderer:(id<SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time {
    
    BOOL isAnyObjectInView = NO;
    for (VirtualObject *object in self.virtualObjectLoader.loadedObjects) {
        if ([self.sceneView isNodeInsideFrustum:object withPointOfView:self.sceneView.pointOfView]) {
            isAnyObjectInView = YES;
            break;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.virtualObjectInteraction updateObjectToCurrentTrackingPosition];
        [self updateFocusSquare:isAnyObjectInView];
    });
    
    //如果对象选择菜单已打开，请更新项目的可用性
    if (self.objectsViewController != nil) {
        [self.objectsViewController updateObjectAvailabilityFor:self.focusSquare.currentPlaneAnchor];
    }
    
    //如果启用了光估计，请更新方向灯的强度
    ARLightEstimate *lightEstimate = self.session.currentFrame.lightEstimate;
    if (lightEstimate != nil) {
        [self.sceneView updateDirectionalLighting:lightEstimate.ambientIntensity queue:self.updateQueue];
    }else {
        [self.sceneView updateDirectionalLighting:1000 queue:self.updateQueue];
    }
}

- (void)renderer:(id<SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    if (![anchor isKindOfClass:ARPlaneAnchor.class]) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.statusViewController cancelScheduledMessageFor:MessageTypePlaneEstimation];
        [self.statusViewController showMessage:@"表面检测" autoHide:YES];
        if (self.virtualObjectLoader.loadedObjects.count == 0) {
            [self.statusViewController scheduleMessage:@"点击 + 放置一个对象" inSeconds:7.5 messageType:MessageTypeContentPlacement];
        }
    });
    
    dispatch_async(self.updateQueue, ^{
        for (VirtualObject *object in self.virtualObjectLoader.loadedObjects) {
            [object adjustOntoPlaneAnchor:(ARPlaneAnchor *)anchor usingNode:node];
        }
    });
}

- (void)renderer:(id<SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    dispatch_async(self.updateQueue, ^{
        if ([anchor isKindOfClass:ARPlaneAnchor.class]) {
            for (VirtualObject *object in self.virtualObjectLoader.loadedObjects) {
                [object adjustOntoPlaneAnchor:(ARPlaneAnchor *)anchor usingNode:node];
            }
        }else {
            VirtualObject *objectAtAnchor = self.virtualObjectLoader.loadedObjects.firstObject;
            if (objectAtAnchor != nil && objectAtAnchor.anchor == anchor) {
                objectAtAnchor.simdPosition = [PositionTranslation getTranslationWithMatrixFloat4x4:anchor.transform];
                objectAtAnchor.anchor = anchor;
            }
        }
    });
}

- (void)session:(ARSession *)session cameraDidChangeTrackingState:(ARCamera *)camera {
    [self.statusViewController showTrackingQualityInfoFor:camera.trackingState reason:camera.trackingStateReason autoHide:YES];
    
    switch (camera.trackingState) {
        case ARTrackingStateNotAvailable:
            [self.statusViewController escalateFeedbackFor:camera.trackingState reason:camera.trackingStateReason seconds:3.0];
            break;
            
        case ARTrackingStateLimited:
            [self.statusViewController escalateFeedbackFor:camera.trackingState reason:camera.trackingStateReason seconds:3.0];
            break;
        
        case ARTrackingStateNormal:
            [self.statusViewController cancelScheduledMessageFor:MessageTypeTrackingStateEscalation];
            //成功重新定位后取消隐藏内容。
            [self.virtualObjectLoader.loadedObjects enumerateObjectsUsingBlock:^(VirtualObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                obj.hidden = NO;
            }];
            break;
            
        default:
            break;
    }
}

- (void)session:(ARSession *)session didFailWithError:(NSError *)error {
    if (error) {
        NSString *errorMessage = [NSString stringWithFormat:@"%@\n%@\n%@", error.localizedDescription, error.localizedFailureReason, error.localizedRecoverySuggestion];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self displayErrorMessage:@"AR会话失败!" message:errorMessage];
        });
    }
}

- (void)sessionInterruptionEnded:(ARSession *)session {
    [self.virtualObjectLoader.loadedObjects enumerateObjectsUsingBlock:^(VirtualObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = YES;
    }];
}

- (BOOL)sessionShouldAttemptRelocalization:(ARSession *)session {
    return YES;
}

@end
