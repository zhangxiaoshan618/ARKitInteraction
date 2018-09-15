//
//  ViewController.m
//  ARKitInteraction
//
//  Created by 张晓珊 on 2018/9/8.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import "ViewController.h"
#import "ChoseItemView.h"
#import "MainFunctionView.h"
#import "LJNetworkService.h"
#import "ConfirmOrderModel.h"
#import "YYModel.h"
#import "ShotedPicView.h"
#import "Theme.h"
#import "ConfirmOrderViewController.h"
#import "ClassItemArrayModel.h"
#import "ViewController+Actions.h"
#import "ViewController+ObjectSelection.h"
#import "ViewController+ARSCNViewDelegate.h"
#import "Masonry.h"
#import "EnumHeader.h"

static const CGFloat itemViewHeight = 200;

@interface ViewController () <ARSCNViewDelegate,MainFunctionViewDelegate,ChoseItemViewDelegate>

@property (nonatomic, strong) ChoseItemView *itemView;
@property (nonatomic, strong) MainFunctionView *mainFunctionView;
@property (nonatomic, strong) ShotedPicView *shotPicVeiw;
@property (nonatomic, strong) UIImageView *shotImageView;
@property (nonatomic, strong) UIImage *currentShotImage;
@property (nonatomic, strong) NSMutableArray *picArray;
@property (nonatomic, assign) NSInteger picCount;
@property (nonatomic, copy) NSString *resultStr;
@property (nonatomic, copy) NSArray<ClassItemModel *> *goodsAllDataSource;

@end

    
@implementation ViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.focusSquare = [FocusSquare new];
        self.virtualObjectLoader = [VirtualObjectLoader new];
        self.isRestartAvailable = YES;
        self.updateQueue = dispatch_queue_create("com.example.apple-samplecode.arkitexample.serialSceneKitQueue", NULL);
    }
    return self;
}

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpUI];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Set the view's delegate
    self.sceneView.delegate = self;
    self.sceneView.session.delegate = self;
    
    // 设置场景内容。
    [self setupCamera];
    [self.sceneView.scene.rootNode addChildNode:self.focusSquare];
    [self.sceneView setupDirectionalLighting:self.updateQueue];
    
    //连接状态视图控制器回调。
    __weak typeof(self) weakSelf = self;
    self.statusViewController.restartExperienceHandler = ^{
        [weakSelf restartExperience];
    };
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showVirtualObjectSelectionViewController)];
    //设置委托以确保仅在场景中没有虚拟对象时使用此手势。
    tapGesture.delegate = self;
    [self.sceneView addGestureRecognizer:tapGesture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.blurView.hidden = YES;
    // Create a session configuration
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    ARWorldTrackingConfiguration *configuration = [ARWorldTrackingConfiguration new];

    // Run the view's session
    [self.sceneView.session runWithConfiguration:configuration];
    _mainFunctionView = [MainFunctionView showInFatherView:self.view];
    _mainFunctionView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //防止屏幕变暗以避免中断AR体验。
    UIApplication.sharedApplication.idleTimerDisabled = YES;
    
    //启动`ARSession`。
    [self resetTracking];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.blurView.hidden = NO;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    // Pause the view's session
    [self.sceneView.session pause];
}

- (void)setUpUI {
    [self.view addSubview:self.sceneView];
    [self.view addSubview:self.blurView];
    [self.view addSubview:self.addObjectButton];
    [self.view addSubview:self.spinner];
    
    [self.sceneView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.trailing.equalTo(self.view);
    }];
    
    [self.blurView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.trailing.equalTo(self.view);
    }];
    
    [self.addObjectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(@48);
        make.bottom.equalTo(self.view).inset(15);
        make.centerX.equalTo(self.view);
    }];
    
    [self.spinner mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(@48);
        make.bottom.equalTo(self.view).inset(15);
        make.centerX.equalTo(self.view);
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_itemView) {
        [self.itemView dismissSelfAndReturnResult];
        NSMutableArray *selectArray = [NSMutableArray array];
        for (ClassItemModel *classModel in self.goodsAllDataSource) {
            for (GoodsItemModel *goodItemModel in classModel.classList) {
                for (GoodsInfoModel *goodInfo in goodItemModel.goodInfoArray) {
                    if (goodInfo.isSelect == YES) {
                        if (goodInfo.goodSizeId) {
                            [selectArray addObject:goodInfo.goodSizeId];
                        }
                    }
                }
            }
        }
        NSMutableString *resultStr = [NSMutableString string];
        for (NSString *infoId in selectArray) {
            if (infoId == selectArray.lastObject) {
                [resultStr appendString:infoId];
            } else {
                [resultStr appendString:[NSString stringWithFormat:@"%@,",infoId]];
            }
        }
        _resultStr = resultStr;
    }
}

