//
//  LJNetworkService.h
//  LJNetworkService
//
//  Created by yangyiyang on 2017/5/2.
//  Copyright © 2017年 lianjia. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AFMultipartFormData;


typedef NS_ENUM(NSInteger, HttpMethodType)
{
    HttpMethodTypeGET = 1,
    HttpMethodTypePOST = 2,
    HttpMethodTypePUT = 3,
    HttpMethodTypeHEAD = 4
};


@class LJNetworkRequest;
@class LJNetworkResponse;

@interface LJNetworkRequest : NSObject
@property (nonatomic, copy, readonly) NSString *url;
@property (nonatomic, assign, readonly) HttpMethodType methodType;
@property (nonatomic, strong, readonly) NSMutableDictionary *body;
@property (nonatomic, strong, readonly) NSMutableDictionary *header;
@property (nonatomic, strong, readonly) Class modelClass;
@property (nonatomic, strong) id userInfo;
- (void)cancel;
- (void)suspend;
- (void)resume;
@end

@interface LJNetworkResponse : NSObject
@property (nonatomic, strong, readonly) id userInfo;//对应request的userinfo
@property (nonatomic, strong, readonly) NSDictionary *header;
@property (nonatomic, strong, readonly) Class modelClass;
@property (nonatomic, strong) id responseData;// nsdata / nsdict /
@property (nonatomic, strong) NSError* error;

@end

@interface LJNetworkService : NSObject

@property (nonatomic, copy) void(^configRequest)(LJNetworkRequest *request);
@property (nonatomic, copy) void(^willSendRequest)(LJNetworkRequest *request);
@property (nonatomic, copy) void(^handleResponse)(LJNetworkResponse *response);


/**
 *  默认的一个单例对象，供主APP使用，其它模块使用不同的configuration的话，由自己写分类或者封装
 *  @return LJNetworkService
 */
+ (instancetype)defaultService;
- (instancetype)init;

#pragma marks - 常规接口

/**
 *  带请求进度的 Get 请求
 *
 *  @param url              具体的请求 url 路径
 *  @param parameters       请求参数
 *  @param modelClass       返回的model类
 *  @param completion       请求完成的 block 回调
 *
 *  @return 请求的 Operation
 */
- (LJNetworkRequest *)getWithUrl:(NSString *)url
                      parameters:(NSDictionary *)parameters
                      modelClass:(Class)modelClass
                      completion:(void(^)(id data,NSError *error))completion;

/**
 *  带请求进度的 Post 请求
 *
 *  @param url          具体的请求 url 路径
 *  @param params          url 请求参数
 *  @param modelClass      返回的model类
 *  @param completion      请求完成的 block 回调
 *
 *  @return 请求的 Operation
 */
- (LJNetworkRequest *)postWithUrl:(NSString *)url
                       parameters:(NSDictionary *)params
                       modelClass:(Class)modelClass
                       completion:(void(^)(id data,NSError *error))completion;

/**
 *  带请求进度的 上传Post 请求
 *
 *  @param url               具体的请求 url 路径
 *  @param params            url 请求参数
 *  @param modelClass        返回的model类
 *  @param constructingBody  表单参数
 *  @param progress          请求进度的 block 回调
 *  @param completion        请求完成的 block 回调
 *
 *  @return 请求的 Operation
 */
- (LJNetworkRequest *)postWithUrl:(NSString *)url
                       parameters:(NSDictionary *)params
                       modelClass:(Class)modelClass
                 constructingBody:(void(^)(id<AFMultipartFormData>formData))constructingBody
                         progress:(void(^)(NSProgress* progress))progress
                       completion:(void(^)(id data,NSError *error))completion;



@end
