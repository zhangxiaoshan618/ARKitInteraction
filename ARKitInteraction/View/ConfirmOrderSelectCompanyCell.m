//
//  ConfirmOrderSelectCompanyCell.m
//  ARKitInteraction
//
//  Created by Yi Li on 2018/9/15.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import "ConfirmOrderSelectCompanyCell.h"
#import "Masonry.h"
#import "UIColor+Category.h"
#import "ConfirmOrderModel.h"

@interface ConfirmOrderSelectCompanyCell()
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *priceLabel;

@end

@implementation ConfirmOrderSelectCompanyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    //公司名称
    _nameLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    [self addSubview:_nameLabel];
    _nameLabel.textColor = [UIColor colorWithHex:0x9399a5];
    _nameLabel.font = [UIFont systemFontOfSize:16.0];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(@20);
    }];
    
    //价格label
    _priceLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    _priceLabel.textColor = [UIColor colorWithHex:0x9399a5];
    _priceLabel.font = [UIFont systemFontOfSize:16.0];
    [self addSubview:_priceLabel];
    [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-30);
        make.top.equalTo(@20);
    }];
}

- (void)setCompanyModel:(CompanyInfoModel *)companyModel {
    _nameLabel.text = companyModel.companyName;
    _priceLabel.text = companyModel.finalPrice;
}


@end
