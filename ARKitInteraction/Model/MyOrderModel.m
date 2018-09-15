//
//  MyOrderModel.m
//  ARKitInteraction
//
//  Created by Yi Li on 2018/9/15.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import "MyOrderModel.h"

@implementation MyOrderModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"orderId":@"order_id",
              @"companyInfo":@"company_info",
              @"fileList":@"file_list",
              @"itemInfoArray":@"info_list",
              @"totalSum":@"total_sum",
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{@"fileList" : NSString.class,
             @"itemInfoArray" : ItemInfoModel.class
             };
}

@end