#pragma mark - 场景内容设置
- (void)setupCamera {
    SCNCamera *camera = self.sceneView.pointOfView.camera;
    if (camera != nil) {
        //使用环境照明和基于物理的材质，启用HDR相机设置以获得最逼真的外观。
        camera.wantsHDR = YES;
        camera.exposureOffset = -1;
        camera.minimumExposure = -1;
        camera.maximumExposure = 3;
    }
}

#pragma mark - Session management

///创建一个新的AR配置以在`session`上运行。
- (void)resetTracking {
    self.virtualObjectInteraction.selectedObject = nil;
    
    ARWorldTrackingConfiguration *configuration = [ARWorldTrackingConfiguration new];
    configuration.planeDetection = ARPlaneDetectionHorizontal | ARPlaneDetectionVertical;
    
    [self.session runWithConfiguration:configuration options:ARSessionRunOptionResetTracking | ARSessionRunOptionRemoveExistingAnchors];
    
    [self.statusViewController scheduleMessage:@"找到一个表面来摆放一个物体" inSeconds:7.5 messageType:MessageTypePlaneEstimation];
}

#pragma mark - 焦点广场

- (void)updateFocusSquare:(BOOL)isObjectVisible {
    if (isObjectVisible) {
        [self.focusSquare hide];
    }else {
        [self.focusSquare unhide];
        [self.statusViewController scheduleMessage:@"请尝试向左或向右移动" inSeconds:5.0 messageType:MessageTypeFocusSquare];
    }
    
    //仅在ARKit跟踪处于良好状态时执行适合性测试。
    ARCamera *camera = self.session.currentFrame.camera;
    
    if (camera != nil && camera.trackingState == ARTrackingStateNormal) {
        ARHitTestResult *result = [self.sceneView smartHitTest:self.screenCenter infinitePlane:NO objectPosition:nil allowedAlignments:@[[NSNumber numberWithInteger:ARPlaneAnchorAlignmentHorizontal], [NSNumber numberWithInteger:ARPlaneAnchorAlignmentVertical]]];
        dispatch_async(self.updateQueue, ^{
            [self.sceneView.scene.rootNode addChildNode:self.focusSquare];
            [self.focusSquare setState:FocusSquareStateDetecting forHitTestResult:result camera:camera];
        });
        self.addObjectButton.hidden = NO;
        [self.statusViewController cancelScheduledMessageFor:MessageTypeFocusSquare];
    }else {
        dispatch_async(self.updateQueue, ^{
            [self.focusSquare setState:FocusSquareStateInitializing forHitTestResult:nil camera:nil];
            [self.sceneView.pointOfView addChildNode:self.focusSquare];
        });
        self.addObjectButton.hidden = YES;
    }
}

#pragma mark - 错误处理

- (void)displayErrorMessage:(NSString *)title message:(NSString *)message {
    //模糊背景
    self.blurView.hidden = NO;
    
    //提供通知，告知已发生的错误。
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *restartAction = [UIAlertAction actionWithTitle:@"Restart Session" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
        self.blurView.hidden = YES;
        [self resetTracking];
    }];
    [alertController addAction:restartAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)didClicedListButton {
    [self loadGoodsAllDataAndShowGoods];
}

- (void)shotButtonClicked {
    _shotPicVeiw = [ShotedPicView showInFatherView:self.view];
    _shotPicVeiw.delegate = self;
    UIGraphicsBeginImageContext(self.view.bounds.size);
    //CGContextRef context = UIGraphicsGetCurrentContext();
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    //    UIBezierPath *p = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:cornerRadius];
    //    p.lineWidth = 0.01;
    //    p.lineCapStyle = kCGLineCapRound;
    //    p.lineJoinStyle = kCGLineJoinRound;
    //    CGContextAddPath(context,p.CGPath);
    //    CGContextClip(context);
    _currentShotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self showImageView];
    
}

- (void)clickBackButton {
    [_shotPicVeiw removeFromSuperview];
    [self hideImageView];
}

