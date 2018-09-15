//
//  UIColor+Category.m
//  ARKitInteraction
//
//  Created by Yi Li on 2018/9/14.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import "UIColor+Category.h"

@implementation UIColor (Category)

+ (UIColor *)colorWithARGBHex:(uint32_t)hex {
    int red, green, blue, alpha;
    
    blue = hex & 0x000000FF;
    green = ((hex & 0x0000FF00) >> 8);
    red = ((hex & 0x00FF0000) >> 16);
    alpha = ((hex & 0xFF000000) >> 24);
    
    return [UIColor colorWithRed:red / 255.0f green:green / 255.0f blue:blue / 255.0f alpha:alpha / 255.f];
}

+ (UIColor *)colorWithHex:(uint32_t)hex {
    if (hex <= 0xffffff) {
        hex = 0xff000000 | hex;
    }
    return [UIColor colorWithARGBHex:hex];
}

+ (UIColor *)themeColor {
    return [UIColor colorWithHex:0x3072f6];
}

@end
