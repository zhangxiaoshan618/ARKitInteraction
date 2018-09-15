//
//  CanDeletePictureCell.h
//  ARKitInteraction
//
//  Created by Yi Li on 2018/9/15.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CanDeletePictureCellDelegate <NSObject>
- (void)didDeletePictureCell:(NSInteger)index;
@end

@interface CanDeletePictureCell : UICollectionViewCell

@property (nonatomic, strong) UIImage *picImage;

- (void)canDelete:(BOOL)canDelete;
@property (nonatomic, weak) id<CanDeletePictureCellDelegate> delegate;
@property (nonatomic, assign) NSInteger index;
@end