- (void)clickSaveButton {
    if (!self.picArray) {
        _picArray = [NSMutableArray array];
    }
    [self.picArray addObject:_currentShotImage];
    [_shotPicVeiw removeFromSuperview];
    [self hideImageView];
}

- (void)clickNextButton {
    [_shotPicVeiw removeFromSuperview];
    [self hideImageView];
    if (_resultStr) {
        NSDictionary *dic = @{@"price_id":_resultStr};
        [[LJNetworkService defaultService] postWithUrl:@"http://10.26.9.140:8020/home/orderconfirm" parameters:dic modelClass:nil completion:^(id data, NSError *error) {
            ConfirmOrderModel *confirmModel = [ConfirmOrderModel yy_modelWithDictionary:data[@"data"]];
            NSLog(@"%@",confirmModel);
            ConfirmOrderViewController *confirmVC = [[ConfirmOrderViewController alloc]init];
            confirmVC.goodsAllDataSource = self.goodsAllDataSource;
            confirmVC.picArray = self.picArray;
            confirmVC.confirmModel = confirmModel;
            [self.navigationController pushViewController:confirmVC animated:YES];
        }];
    }
}

- (void)showImageView {
    if (!_shotImageView) {
        _shotImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [Theme screenWidth], [Theme screenHeight]-itemViewHeight)];
        [self.view addSubview:_shotImageView];
        [self.view bringSubviewToFront:_shotImageView];
        _shotImageView.image = self.currentShotImage;
    }
    _shotImageView.hidden = NO;
}

- (void)hideImageView {
    _shotImageView.hidden = YES;
}

- (void)loadGoodsAllDataAndShowGoods {
    [[LJNetworkService defaultService] getWithUrl:@"http://10.26.9.140:8020/home/goodsall" parameters:nil modelClass:nil completion:^(id data, NSError *error) {
        if (!error) {
            if ([data isKindOfClass:NSDictionary.class]) {
                ClassItemArrayModel *itemModel = [ClassItemArrayModel yy_modelWithDictionary:data];
                self.goodsAllDataSource = itemModel.classArray;
                self.itemView = [ChoseItemView showChoseItemViewWithFatherView:self.view dataSource:self.goodsAllDataSource];
                self.itemView.delegate = self;
            }
        }
    }];
}

- (void)didSelectItemWithGoodType:(EGoogsType)goodType; {
    NSInteger canShow = EGoogsTypeVase|EGoogsTypeTeaCup|EGoogsTypeTeaTable|EGoogsTypePhotoFrame|EGoogsTypeSticker|EGoogsDeskLamp|EGoogsFloorLamp;
    if (!(canShow&goodType)) {
        //不符合条件的都当花瓶看待
        goodType = EGoogsTypeVase;
    }
}

#pragma mark - setter/getter

- (StatusViewController *)statusViewController {
    if (!_statusViewController) {
        NSMutableArray<StatusViewController *> *controllers = [NSMutableArray<StatusViewController *> array];
        for (UIViewController *controller in self.childViewControllers) {
            if ([controller isKindOfClass:StatusViewController.class]) {
                [controllers addObject:(StatusViewController *)controller];
            }
        }
        _statusViewController = controllers.firstObject;
    }
    return _statusViewController;
}

- (VirtualObjectInteraction *)virtualObjectInteraction {
    if (!_virtualObjectInteraction) {
        _virtualObjectInteraction = [[VirtualObjectInteraction alloc] initWithSceneView:self.sceneView];
    }
    return _virtualObjectInteraction;
}

- (CGPoint)screenCenter {
    CGRect bounds = self.sceneView.bounds;
    return CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
}

- (ARSession *)session {
    return self.sceneView.session;
}

- (UIActivityIndicatorView *)spinner {
    if (!_spinner) {
        UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _spinner = view;
    }
    return _spinner;
}

- (UIVisualEffectView *)blurView {
    if (!_blurView) {
        UIVisualEffectView *view = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        _blurView = view;
    }
    return _blurView;
}

- (UIButton *)addObjectButton {
    if (_addObjectButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(showVirtualObjectSelectionViewController) forControlEvents:UIControlEventTouchUpInside];
        _addObjectButton = button;
    }
    return _addObjectButton;
}

- (VirtualObjectARView *)sceneView {
    if (!_sceneView) {
        VirtualObjectARView *view = [VirtualObjectARView new];
        _sceneView = view;
    }
    return _sceneView;
}

@end
