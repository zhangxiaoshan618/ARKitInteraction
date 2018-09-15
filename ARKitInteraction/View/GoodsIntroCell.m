//
//  GoodsIntroCell.m
//  ARKitInteraction
//
//  Created by Yi Li on 2018/9/14.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import "GoodsIntroCell.h"
#import "Masonry.h"
#import "UIColor+Category.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface GoodsIntroCell()
@property (nonatomic, strong) UIImageView *headerImage;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UILabel *sizeLabel;
@property (nonatomic, strong) UILabel *supplierLabel;
@end


@implementation GoodsIntroCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initUI];
    }
    return self;
}

- (void) initUI {
    //头图
    _headerImage = [[UIImageView alloc]initWithFrame:CGRectZero];
    [self addSubview:_headerImage];
    [_headerImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(@20);
        make.width.equalTo(@100);
        make.height.equalTo(@80);
    }];
    
    //品类
    _titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    [self addSubview:_titleLabel];
    _titleLabel.textColor = [UIColor colorWithHex:0x9399a5];
    _titleLabel.text = @"台灯";
    _titleLabel.font = [UIFont systemFontOfSize:13.0];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerImage.mas_right).offset(20);
        make.top.equalTo(self.headerImage.mas_top);
    }];
    
    //价格
    _priceLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    [self addSubview:_priceLabel];
    _priceLabel.textColor = [UIColor redColor];
    _priceLabel.text = @"￥49.9";
    _priceLabel.font = [UIFont systemFontOfSize:13.0];
    [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerImage.mas_right).offset(20);
        make.bottom.equalTo(self.headerImage.mas_bottom);
    }];
    
    //品类
    _sizeLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    [self addSubview:_sizeLabel];
    _sizeLabel.textColor = [UIColor blackColor];
    _sizeLabel.font = [UIFont systemFontOfSize:13.0];
    [_sizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.priceLabel.mas_right).offset(20);
        make.bottom.equalTo(self.headerImage.mas_bottom);
    }];
    
    //供应商
    _supplierLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    [self addSubview:_supplierLabel];
    _supplierLabel.textColor = [UIColor blackColor];
    _supplierLabel.text = @"供应商A";
    _supplierLabel.font = [UIFont systemFontOfSize:13.0];
    [_supplierLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-20);
        make.bottom.equalTo(self.headerImage.mas_bottom);
    }];
}

- (void)setItemInfoModel:(ItemInfoModel *)itemInfoModel {
    [_headerImage sd_setImageWithURL:itemInfoModel.goodUrl placeholderImage:[UIImage imageNamed:@"goodImage"]];
    _titleLabel.text = itemInfoModel.goodName;
    _supplierLabel.text = itemInfoModel.companyName;
    _priceLabel.text = [NSString stringWithFormat:@"￥%@",itemInfoModel.goodPrice];
    _sizeLabel.text = itemInfoModel.goodSize;
}

@end
