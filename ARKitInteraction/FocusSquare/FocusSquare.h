//
//  FocusSquare.h
//  ARKitInteraction
//
//  Created by 张晓珊 on 2018/9/9.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>

typedef NS_ENUM(NSUInteger, FocusSquareState) {
    FocusSquareStateInitializing,
    FocusSquareStateDetecting,
};

@interface FocusSquare : SCNNode

@property (nonatomic, assign) FocusSquareState state;
@property (nonatomic, assign, readonly) simd_float3 lastPosition;
@property (nonatomic, strong, readonly) ARPlaneAnchor *currentPlaneAnchor;
@property (nonatomic, strong, readonly) NSMutableArray<NSNumber *> *recentFocusSquareAlignments;

- (void)unhide;
+ (CGFloat)size;
+ (CGFloat)thickness;
+ (CGFloat)scaleForClosedSquare;
+ (CGFloat)sideLengthForOpenSegments;
+ (CGFloat)animationDuration;
+ (UIColor *)primaryColor;
+ (UIColor *)fillColor;

@end
