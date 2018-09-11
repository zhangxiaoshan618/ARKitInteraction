//
//  PositionTranslation.h
//  ARKitInteraction
//
//  Created by 张晓珊 on 2018/9/9.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ARKit/ARKit.h>

@interface PositionTranslation : NSObject

+ (matrix_float4x4)instanceMatrixFloat4x4WithUniformScale:(float)scale;
+ (simd_quatf)getOrientationWithMatrixFloat4x4:(matrix_float4x4)matrixFloat4x4;
+ (void)setMatrixFloat4x4:(matrix_float4x4 *)matrixFloat4x4 withTranslation:(simd_float3)translation;
+ (simd_float3)getTranslationWithMatrixFloat4x4:(matrix_float4x4)matrixFloat4x4;

@end

@interface PositionPoint : NSObject

+ (CGPoint)instancePointWithVector:(SCNVector3)vector;
+ (CGFloat)getLengthWithPoint:(CGPoint)point;

@end

