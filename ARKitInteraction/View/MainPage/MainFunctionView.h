//
//  MainFunctionView.h
//  ARKitInteraction
//
//  Created by Yi Li on 2018/9/15.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MainFunctionViewDelegate <NSObject>

- (void)didClicedListButton;
- (void)shotButtonClicked;

@end

@interface MainFunctionView : UIView

+ (MainFunctionView *)showInFatherView:(UIView *)fatherView;

@property (nonatomic, weak) id<MainFunctionViewDelegate> delegate;

@end
