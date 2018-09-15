//
//  ViewController.h
//  ARKitInteraction
//
//  Created by 张晓珊 on 2018/9/8.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>
#import "FocusSquare.h"
#import "StatusViewController.h"
#import "VirtualObjectSelectionViewController.h"
#import "VirtualObjectInteraction.h"
#import "VirtualObjectLoader.h"
#import "VirtualObjectARView.h"

@interface ViewController : UIViewController

@property (nonatomic, strong) IBOutlet VirtualObjectARView *sceneView;

@property (nonatomic, strong) UIButton *addObjectButton;

@property (nonatomic, strong) UIVisualEffectView *blurView;

@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@property (nonatomic, strong) FocusSquare *focusSquare;

///显示状态和“重新启动体验”UI的视图控制器。
@property (nonatomic, strong) StatusViewController *statusViewController;
///显示虚拟对象选择菜单的视图控制器。
@property (nonatomic, strong) VirtualObjectSelectionViewController *objectsViewController;

#pragma mark - ARKit配置属性
///管理场景中虚拟内容的手势操作的类型。
@property (nonatomic, strong) VirtualObjectInteraction *virtualObjectInteraction;
///协调虚拟对象的引用节点的加载和卸载。
@property (nonatomic, strong) VirtualObjectLoader *virtualObjectLoader;
///标记AR体验是否可用于重新启动。
@property (nonatomic, assign) BOOL isRestartAvailable;
///用于协调从场景添加或删除节点的串行队列。
@property (nonatomic, assign) dispatch_queue_t updateQueue;

@property (nonatomic, assign, readonly) CGPoint screenCenter;
@property (nonatomic, strong, readonly) ARSession *session;

- (void)resetTracking;

@end
