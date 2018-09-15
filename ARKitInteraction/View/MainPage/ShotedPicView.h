//
//  ShotedPicView.h
//  ARKitInteraction
//
//  Created by Yi Li on 2018/9/15.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShotedPicViewDelegate <NSObject>

- (void)clickBackButton;
- (void)clickSaveButton;
- (void)clickNextButton;

@end

@interface ShotedPicView : UIView

@property (nonatomic, weak) id<ShotedPicViewDelegate> delegate;
+ (ShotedPicView *)showInFatherView:(UIView *)fatherView;
@end
