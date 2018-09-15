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
#import "LJNetworkService.h"
#import "YYModel.h"
#import "ConfirmOrderModel.h"
#import "SelectPictureCell.h"
#import "SelectCompanyController.h"
#import "TotalPriceCell.h"
#import <AFNetworking/AFNetworking.h>
#import "MyOrderViewController.h"
#import "Theme.h"

typedef NS_ENUM(NSInteger, ConfirmOrderType) {
    ConfirmOrderTypeCommit,
    ConfirmOrderTypePayment,
    ConfirmOrderTypeFinished,
};

@interface ConfirmOrderViewController ()<UITableViewDelegate,UITableViewDataSource,SelectPictureCellDelegate,SelectCompanyControllerDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) NSInteger picSection;
@property (nonatomic, assign) NSInteger goodsSection;
@property (nonatomic, assign) NSInteger priceSection;
@property (nonatomic, assign) NSInteger companySection;
@property (nonatomic, strong) CompanyInfoModel *selectCompanyModel;
@property (nonatomic, strong) UIButton *commitButton;
@property (nonatomic, assign) NSInteger requestCount;
@property (nonatomic, assign) NSInteger currentFinishPicCount;
@property (nonatomic, assign) NSInteger currentFinishAllCount;
@property (nonatomic, assign) ConfirmOrderType currentConfirmType;
@end

@implementation ConfirmOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self registCell];
    self.currentConfirmType = ConfirmOrderTypeCommit;
    // Do any additional setup after loading the view.
}

- (void)initUI {
    self.title = @"确认装配订单";
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0,[Theme screenWidth] ,[Theme screenHeight]-70) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    //提交订单按钮
    _commitButton = [[UIButton alloc]initWithFrame:CGRectZero];
    [self.view addSubview:_commitButton];
    _commitButton.titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
    [_commitButton setTitle:@"提交订单" forState:UIControlStateNormal];
    [_commitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _commitButton.backgroundColor = [UIColor themeColor];
    _commitButton.layer.cornerRadius = 5.0;
    [_commitButton addTarget:self action:@selector(commitOrder) forControlEvents:UIControlEventTouchUpInside];
    [_commitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@20);
        make.bottom.equalTo(@-20);
        make.right.equalTo(@-20);
        make.height.equalTo(@50);
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    if ([self.delegate respondsToSelector:@selector(finishDelePic:)]) {
        [self.delegate finishDelePic:self.picArray];
    }
}

- (void)commitOrder {
    switch (self.currentConfirmType) {
        case ConfirmOrderTypeCommit:
            self.currentFinishPicCount = 0;
            self.currentFinishAllCount = 0;
            self.requestCount = 1+self.picArray.count;
            if (self.selectCompanyModel) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                [dic setValue:self.confirmModel.orderId forKey:@"order_id"];
                [dic setValue:self.selectCompanyModel.companyId forKey:@"choose_company"];
                [dic setValue:self.confirmModel.totalSum forKey:@"total_sum"];
                [dic setValue:self.selectCompanyModel.companyPrice forKey:@"company_price"];
                [dic setValue:self.selectCompanyModel.finalPrice forKey:@"final_price"];
                [[LJNetworkService defaultService] postWithUrl:@"http://10.26.9.140:8020/home/ordersubmit" parameters:dic modelClass:nil completion:^(id data, NSError *error) {
                    self.currentFinishAllCount++;
                    if (!error) {
                        
                    }
                    [self finishCommitWithCount:self.currentFinishAllCount];
                }];
                [self commitAllPic];
                
            }
            break;
        case ConfirmOrderTypePayment:
            [_commitButton setTitle:@"查看订单" forState:UIControlStateNormal];
            self.currentConfirmType = ConfirmOrderTypeFinished;
            break;
        case ConfirmOrderTypeFinished: {
            MyOrderViewController *myOrderViewController = [[MyOrderViewController alloc]init];
            [self.navigationController pushViewController:myOrderViewController animated:YES];
            break;
        }
        default:
            break;
    }
    
}

