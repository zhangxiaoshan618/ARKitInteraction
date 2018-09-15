//
//  ConfirmOrderViewController.h
//  ARKitInteraction
//
//  Created by Yi Li on 2018/9/14.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ConfirmOrderModel;
@class ClassItemModel;

@interface ConfirmOrderViewController : UIViewController

@property (nonatomic, strong) ConfirmOrderModel *confirmModel;
@property (nonatomic, copy) NSArray <UIImage *>*picArray;
@property (nonatomic, copy) NSArray<ClassItemModel *> *goodsAllDataSource;

@end
