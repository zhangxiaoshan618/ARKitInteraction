//
//  SelectPictureCell.h
//  ARKitInteraction
//
//  Created by Yi Li on 2018/9/15.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SelectPictureCellDelegate <NSObject>

- (void)finishDelePic:(NSArray<UIImage *>*)imageArray;

@end

@interface SelectPictureCell : UITableViewCell

@property (nonatomic, copy) NSArray <UIImage *> *imageArray;
@property (nonatomic, weak) id<SelectPictureCellDelegate> delegate;
@property (nonatomic, copy) NSArray <NSString *> *imageUrlArray;

@end
