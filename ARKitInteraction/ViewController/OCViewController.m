//
//  OCViewController.m
//  ARKitInteraction
//
//  Created by 张晓珊 on 2018/9/16.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import "OCViewController.h"
#import "Masonry.h"
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

@interface OCViewController () <MainFunctionViewDelegate, ChoseItemViewDelegate>

@property (nonatomic, strong) ViewController *arVC;
@property (nonatomic, strong) VirtualObjectSelectionViewController *vc;
@property (nonatomic, strong) NSArray<VirtualObject *> *allVirtualObject;

@property (nonatomic, strong) ChoseItemView *itemView;
@property (nonatomic, strong) MainFunctionView *mainFunctionView;
@property (nonatomic, strong) ShotedPicView *shotPicVeiw;
@property (nonatomic, strong) UIImageView *shotImageView;
@property (nonatomic, strong) UIImage *currentShotImage;
@property (nonatomic, strong) NSMutableArray *picArray;
@property (nonatomic, assign) NSInteger picCount;
@property (nonatomic, copy) NSString *resultStr;
@property (nonatomic, copy) NSArray<ClassItemModel *> *goodsAllDataSource;

@property (nonatomic, copy) NSDictionary<NSNumber *, VirtualObject *> *dic;

@end

@implementation OCViewController

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setUpUI];
}

- (void)setUpUI {
    [self.view addSubview:self.arVC.view];
    [self.arVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.trailing.equalTo(self.view);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finisheditNotification) name:@"finishedit" object:nil];
    
    self.allVirtualObject = [OCViewController availableObjects];
    
    NSMutableDictionary<NSNumber *, VirtualObject *> *dic = [NSMutableDictionary<NSNumber *, VirtualObject *> dictionary];
    
    for (VirtualObject *obj in self.allVirtualObject) {
        NSString *string = obj.referenceURL.absoluteString;
        if ([string containsString:@"vase.scn"]) {
            [dic setObject:obj forKey:[NSNumber numberWithInteger:EGoogsTypeVase]];
        }else if ([string containsString:@"cup.scn"]) {
            [dic setObject:obj forKey:[NSNumber numberWithInteger:EGoogsTypeTeaCup]];
        }else if ([string containsString:@"painting.scn"]) {
            [dic setObject:obj forKey:[NSNumber numberWithInteger:EGoogsTypePhotoFrame]];
        }else if ([string containsString:@"sticky note.scn"]) {
            [dic setObject:obj forKey:[NSNumber numberWithInteger:EGoogsTypeSticker]];
        }else if ([string containsString:@"lamp.scn"]) {
            [dic setObject:obj forKey:[NSNumber numberWithInteger:EGoogsDeskLamp]];
        }else if ([string containsString:@"candle.scn"]) {
            [dic setObject:obj forKey:[NSNumber numberWithInteger:EGoogsFloorLamp]];
        }
    }
    self.dic = dic.copy;
}

- (void)finisheditNotification {
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    _mainFunctionView = [MainFunctionView showInFatherView:self.view];
    _mainFunctionView.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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

//isSelect是选中状态
- (void)didSelectItemWithGoodType:(EGoogsType)goodType isSelect:(BOOL)isSelect {
    NSInteger canShow = EGoogsTypeVase|EGoogsTypeTeaCup|EGoogsTypePhotoFrame|EGoogsTypeSticker|EGoogsDeskLamp|EGoogsFloorLamp;
    if (!(canShow&goodType)) {
        //不符合条件的都当花瓶看待
        goodType = EGoogsTypeVase;
    }
    
    VirtualObject *obj = self.dic[[NSNumber numberWithInteger:goodType]];
    
    if (isSelect) {
        [self.arVC virtualObjectSelectionViewController:nil didSelectObject:obj];
    }else {
        [self.arVC virtualObjectSelectionViewController:nil didDeselectObject:obj];
    }
}

#pragma mark - 懒加载


- (ViewController *)arVC {
    if (!_arVC) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ViewController *vc = [storyBoard instantiateInitialViewController];
        [self addChildViewController:vc];
        _arVC = vc;
    }
    return _arVC;
}

- (VirtualObjectSelectionViewController *)vc {
    if (!_vc) {
        VirtualObjectSelectionViewController *controller = [VirtualObjectSelectionViewController new];
        _vc = controller;
    }
    return _vc;
}

+ (NSArray<VirtualObject *> *)availableObjects {
    
    return [VirtualObject allObjects];
}

@end
