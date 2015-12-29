

#import <Foundation/Foundation.h>

typedef void(^YGPWebImageDownloaderProgressBlock)(NSInteger receivedSize,
                                                  NSInteger expectedSize);

typedef void(^YGPWebImageDownloadeCompleteBlock)(NSURL *location,
                                                 NSURL *downLoadURL,
                                                 NSError *error);

typedef void(^YGPRequestSuccessBlock)(NSURLRequest *urlRequest, id responseData);
typedef void(^YGPRequestFailureBlock)(NSURLRequest *urlRequest, NSError *error);

@interface YGPURLSessionManager : NSObject

@property (nonatomic,strong)NSURLSession             *session;
@property (nonatomic,copy)  NSURLRequest             *request;
@property (nonatomic,strong)NSOperationQueue         *OperationQueue;
@property (nonatomic,strong)NSURLSessionDownloadTask *downLoadTask;

@property (nonatomic,copy)  YGPWebImageDownloaderProgressBlock webImageDownloaderProgressBlock;
@property (nonatomic,copy)  YGPWebImageDownloadeCompleteBlock
webImageDownloadeCompleteBlock;


- (instancetype)initSessionWitiSessionConfiguration:(NSURLSessionConfiguration*)configuration;

- (void)GET:(NSURL*)url
     params:(NSDictionary*)params
    success:(YGPRequestSuccessBlock)success
    failure:(YGPRequestFailureBlock)failure;

- (void)GET:(NSURL*)url
    success:(YGPRequestSuccessBlock)success
    failure:(YGPRequestFailureBlock)failure;

- (void)downLoadTaskURL:(NSURL*)url
               progress:(YGPWebImageDownloaderProgressBlock)progres
               complete:(YGPWebImageDownloadeCompleteBlock)complete;
- (void)cancel;
@end
