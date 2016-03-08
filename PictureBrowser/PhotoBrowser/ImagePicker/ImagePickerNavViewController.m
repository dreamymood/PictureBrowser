//
//  ImagePickerNavViewController.m
//  ImagePickerNew
//
//  Created by admin on 15/6/3.
//  Copyright (c) 2015年 admin. All rights reserved.
//

#import "ImagePickerNavViewController.h"

//版本支持
#define IOS_VERSION_MORE_THAN(__VERSIONSTRING) ([[[UIDevice currentDevice]systemVersion]compare:__VERSIONSTRING options:NSNumericSearch]==NSOrderedDescending)

@interface ImagePickerNavViewController () <UIGestureRecognizerDelegate,UINavigationControllerDelegate,ImagePickerControllerDelegate>

@property (nonatomic,assign) id <UINavigationControllerDelegate> navDelegate;
@property (nonatomic,assign) BOOL isDuringPushAnimation;

@end

@implementation ImagePickerNavViewController

- (instancetype)initWithImagePickerMode:(ImagePickerMode)mode {
    if (self = [super init]) {
        [ImagePickerModeProtocol sharedInstance].imagePickerMode = mode;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.delegate) {
        self.delegate = self;
    }
    if (IOS_VERSION_MORE_THAN(@"7.0")) {
        self.interactivePopGestureRecognizer.delegate = self;
    }
    
    ImagePickerController *imagePickerController = [[ImagePickerController alloc] init];
    imagePickerController.delegate = self;
    [self setViewControllers:@[imagePickerController]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (ImagePickerMode)imagePickerMode {
    return [[ImagePickerModeProtocol sharedInstance] imagePickerMode];
}

#pragma mark --UINavigationController
- (void)setDelegate:(id<UINavigationControllerDelegate>)delegate {
    [super setDelegate:delegate ? self : nil];
    self.navDelegate = delegate != self ? self : nil;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.isDuringPushAnimation = YES;
    [super pushViewController:viewController animated:animated];
}

#pragma mark --UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.isDuringPushAnimation = NO;
    if ([self.navDelegate respondsToSelector:_cmd]) {
        [self.navDelegate navigationController:navigationController didShowViewController:viewController animated:animated];
    }
}

#pragma mark --UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        return self.viewControllers.count > 1 && !self.isDuringPushAnimation;
    } else {
        return YES;
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [super respondsToSelector:aSelector] || [self.navDelegate respondsToSelector:aSelector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [super methodSignatureForSelector:aSelector] ? : [(id)self.navDelegate methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if ([self.navDelegate respondsToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:self.navDelegate];
    }
}

#pragma mark --ImagePickerControllerDelegate
- (void)imagePickerController:(ImagePickerController *)imagePickerController didTouchAsset:(ALAsset *)asset {
    if (_pickerDelegate && [_pickerDelegate respondsToSelector:@selector(imagePickerNavViewControllerDelegate:didTouchAsset:)]) {
        [_pickerDelegate imagePickerNavViewControllerDelegate:self didTouchAsset:asset];
    }
    NSLog(@"选中图片。。");
}

- (void)didCancelImagePickerController:(ImagePickerController *)imagePickerController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(ImagePickerController *)imagePickerController didFinishPickingMedias:(NSArray *)medias useOriginalImage:(BOOL)useOriginalImage {
    if (_pickerDelegate && [_pickerDelegate respondsToSelector:@selector(imagePickerNavViewControllerDelegate:didFinishPickingMedias:useOriginalImage:)]) {
        [_pickerDelegate imagePickerNavViewControllerDelegate:self didFinishPickingMedias:medias useOriginalImage:useOriginalImage];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSelectedImageOfImagePickerController:(ImagePickerController *)imagePickerController {
    if (_pickerDelegate && [_pickerDelegate respondsToSelector:@selector(numberOfSelectedImageOfImagePickerNavViewControllerDelegate:)]) {
        return [_pickerDelegate numberOfSelectedImageOfImagePickerNavViewControllerDelegate:self];
    }
    return DEFAULT_NUMBER_OF_SELECTED_IMAGE;
}

@end
