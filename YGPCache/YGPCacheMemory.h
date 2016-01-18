

#import <Foundation/Foundation.h>

@interface YGPCacheMemory : NSObject
@property (nonatomic,assign)NSUInteger memoryCacheCostLimit;

+ (instancetype)sharedMemory;

- (void)setObject:(id)object forKey:(NSString*)key;
- (void)setObject:(id)object forKey:(NSString*)key isEvitable:(BOOL)isEvitable costLimit:(NSUInteger)costLimit;

- (id)objectForKey:(NSString*)key;

- (void)removeDataForKey:(NSString*)key;
- (void)removeAllData;

- (BOOL)containsDataForKey:(NSString*)key;





@end
