//
//  MainFunctionView.m
//  ARKitInteraction
//
//  Created by Yi Li on 2018/9/15.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import "MainFunctionView.h"
#import "Masonry.h"
#import "UIColor+Category.h"
#import "Theme.h"
#import "UIColor+Category.h"

static const CGFloat itemViewHeight = 200;

@interface MainFunctionView()
@property (nonatomic, strong) UIButton *itemListButton;
@property (nonatomic, strong) UIButton *screenShotButton;
@property (nonatomic, strong) UIButton *mainButton;

@end

@implementation MainFunctionView
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
    _itemListButton = [self creatButtonWithText:@"清单" imageName:@"list" action:@selector(listButtonClicked)];
    [self addSubview:_itemListButton];
    [_itemListButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@30);
        make.centerY.equalTo(@0);
        make.width.height.equalTo(@80);
    }];
    
    _screenShotButton = [[UIButton alloc]initWithFrame:CGRectZero];
    _screenShotButton.layer.cornerRadius = 50;
    _screenShotButton.backgroundColor = [UIColor colorWithHex:0x858585];
    [_screenShotButton addTarget:self action:@selector(shotButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_screenShotButton];
    [_screenShotButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(@0);
        make.width.height.equalTo(@100);
        make.centerY.equalTo(@0);
    }];
    
    //右侧的我的按钮
    _itemListButton = [self creatButtonWithText:@"我的" imageName:@"mine" action:@selector(mineButtonClicked)];
    [self addSubview:_itemListButton];
    [_itemListButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-30);
        make.centerY.equalTo(@0);
        make.width.height.equalTo(@80);
    }];
    
}

- (void)listButtonClicked {
    if ([self.delegate respondsToSelector:@selector(didClicedListButton)]) {
        [self.delegate didClicedListButton];
    }
}

- (void)mineButtonClicked {
    if ([self.delegate respondsToSelector:@selector(mineButtonClicked)]) {
        [self.delegate mineButtonClicked];
    }
}

- (void)shotButtonClicked {
    if ([self.delegate respondsToSelector:@selector(shotButtonClicked)]) {
        [self.delegate shotButtonClicked];
    }
}

+ (MainFunctionView *)showInFatherView:(UIView *)fatherView {
    MainFunctionView *view = [[MainFunctionView alloc]initWithFrame:CGRectMake(0, [Theme screenHeight]-itemViewHeight, [Theme screenWidth], itemViewHeight)];
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
