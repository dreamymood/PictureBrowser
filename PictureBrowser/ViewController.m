//
//  ViewController.m
//  PictureBrowser
//
//  Created by admin on 16/3/8.
//  Copyright © 2016年 Dreamymood. All rights reserved.
//

#import "ViewController.h"
#import "ImagePickerNavViewController.h"

@interface ViewController () <ImagePickerNavViewControllerDelegate>

@property (nonatomic, strong) UIButton *showPhotosPicker;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.showPhotosPicker];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIButton *)showPhotosPicker {
    if (!_showPhotosPicker) {
        _showPhotosPicker = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
        _showPhotosPicker.center = self.view.center;
        _showPhotosPicker.backgroundColor = [UIColor grayColor];
        [_showPhotosPicker setTitle:@"Open Photo Picker" forState:UIControlStateNormal];
        [_showPhotosPicker addTarget:self action:@selector(openPhotoPicker:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _showPhotosPicker;
}

#pragma mark - button event
- (void)openPhotoPicker:(UIButton *)button {
    ImagePickerNavViewController *imagePicker = [[ImagePickerNavViewController alloc] initWithImagePickerMode:ImagePickerModeUseOriginalImage];
    imagePicker.pickerDelegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - imagepickerDelegate
- (NSInteger)numberOfSelectedImageOfImagePickerNavViewControllerDelegate:(ImagePickerNavViewController *)imagePickerController {
    return 4;
}

- (void)imagePickerNavViewControllerDelegate:(ImagePickerNavViewController *)imagePickerController didFinishPickingMedias:(NSArray *)medias useOriginalImage:(BOOL)useOriginalImage {
    NSString *message = [NSString stringWithFormat:@"It is used original image:%d\nimage urls:%@",useOriginalImage, medias];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tip" message:message delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil];
    [alert show];
}

@end
