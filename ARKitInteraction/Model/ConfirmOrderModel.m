//
//  ConfirmOrderModel.m
//  ARKitInteraction
//
//  Created by Yi Li on 2018/9/15.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import "ConfirmOrderModel.h"

@implementation ConfirmOrderModel
@class ItemInfoModel;

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"itemInfoArray" :@"info_list",
             @"orderId" :@"order_id",
             @"totalSum" :@"total_sum",
             @"companyArray" :@"company_info"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{@"itemInfoArray" : ItemInfoModel.class,
             @"companyArray": CompanyInfoModel.class
             };
}

@end


@implementation ItemInfoModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"companyName":@"company_name",
             @"goodUrl":@"good_url",
             @"companyId":@"company_id",
             @"priceId":@"price_id",
             @"goodPrice":@"good_price",
             @"goodSize":@"good_size",
             @"goodName":@"good_name",
             @"goodId":@"good_id",
             };
}
@end

@implementation CompanyInfoModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"companyName":@"company_name",
             @"companyPrice":@"company_price",
             @"finalPrice":@"final_price",
             @"companyId":@"company_id",
             };
}
@end
