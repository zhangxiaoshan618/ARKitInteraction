//
//  WCHTTPDataSource.h
//  WoolCutter
//
//  Created by Xiaobin Chen on 11/13/14.
//  Copyright (c) 2014 Lianjia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSProgress.h>
#import <Foundation/NSURLSession.h>

@class LJBaseResponseModel;
@protocol AFMultipartFormData;

@interface LJHTTPDataSource : NSObject


/**
 *  带请求进度的 Get 请求
 *
 *  @param URLPath          具体的请求 url 路径
 *  @param parameters       请求参数
 *  @param downloadProgress 请求进度的 block 回调
 *  @param completionBlock  请求完成的 block 回调
 *
 *  @return 请求的 sessionTask
 */
- (NSURLSessionDataTask *)GET:(NSString *)URLPath
                       header:(NSDictionary*)header
                   parameters:(NSDictionary *)parameters
                     progress:(void (^)(NSProgress *progress))downloadProgress
                   completion:(void (^)(id resObc, NSError *error))completionBlock;

/**
 *  带请求进度的 Post 请求
 *
 *  @param URLPath          具体的请求 url 路径
 *  @param urlParas         url 请求参数
 *  @param bodyParas        body 请求参数
 *  @param downloadProgress 请求进度的 block 回调
 *  @param completionBlock  请求完成的 block 回调
 *
 *  @return 请求的 sessionTask
 */
- (NSURLSessionDataTask *)POST:(NSString *)URLPath
                        header:(NSDictionary*)header
                 urlParameters:(NSDictionary *)urlParas
                bodyParameters:(NSDictionary *)bodyParas
                      progress:(void (^)(NSProgress *progress))downloadProgress
                    completion:(void (^)(id resObc, NSError *error))completionBlock;

/**
 *  带请求进度的 Post 请求
 *
 *  @param URLPath          具体的请求 url 路径
 *  @param urlParams         url 请求参数
 *  @param bodyParams        body 请求参数
 *  @param block            表单参数
 *  @param downloadProgress 请求进度的 block 回调
 *  @param completionBlock  请求完成的 block 回调
 *
 *  @return 请求的 sessionTask
 */
- (NSURLSessionDataTask *)POST:(NSString *)URLPath
                        header:(NSDictionary*)header
                 urlParameters:(NSDictionary *)urlParams
                bodyParameters:(NSDictionary *)bodyParams
     constructingBodyWithBlock:(void (^)(id <AFMultipartFormData>))block
                      progress:(void (^)(NSProgress *progress))downloadProgress
                    completion:(void (^)(id resObc, NSError *error))completionBlock;


@end
