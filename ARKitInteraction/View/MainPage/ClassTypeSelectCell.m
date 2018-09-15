//
//  ClassTypeSelectCell.m
//  ARKitInteraction
//
//  Created by Yi Li on 2018/9/15.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import "ClassTypeSelectCell.h"
#import "Masonry.h"
#import "ClassItemArrayModel.h"
#import "ItemSelectCollectionViewCell.h"

@interface ClassTypeSelectCell()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UILabel *goodNameLabel;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIControl *deleteControl;
@end

@implementation ClassTypeSelectCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initUI];
    }
    return self;
}

- (void)initUI {
    _goodNameLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    [self addSubview:self.self.goodNameLabel];
    _goodNameLabel.textColor = [UIColor redColor];
    _goodNameLabel.font = [UIFont systemFontOfSize:13.0];
    [_goodNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@20);
        make.centerY.equalTo(@0);
    }];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@80);
        make.height.equalTo(@50);
        make.top.right.equalTo(@0);
    }];
    [self.collectionView registerClass:[ItemSelectCollectionViewCell class] forCellWithReuseIdentifier:@"ItemSelectCollectionViewCell"];
    
}

- (void)setModel:(GoodsItemModel *)model {
    _model = model;
    _goodNameLabel.text = model.goodName;
    [self.collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ItemSelectCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ItemSelectCollectionViewCell" forIndexPath:indexPath];
    cell.goodInfoModel = self.model.goodInfoArray[indexPath.row];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.model.goodInfoArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(80, 45);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = 0;
    for (GoodsInfoModel * model in self.model.goodInfoArray) {
        if (index == indexPath.row) {
            model.isSelect = !model.isSelect;
        } else {
            model.isSelect = NO;
        }
        index ++;
    }
    [collectionView reloadData];
    
    if ([self.delegate respondsToSelector:@selector(didSelectItemWithGoodType:)]) {
        [self.delegate didSelectItemWithGoodType:self.position];
    }
}

@end
