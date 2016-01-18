



#import "YGPCacheMemory.h"
#import <UIKit/UIKit.h>

#pragma mark memory cache
@interface YGPMemoryCacheNode : NSObject
{
    @public
    NSString       *_key;
    NSUInteger     _accessedCount;//object access count
    BOOL           _isEvitable;
}

@end
@implementation YGPMemoryCacheNode

@end
static NSUInteger  const YGPCacheCacheMemoryObjLimit    = 35; //max count
static NSString   *const YGPCacheAttributeListName      = @"YGPCacheAttributeList";
static char       *const YGPCacheMemoryIOQueue          = "YGPCacheMemoryIOQueue";

@interface YGPCacheMemory ()
{
    NSMutableDictionary *_objects;
    NSMutableDictionary *_cacheNode;
    NSUInteger           _totalAccessed;
}

@property (nonatomic,strong) dispatch_queue_t memoryIoQueue;
@end

@implementation YGPCacheMemory

+ (instancetype)sharedMemory{
    
    static YGPCacheMemory *_ygp_YGPCacheMemory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _ygp_YGPCacheMemory = [[YGPCacheMemory alloc]init];
    });
    return _ygp_YGPCacheMemory;
}

- (instancetype)init{
    
    self = [super init];
    
    if (self) {
        
        _objects               = [[NSMutableDictionary alloc]init];
        _cacheNode             = [[NSMutableDictionary alloc]init];
        _totalAccessed         = 0;
        
        _memoryCacheCostLimit = YGPCacheCacheMemoryObjLimit;
        _memoryIoQueue         = dispatch_queue_create(YGPCacheMemoryIOQueue, DISPATCH_QUEUE_SERIAL);
        
        [[NSNotificationCenter defaultCenter]addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * __unused note) {
            [self removeAllData];
        }];
        
        [[NSNotificationCenter defaultCenter]addObserverForName:UIApplicationWillTerminateNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * __unused note) {
            [self removeAllData];
        }];
        
        [[NSNotificationCenter defaultCenter]addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * __unused note) {
            [self removeAllData];
        }];
        

        
    }
    return self;
}

- (void)setMemoryCacheCostLimit:(NSUInteger)memoryCacheCostLimit{
    _memoryCacheCostLimit = memoryCacheCostLimit;
}

- (void)setObject:(id)object forKey:(NSString *)key{
    
    [self setObject:object forKey:key isEvitable:NO costLimit:_memoryCacheCostLimit];
    
}

- (void)setObject:(id)object forKey:(NSString *)key isEvitable:(BOOL)isEvitable costLimit:(NSUInteger)costLimit{
    
    if (![key length] ||!object) {return;}
    
    dispatch_async(_memoryIoQueue, ^{
        
        YGPMemoryCacheNode *oldCacheNode = _objects[key];
        YGPMemoryCacheNode *newCacheNode = nil;
        
        if (oldCacheNode) {
            [_objects   removeObjectForKey:key];
            [_cacheNode removeObjectForKey:key];
            [self setTotalAccessed:key];
        }
        
        [self cacheObjectManagerWithcostLimit:costLimit];

        newCacheNode = [YGPMemoryCacheNode new];
        newCacheNode->_key = key;
        newCacheNode->_accessedCount ++;
        newCacheNode->_isEvitable = isEvitable;
        
        [_objects   setObject:object       forKey:key];
        [_cacheNode setObject:newCacheNode forKey:key];
        
    });

}

- (id)objectForKey:(NSString *)key{

    if (![key length]) {return nil;}
    
    __block id cacheData = nil;
    
    dispatch_sync(_memoryIoQueue, ^{
        
        cacheData = _objects[key];
        
        YGPMemoryCacheNode *cacheNodeObject = _cacheNode[key];
        cacheNodeObject->_accessedCount ++;
        [_cacheNode removeObjectForKey:key];
        [_cacheNode setObject:cacheNodeObject forKey:key];
        _totalAccessed ++;
        
    });
    
    return cacheData;
}

- (void)removeAllData{
    
    dispatch_async(_memoryIoQueue, ^{
        
        [_objects      removeAllObjects];
        [_cacheNode    removeAllObjects];
        _totalAccessed = 0;
        
    });
    
}

- (void)removeDataForKey:(NSString*)key{
    
    if (![key length]) {return;}
    
    dispatch_async(_memoryIoQueue, ^{
        
        [self setTotalAccessed:key];
        
        [_objects   removeObjectForKey:key];
        [_cacheNode removeObjectForKey:key];
        
    });
}

- (BOOL)containsDataForKey:(NSString*)key{
    
    __block BOOL isContains = NO;
    
    dispatch_sync(_memoryIoQueue, ^{
        
        if (_objects[key]) {isContains = YES;}
        
    });
    
    return isContains;
}

- (void)setTotalAccessed:(NSString*)key{
    
    YGPMemoryCacheNode *cacheNode = _cacheNode[key];
    if (cacheNode) {
        _totalAccessed -=cacheNode->_accessedCount;
    }
}

/*
 
 */
- (void)cacheObjectManagerWithcostLimit:(NSUInteger)costLimit{
    
    NSUInteger count = [_objects count];
    
    //移除近期不访问
    if (count >= costLimit) {
        
        NSUInteger averageAccessed = _totalAccessed / count + 1;

        [_cacheNode enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            
            YGPMemoryCacheNode *cacheNode = obj;
            if (cacheNode) {
                
                if (cacheNode->_accessedCount <= averageAccessed && !cacheNode->_isEvitable) {

                    [_objects   removeObjectForKey:key];
                    [_cacheNode removeObjectForKey:key];
                }
            }
        }];
    }
}

@end



