//
//  ClassItemArrayModel.h
//  ARKitInteraction
//
//  Created by Yi Li on 2018/9/14.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GoodsInfoModel;
@class GoodsItemModel;
@class ClassItemModel;

@interface ClassItemArrayModel : NSObject
@property (nonatomic, copy) NSArray <ClassItemModel *> *classArray;
@end

@interface ClassItemModel : NSObject
@property (nonatomic, copy) NSString *className;
@property (nonatomic, copy) NSArray <GoodsItemModel *> *classList;
@property (nonatomic, copy) NSString *classId;

@end

@interface GoodsItemModel : NSObject
@property (nonatomic, copy) NSString *goodUrl;
@property (nonatomic, copy) NSString *goodName;
@property (nonatomic, assign) NSInteger goodId;
@property (nonatomic, copy) NSArray<GoodsInfoModel *> *goodInfoArray;

@end

@interface GoodsInfoModel : NSObject
@property (nonatomic, copy) NSString *goodSize;
@property (nonatomic, copy) NSString *goodPrice;
@property (nonatomic, copy) NSString *goodSizeId;
@property (nonatomic, copy) NSString *goodImage;
@property (nonatomic, assign) BOOL isSelect;

@end
