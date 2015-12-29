

#import "YGPURLSessionManager.h"

static NSString *const YGPRequestHTTPMethodGET  = @"GET";
static NSString *const YGPRequestHTTPMethodPOST = @"POST";

@interface YGPURLSessionManager () <NSURLSessionDataDelegate,NSURLSessionDelegate,NSURLSessionDownloadDelegate>

@end
@implementation YGPURLSessionManager

- (instancetype)initSessionWitiSessionConfiguration:(nullable NSURLSessionConfiguration*)configuration {
    
    self = [super init];
    
    if (self) {
        
        if (!configuration) {
            configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        }
        
        self.OperationQueue = [[NSOperationQueue alloc]init];
        [self.OperationQueue  setMaxConcurrentOperationCount:1];
        
        self.session = [NSURLSession sessionWithConfiguration:configuration
                                                     delegate:self
                                                delegateQueue:self.OperationQueue];
        
        
    }
    return self;
}
#pragma mark Request Method

- (void)downLoadTaskURL:(NSURL*)url progress:(YGPWebImageDownloaderProgressBlock)progres
               complete:(YGPWebImageDownloadeCompleteBlock)complete{
    
    _webImageDownloadeCompleteBlock  = complete;
    _webImageDownloaderProgressBlock = progres;
    
    self.request      = [NSURLRequest requestWithURL:url];
    self.downLoadTask = [self.session downloadTaskWithRequest:_request];
    
    [_downLoadTask resume];
    
}

- (void)GET:(NSURL *)url success:(YGPRequestSuccessBlock)success failure:(YGPRequestFailureBlock)failure{
    [self GET:url params:nil success:success failure:failure];
}

- (void)GET:(NSURL *)url params:(NSDictionary *)params success:(YGPRequestSuccessBlock)success failure:(YGPRequestFailureBlock)failure{
    
    [self request:url method:YGPRequestHTTPMethodGET params:params success:success failure:failure];
    
}

- (void)request:(NSURL*)URL method:(NSString*)method params:(NSDictionary*)params success:(YGPRequestSuccessBlock)success failure:(YGPRequestFailureBlock)failure{
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:method];
    [request setTimeoutInterval:60];
    
    // setting HTTPBody
    id bodyData = [self setHTTPBody:params url:URL method:method];
    
    if ([bodyData isKindOfClass:[NSData class]]) { // POST
        
        [request setHTTPBody:bodyData];
        
    }else if ([bodyData isKindOfClass:[NSURL class]]){ //GET method
        
        request.URL = bodyData;
    }
    
    NSURLSessionDataTask *URLSessionDataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data) {
            
            NSError *jsonError = nil;
            __block id jsonObject = nil;
            
            if (data.length >0) {
                
                //JSON
                
                jsonObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                if (jsonError) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        jsonObject = data;
                    });
                }
                
                
            }
            
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    success(request,jsonObject);
                });
            }
            
        }//success
        
        if (error) {
            if (failure) {
                failure(request,error);
            }
        }//error
        
        
    }];
    
    [URLSessionDataTask resume];
}

- (id)setHTTPBody:(NSDictionary*)params url:(NSURL*)url method:(NSString*)method{
    
    NSMutableString *paramsString = nil;
    
    //请求体
    if (params) {
        
        paramsString = [[NSMutableString alloc]init];
        for (NSString *key in params) {
            [paramsString appendFormat:@"%@=%@&",key,params[key]];
        }
        
        if ([paramsString hasSuffix:@"&"]) {
            paramsString = [NSMutableString stringWithString:[paramsString substringToIndex:paramsString.length - 1]];
        }
    }
    
    //GET Method 将参数链接到URL尾部
    if ([method isEqualToString:YGPRequestHTTPMethodGET] && params) {
        
        NSString *connector = [url query] ? @"&" : @"?";
        NSString *urlString = [NSString stringWithFormat:@"%@%@%@",[url absoluteString],connector,paramsString];
        NSURL *newUrl = [NSURL URLWithString:urlString];
        
        return newUrl;
    }
    
    return [paramsString dataUsingEncoding:NSUTF8StringEncoding];
}






#pragma mark NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
    if (_webImageDownloaderProgressBlock) {
        self.webImageDownloaderProgressBlock(totalBytesWritten,totalBytesExpectedToWrite);
    }
    
}
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location{
    
    if (_webImageDownloadeCompleteBlock) {
        _webImageDownloadeCompleteBlock(location,_request.URL,nil);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error{
    
    //取消一个请求会报错 cancelled
    //    BOOL isCancelled = [error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"cancelled"];
    
    if (error) {
        if (_webImageDownloadeCompleteBlock) {
            _webImageDownloadeCompleteBlock(nil,_request.URL,error);
        }
    }
}

- (void)cancel{
    [self.session invalidateAndCancel];
}

@end
