//
//  SelectCompanyController.m
//  ARKitInteraction
//
//  Created by Yi Li on 2018/9/15.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import "SelectCompanyController.h"
#import "ConfirmOrderModel.h"
#import "ConfirmOrderSelectCompanyCell.h"

@interface SelectCompanyController ()
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation SelectCompanyController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)initUI {
    self.title = @"选择装修公司";
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[ConfirmOrderSelectCompanyCell class] forCellReuseIdentifier:@"ConfirmOrderSelectCompanyCell"];
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ConfirmOrderSelectCompanyCell *companyCell = [tableView dequeueReusableCellWithIdentifier:@"ConfirmOrderSelectCompanyCell" forIndexPath:indexPath];
    companyCell.companyModel = self.companyArray[indexPath.row];
    return companyCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.companyArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.navigationController popViewControllerAnimated:YES];
    if ([self.delegate respondsToSelector:@selector(didSelectCompany:)]) {
        [self.delegate didSelectCompany:self.companyArray[indexPath.row]];
    }
}


@end
