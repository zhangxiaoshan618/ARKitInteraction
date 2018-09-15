//
//  VirtualObjectLoader.m
//  ARKitInteraction
//
//  Created by 张晓珊 on 2018/9/13.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import "VirtualObjectLoader.h"

/**
 在后台队列上加载多个`VirtualObject`，以便能够在需要时快速显示对象。
 */

@interface VirtualObjectLoader ()

@property (nonatomic, strong) NSMutableArray<VirtualObject *> *loadedObjects;
@property (nonatomic, assign) BOOL isLoading;


@end

@implementation VirtualObjectLoader

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.loadedObjects = [NSMutableArray<VirtualObject *> array];
        self.isLoading = NO;
    }
    return self;
}

#pragma mark - 加载对象
/**
 在后台队列上加载`VirtualObject`。 加载`object`后，在后台队列上调用`loadedHandler`。
 */
- (void)loadVirtualObject:(VirtualObject *)object loadedHandler:(void(^)(VirtualObject *object))loadedHandler {
    self.isLoading = YES;
    [self.loadedObjects addObject:object];
    
    [object reset];
    [object load];
    
    self.isLoading = NO;
    loadedHandler(object);
    
    //异步加载内容。
//    dispatch_queue_t queue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0);
//    dispatch_async(queue, ^{
//        [object reset];
//        [object load];
//        
//        self.isLoading = NO;
//        loadedHandler(object);
//    });
}

#pragma mark - 移除对象

- (void)removeAllVirtualObjects {
    for (VirtualObject *object in self.loadedObjects) {
        [object removeFromParentNode];
    }
    
    [self.loadedObjects removeAllObjects];
}


- (void)removeVirtualObjectAt:(NSInteger)index {
    NSUInteger count = self.loadedObjects.count;
    if (index >= 0 && index < count) {
        [self.loadedObjects[index] removeFromParentNode];
        [self.loadedObjects removeObjectAtIndex:index];
    }
}

@end
