//
//  ItemSelectCollectionViewCell.m
//  ARKitInteraction
//
//  Created by Yi Li on 2018/9/15.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import "ItemSelectCollectionViewCell.h"
#import "Masonry.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ItemSelectCollectionViewCell()
@property (nonatomic, strong) UIImageView *mainImage;
@property (nonatomic, strong) UIImageView *selectImage;
@property (nonatomic, strong) UIControl *deleteControl;

@end

@implementation ItemSelectCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    //头图
    _mainImage = [[UIImageView alloc]initWithFrame:CGRectZero];
    [self addSubview:_mainImage];
    [_mainImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(@20);
        make.top.top.equalTo(@0);
        make.width.equalTo(@50);
        make.height.equalTo(@50);
    }];
    
    //选择图标
    _selectImage = [[UIImageView alloc]initWithFrame:CGRectZero];
    _selectImage.image = [UIImage imageNamed:@"AssetsPickerChecked"];
    [self addSubview:_selectImage];
    [_selectImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-10);
        make.top.equalTo(@0);
        make.width.height.equalTo(@15);
    }];
}

- (void)setGoodInfoModel:(GoodsInfoModel *)goodInfoModel {
    NSURL *url = [NSURL URLWithString:goodInfoModel.goodImage];
    [_mainImage sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"goodImage"]];
    _selectImage.hidden = !goodInfoModel.isSelect;
}

@end
