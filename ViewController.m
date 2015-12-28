

#import "ViewController.h"
#import "YGPCache.h"
#import "YGPURLSessionManager.h"
#import "UIImageView+YGPWebImage.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(100, 300, 100, 100)];
    [self.view addSubview:imageView];
    
    UIImage * image = [UIImage imageNamed:@"1.jpg"];
    
    
    [[YGPCache sharedManager] setImageToDiskWithImage:image forKey:@"aa"];
    
    [[YGPCache sharedManager]imageFromDiskForKey:@"aa" block:^(UIImage *image, NSString *key) {
        NSLog(@"%@",image);
        [imageView setImage:image];
        
    }];
    
    //    NSData *data =[YGPCache dataWithImageObject:image];
    //    [[YGPCache sharedManager]setDataToMemoryWithData:data forKey:@"cc"];
    //    [[YGPCache sharedManager]setDataToDiskWithData:data forKey:@"aa"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
