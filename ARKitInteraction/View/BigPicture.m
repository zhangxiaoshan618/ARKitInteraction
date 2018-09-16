//
//  BigPicture.m
//  PictureShow
//
//  Created by 张晓珊 on 2018/6/4.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import "BigPicture.h"

@interface BigPicture ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) CGRect originalFrame;

@end

@implementation BigPicture

- (instancetype)initWithImageView: (UIImageView *)imageView {
    self = [super init];
    if (self) {
        self.frame = [[UIApplication sharedApplication] keyWindow].frame;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
        self.originalFrame = [imageView.superview convertRect:imageView.frame toView:nil];
        self.imageView.frame = self.originalFrame;
        [self addSubview:self.imageView];
        self.imageView.image = imageView.image;
    }
    return self;
}

- (void)showPicture {
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1.0];
        self.imageView.frame = self.frame;
    }];
}

- (void)hidePicture {
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
        self.imageView.frame = self.originalFrame;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.userInteractionEnabled = true;
        [_imageView addGestureRecognizer:[self tap]];
    }
    return _imageView;
}

- (UITapGestureRecognizer *) tap {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapActionWith:)];
    return tap;
}

- (void)tapActionWith: (UIImageView *)sinder {
    [self hidePicture];
}

@end