- (void)commitAllPic {
    UIImage *image = self.picArray[self.currentFinishPicCount];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.9);
    NSString *url = @"http://10.26.9.140:8020/home/pictureupload";
    NSString *fileDataName = @"pic";
    [[LJNetworkService defaultService] postWithUrl:url parameters:@{@"order_id":self.confirmModel.orderId} modelClass:nil constructingBody:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:fileDataName fileName:[NSString stringWithFormat:@"%ld.png",self.currentFinishPicCount] mimeType:@"image/jpeg"];
    } progress:^(NSProgress *progress) {
        
    } completion:^(id data, NSError *error) {
        self.currentFinishPicCount++;
        self.currentFinishAllCount++;
        if (self.currentFinishPicCount<self.picArray.count) {
            [self commitAllPic];
        }
        [self finishCommitWithCount:self.currentFinishAllCount];
    }];
}

- (void)finishCommitWithCount:(NSInteger)count {
    if (self.requestCount <= count) {
        [_commitButton setTitle:@"确认支付" forState:UIControlStateNormal];
        self.currentConfirmType = ConfirmOrderTypePayment;
        [[NSUserDefaults standardUserDefaults] setObject:self.confirmModel.orderId forKey:@"orderId"];
    }
}

- (void)registCell {
    [self.tableView registerClass:[GoodsIntroCell class] forCellReuseIdentifier:@"GoodsIntroCell"];
    [self.tableView registerClass:[SelectPictureCell class] forCellReuseIdentifier:@"SelectPictureCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    [self.tableView registerClass:[TotalPriceCell class] forCellReuseIdentifier:@"TotalPriceCell"];
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
    if (self.selectCompanyModel) {
        self.priceSection = sectionCount++;
    }
    return sectionCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == self.picSection) {
        SelectPictureCell *picCell = [tableView dequeueReusableCellWithIdentifier:@"SelectPictureCell" forIndexPath:indexPath];
        picCell.imageArray = self.picArray;
        picCell.delegate = self;
        return picCell;
    } else if (indexPath.section == self.goodsSection) {
        GoodsIntroCell *goodIntroCell = [tableView dequeueReusableCellWithIdentifier:@"GoodsIntroCell" forIndexPath:indexPath];
        goodIntroCell.itemInfoModel = self.confirmModel.itemInfoArray[indexPath.row];
        return goodIntroCell;
    } else if (indexPath.section == self.companySection) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.row == 0) {
            cell.textLabel.text = @"装配公司";
        } else if (indexPath.row == 1){
            cell.textLabel.text = @"上门时间";
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"备注";
        }
        return cell;
    } else if (indexPath.section == self.priceSection) {
        TotalPriceCell *totalPriceCell = [tableView dequeueReusableCellWithIdentifier:@"TotalPriceCell" forIndexPath:indexPath];
        if (indexPath.row == 0) {
            [totalPriceCell setTitleText:@"物品总价" priceText:[NSString stringWithFormat:@"￥%@",self.confirmModel.totalSum]];
        } else if (indexPath.row == 1){
            [totalPriceCell setTitleText:@"服务费" priceText:[NSString stringWithFormat:@"￥%@",self.selectCompanyModel.companyPrice]];
        } else if (indexPath.row == 2) {
            [totalPriceCell setTitleText:@"总计" priceText:[NSString stringWithFormat:@"￥%@",self.selectCompanyModel.finalPrice]];
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
        return self.confirmModel.itemInfoArray.count;
    } else if (section == self.companySection) {
        return 3;
    } else if (section == self.priceSection) {
        return 3;
    } else {
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == self.companySection) {
        if (indexPath.row == 0) {
            SelectCompanyController *selectCompanyVC = [[SelectCompanyController alloc]init];
            selectCompanyVC.delegate = self;
            selectCompanyVC.companyArray = self.confirmModel.companyArray;
            [self.navigationController pushViewController:selectCompanyVC animated:YES];
        }
    }
}

- (void)finishDelePic:(NSArray<UIImage *>*)imageArray {
    self.picArray = imageArray;
}

- (void)didSelectCompany:(CompanyInfoModel *)companyModel {
    self.selectCompanyModel = companyModel;
    [self.tableView reloadData];
}

@end
