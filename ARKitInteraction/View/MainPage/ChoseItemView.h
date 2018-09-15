//
//  ChoseItemView.h
//  ARKitInteraction
//
//  Created by Yi Li on 2018/9/14.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GoodsItemModel;
@class ClassItemModel;

@protocol ChoseItemViewDelegate <NSObject>

- (void)didSelectItemWithGoodModel:(GoodsItemModel *)goodModel;

@end

@interface ChoseItemView : UIView

+ (ChoseItemView *)showChoseItemViewWithFatherView:(UIView *)fatherView dataSource:(NSArray<ClassItemModel *> *)dataSource;
- (void)dismissSelfAndReturnResult;

@end
