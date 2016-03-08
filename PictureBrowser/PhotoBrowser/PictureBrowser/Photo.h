//
//  Photo.h
//  PictureBrowser
//
//  Created by admin on 15/6/9.
//  Copyright (c) 2015年 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoProtocol.h"
//#import "AFNetworking.h"

typedef void (^ProgressUpdateBlock)(CGFloat progress);

@interface Photo : NSObject <PhotoProtocol>

@property (nonatomic,strong) NSURL *photoURL;
@property (nonatomic,copy) ProgressUpdateBlock progressUpdateBlock;

+ (Photo *)photoWithImage:(UIImage *)image;
+ (Photo *)photoWithFilePath:(NSString *)filePath;
+ (Photo *)photoWithURL:(NSURL *)url;

+ (NSArray *)photoWithImages:(NSArray *)images;
+ (NSArray *)photoWithFilePaths:(NSArray *)filePaths;
+ (NSArray *)photoWithURLs:(NSArray *)urls;

- (instancetype)initWithImage:(UIImage *)image;
- (instancetype)initWithFilePath:(NSString *)filePath;
- (instancetype)initWithURL:(NSURL *)url;


@end
