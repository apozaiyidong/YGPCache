

#import <UIKit/UIKit.h>
#import "YGPURLSessionManager.h"

typedef NS_ENUM(NSInteger, YGPImageCacheOperation){
    YGPImageCacheNone,
    YGPImageCacheMemory,
    YGPImageCacheDisk,
};

typedef void(^YGPWebImageDownLoadComplete)(NSData *data ,NSURL *url,NSError *error);

@interface UIImageView (YGPWebImage)

- (NSURL*)YGP_imageURL;

- (void)YGP_setImageWithURL:(NSURL *)url;

- (void)YGP_setImageWithURL:(NSURL *)url
           placeholderImage:(UIImage *)placeholder;

- (void)YGP_setImageWithURL:(NSURL *)url
           placeholderImage:(UIImage *)placeholder
                   complete:(YGPWebImageDownLoadComplete)complete;

- (void)YGP_setImageWithURL:(NSURL *)url
           placeholderImage:(UIImage *)placeholder
             cacheOperation:(YGPImageCacheOperation)cacheOperation
                   progress:(YGPWebImageDownloaderProgressBlock)progres
                   complete:(YGPWebImageDownLoadComplete)complete;
/**
 *  取消请求
 */
- (void)cancel;
@end
