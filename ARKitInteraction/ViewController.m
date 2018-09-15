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
static const CGFloat itemViewHeight = 200;

@interface ViewController () <ARSCNViewDelegate,MainFunctionViewDelegate>

@property (nonatomic, strong) IBOutlet ARSCNView *sceneView;
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

- (void)viewDidLoad {
    [super viewDidLoad];

    // Set the view's delegate
    self.sceneView.delegate = self;
    
    // Show statistics such as fps and timing information
    self.sceneView.showsStatistics = YES;
    
    // Create a new scene
    SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/ship.scn"];
    
    // Set the scene to the view
    self.sceneView.scene = scene;
    self.picCount = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Create a session configuration
    ARWorldTrackingConfiguration *configuration = [ARWorldTrackingConfiguration new];

    // Run the view's session
    [self.sceneView.session runWithConfiguration:configuration];
    _mainFunctionView = [MainFunctionView showInFatherView:self.view];
    _mainFunctionView.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Pause the view's session
    [self.sceneView.session pause];
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

#pragma mark - ARSCNViewDelegate

/*
// Override to create and configure nodes for anchors added to the view's session.
- (SCNNode *)renderer:(id<SCNSceneRenderer>)renderer nodeForAnchor:(ARAnchor *)anchor {
    SCNNode *node = [SCNNode new];
 
    // Add geometry to the node...
 
    return node;
}
*/

- (void)session:(ARSession *)session didFailWithError:(NSError *)error {
    // Present an error message to the user
    
}

- (void)sessionWasInterrupted:(ARSession *)session {
    // Inform the user that the session has been interrupted, for example, by presenting an overlay
    
}

- (void)sessionInterruptionEnded:(ARSession *)session {
    // Reset tracking and/or remove existing anchors if consistent tracking is required
    
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
                _itemView = [ChoseItemView showChoseItemViewWithFatherView:self.view dataSource:self.goodsAllDataSource];
            }
        }
    }];
}

@end
