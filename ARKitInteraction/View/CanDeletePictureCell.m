//
//  CanDeletePictureCell.m
//  ARKitInteraction
//
//  Created by Yi Li on 2018/9/15.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import "CanDeletePictureCell.h"
#import "Masonry.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "BigPicture.h"

@interface CanDeletePictureCell()
@property (nonatomic, strong) UIImageView *mainImage;
@property (nonatomic, strong) UIImageView *deleteImage;
@property (nonatomic, strong) UIControl *deleteControl;

@end

@implementation CanDeletePictureCell

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
    _mainImage.userInteractionEnabled = YES;
    [_mainImage addGestureRecognizer:[self tap]];
    [self addSubview:_mainImage];
    [_mainImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(@0);
        make.width.equalTo(@80);
        make.height.equalTo(@80);
    }];
    
    //删除图标
    _deleteImage = [[UIImageView alloc]initWithFrame:CGRectZero];
    _deleteImage.image = [UIImage imageNamed:@"close"];
    [self addSubview:_deleteImage];
    [_deleteImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-20);
        make.top.equalTo(@0);
        make.height.width.equalTo(@23);
    }];
    
    //删除按钮
    _deleteControl = [[UIControl alloc]initWithFrame:CGRectZero];
    [_deleteControl addTarget:self action:@selector(clickDeleteButton) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_deleteControl];
    [_deleteControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.deleteImage).offset(-3);
        make.bottom.right.equalTo(self.deleteImage).offset(3);
    }];
}

- (void)setPicImage:(UIImage *)picImage {
    _mainImage.image = picImage;
}

- (void)clickDeleteButton {
    if ([self.delegate respondsToSelector:@selector(didDeletePictureCell:)]) {
        [self.delegate didDeletePictureCell:self.index];
    }
}

- (void)canDelete:(BOOL)canDelete {
    _deleteImage.hidden = !canDelete;
    _deleteControl.hidden = !canDelete;
}

- (void)setImageUrl:(NSString *)imageUrl {
    [_mainImage sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"goodImage"]];
}

- (UITapGestureRecognizer *) tap {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapActionWith:)];
    return tap;
}

- (void)tapActionWith: (UITapGestureRecognizer *)sinder {
    UIView *view = sinder.view;
    if ([view isKindOfClass:UIImageView.class]) {
        BigPicture *picture = [[BigPicture alloc] initWithImageView: (UIImageView *)view];
        [picture showPicture];
    }
}

@end
