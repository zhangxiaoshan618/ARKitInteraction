//
//  TotalPriceCell.m
//  ARKitInteraction
//
//  Created by Yi Li on 2018/9/15.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import "TotalPriceCell.h"
#import "Masonry.h"
#import "UIColor+Category.h"
#import "ConfirmOrderModel.h"

@interface TotalPriceCell()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *priceLabel;

@end

@implementation TotalPriceCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initUI];
    }
    return self;
}

- (void)initUI {
    //价格label
    _priceLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    _priceLabel.textColor = [UIColor colorWithHex:0x9399a5];
    _priceLabel.font = [UIFont systemFontOfSize:20.0];
    [self addSubview:_priceLabel];
    [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-30);
        make.top.equalTo(@20);
    }];
    //公司名称
    _titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    [self addSubview:_titleLabel];
    _titleLabel.textColor = [UIColor redColor];
    _titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.priceLabel.mas_left).offset(-20);
        make.top.equalTo(@20);
    }];
    
    
}

- (void)setTitleText:(NSString *)titleText priceText:(NSString *)priceText {
    _titleLabel.text = titleText;
    _priceLabel.text = priceText;
}

@end
