//
//  SelectCompanyController.h
//  ARKitInteraction
//
//  Created by Yi Li on 2018/9/15.
//  Copyright © 2018年 张晓珊. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CompanyInfoModel;

@protocol SelectCompanyControllerDelegate <NSObject>

- (void)didSelectCompany:(CompanyInfoModel *)companyModel;

@end

@interface SelectCompanyController : UIViewController
@property (nonatomic, copy) NSArray <CompanyInfoModel *>*companyArray;

@property (nonatomic, weak) id<SelectCompanyControllerDelegate> delegate;
@end
