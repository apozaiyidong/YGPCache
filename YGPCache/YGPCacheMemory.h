

#import <Foundation/Foundation.h>

@interface YGPCacheMemory : NSObject
@property (nonatomic,assign)NSUInteger memoryCacheCountLimit;

+ (instancetype)sharedMemory;

- (void)setData:(NSData*)data forKey:(NSString*)key;

- (NSData*)dataForKey:(NSString*)key;

- (void)removeDataForKey:(NSString*)key;

- (void)removeAllData;

- (BOOL)containsDataForKey:(NSString*)key;

- (void)setObject:(id)object forKey:(NSString*)key;
- (id)objectForKey:(NSString*)key;

@end
