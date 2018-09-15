//
//  ConfirmOrderViewController.m
//  ARKitInteraction
//
//  Created by Yi Li on 2018/9/14.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import "ConfirmOrderViewController.h"
#import "GoodsIntroCell.h"
#import "Masonry.h"
#import "UIColor+Category.h"
#import "ChoseItemView.h"
#import "LJNetworkService.h"
#import "YYModel.h"
#import "ConfirmOrderModel.h"
#import "SelectPictureCell.h"

@interface ConfirmOrderViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) NSInteger picSection;
@property (nonatomic, assign) NSInteger goodsSection;
@property (nonatomic, assign) NSInteger priceSection;
@property (nonatomic, assign) NSInteger companySection;
@end

@implementation ConfirmOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self registCell];
    // Do any additional setup after loading the view.
}

- (void)initUI {
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    //提交订单按钮
    UIButton *commitButton = [[UIButton alloc]initWithFrame:CGRectZero];
    [self.view addSubview:commitButton];
    commitButton.titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
    [commitButton setTitle:@"提交订单" forState:UIControlStateNormal];
    [commitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    commitButton.backgroundColor = [UIColor themeColor];
    commitButton.layer.cornerRadius = 5.0;
    [commitButton addTarget:self action:@selector(commitOrder) forControlEvents:UIControlEventTouchUpInside];
    [commitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@20);
        make.bottom.equalTo(@-20);
        make.right.equalTo(@-20);
        make.height.equalTo(@50);
    }];
}

- (void)commitOrder {
    
}

- (void)commitPicture {
    
}

- (void)registCell {
    [self.tableView registerClass:[GoodsIntroCell class] forCellReuseIdentifier:@"GoodsIntroCell"];
    [self.tableView registerClass:[SelectPictureCell class] forCellReuseIdentifier:@"SelectPictureCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sectionCount = 0;
    if (self.picArray.count) {
        self.picSection = sectionCount++;
    }
    if (self.confirmModel) {
        self.goodsSection = sectionCount++;
    }
    if (self.confirmModel.companyArray.count) {
        self.companySection = sectionCount++;
    }
    if (self.confirmModel.totalSum) {
        self.priceSection = sectionCount++;
    }
    return sectionCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == self.picSection) {
        SelectPictureCell *goodIntroCell = [tableView dequeueReusableCellWithIdentifier:@"SelectPictureCell" forIndexPath:indexPath];
        goodIntroCell.imageArray = self.picArray;
        return goodIntroCell;
    } else if (indexPath.section == self.goodsSection){
        GoodsIntroCell *goodIntroCell = [tableView dequeueReusableCellWithIdentifier:@"GoodsIntroCell" forIndexPath:indexPath];
        goodIntroCell.itemInfoModel = self.confirmModel.itemInfoArray[indexPath.row];
        return goodIntroCell;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 100;
    } else {
        return 120;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == self.picSection) {
        return 1;
    } else if (section == self.goodsSection){
        return self.confirmModel.itemInfoArray.count;
    } else {
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
