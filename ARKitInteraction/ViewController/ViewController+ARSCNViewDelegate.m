//
//  ViewController+ARSCNViewDelegate.m
//  ARKitInteraction
//
//  Created by 张晓珊 on 2018/9/15.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import "ViewController+ARSCNViewDelegate.h"
#import <ARKit/ARError.h>

@implementation ViewController (ARSCNViewDelegate)


- (void)session:(ARSession *)session didFailWithError:(NSError *)error {
    if (error) {
        NSString *errorMessage = [NSString stringWithFormat:@"%@\n%@\n%@", error.localizedDescription, error.localizedFailureReason, error.localizedRecoverySuggestion];
        dispatch_async(dispatch_get_main_queue(), ^{
//            [self disp]
        })
    }
    
    
}

- (void)sessionInterruptionEnded:(ARSession *)session {
    [self.virtualObjectLoader.loadedObjects enumerateObjectsUsingBlock:^(VirtualObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = YES;
    }];
}

- (BOOL)sessionShouldAttemptRelocalization:(ARSession *)session {
    return YES;
}

@end
