//
//  ViewController.m
//  symbolicLinkTest
//
//  Created by ATM on 2017/8/16.
//  Copyright © 2017年 ATM. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageV;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"mp4"];
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *uuid = nil;
    uuid = [[NSUserDefaults standardUserDefaults] objectForKey:@"uuid"];
    NSString *videoPath = nil;
    if (!uuid) {
        uuid = [[NSUUID UUID] UUIDString];
        [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:@"uuid"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    videoPath = [documentPath stringByAppendingPathComponent:uuid];
    if ([fileManager fileExistsAtPath:[documentPath stringByAppendingPathComponent:@"test"]]) {
        [fileManager removeItemAtPath:[documentPath stringByAppendingPathComponent:@"test"] error:nil];
    }
    [fileManager createDirectoryAtPath:[documentPath stringByAppendingPathComponent:@"test"] withIntermediateDirectories:YES
                            attributes:nil error:nil];
    //remove symbolicLink if exist
    NSString *testPath = [documentPath stringByAppendingPathComponent:@"test"];
    NSString *symbolicLinkPath = [testPath stringByAppendingPathComponent:[uuid stringByAppendingPathExtension:@"mp4"]];
    NSLog(@"videoPath:%@",videoPath);
    if (![fileManager fileExistsAtPath:videoPath]) {
       [fileManager copyItemAtPath:path toPath:videoPath error:nil];
    }
    //create symbolicLink
    [fileManager createSymbolicLinkAtPath:symbolicLinkPath withDestinationPath:videoPath error:nil];
    //get thumbnail image of video
    AVURLAsset *avUrlAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:symbolicLinkPath] options:nil];
    AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:avUrlAsset];
    generate.appliesPreferredTrackTransform = YES;
    NSError *err = NULL;
    CMTime time = CMTimeMake(1, 60);
    CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
    UIImage *image = [[UIImage alloc] initWithCGImage:imgRef];
    self.imageV.image = image;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
