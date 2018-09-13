//
//  LJNetworkService.m
//  LJNetworkService
//
//  Created by yangyiyang on 2017/5/2.
//  Copyright © 2017年 lianjia. All rights reserved.
//

#import "LJNetworkService.h"
#import "LJHTTPDataSource.h"
#import "LJHTTPErrorCode.h"


@interface LJNetworkRequest ()
@property (strong, nonatomic)NSURLSessionDataTask *task;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) HttpMethodType methodType;
@property (nonatomic, strong) NSMutableDictionary *body;
@property (nonatomic, strong) NSMutableDictionary *header;
@property (nonatomic, strong) Class modelClass;

@end


@implementation LJNetworkRequest

- (void)cancel {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.task cancel];
    });
}

- (void)suspend {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.task suspend];
    });
}

- (void)resume {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.task resume];
    });
}

- (void)setTask:(NSURLSessionDataTask *)task
{
    _task = task;
}
@end


@interface LJNetworkResponse ()
@property (nonatomic, strong) Class modelClass;
@property (nonatomic, strong) id    userInfo;
@property (nonatomic, strong) NSDictionary *header;
@end

@implementation LJNetworkResponse
@end


@interface LJNetworkService ()
@property (nonatomic, strong)LJHTTPDataSource    *dataSource;
@end

@implementation LJNetworkService

+ (instancetype)defaultService {
    static LJNetworkService *service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[LJNetworkService alloc] init];
    });
    
    return service;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _dataSource = [[LJHTTPDataSource alloc] init];
    }
    return self;
}


- (LJNetworkRequest*)createRequestWithUrl:(NSString*)url
                               paramaters:(NSDictionary*)params
                               methodType:(HttpMethodType)methodType
                               modelClass:(Class)modelClass
                                taskBlock:(NSURLSessionDataTask*(^)(LJNetworkRequest*))taskBlock
{
    LJNetworkRequest *request = [[LJNetworkRequest alloc] init];
    request.body = [[NSMutableDictionary alloc] initWithDictionary:params];
    request.header = [[NSMutableDictionary alloc] init];
    request.url = [url copy];
    request.methodType = methodType;
    request.modelClass = modelClass;


    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.configRequest)
        {
            self.configRequest(request);
        }

        if (self.willSendRequest)
        {
            self.willSendRequest(request);
        }
        request.task = taskBlock(request);
    });

    return request;
}


- (LJNetworkRequest*)getWithUrl:(NSString *)url
                     parameters:(NSDictionary *)params
                     modelClass:(__unsafe_unretained Class)modelClass
                     completion:(void (^)(id, NSError *))completion {
    if (!url)
    {
        return nil;
    }

    return [self createRequestWithUrl:url
                           paramaters:params
                           methodType:HttpMethodTypeGET
                           modelClass:modelClass
                            taskBlock:^NSURLSessionDataTask *(LJNetworkRequest *request){
                                id completionBlock = [self completionBlockWithRequest:request
                                                                      completionBlock:completion];
                                return [_dataSource GET:url
                                                 header:request.header
                                             parameters:request.body
                                               progress:nil
                                             completion:completionBlock];
                            }];
}

- (LJNetworkRequest *)postWithUrl:(NSString *)url
                       parameters:(NSDictionary *)params
                       modelClass:(__unsafe_unretained Class)modelClass
                       completion:(void (^)(id, NSError *))completion {
    return [self postWithUrl:url
                  parameters:params
                  modelClass:modelClass
            constructingBody:nil
                    progress:nil
                  completion:completion];
}

- (LJNetworkRequest *)postWithUrl:(NSString *)url
                       parameters:(NSDictionary *)params
                       modelClass:(__unsafe_unretained Class)modelClass
                 constructingBody:(void (^)(id<AFMultipartFormData>))constructingBody
                         progress:(void (^)(NSProgress *))progress
                       completion:(void (^)(id, NSError *))completion {
    if (!url)
    {
        return nil;
    }

    constructingBody = [constructingBody copy];
    return
    [self createRequestWithUrl:url
                    paramaters:params
                    methodType:HttpMethodTypePOST
                    modelClass:modelClass
                     taskBlock:^NSURLSessionDataTask *(LJNetworkRequest *request) {
                         id completionBlock = [self completionBlockWithRequest:request
                                                               completionBlock:completion];
                         if (constructingBody)
                         {
                             return
                             [_dataSource POST:url
                                        header:request.header
                                 urlParameters:nil
                                bodyParameters:request.body
                     constructingBodyWithBlock:constructingBody
                                      progress:progress
                                    completion:completionBlock];
                         }
                         else
                         {
                             return [_dataSource POST:url
                                               header:request.header
                                        urlParameters:nil
                                       bodyParameters:request.body
                                             progress:progress
                                           completion:completionBlock];
                         }
                    }];
}

#pragma mark - private methods
- (void(^)(id,NSError*))completionBlockWithRequest:(LJNetworkRequest*)request
                                      completionBlock:(void(^)(id,NSError*))completionBlock
{
    completionBlock = [completionBlock copy];
    void (^URLCompletion) (id resObj, NSError *error) = ^(id resObj, NSError *error) {
        if (!completionBlock)
        {
            return ;
        }
        
        LJNetworkResponse *response = [[LJNetworkResponse alloc] init];
        response.modelClass = request.modelClass;
        response.responseData = resObj;
        response.error = error;
        response.userInfo = request.userInfo;
        if ([request.task.response respondsToSelector:@selector(allHeaderFields)])
        {
            response.header = [((id)request.task.response) allHeaderFields];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.handleResponse)
            {
                self.handleResponse(response);
            }
            completionBlock(response.responseData,response.error);
        });
    };
    return [URLCompletion copy];
}

@end
