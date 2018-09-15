//
//  UIColor+Category.h
//  ARKitInteraction
//
//  Created by Yi Li on 2018/9/14.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Category)

+ (UIColor *)colorWithARGBHex:(uint32_t)hex;
+ (UIColor *)colorWithHex:(uint32_t)hex;
+ (UIColor *)themeColor;

@end
