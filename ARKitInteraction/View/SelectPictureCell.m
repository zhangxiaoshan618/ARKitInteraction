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
    cell.delegate = self;
    if (self.imageArray.count) {
        if (self.imageArray.count<=1) {
            [cell canDelete:NO];
        } else {
            [cell canDelete:YES];
        }
        cell.index = indexPath.row;
        
        cell.picImage = self.imageArray[indexPath.row];
    } else {
        [cell canDelete:NO];
        cell.index = indexPath.row;
        cell.imageUrl = self.imageUrlArray[indexPath.row];
    }
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.imageArray.count) {
        return self.imageArray.count;
    } else {
        return self.imageUrlArray.count;
    }
    
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

- (void)setImageUrlArray:(NSArray<NSString *> *)imageUrlArray {
    _imageUrlArray = imageUrlArray;
}

- (void)didDeletePictureCell:(NSInteger)index {
    NSMutableArray *imgArray = [NSMutableArray arrayWithArray:self.imageArray];
    [imgArray removeObjectAtIndex:index];
    self.imageArray = imgArray;
    [self.collectionView reloadData];
}

@end
