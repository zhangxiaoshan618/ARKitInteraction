//
//  ClassItemArrayModel.m
//  ARKitInteraction
//
//  Created by Yi Li on 2018/9/14.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import "ClassItemArrayModel.h"

@implementation ClassItemArrayModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"classArray":@"data",
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{@"classArray" : ClassItemModel.class,
             };
}

@end

@implementation ClassItemModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"className":@"class_name",
             @"classList":@"class_list",
             @"classId":@"class_id",
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{@"classList" : GoodsItemModel.class,
             };
}

@end

@implementation GoodsItemModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
              @"goodUrl":@"good_url",
              @"goodName":@"good_name",
              @"goodId":@"good_id",
              @"goodInfoArray":@"good_info",

              };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{@"goodInfoArray" : GoodsInfoModel.class,
             };
}

@end

@implementation GoodsInfoModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"goodSize":@"good_size",
             @"goodPrice":@"good_price",
             @"goodSizeId":@"price_id",
             @"goodImage":@"good_url"
             };
}

@end
