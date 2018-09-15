//
//  StatusViewController.m
//  ARKitInteraction
//
//  Created by 张晓珊 on 2018/9/15.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import "StatusViewController.h"
#import <ARKit/ARKit.h>
#import <Masonry.h>

@interface StatusViewController ()

@property (nonatomic, strong) UIVisualEffectView *messagePanel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIButton *restartExperienceButton;

@property (nonatomic, assign) NSTimeInterval displayDuration;
@property (nonatomic, weak) NSTimer *messageHideTimer;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSTimer *> *timers;

@property (nonatomic, copy) NSArray<NSNumber *> *messageTypeAll;

@end

@implementation StatusViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.displayDuration = 6;
        self.timers = [NSMutableDictionary<NSNumber *, NSTimer*> dictionary];
        self.messageTypeAll = @[[NSNumber numberWithInteger:MessageTypeTrackingStateEscalation],
                                [NSNumber numberWithInteger:MessageTypePlaneEstimation],
                                [NSNumber numberWithInteger:MessageTypeContentPlacement],
                                [NSNumber numberWithInteger:MessageTypeFocusSquare],
                                ];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    [self setUpUI];
}

- (void)setUpUI {
    [self.view addSubview:self.messagePanel];
    [self.view addSubview:self.restartExperienceButton];
    [self.messagePanel.contentView addSubview:self.messageLabel];
    
    [self.messagePanel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.equalTo(self.view).inset(16);
        make.trailing.greaterThanOrEqualTo(self.restartExperienceButton.mas_leading).offset(-8);
    }];
    [self.restartExperienceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.top.equalTo(self.view).inset(16);
        make.width.equalTo(@44);
        make.height.equalTo(@59);
    }];
    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.messagePanel.contentView).inset(8);
        make.leading.trailing.equalTo(self.messagePanel.contentView).inset(16);
    }];
}

#pragma mark - Message Handling
- (void)showMessage:(NSString *)text autoHide:(BOOL)autoHide {
    //取消之前的任何隐藏计时器
    [self.messageHideTimer invalidate];
    self.messageLabel.text = text;
    
    [self setMessageHidden:NO animated:YES];
    
    if (autoHide) {
         __weak typeof(self) weakSelf = self;
        self.messageHideTimer = [NSTimer scheduledTimerWithTimeInterval:self.displayDuration repeats:NO block:^(NSTimer * _Nonnull timer) {
            [weakSelf setMessageHidden:YES animated:YES];
        }];
    }
}


- (void)scheduleMessage:(NSString *)text inSeconds:(NSTimeInterval)seconds messageType:(MessageType)messageType {
    [self cancelScheduledMessageFor:messageType];
    __weak typeof(self) weakSelf = self;
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:seconds repeats:NO block:^(NSTimer * _Nonnull timer) {
        [weakSelf showMessage:text autoHide:YES];
        [timer invalidate];
    }];
    
    self.timers[[NSNumber numberWithInteger:messageType]] = timer;
}

- (void)cancelScheduledMessageFor:(MessageType)messageType {
    [self.timers[[NSNumber numberWithInteger:messageType]] invalidate];
    self.timers[[NSNumber numberWithInteger:messageType]] = nil;
}

- (void)cancelAllScheduledMessages {
    for (NSNumber *number in self.messageTypeAll) {
        [self cancelScheduledMessageFor:number.integerValue];
    }
}


#pragma mark -

- (void)showTrackingQualityInfoFor:(ARTrackingState)trackingState reason:(ARTrackingStateReason)reason autoHide:(BOOL)autoHide {
    [self showMessage:[self presentationStringWith:trackingState andReason:reason] autoHide:autoHide];
}

- (void)escalateFeedbackFor:(ARTrackingState)trackingState reason:(ARTrackingStateReason)reason seconds:(NSTimeInterval)seconds {
    [self cancelScheduledMessageFor:MessageTypeTrackingStateEscalation];

    __weak typeof(self) weakSelf = self;
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:seconds repeats:NO block:^(NSTimer * _Nonnull timer) {
        [weakSelf cancelScheduledMessageFor:MessageTypeTrackingStateEscalation];

        NSMutableString *message = [NSMutableString stringWithString: [self presentationStringWith:trackingState andReason:reason]];
        NSString *recommendation = [weakSelf recommendationWith:trackingState andReason:reason];
        if (recommendation != nil) {
            [message appendString:recommendation];
        }

        [weakSelf showMessage:message.copy autoHide:NO];
    }];

    self.timers[[NSNumber numberWithInteger:MessageTypeTrackingStateEscalation]] = timer;
}


#pragma mark - Button Actions Click

- (void)restartExperienceWith:(UIButton *)sinder {
    if (self.restartExperienceHandler) {
        self.restartExperienceHandler();
    }
}

#pragma mark - 面板可见性

- (void)setMessageHidden:(BOOL)hide animated:(BOOL)animated {
    //面板开始隐藏，因此在动画不透明度之前显示它。
    self.messagePanel.hidden = NO;
    
    if (!animated) {
        self.messageLabel.alpha = hide ? 0 : 1;
    }
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.messagePanel.alpha = hide ? 0 : 1;
    } completion:nil];
}

#pragma mark - enum

- (NSString *)presentationStringWith:(ARTrackingState)state andReason:(ARTrackingStateReason)reason {
    switch (state) {
        case ARTrackingStateNotAvailable:
            return @"追踪无法实现";
            break;
           
        case ARTrackingStateNormal:
            return @"跟踪正常";
            break;
            
        case ARTrackingStateLimited: {
            switch (reason) {
                case ARTrackingStateReasonExcessiveMotion:
                    return @"（跟踪限制）请不要移动过快";
                    break;
                    
                case ARTrackingStateReasonInsufficientFeatures:
                    return @"（跟踪限制）信息不足";
                    break;
                    
                case ARTrackingStateReasonInitializing:
                    return @"正在初始化";
                    break;
                    
                case ARTrackingStateReasonRelocalizing:
                    return @"正在从中断中恢复";
                    break;
                  
                default:
                    return @"";
                    break;
            }
        } break;
    }
}

- (NSString *)recommendationWith:(ARTrackingState)state andReason:(ARTrackingStateReason)reason  {
    switch (state) {
            
        case ARTrackingStateLimited: {
            switch (reason) {
                case ARTrackingStateReasonExcessiveMotion:
                    return @"请尝试减慢您的移动速度，或重置会话。";
                    break;
                    
                case ARTrackingStateReasonInsufficientFeatures:
                    return @"请尝试对准平面，或重置会话。";
                    break;

                case ARTrackingStateReasonRelocalizing:
                    return @"请尝试移动位置，或重置会话。";
                    break;
                    
                default:
                    break;
            }
        } break;
            
        default:
            break;
    }
    return nil;
}


#pragma mark - setter/getter

- (UIVisualEffectView *)messagePanel {
    if (!_messagePanel) {
        UIVisualEffectView *view = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        _messagePanel = view;
    }
    return _messagePanel;
}

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        UILabel *label = [UILabel new];
        label.textColor = [UIColor yellowColor];
        _messageLabel = label;
    }
    return _messageLabel;
}

- (UIButton *)restartExperienceButton {
    if (!_restartExperienceButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"restart"] forState:UIControlStateNormal];
        _restartExperienceButton = button;
    }
    return _restartExperienceButton;
}


@end
