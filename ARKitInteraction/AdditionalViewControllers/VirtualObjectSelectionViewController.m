//
//  VirtualObjectSelectionViewController.m
//  ARKitInteraction
//
//  Created by 张晓珊 on 2018/9/15.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import "VirtualObjectSelectionViewController.h"
#import <Masonry.h>

@implementation ObjectCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)setUpUI {
    [self.contentView addSubview:self.vibrancyView];
    [self.vibrancyView.contentView addSubview:self.imageView];
    [self.vibrancyView.contentView addSubview:self.textLabel];
}


#pragma mark - setter/getter

- (void)setModelName:(NSString *)modelName {
    _modelName = modelName;
    self.objectTitleLabel.text = modelName.capitalizedString;
    self.objectImageView.image = [UIImage imageNamed:modelName];
}

- (UILabel *)objectTitleLabel {
    if (!_objectTitleLabel) {
        UILabel *label = [UILabel new];
        label.textColor = [UIColor darkGrayColor];
        _objectTitleLabel = label;
    }
    return _objectTitleLabel;
}

- (UIImageView *)objectImageView {
    if (!_objectImageView) {
        UIImageView *image = [UIImageView new];
        _objectImageView = image;
    }
    return _objectImageView;
}

- (UIVisualEffectView *)vibrancyView {
    if (!_vibrancyView) {
        UIVisualEffectView *view = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
        _vibrancyView = view;
    }
    return _vibrancyView;
}

@end

@interface VirtualObjectSelectionViewController ()

@end

@implementation VirtualObjectSelectionViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.selectedVirtualObjectRows = [[NSIndexSet alloc] init];
        self.enabledVirtualObjectRows = [NSMutableSet<NSNumber *> set];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:ObjectCell.class forCellReuseIdentifier:NSStringFromClass(ObjectCell.class)];
    self.tableView.separatorEffect = [UIVibrancyEffect effectForBlurEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
}

- (void)viewWillLayoutSubviews {
    self.preferredContentSize = CGSizeMake(250, self.tableView.contentSize.height);
    
}

- (void)updateObjectAvailabilityFor:(ARPlaneAnchor *)planeAnchor {
    NSMutableSet<NSNumber *> *newEnabledVirtualObjectRows = [NSMutableSet<NSNumber *> set];
    
    [VirtualObject.availableObjects enumerateObjectsUsingBlock:^(VirtualObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isPlacementValidOn:planeAnchor]) {
            [newEnabledVirtualObjectRows addObject:[NSNumber numberWithInteger:idx]];
        }
        
        if ([self.selectedVirtualObjectRows containsIndex:idx]) {
            [newEnabledVirtualObjectRows addObject:[NSNumber numberWithInteger:idx]];
        }
    }];
    
    NSMutableArray<NSNumber *> *changedRows = [NSMutableArray<NSNumber *> array];
    for (NSNumber *number in newEnabledVirtualObjectRows) {
        if (![self.enabledVirtualObjectRows containsObject:number]) {
            [changedRows addObject:number];
        }
    }
    
    for (NSNumber *number in self.enabledVirtualObjectRows) {
        if (![newEnabledVirtualObjectRows containsObject:number]) {
            [changedRows addObject:number];
        }
    }
    
    self.enabledVirtualObjectRows = newEnabledVirtualObjectRows;
    NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray<NSIndexPath *> array];
    [changedRows enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:obj.integerValue inSection:0]];
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadRowsAtIndexPaths:indexPaths.copy withRowAnimation:UITableViewRowAnimationAutomatic];
    });
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.virtualObjects.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ObjectCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(ObjectCell.class) forIndexPath:indexPath];
    
    cell.modelName = self.virtualObjects[indexPath.row].modelName;
    
    if ([self.selectedVirtualObjectRows containsIndex:indexPath.row]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    BOOL cellIsEnabled = [self.enabledVirtualObjectRows containsObject:[NSNumber numberWithInteger:indexPath.row]];
    
    if (cellIsEnabled) {
        cell.vibrancyView.alpha = 1.0;
    }else {
        cell.vibrancyView.alpha = 0.1;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL cellIsEnabled = [self.enabledVirtualObjectRows containsObject:[NSNumber numberWithInteger:indexPath.row]];
    if (!cellIsEnabled) {
        return;
    }
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL cellIsEnabled = [self.enabledVirtualObjectRows containsObject:[NSNumber numberWithInteger:indexPath.row]];
    if (!cellIsEnabled) {
        return;
    }
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL cellIsEnabled = [self.enabledVirtualObjectRows containsObject:[NSNumber numberWithInteger:indexPath.row]];
    
    if (!cellIsEnabled) {
        return;
    }
    
    VirtualObject *object = self.virtualObjects[indexPath.row];
    
    if ([self.selectedVirtualObjectRows containsIndex:indexPath.row]) {
        [self.delegate virtualObjectSelectionViewController:self didDeselectObject:object];
    }else {
        [self.delegate virtualObjectSelectionViewController:self didSelectObject:object];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
