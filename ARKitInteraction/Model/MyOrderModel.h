//
//  MyOrderModel.h
//  ARKitInteraction
//
//  Created by Yi Li on 2018/9/15.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConfirmOrderModel.h"
#import "ClassItemArrayModel.h"
@class GoodsInfoModel;
@class GoodsItemModel;
@class ClassItemModel;

@interface MyOrderModel : NSObject
@property (nonatomic, copy) NSString *orderId;
@property (nonatomic, strong) CompanyInfoModel *companyInfo;
@property (nonatomic, copy) NSArray <NSString *> *fileList;
@property (nonatomic, copy) NSArray <ItemInfoModel *> *itemInfoArray;
@property (nonatomic, copy) NSString *totalSum;
@end

