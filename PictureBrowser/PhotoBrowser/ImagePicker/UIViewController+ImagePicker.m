//
//  UIViewController+ImagePicker.m
//  ImagePickerNew
//
//  Created by admin on 15/6/3.
//  Copyright (c) 2015年 admin. All rights reserved.
//

#import "UIViewController+ImagePicker.h"

@implementation UIViewController (ImagePicker)

- (void)createBarButtonItemAtPositon:(NavigationBarButtonPosition)position normalImage:(UIImage *)normalImage highlightImage:(UIImage *)highlightImage action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIEdgeInsets insets = UIEdgeInsetsZero;
    switch (position) {
        case NavigationBarButtonPositionLeft:
            insets = UIEdgeInsetsMake(0, -20, 0, 20);
            break;
        case NavigationBarButtonPositionRight:
            insets = UIEdgeInsetsMake(0, 13, 0, -13);
            break;
        default:
            break;
    }
    
    [button setImageEdgeInsets:insets];
    [button setFrame:CGRectMake(0, 0, 44, 44)];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [button setImage:normalImage forState:UIControlStateNormal];
    [button setImage:highlightImage forState:UIControlStateHighlighted];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    switch (position) {
        case NavigationBarButtonPositionLeft:
            self.navigationItem.leftBarButtonItem = buttonItem;
            break;
        case NavigationBarButtonPositionRight:
            self.navigationItem.rightBarButtonItem = buttonItem;
            break;
        default:
            break;
    }
}

- (void)createBarButtonItemAtPositon:(NavigationBarButtonPosition)position text:(NSString *)text action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIEdgeInsets insets = UIEdgeInsetsZero;
    switch (position) {
        case NavigationBarButtonPositionLeft:
            insets = UIEdgeInsetsMake(0, - 49 + 26, 0, 19);
            break;
        case NavigationBarButtonPositionRight:
            insets = UIEdgeInsetsMake(0, 49 - 26, 0, - 19);
            break;
        default:
            break;
    }
    
    [button setTitleEdgeInsets:insets];
    [button setFrame:CGRectMake(0, 0, 64, 34)];
    [button setTitle:text forState:UIControlStateNormal];
    button.titleLabel.font = [button.titleLabel.font fontWithSize:15];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor greenColor] forState:UIControlStateHighlighted];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    switch (position) {
        case NavigationBarButtonPositionLeft:
            self.navigationItem.leftBarButtonItem = buttonItem;
            break;
        case NavigationBarButtonPositionRight:
            self.navigationItem.rightBarButtonItem = buttonItem;
            break;
        default:
            break;
    }
}

@end
