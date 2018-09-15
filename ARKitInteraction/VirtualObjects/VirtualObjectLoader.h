//
//  VirtualObjectLoader.h
//  ARKitInteraction
//
//  Created by 张晓珊 on 2018/9/13.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VirtualObject.h"

@interface VirtualObjectLoader : NSObject

@property (nonatomic, strong, readonly) NSMutableArray<VirtualObject *> *loadedObjects;
@property (nonatomic, assign, readonly) BOOL isLoading;
- (void)loadVirtualObject:(VirtualObject *)object loadedHandler:(void(^)(VirtualObject *object))loadedHandler;
- (void)removeAllVirtualObjects;
- (void)removeVirtualObjectAt:(NSInteger)index;

@end
