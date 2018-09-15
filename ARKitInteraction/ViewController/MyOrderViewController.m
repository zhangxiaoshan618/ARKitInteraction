//
//  MyOrderViewController.m
//  ARKitInteraction
//
//  Created by Yi Li on 2018/9/15.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import "MyOrderViewController.h"
#import "GoodsIntroCell.h"
#import "Masonry.h"
#import "UIColor+Category.h"
#import "LJNetworkService.h"
#import "YYModel.h"
#import "ConfirmOrderModel.h"
#import "SelectPictureCell.h"
#import "SelectCompanyController.h"
#import "TotalPriceCell.h"
#import <AFNetworking/AFNetworking.h>
#import "MyOrderModel.h"
#import "ConfirmOrderSelectCompanyCell.h"

@interface MyOrderViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) NSInteger picSection;
@property (nonatomic, assign) NSInteger goodsSection;
@property (nonatomic, assign) NSInteger priceSection;
@property (nonatomic, assign) NSInteger companySection;
@property (nonatomic, strong) MyOrderModel *myOrderModel;
@property (nonatomic, strong) UILabel *errorLabel;

@end

@implementation MyOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self registCell];
    [self loadData];
    // Do any additional setup after loading the view.
}

- (void)initUI {
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.title = @"我的订单";
    [self.view addSubview:self.tableView];
    
    self.errorLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    [self.view addSubview:self.errorLabel];
    self.errorLabel.text = @"暂无数据";
    self.errorLabel.textColor = [UIColor colorWithHex:0x9399a5];
    self.errorLabel.font = [UIFont systemFontOfSize:20.0];
    [self.errorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.centerX.equalTo(@0);
    }];
}

- (void)loadData {
    NSString *orderId = [[NSUserDefaults standardUserDefaults]objectForKey:@"orderId"];
    [[LJNetworkService defaultService] getWithUrl:@"http://10.26.9.140:8020/home/orderdetail" parameters:@{@"order_id":orderId} modelClass:nil completion:^(id data, NSError *error) {
        if (!error) {
            if ([data isKindOfClass:NSDictionary.class]) {
                _myOrderModel = [MyOrderModel yy_modelWithDictionary:data[@"data"]];
                [self.tableView reloadData];
                self.errorLabel.hidden = YES;
            }
        }
    }];
}


- (void)registCell {
    [self.tableView registerClass:[GoodsIntroCell class] forCellReuseIdentifier:@"GoodsIntroCell"];
    [self.tableView registerClass:[SelectPictureCell class] forCellReuseIdentifier:@"SelectPictureCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    [self.tableView registerClass:[TotalPriceCell class] forCellReuseIdentifier:@"TotalPriceCell"];
    [self.tableView registerClass:[ConfirmOrderSelectCompanyCell class] forCellReuseIdentifier:@"ConfirmOrderSelectCompanyCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sectionCount = 0;
    if (self.myOrderModel.fileList.count) {
        self.picSection = sectionCount++;
    }
    if (self.myOrderModel.itemInfoArray) {
        self.goodsSection = sectionCount++;
    }
    if (self.myOrderModel.companyInfo) {
        self.companySection = sectionCount++;
    }
    if (self.myOrderModel.totalSum) {
        self.priceSection = sectionCount++;
    }
    return sectionCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == self.picSection) {
        SelectPictureCell *picCell = [tableView dequeueReusableCellWithIdentifier:@"SelectPictureCell" forIndexPath:indexPath];
        picCell.imageUrlArray = self.myOrderModel.fileList;
        picCell.delegate = self;
        return picCell;
    } else if (indexPath.section == self.goodsSection) {
        GoodsIntroCell *goodIntroCell = [tableView dequeueReusableCellWithIdentifier:@"GoodsIntroCell" forIndexPath:indexPath];
        goodIntroCell.itemInfoModel = self.myOrderModel.itemInfoArray[indexPath.row];
        return goodIntroCell;
    } else if (indexPath.section == self.companySection) {
        if (indexPath.row == 0) {
            ConfirmOrderSelectCompanyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConfirmOrderSelectCompanyCell" forIndexPath:indexPath];
            [cell setCompanyModel:self.myOrderModel.companyInfo];
            return cell;
        } else if (indexPath.row == 1){
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"上门时间";
            return cell;
        } else if (indexPath.row == 2) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"备注";
            return cell;
        } else {
            return [[UITableViewCell alloc]init];
        }
    } else if (indexPath.section == self.priceSection) {
        TotalPriceCell *totalPriceCell = [tableView dequeueReusableCellWithIdentifier:@"TotalPriceCell" forIndexPath:indexPath];
        if (indexPath.row == 0) {
            [totalPriceCell setTitleText:@"物品总价" priceText:[NSString stringWithFormat:@"￥%@",self.myOrderModel.totalSum]];
        } else if (indexPath.row == 1){
            [totalPriceCell setTitleText:@"服务费" priceText:[NSString stringWithFormat:@"￥%@",self.myOrderModel.companyInfo.companyPrice]];
        } else if (indexPath.row == 2) {
            [totalPriceCell setTitleText:@"总计" priceText:[NSString stringWithFormat:@"￥%@",self.myOrderModel.companyInfo.finalPrice]];
        }
        return totalPriceCell;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == self.picSection) {
        return 100;
    } else if (indexPath.section == self.goodsSection){
        return 120;
    } else if (indexPath.section == self.companySection){
        return 50;
    } else if (indexPath.section == self.priceSection){
        return 60;
    } else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == self.picSection) {
        return 1;
    } else if (section == self.goodsSection){
        return self.self.myOrderModel.itemInfoArray.count;
    } else if (section == self.companySection) {
        return 3;
    } else if (section == self.priceSection) {
        return 3;
    } else {
        return 0;
    }
}


@end
