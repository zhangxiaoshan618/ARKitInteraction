//
//  PaymentOrderViewController.m
//  ARKitInteraction
//
//  Created by Yi Li on 2018/9/15.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import "PaymentOrderViewController.h"
#import "GoodsIntroCell.h"
#import "Masonry.h"
#import "UIColor+Category.h"
#import "ChoseItemView.h"

@interface PaymentOrderViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation PaymentOrderViewController

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        GoodsIntroCell *goodIntroCell = [tableView dequeueReusableCellWithIdentifier:@"GoodsIntroCell" forIndexPath:indexPath];
        return goodIntroCell;
    } else if (indexPath.section == 1){
        GoodsIntroCell *goodIntroCell = [tableView dequeueReusableCellWithIdentifier:@"GoodsIntroCell" forIndexPath:indexPath];
        return goodIntroCell;
    } else {
        GoodsIntroCell *goodIntroCell = [tableView dequeueReusableCellWithIdentifier:@"GoodsIntroCell" forIndexPath:indexPath];
        return goodIntroCell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


@end
