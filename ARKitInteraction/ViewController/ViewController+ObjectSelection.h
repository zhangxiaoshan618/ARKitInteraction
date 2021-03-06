//
//  ViewController+ObjectSelection.h
//  ARKitInteraction
//
//  Created by 张晓珊 on 2018/9/15.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import "ViewController.h"
#import "VirtualObject.h"
#import "FocusSquare.h"
#import "StatusViewController.h"
#import "VirtualObjectSelectionViewController.h"
#import "VirtualObjectInteraction.h"
#import "VirtualObjectLoader.h"


@interface ViewController (ObjectSelection) <VirtualObjectSelectionViewControllerDelegate>
- (void)placeVirtualObject:(VirtualObject *)virtualObject;
- (void)displayObjectLoadingUI;
- (void)hideObjectLoadingUI;
- (void)virtualObjectSelectionViewController:(VirtualObjectSelectionViewController *)selectionViewController didSelectObject:(VirtualObject *)selectObject;
- (void)virtualObjectSelectionViewController:(VirtualObjectSelectionViewController *)selectionViewController didDeselectObject:(VirtualObject *)deselectObject;

@end

