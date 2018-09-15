//
//  VirtualObjectSelectionViewController.h
//  ARKitInteraction
//
//  Created by 张晓珊 on 2018/9/15.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VirtualObject.h"

@class VirtualObjectSelectionViewController;

@interface ObjectCell : UITableViewCell

@property (nonatomic, strong) UILabel *objectTitleLabel;
@property (nonatomic, strong) UIImageView *objectImageView;
@property (nonatomic, strong) UIVisualEffectView *vibrancyView;

@property (nonatomic, copy) NSString *modelName;

@end

@protocol VirtualObjectSelectionViewControllerDelegate <NSObject>

- (void)virtualObjectSelectionViewController:(VirtualObjectSelectionViewController *)selectionViewController didSelectObject:(VirtualObject *)selectObject;
- (void)virtualObjectSelectionViewController:(VirtualObjectSelectionViewController *)selectionViewController didDeselectObject:(VirtualObject *)deselectObject;

@end

@interface VirtualObjectSelectionViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray<VirtualObject *> *virtualObjects;
@property (nonatomic, strong) NSIndexSet *selectedVirtualObjectRows;
@property (nonatomic, strong) NSMutableSet<NSNumber *> *enabledVirtualObjectRows;

@property (nonatomic, weak) id<VirtualObjectSelectionViewControllerDelegate> delegate;

- (void)updateObjectAvailabilityFor:(ARPlaneAnchor *)planeAnchor;

@end
