# YGPCache
可以将数据保存到内存或磁盘

查找缓存数据 内存 -> 磁盘
获取数据时如果数据保存在磁盘里，会将数据放置在内存中。供下次快速读取。

获取内存的缓存数据时会将其移动到缓存队列的最顶端，队列内越后的数据就是调用次数最少的。
同时设置一个内存 LIMIT 最大值，当缓存数超过了最大值，每次有新的数据进入列队就会将列队
的最后一个缓存数据移除掉。每个缓存数据都会组建成一个结构体里面包含 （访问次数 ，访问时间）。

每隔3分钟（当获取内存数据时做时间判断）就会查找缓存数据，将访问次数最少和访问时间离现在最久的数据将其出列


保存数据
[[YGPCache sharedManager]setDataToDiskWithData:data forKey:@"YGPCache"];

获取保存的数据
[[YGPCache sharedManager]dataFromDiskForKey:@"" block:^(NSData *data, NSString *key) {
      //block 返回的数据
    }];
    

