//
//  SelectPictureCell.m
//  ARKitInteraction
//
//  Created by Yi Li on 2018/9/15.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import "SelectPictureCell.h"
#import "Masonry.h"
#import "CanDeletePictureCell.h"

@interface SelectPictureCell ()<CanDeletePictureCellDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation SelectPictureCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initUI];
    }
    return self;
}

- (void)initUI {
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.height.equalTo(@120);
        make.top.equalTo(@0);
    }];
    [self.collectionView registerClass:[CanDeletePictureCell class] forCellWithReuseIdentifier:@"CanDeletePictureCell"];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CanDeletePictureCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CanDeletePictureCell" forIndexPath:indexPath];
    cell.index = indexPath.row;
    cell.picImage = self.imageArray[indexPath.row];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(100, 100);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)setImageArray:(NSArray<UIImage *> *)imageArray {
    _imageArray = imageArray;
    [self.collectionView reloadData];
}

- (void)didDeletePictureCell:(NSInteger)index {
    
}

@end
