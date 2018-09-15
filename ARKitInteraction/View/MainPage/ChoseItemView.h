//
//  ChoseItemView.h
//  ARKitInteraction
//
//  Created by Yi Li on 2018/9/14.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EnumHeader.h"
@class GoodsItemModel;
@class ClassItemModel;

@protocol ChoseItemViewDelegate <NSObject>

- (void)didSelectItemWithGoodType:(EGoogsType)goodType isSelect:(BOOL)isSelect;

@end

@interface ChoseItemView : UIView

+ (ChoseItemView *)showChoseItemViewWithFatherView:(UIView *)fatherView dataSource:(NSArray<ClassItemModel *> *)dataSource;
@property (nonatomic, weak) id<ChoseItemViewDelegate> delegate;
- (void)dismissSelfAndReturnResult;

@end
