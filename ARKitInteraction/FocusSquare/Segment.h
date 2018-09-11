//
//  Segment.h
//  ARKitInteraction
//
//  Created by 张晓珊 on 2018/9/9.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import <SceneKit/SceneKit.h>

typedef NS_ENUM(NSUInteger, Corner) {
    CornerTopLeft,
    CornerTopRight,
    CornerBottomRight,
    CornerBottomLeft,
};

typedef NS_ENUM(NSUInteger, Alignment) {
    AlignmentHorizontal,
    AlignmentVertical,
};

typedef NS_ENUM(NSUInteger, Direction) {
    DirectionUp,
    DirectionDown,
    DirectionLeft,
    DirectionRight,
};

@interface Segment : SCNNode

@property (nonatomic, assign, readonly) Direction openDirection;

- (instancetype)initWithName:(NSString *)name corner:(Corner)corner alignment:(Alignment)alignment;
- (void)open;
- (void)close;

@end
