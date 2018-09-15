//
//  StatusViewController.h
//  ARKitInteraction
//
//  Created by 张晓珊 on 2018/9/15.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ARKit/ARKit.h>

typedef NS_ENUM(NSUInteger, MessageType) {
    MessageTypeTrackingStateEscalation,
    MessageTypePlaneEstimation,
    MessageTypeContentPlacement,
    MessageTypeFocusSquare,
};

/**
   显示在应用程序主界面的顶部，允许用户查看
   AR体验的状态，以及控制重启的能力
   完全的体验。
   - 标签：StatusViewController
 */

@interface StatusViewController : UIViewController

///点击“重新启动体验”按钮时触发。
@property (nonatomic, copy) void(^restartExperienceHandler)(void);

- (void)showMessage:(NSString *)text autoHide:(BOOL)autoHide;

- (void)cancelScheduledMessageFor:(MessageType)messageType;

- (void)cancelAllScheduledMessages;

- (void)scheduleMessage:(NSString *)text inSeconds:(NSTimeInterval)seconds messageType:(MessageType)messageType;

- (void)showTrackingQualityInfoFor:(ARTrackingState)trackingState reason:(ARTrackingStateReason)reason autoHide:(BOOL)autoHide;

- (void)escalateFeedbackFor:(ARTrackingState)trackingState reason:(ARTrackingStateReason)reason seconds:(NSTimeInterval)seconds;
@end

