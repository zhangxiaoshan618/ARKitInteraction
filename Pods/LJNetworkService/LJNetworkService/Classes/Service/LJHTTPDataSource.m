//
//  WCHTTPDataSource.m
//  WoolCutter
//
//  Created by Xiaobin Chen on 11/13/14.
//  Copyright (c) 2014 Lianjia. All rights reserved.
//

#import "AFNetworking.h"
#import "LJHTTPDataSource.h"
#import "LJHTTPErrorCode.h"
#import <CoreTelephony/CTCellularData.h>

#define MAX_CONCURRENT_HTTP_REQUEST_COUNT 3

#define INTERNAL_TIME_OUT 45

NSString * const LJNetworkServiceErrorDomain = @"com.lianjia.error.nerworkService";

@interface LJHTTPDataSource () {
    AFHTTPSessionManager *_afManager;
    CTCellularData *_cellularData;
    CTCellularDataRestrictedState _restrictState;
}
@end

@implementation LJHTTPDataSource

- (instancetype)init {
    self = [super init];
    if (self ) {
        _afManager = [[AFHTTPSessionManager alloc] initWithBaseURL:nil];
        [_afManager.operationQueue setMaxConcurrentOperationCount:MAX_CONCURRENT_HTTP_REQUEST_COUNT];
        _afManager.completionQueue = dispatch_queue_create("afmanager.completion.queue", DISPATCH_QUEUE_SERIAL);
        _afManager.requestSerializer.timeoutInterval = INTERNAL_TIME_OUT;
        _cellularData = [[CTCellularData alloc]init];
        _cellularData.cellularDataRestrictionDidUpdateNotifier = ^(CTCellularDataRestrictedState state) { //获取联网状态
            _restrictState = state;
        };
    }
    
    return self;
}

- (void)buildHeader:(NSDictionary*)header
{
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer new];
    requestSerializer.timeoutInterval = INTERNAL_TIME_OUT;
    if (header.count)
    {
        [header enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    }
    _afManager.requestSerializer = requestSerializer;
}

- (NSURLSessionDataTask *)GET:(NSString *)URLPath
                       header:(NSDictionary*)header
                   parameters:(NSDictionary *)parameters
                     progress:(void (^)(NSProgress *progress))downloadProgress
                   completion:(void (^)(id resObc, NSError *error))completionBlock
{
    [self buildHeader:header];
    __weak __typeof(self) weakSelf = self;

    NSURLSessionDataTask *task = [_afManager GET:URLPath parameters:parameters progress:downloadProgress success:^(NSURLSessionDataTask *task, id responseObject) {
        if(completionBlock){
            completionBlock(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(completionBlock){
            completionBlock(nil, [weakSelf failureErrorWithTask:error]);
        }
    }];

    return task;
}

- (NSURLSessionDataTask *)POST:(NSString *)URLPath
                        header:(NSDictionary*)header
                 urlParameters:(NSDictionary *)urlParams
                bodyParameters:(NSDictionary *)bodyParams
                      progress:(void (^)(NSProgress *progress))downloadProgress
                    completion:(void (^)(id resObc, NSError *error))completionBlock
{
    [self buildHeader:header];
    NSString *urlWithParams = [self constructUrlString:URLPath withUrlParameters:urlParams];
    __weak __typeof(self) weakSelf = self;

    NSURLSessionDataTask *task = [_afManager POST:urlWithParams parameters:bodyParams progress:downloadProgress success:^(NSURLSessionDataTask *task, id responseObject) {
        if(completionBlock){
            completionBlock(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(completionBlock){
            completionBlock(nil, [weakSelf failureErrorWithTask:error]);
        }
    }];

    return task;
}

- (NSURLSessionDataTask *)POST:(NSString *)URLPath
                        header:(NSDictionary*)header
                 urlParameters:(NSDictionary *)urlParams
                bodyParameters:(NSDictionary *)bodyParams
     constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))block
                      progress:(void (^)(NSProgress *))downloadProgress
                    completion:(void (^)(id, NSError *))completionBlock
{

    NSAssert(URLPath, @"url path cannot be nil");
    [self buildHeader:header];
    NSString *urlWithParams = [self constructUrlString:URLPath withUrlParameters:urlParams];
    __weak __typeof(self) weakSelf = self;

    NSURLSessionDataTask *task = [_afManager POST:urlWithParams parameters:bodyParams constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        block(formData);
    } progress:downloadProgress success:^(NSURLSessionDataTask *task, id responseObject) {
        if(completionBlock){
            completionBlock(responseObject, nil);
        }
    }
    failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(completionBlock){
            completionBlock(nil, [weakSelf failureErrorWithTask:error]);
        }
    }];
    return task;
}

- (NSError *)failureErrorWithTask:(NSError *)error {
    int errorCode = LJHttpErrorTypeRequestGeneral;

    switch ([error code]) {
        case NSURLErrorTimedOut:
            errorCode = LJHttpErrorTypeRequestTimedOut;
            break;

        case NSURLErrorCancelled:
            errorCode = LJHttpErrorTypeRequestCancel;
            break;

        case NSURLErrorUnsupportedURL:
        case NSURLErrorCannotFindHost:
        case NSURLErrorCannotConnectToHost:
        case NSURLErrorNetworkConnectionLost:
        case NSURLErrorDNSLookupFailed:
        case NSURLErrorHTTPTooManyRedirects:
            errorCode = LJHttpErrorTypeConnectionFailure;
            break;
		case NSURLErrorNotConnectedToInternet:
			errorCode = LJHttpErrorTypeNotConnectedToInternet;
			break;

        default:
            errorCode = LJHttpErrorTypeRequestGeneral;
            break;
    }
    
    if (errorCode == LJHttpErrorTypeNotConnectedToInternet) {
        NSError *underlyingError = [self cellularDataNetWorkPermission];
        if (underlyingError) {
            return [NSError errorWithDomain:error.domain code:errorCode userInfo:@{NSLocalizedDescriptionKey : [error description].length ? [error description] : @"unknown error", NSUnderlyingErrorKey:underlyingError}];
        } else {
            return [NSError errorWithDomain:error.domain code:errorCode userInfo:@{NSLocalizedDescriptionKey : [error description].length ? [error description] : @"unknown error"}];
        }
    } else {
        return [NSError errorWithDomain:error.domain code:errorCode userInfo:@{NSLocalizedDescriptionKey : [error description].length ? [error description] : @"unknown error"}];
    }
}

#pragma mark - Internal helpers
- (NSString *)constructUrlString:(NSString *)urlPath withUrlParameters:(NSDictionary *)urlDics {
    if (!urlDics || 0 == urlDics.count) {
        return urlPath;
    }

    NSMutableString *url = [urlPath mutableCopy];
    NSRange range = [url rangeOfString:@"?"];

    if (range.location == NSNotFound) {
        [url appendString:@"?"];
    } else {
        [url appendString:@"&"];
    }

    int i = 0;
    for (NSString *key in urlDics) {
        [url appendFormat:@"%@=%@", key, urlDics[key]];
        if (i != urlDics.count - 1) {
            // Not last one, should append '&'
            [url appendString:@"&"];
        }
        i++;
    }

    return url;
}

- (NSError *)cellularDataNetWorkPermission {
    if (_restrictState == kCTCellularDataRestricted) {
        return [NSError errorWithDomain:LJNetworkServiceErrorDomain code:LJOtherErrorTypeCellularDataRestricted userInfo:@{NSLocalizedDescriptionKey:@"Cellular Data Restricted"}];
    } else {
        return nil;
    }
}
@end
