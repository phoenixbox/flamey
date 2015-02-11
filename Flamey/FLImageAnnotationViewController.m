//
//  FLImageAnnotationViewController.m
//  Flamey
//
//  Created by Shane Rogers on 2/11/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLImageAnnotationViewController.h"

// Pods
#import <SDWebImage/UIImageView+WebCache.h>


@interface FLImageAnnotationViewController ()

@property (nonatomic, strong) UIImage *facebookImage;

@end

@implementation FLImageAnnotationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [_photoImageView sd_setImageWithURL:[NSURL URLWithString:self.selectedPhoto.URL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        NSLog(@"imageView phto set");

        _facebookImage = image;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
