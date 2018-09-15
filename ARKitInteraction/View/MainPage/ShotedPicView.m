//
//  ShotedPicView.m
//  ARKitInteraction
//
//  Created by Yi Li on 2018/9/15.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import "ShotedPicView.h"
#import "Masonry.h"
#import "UIColor+Category.h"
#import "Theme.h"
#import "UIColor+Category.h"

static const CGFloat itemViewHeight = 200;

@interface ShotedPicView()
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *nextButton;

@end

@implementation ShotedPicView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    //左侧的清单按钮
    self.backgroundColor = [UIColor whiteColor];
    _backButton = [self creatButtonWithText:@"返回" imageName:@"back" action:@selector(clickBackButton)];
    [self addSubview:_backButton];
    [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@30);
        make.centerY.equalTo(@0);
        make.width.height.equalTo(@80);
    }];
    
    _saveButton = [[UIButton alloc]initWithFrame:CGRectZero];
    _saveButton.layer.cornerRadius = 50;
    [_saveButton setImage:[UIImage imageNamed:@"save"] forState:UIControlStateNormal];
    _saveButton.backgroundColor = [UIColor colorWithHex:0xf5f5f5];
    [_saveButton addTarget:self action:@selector(clickSaveButton) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_saveButton];
    [_saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(@0);
        make.width.height.equalTo(@100);
        make.centerY.equalTo(@0);
    }];
    
    //右侧的我的按钮
    _nextButton = [self creatButtonWithText:@"下一步" imageName:@"next" action:@selector(clickNextButton)];
    [self addSubview:_nextButton];
    [_nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-30);
        make.centerY.equalTo(@0);
        make.width.height.equalTo(@80);
    }];
    
}

- (void)clickBackButton {
    if ([self.delegate respondsToSelector:@selector(clickBackButton)]) {
        [self.delegate clickBackButton];
    }
}
- (void)clickSaveButton {
    if ([self.delegate respondsToSelector:@selector(clickSaveButton)]) {
        [self.delegate clickSaveButton];
    }
}

- (void)clickNextButton {
    if ([self.delegate respondsToSelector:@selector(clickNextButton)]) {
        [self.delegate clickNextButton];
    }
}

+ (ShotedPicView *)showInFatherView:(UIView *)fatherView {
    ShotedPicView *view = [[ShotedPicView alloc]initWithFrame:CGRectMake(0, [Theme screenHeight]-itemViewHeight, [Theme screenWidth], itemViewHeight)];
    [fatherView addSubview:view];
    [fatherView bringSubviewToFront:view];
    return view;
}

- (UIButton *)creatButtonWithText:(NSString *)buttonText imageName:(NSString *)imageName action:(SEL)action {
    UIButton *button = [[UIButton alloc]init];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    imageView.image = [UIImage imageNamed:imageName];
    [button addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.centerX.equalTo(@0);
        make.width.height.equalTo(@35);
    }];
    
    UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    textLabel.text = buttonText;
    textLabel.textColor = [UIColor colorWithHex:0x9399a5];
    textLabel.font = [UIFont systemFontOfSize:13.0];
    [button addSubview:textLabel];
    [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageView.mas_bottom).offset(10);
        make.centerX.equalTo(@0);
    }];
    return button;
}

@end
