//
//  ViewController+Actions.m
//  ARKitInteraction
//
//  Created by 张晓珊 on 2018/9/15.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import "ViewController+Actions.h"

@implementation ViewController (Actions)

#pragma mark - 界面操作

///显示来自`addObjectButton`的`VirtualObjectSelectionViewController`或响应`sceneView`中的点击手势。
- (void)showVirtualObjectSelectionViewController {
    //确保添加对象是可用操作，我们不加载另一个对象（以避免对场景进行并发修改）。
    if (!self.addObjectButton.hidden && !self.virtualObjectLoader.isLoading) {
        [self.statusViewController cancelScheduledMessageFor:MessageTypeContentPlacement];
        // TODO: 跳转VC
    }
}

///确定是否应该使用用于呈现“VirtualObjectSelectionViewController”的轻击手势。
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gesture {
    return self.virtualObjectLoader.loadedObjects.count == 0;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gesture shouldRecognizeSimultaneouslyWith:(UIGestureRecognizer *)otherGesture {
    return YES;
}

/// 重启经验
- (void)restartExperience {
    if (self.isRestartAvailable && !self.virtualObjectLoader.isLoading) {
        self.isRestartAvailable = NO;
        
        [self.statusViewController cancelAllScheduledMessages];
        
        [self.virtualObjectLoader removeAllVirtualObjects];
        [self.addObjectButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
        [self.addObjectButton setImage:[UIImage imageNamed:@"addPressed"] forState:UIControlStateHighlighted];
        
        [self resetTracking];
        
        //暂停重启一段时间，以便重新启动会话时间。
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.isRestartAvailable = YES;
        });
    }
}

#pragma mark - UIPopoverPresentationControllerDelegate

//- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
//    return UIModalPresentationNone;
//}
//
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    //所有菜单都应该是popovers（甚至在iPhone上）。
//    if
//}

@end
