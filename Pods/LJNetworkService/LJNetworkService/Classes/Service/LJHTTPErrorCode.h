//
//  BHErrorNumber.h
//  Netdisk_Mac
//
//  Created by wuxiaoyue on 13-3-15.
//  Copyright (c) 2013年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LJHttpErrorType) {
    LJHttpErrorTypeConnectionFailure = -1000,
    LJHttpErrorTypeRequestTimedOut = -1001,
    LJHttpErrorTypeRequestCancel = -1002,
    LJHttpErrorTypeRequestResourceNotFound = -1003,
    LJHttpErrorTypeRequestAuth = -1004,
    LJHttpErrorTypeRequestServer = -1009,
    LJHttpErrorTypeRequestGeneral = -1010,
    LJHttpErrorTypeRequestParse = -1011,
	LJHttpErrorTypeNotConnectedToInternet = -1012  //无网络时
};

typedef NS_ENUM(NSInteger, LJAccountLoginErrorType) {
    LJAccountLoginErrorTypeUserNameFormat = -200,
    LJAccountLoginErrorTypeUserNoExists = -201,
    LJAccountLoginErrorTypePassword = -202,
    LJAccountLoginErrorTypeCheckCode = -203,
    LJAccountLoginErrorTypeNeedCheckCode = -204,
    LJAccountLoginErrorTypeCanNotLogin = -205,
    LJAccountLoginErrorTypeUserIdNotSatisfied = -206,
    LJAccountLoginErrorTypeSMSCode = -207,
    LJAccountLoginErrorTypeGeneral = -210,
};

typedef NS_ENUM(NSInteger, LJAccountRegErrorType) {
    LJAccountRegErrorTypeUserNameFormat = -211,
    LJAccountRegErrorTypeUserNameEmpty = -212,
    LJAccountRegErrorTypeUserNameBan = -213,
    LJAccountRegErrorTypeUserNameExists = -214,
    LJAccountRegErrorTypePassWordFormat = -215,
    LJAccountRegErrorTypePassWordEmpty = -216,
    LJAccountRegErrorTypePassWordWeak = -217,
    LJAccountRegErrorTypePhoneNumFormat = -218,
    LJAccountRegErrorTypePhoneNumEmpty = -219,
    LJAccountRegErrorTypePhoneNumBind = -220,
    LJAccountRegErrorTypeCode = -221,
    LJAccountRegErrorTypeCodeEmpty = -222,
    LJAccountRegErrorTypeCodeExpiration = -223,
    LJAccountRegErrorTypeMissRequireField = -224,
    LJAccountRegErrorTypeGeneral = -230,
    LJAccountRegErrorTypeBanUser = -240,
};

typedef NS_ENUM(NSInteger, LJServerErrorType) {
    LJServerErrorTypeInternal = -300,            // 服务器内部错误
    LJServerErrorTypeServiceOther = -301,        // 服务器其他错误
    LJServerErrorTypeUserTokenInvalid = -302,    // 用户 token 过期，重新登录！
    LJServerErrorTypeRequestParamMissing = -303, // 缺少必要参数
    LJServerErrorTypeRequestParamInvalid = -304, // 参数错误
    LJServerErrorTypeRequestAPINotFound = -305,  // API 地址有误
    LJServerErrorTypeVersionNotMatch = -306,     //版本不匹配
    LJServerErrorTypeUserAgent = -307, // User-agetn错误
    LJServerErrorTypeDataOperateFail = -308,                  //数据操作失败
    LJServerErrorTypeLoginInOtherDivice = -309,               //其他设备登录，踢出
    LJServerErrorTypeRequestMissingParam = -310,              // 参数未传入
    LJServerErrorTypeRequestParamType = -311,                 // 参数类型错误
    LJServerErrorTypeRequestParamMissData = -312,             // 参数缺少数据
    LJServerErrorTypeUserPermission = -313,                   // 权限错误
    LJServerErrorTypeUserHasNoCorrespondingPermission = -314, // 没有对应资源权限
    LJServerErrorTypeBusinessException = -315,                // 业务异常
    LJServerErrorTypeUnknow = -316,                           // 未知错误
};

typedef NS_ENUM(NSInteger, LJOtherErrorType) {
    LJOtherErrorTypeCellularDataRestricted = -30001,  //用户网络权限未打开
};
