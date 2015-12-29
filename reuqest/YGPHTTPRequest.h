

#import <Foundation/Foundation.h>
#import "YGPURLSessionManager.h"
@interface YGPHTTPRequest : NSObject
@property (nonatomic,strong)NSURLSessionConfiguration *sessionConfiguration;
@property (nonatomic,strong)NSMutableDictionary *sessionSet;

+ (instancetype)sharedRequest;
- (YGPURLSessionManager*)downLoadImageURL:(NSURL*)url
                                 progress:(YGPWebImageDownloaderProgressBlock)progres
                                 complete:(YGPWebImageDownloadeCompleteBlock)complete;

- (YGPURLSessionManager*)GET:(NSString*)url
                      params:(NSDictionary*)params
                     success:(YGPRequestSuccessBlock)success
                     failure:(YGPRequestFailureBlock)failure;

- (YGPURLSessionManager*)GET:(NSString*)url
                     success:(YGPRequestSuccessBlock)success
                     failure:(YGPRequestFailureBlock)failure;

- (void)cancelRequest:(NSURL*)url;
@end
