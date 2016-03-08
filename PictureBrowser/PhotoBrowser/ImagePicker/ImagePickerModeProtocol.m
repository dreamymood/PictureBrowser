//
//  ImagePickerModeProtocol.m
//  PictureBrowser
//
//  Created by admin on 16/2/24.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "ImagePickerModeProtocol.h"

@implementation ImagePickerModeProtocol

+ (instancetype)sharedInstance {
    static ImagePickerModeProtocol *imagePickerModeProtocol;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imagePickerModeProtocol = [[ImagePickerModeProtocol alloc] init];
    });
    return imagePickerModeProtocol;
}

- (instancetype)init {
    if (self = [super init]) {
        self.imagePickerMode = ImagePickerModeNone;
    }
    return self;
}

@end
