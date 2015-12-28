

#import "YGPURLSessionManager.h"
#import <libkern/OSAtomic.h>
#import "YGPCache.h"

@interface YGPURLSessionManager () <NSURLSessionDataDelegate,NSURLSessionDelegate,NSURLSessionDownloadDelegate>
{
    OSSpinLock *_lock;

}
@end
@implementation YGPURLSessionManager

- (instancetype)initSessionWitiSessionConfiguration:(nullable NSURLSessionConfiguration*)configuration progress:(YGPWebImageDownloaderProgressBlock)progres
                                           complete:(YGPWebImageDownloadeCompleteBlock)complete{

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
        
        _webImageDownloadeCompleteBlock  = complete;
        _webImageDownloaderProgressBlock = progres;
    }
    return self;
}

- (void)downLoadTaskURL:(NSURL*)url{

    self.request      = [NSURLRequest requestWithURL:url];
    self.downLoadTask = [self.session downloadTaskWithRequest:_request];
    
    [_downLoadTask resume];
    
}

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
