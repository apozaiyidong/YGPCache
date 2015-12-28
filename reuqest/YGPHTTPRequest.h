

#import <Foundation/Foundation.h>
#import "YGPURLSessionManager.h"
@interface YGPHTTPRequest : NSObject
@property (nonatomic,strong)NSURLSessionConfiguration *sessionConfiguration;
@property (nonatomic,strong)NSMutableDictionary *sessionSet;

+ (instancetype)sharedRequest;
- (YGPURLSessionManager*)downLoadImageURL:(NSURL*)url
                progress:(YGPWebImageDownloaderProgressBlock)progres
                complete:(YGPWebImageDownloadeCompleteBlock)complete;

- (void)cancelRequest:(NSURL*)url;
@end
