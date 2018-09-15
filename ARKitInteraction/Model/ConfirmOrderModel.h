//
//  ConfirmOrderModel.h
//  ARKitInteraction
//
//  Created by Yi Li on 2018/9/15.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class CompanyInfoModel;
@class ItemInfoModel;

@interface ConfirmOrderModel : NSObject

@property (nonatomic, copy) NSArray <ItemInfoModel *> *itemInfoArray;
@property (nonatomic, copy) NSString *orderId;
@property (nonatomic, assign) CGFloat totalSum;
@property (nonatomic, copy) NSArray <CompanyInfoModel *> *companyArray;

@end


@interface ItemInfoModel : NSObject
@property (nonatomic, copy) NSString *companyName;
@property (nonatomic, copy) NSString *goodUrl;
@property (nonatomic, copy) NSString *companyId;
@property (nonatomic, copy) NSString *priceId;
@property (nonatomic, copy) NSString *goodSize;
@property (nonatomic, copy) NSString *goodName;
@property (nonatomic, copy) NSString *goodId;
@property (nonatomic, copy) NSString *goodPrice;
@end

@interface CompanyInfoModel : NSObject
@property (nonatomic, copy) NSString *companyName;
@property (nonatomic, copy) NSString *companyPrice;
@property (nonatomic, copy) NSString *finalPrice;
@property (nonatomic, copy) NSString *companyId;

@end
