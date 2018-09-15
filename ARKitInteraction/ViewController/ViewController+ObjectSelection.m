//
//  ViewController+ObjectSelection.m
//  ARKitInteraction
//
//  Created by 张晓珊 on 2018/9/15.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import "ViewController+ObjectSelection.h"

/**
 将指定的虚拟对象添加到场景中，放置在世界空间位置
       通过屏幕中心的命中测试估计。
      
       - 标签：PlaceVirtualObject
 */

@implementation ViewController (ObjectSelection)

- (void)placeVirtualObject:(VirtualObject *)virtualObject {
    if (self.focusSquare.state == ARTrackingStateReasonInitializing) {
        [self.statusViewController showMessage:@"无法放置物体\n请尝试向左或向右移动" autoHide:YES];
        
        if (self.objectsViewController != nil) {
            // TODO:
        }
        return;
    }
    
    [self.virtualObjectInteraction translateWith:virtualObject basedOn:self.screenCenter infinitePlane:NO allowAnimation:NO];
    self.virtualObjectInteraction.selectedObject = virtualObject;
    
    dispatch_async(self.updateQueue, ^{
        [self.sceneView.scene.rootNode addChildNode:virtualObject];
        [self.sceneView addOrUpdateAnchorFor:virtualObject];
    });
}

#pragma mark - VirtualObjectSelectionViewControllerDelegate

- (void)virtualObjectSelectionViewController:(VirtualObjectSelectionViewController *)selectionViewController didSelectObject:(VirtualObject *)selectObject {

    if (selectObject == nil) {
        return;
    }
    
    [self.virtualObjectLoader loadVirtualObject:selectObject loadedHandler:^(VirtualObject *loadedObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideObjectLoadingUI];
            [self placeVirtualObject:loadedObject];
        });
    }];
}

- (void)virtualObjectSelectionViewController:(VirtualObjectSelectionViewController *)selectionViewController didDeselectObject:(VirtualObject *)deselectObject {
    
    if (deselectObject == nil) {
        return;
    }
    
    if (![self.virtualObjectLoader.loadedObjects containsObject:deselectObject]) {
        return;
    }
    
    NSInteger objectIndex = [self.virtualObjectLoader.loadedObjects indexOfObject:deselectObject];
    
    [self.virtualObjectLoader removeVirtualObjectAt:objectIndex];
    self.virtualObjectInteraction.selectedObject = nil;
    
    if (deselectObject.anchor != nil) {
        [self.session removeAnchor:deselectObject.anchor];
    }
}

#pragma mark - 加载对象的动画

- (void)displayObjectLoadingUI {
    [self.spinner startAnimating];
    
    [self.addObjectButton setImage:[UIImage imageNamed:@"buttonring"] forState:UIControlStateNormal];
    
    self.addObjectButton.enabled = NO;
    self.isRestartAvailable = NO;
}

- (void)hideObjectLoadingUI {
    [self.spinner stopAnimating];
    
    [self.addObjectButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [self.addObjectButton setImage:[UIImage imageNamed:@"addPressed"] forState:UIControlStateHighlighted];
    
    self.addObjectButton.enabled = YES;
    self.isRestartAvailable = YES;
}

@end
