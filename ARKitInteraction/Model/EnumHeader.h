//
//  EnumHeader.h
//  ARKitInteraction
//
//  Created by Yi Li on 2018/9/16.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, EGoogsType) {
    EGoogsTypeSofa = 1<<0,//沙发
    EGoogsTypeVase = 1<<1,//花瓶
    EGoogsTypeTeaCup = 1<<2,//茶杯
    EGoogsTypeTeaTable = 1<<3,//茶几
    EGoogsTypePhotoFrame = 1<<4,//相框
    EGoogsTypeSticker = 1<<5,//贴纸
    EGoogsTypeWardrobe = 1<<6,//衣柜
    EGoogsTypeCoffeePot = 1<<7,//咖啡壶
    EGoogsTypePan = 1<<8,//炒锅
    EGoogsDeskLamp = 1<<9,//台灯
    EGoogsFloorLamp = 1<<10,//落地灯
    EGoogspendantLamp = 1<<11,//吊灯
    EGoogsDragonHead = 1<<12,//龙头
    EGoogsClosesTool = 1<<13,//马桶
    EGoogsBathHeater = 1<<14//浴霸
    
};
