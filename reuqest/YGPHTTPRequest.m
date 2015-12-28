

#import "YGPHTTPRequest.h"


@interface YGPHTTPRequest ()
@property (nonatomic,strong)YGPURLSessionManager *sessionManager;

@end
@implementation YGPHTTPRequest

+ (instancetype)sharedRequest{

    static YGPHTTPRequest *ygp_YGPHTTPRequest = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ygp_YGPHTTPRequest = [[YGPHTTPRequest alloc]init];
    });
    
    return ygp_YGPHTTPRequest;
}

- (instancetype)init{

    self = [super init];
    if (self) {
        
        self.sessionSet = [[NSMutableDictionary alloc]init];
        
    }
    return self;
}

- (YGPURLSessionManager*)downLoadImageURL:(NSURL*)url
                progress:(YGPWebImageDownloaderProgressBlock)progres
                complete:(YGPWebImageDownloadeCompleteBlock)complete{
    
    YGPURLSessionManager *sessionManager = [[YGPURLSessionManager alloc]initSessionWitiSessionConfiguration:self.sessionConfiguration progress:progres complete:complete];
    
    [sessionManager downLoadTaskURL:url];
    
    [self.sessionSet setObject:sessionManager forKey:[url absoluteString]];
    
    return sessionManager;
    
}

- (void)cancelRequest:(NSURL*)url{

    if (_sessionSet[[url absoluteString]]) {
        YGPURLSessionManager *sessionManager = _sessionSet[[url absoluteString]];
        [sessionManager cancel];
        [_sessionSet removeObjectForKey:[url absoluteString]];
    }
}
@end
