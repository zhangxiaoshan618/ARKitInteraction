//
//  Segment.m
//  ARKitInteraction
//
//  Created by 张晓珊 on 2018/9/9.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import "Segment.h"
#import "FocusSquare.h"

@interface Segment ()

@property (nonatomic, assign, readonly) CGFloat thickness;
@property (nonatomic, assign, readonly) CGFloat length;
@property (nonatomic, assign, readonly) CGFloat openLength;
@property (nonatomic, assign, readonly) Corner corner;
@property (nonatomic, assign, readonly) Alignment alignment;
@property (nonatomic, strong, readonly) SCNPlane *plane;

@end

@implementation Segment

- (instancetype)initWithName:(NSString *)name corner:(Corner)corner alignment:(Alignment)alignment
{
    self = [super init];
    if (self) {
        _thickness = 0.018;
        _length = 0.5;
        _openLength = 0.2;
        self.name = name;
        _corner = corner;
        _alignment = alignment;
        switch (alignment) {
            case AlignmentVertical:
                _plane = [SCNPlane planeWithWidth:self.thickness height:self.length];
                break;
                
            case AlignmentHorizontal:
                _plane = [SCNPlane planeWithWidth:self.length height:self.thickness];
                break;
        }
        
        SCNMaterial *material = self.plane.firstMaterial;
        material.diffuse.contents = FocusSquare.primaryColor;
        material.doubleSided = YES;
        material.ambient.contents = [UIColor blackColor];
        material.lightingModelName = SCNLightingModelConstant;
        material.emission.contents = FocusSquare.primaryColor;
        self.geometry = self.plane;
    }
    return self;
}

- (void)open {
    if (self.alignment == AlignmentHorizontal) {
        self.plane.width = self.openLength;
    }else {
        self.plane.height = self.openLength;
    }
    
    CGFloat offset = self.length / 2 - self.openLength / 2;
    [self updatePositionWithOffset:offset forDirection:self.openDirection];
}

- (void)close {
    CGFloat oldLength;
    if (self.alignment == AlignmentHorizontal) {
        oldLength = self.plane.width;
        self.plane.width = self.length;
    } else {
        oldLength = self.plane.height;
        self.plane.height = self.length;
    }
    
    CGFloat offset = self.length / 2 - oldLength / 2;
    [self updatePositionWithOffset:offset forDirection:[self directionReversed]];
}

- (void)updatePositionWithOffset:(CGFloat)offset forDirection:(Direction)direction {
    switch (direction) {
        case DirectionLeft:
            self.position = SCNVector3Make(self.position.x - offset, self.position.y, self.position.z);
            break;
            
        case DirectionRight:
            self.position = SCNVector3Make(self.position.x + offset, self.position.y, self.position.z);
            break;
            
        case DirectionUp:
            self.position = SCNVector3Make(self.position.x, self.position.y - offset, self.position.z);
            break;
            
        case DirectionDown:
            self.position = SCNVector3Make(self.position.x, self.position.y + offset, self.position.z);
            break;
    }
}

- (Direction)directionReversed {
    switch (self.openDirection) {
        case DirectionUp:
            return DirectionDown;
            break;
            
        case DirectionDown:
            return DirectionUp;
            break;
            
        case DirectionLeft:
            return DirectionRight;
            break;
            
        case DirectionRight:
            return DirectionLeft;
            break;
    }
}


#pragma mark - getter/setter

- (Direction)openDirection {

    switch (self.corner) {
        case CornerTopLeft: {
            switch (self.alignment) {
                case AlignmentHorizontal:
                    return DirectionLeft;
                    break;
                    
                case AlignmentVertical:
                    return DirectionUp;
                    break;
            }
        }break;
            
        case CornerTopRight: {
            switch (self.alignment) {
                case AlignmentHorizontal:
                    return DirectionRight;
                    break;
                    
                case AlignmentVertical:
                    return DirectionUp;
                    break;
            }
        }break;
            
        case CornerBottomLeft: {
            switch (self.alignment) {
                case AlignmentHorizontal:
                    return DirectionLeft;
                    break;
                    
                case AlignmentVertical:
                    return DirectionDown;
                    break;
            }
        }break;
            
        case CornerBottomRight: {
            switch (self.alignment) {
                case AlignmentHorizontal:
                    return DirectionRight;
                    break;
                    
                case AlignmentVertical:
                    return DirectionDown;
                    break;
            }
        }break;
    }
}

@end
