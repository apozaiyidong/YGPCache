

#import <Foundation/Foundation.h>

typedef void(^YGPWebImageDownloaderProgressBlock)(NSInteger receivedSize, NSInteger expectedSize);
typedef void(^YGPWebImageDownloadeCompleteBlock)(NSURL *location, NSURL *downLoadURL ,NSError *error);

@interface YGPURLSessionManager : NSObject

@property (nonatomic,strong)NSURLSession *session;
@property (nonatomic,strong)NSURLRequest *request;
@property (nonatomic,strong)NSOperationQueue *OperationQueue;
@property (nonatomic,strong)NSURLSessionDownloadTask *downLoadTask;


@property (nonatomic,copy)  YGPWebImageDownloaderProgressBlock webImageDownloaderProgressBlock;
@property (nonatomic,copy)  YGPWebImageDownloadeCompleteBlock  webImageDownloadeCompleteBlock;

- (instancetype)initSessionWitiSessionConfiguration:(NSURLSessionConfiguration*)configuration progress:(YGPWebImageDownloaderProgressBlock)progres
                                           complete:(YGPWebImageDownloadeCompleteBlock)complete;

- (void)downLoadTaskURL:(NSURL*)url;
- (void)cancel;
@end
