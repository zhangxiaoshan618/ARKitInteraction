//
//  BigPicture.h
//  PictureShow
//
//  Created by 张晓珊 on 2018/6/4.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BigPicture : UIView
- (instancetype)initWithImageView: (UIImageView *)imageVie;
- (void)showPicture;
- (void)hidePicture;

@end
