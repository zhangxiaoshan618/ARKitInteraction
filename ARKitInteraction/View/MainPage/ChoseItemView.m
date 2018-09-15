//
//  choseItemView.m
//  ARKitInteraction
//
//  Created by Yi Li on 2018/9/14.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import "ChoseItemView.h"
#import "ClassItemArrayModel.h"
#import "LJNetworkService.h"
#import "YYModel.h"
#import "Theme.h"
#import "UIColor+Category.h"
#import "Masonry.h"
#import "ClassTypeSelectCell.h"
#import "AFNetworking.h"
#import "ConfirmOrderModel.h"

static const CGFloat itemViewHeight = 200;

@interface ChoseItemView()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *headViewBtnArray;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, copy) NSArray<ClassItemModel *> *dataSource;
//当前品类
//@property (nonatomic, strong) ClassItemModel *currentClass;
@property (nonatomic, assign) NSInteger classType;
@end;

@implementation ChoseItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    return self;
}

- (void)initUI {
    //头部的品类选择
    if (!self.headViewBtnArray) {
        self.headerView = [[UIView alloc] initWithFrame:CGRectZero];
        self.headerView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.headerView];
        [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(@0);
            make.height.equalTo(@50);
            make.top.equalTo(@0);
        }];
        [self addSubview:self.headerView];
        NSInteger classCount = self.dataSource.count;
        self.headViewBtnArray = [[NSMutableArray alloc] initWithCapacity:classCount];
        for (NSInteger i = 0; i < classCount; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:((ClassItemModel *)self.dataSource[i]).className forState:UIControlStateNormal];
            if (i == 0) {
                [button setTitleColor:[UIColor themeColor] forState:UIControlStateNormal];
            } else {
                [button setTitleColor:[UIColor colorWithHex:0x9399a5] forState:UIControlStateNormal];
            }
            button.titleLabel.font = [UIFont systemFontOfSize:16.0f];
            button.tag = i;
            [button addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.headerView addSubview:button];
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@(20 + i * (45 + 32)));
                make.top.equalTo(@0);
                make.width.equalTo(@50);
                make.height.equalTo(@50);
            }];
            [self.headViewBtnArray addObject:button];
        }
        self.classType = 0;
    }
    [self.tableView reloadData];
    
    //各个品类
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 50, [Theme screenWidth], 150) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self addSubview:self.tableView];
    [self.tableView registerClass:[ClassTypeSelectCell class] forCellReuseIdentifier:@"ClassTypeSelectCell"];
}

//品类选择点击
- (void)btnClicked:(UIButton *)btn {
    if (btn.tag == self.classType) {
        return;
    }
    self.classType = btn.tag;
    for (UIButton *tempBtn in self.headViewBtnArray) {
        [tempBtn setTitleColor:[UIColor colorWithHex:0x9399a5] forState:UIControlStateNormal];
    }
    
    if (self.headViewBtnArray.count > self.classType) {
        UIButton *selectedBtn = [self.headViewBtnArray objectAtIndex:self.classType];
        [selectedBtn setTitleColor:[UIColor themeColor] forState:UIControlStateNormal];
    }
    [self.tableView reloadData];
}

- (void)setDataSource:(NSArray<ClassItemModel *> *)dataSource {
    _dataSource = dataSource;
    [self initUI];
}

+ (ChoseItemView *)showChoseItemViewWithFatherView:(UIView *)fatherView dataSource:(NSArray<ClassItemModel *> *)dataSource {
    ChoseItemView *choseItemView = [[ChoseItemView alloc]initWithFrame:CGRectMake(0, [Theme screenHeight]-itemViewHeight, [Theme screenWidth], itemViewHeight)];
    choseItemView.dataSource = dataSource;
    [fatherView addSubview:choseItemView];
    [fatherView bringSubviewToFront:choseItemView];
    return choseItemView;
}

//使当前view消失
- (void)dismissSelfAndReturnResult {
    [self removeFromSuperview];
}

#pragma mark - tabelviewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ClassTypeSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ClassTypeSelectCell" forIndexPath:indexPath];
    ClassItemModel *classItemModel = self.dataSource[self.classType];
    GoodsItemModel *goodItemModel = (GoodsItemModel *)(classItemModel.classList[indexPath.row]);
    [cell setModel:goodItemModel];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource[self.classType].classList.count;
}

@end
