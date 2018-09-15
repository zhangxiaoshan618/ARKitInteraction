//
//  ClassTypeSelectCell.h
//  ARKitInteraction
//
//  Created by Yi Li on 2018/9/15.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClassItemArrayModel.h"
#import "EnumHeader.h"

@protocol ClassTypeSelectCellDelegate <NSObject>

- (void)didSelectItemWithGoodType:(EGoogsType)goodType;

@end

@interface ClassTypeSelectCell : UITableViewCell

@property (nonatomic, strong) GoodsItemModel *model;
@property (nonatomic, assign) NSInteger position;
@property (nonatomic, weak) id<ClassTypeSelectCellDelegate> delegate;

@end
