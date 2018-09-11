//
//  PositionTranslation.m
//  ARKitInteraction
//
//  Created by 张晓珊 on 2018/9/9.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import "PositionTranslation.h"

@implementation PositionTranslation

+ (matrix_float4x4)instanceMatrixFloat4x4WithUniformScale:(float)scale {
    matrix_float4x4 instance = matrix_identity_float4x4;
    instance.columns[0].x = scale;
    instance.columns[1].y = scale;
    instance.columns[2].z = scale;
    return instance;
}

+ (simd_quatf)getOrientationWithMatrixFloat4x4:(matrix_float4x4)matrixFloat4x4 {
    return simd_quaternion(matrixFloat4x4);
}

+ (void)setMatrixFloat4x4:(matrix_float4x4 *)matrixFloat4x4 withTranslation:(simd_float3)translation {
    simd_float4 columns3 = matrixFloat4x4->columns[3];
    matrixFloat4x4->columns[3] = simd_make_float4(translation.x, translation.y, translation.z, columns3.w);
}

+ (simd_float3)getTranslationWithMatrixFloat4x4:(matrix_float4x4)matrixFloat4x4 {
    simd_float4 translation = matrixFloat4x4.columns[3];
    return simd_make_float3(translation.x, translation.y, translation.z);
}

@end

@implementation PositionPoint

+ (CGPoint)instancePointWithVector:(SCNVector3)vector {
    return CGPointMake(vector.x, vector.y);
}

+ (CGFloat)getLengthWithPoint:(CGPoint)point {
    return sqrtf(point.x * point.x + point.y * point.y);
}

@end
