//
//  UIViewController+ImagePicker.h
//  ImagePickerNew
//
//  Created by admin on 15/6/3.
//  Copyright (c) 2015年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NavigationBarButtonPosition) {
    NavigationBarButtonPositionLeft,
    NavigationBarButtonPositionRight
};

@interface UIViewController (ImagePicker)

- (void)createBarButtonItemAtPositon:(NavigationBarButtonPosition)position normalImage:(UIImage *)normalImage highlightImage:(UIImage *)highlightImage action:(SEL)action;
- (void)createBarButtonItemAtPositon:(NavigationBarButtonPosition)position text:(NSString *)text action:(SEL)action ;

@end
