

#import "UIImageView+YGPWebImage.h"
#import "YGPHTTPRequest.h"
#import "YGPCache.h"
#import <objc/runtime.h>

@implementation UIImageView (YGPWebImage)

- (void)YGP_setImageWithURL:(NSURL *)url{

    [self YGP_setImageWithURL:url
             placeholderImage:nil
               cacheOperation:YGPImageCacheMemory
                     progress:nil complete:nil];
}

- (void)YGP_setImageWithURL:(NSURL *)url
           placeholderImage:(UIImage *)placeholder{

    [self YGP_setImageWithURL:url
             placeholderImage:placeholder
               cacheOperation:YGPImageCacheMemory
                     progress:nil complete:nil];
    
}

- (void)YGP_setImageWithURL:(NSURL *)url
           placeholderImage:(UIImage *)placeholder
                   complete:(YGPWebImageDownLoadComplete)complete {

    [self YGP_setImageWithURL:url
             placeholderImage:placeholder
               cacheOperation:YGPImageCacheMemory
                     progress:nil complete:complete];
    
}

- (void)YGP_setImageWithURL:(NSURL *)url
           placeholderImage:(UIImage *)placeholder
             cacheOperation:(YGPImageCacheOperation)cacheOperation
                   progress:(YGPWebImageDownloaderProgressBlock)progres
                   complete:(YGPWebImageDownLoadComplete)complete{
    
    [self setImageURL:url];
    
    if (placeholder) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setImage:placeholder];
        });
    }
    
    __weak typeof(self) wSelf = self;

    [[YGPCache sharedManager]dataFromDiskForKey:[url absoluteString] block:^(NSData *data, NSString *key) {
        __strong typeof(wSelf) sSelf = wSelf;

        if (data) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [sSelf setImage:[UIImage imageWithData:data]];
                
                if (complete) {
                    complete(data,[self YGP_imageURL],nil);
                }
                
            });
            
        }else{
            
         [[YGPHTTPRequest sharedRequest] downLoadImageURL:url progress:progres complete:^(NSURL *location, NSURL *downLoadURL ,NSError *error) {
             
                __strong typeof(wSelf) sSelf = wSelf;
                
                if (wSelf) {
                    
                    NSData *data = [NSData dataWithContentsOfURL:location];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [sSelf setImage:[UIImage imageWithData:data]];
                        [[NSFileManager defaultManager]removeItemAtURL:location error:nil];
                        
                        if (complete) {
                            complete(data,[self YGP_imageURL],nil);
                        }
                        
                    });
                    
                    switch (cacheOperation) {
                        case YGPImageCacheMemory:
                            
                            [[YGPCache sharedManager] setDataToMemoryWithData:data forKey:[[self YGP_imageURL] absoluteString]];
                        
                            break;
                        case YGPImageCacheDisk:
                            
                            [[YGPCache sharedManager]setDataToDiskWithData:data forKey:[[self YGP_imageURL] absoluteString]];
                            
                            break;
                        default:
                            break;
                    }
                }
            }];
            [self cancel];
        }
    }];
}

- (void)cancel{

    [[YGPHTTPRequest sharedRequest]cancelRequest:[self YGP_imageURL]];
    
}

- (void)setImageURL:(NSURL*)url{
    objc_setAssociatedObject(self, @"imageURL", url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSURL*)YGP_imageURL{
    return objc_getAssociatedObject(self, @"imageURL");
}










@end
