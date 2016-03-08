//
//  Photo.m
//  PictureBrowser
//
//  Created by admin on 15/6/9.
//  Copyright (c) 2015年 Daniel. All rights reserved.
//

#import "Photo.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface Photo () {
    UIImage *_underlyingImage;
    BOOL _loadingInProgress;
}

@property (nonatomic,strong) UIImage *underlyingImage;

- (void)imageLoadingComplete;

@end

@implementation Photo

+ (Photo *)photoWithImage:(UIImage *)image {
    return [[Photo alloc] initWithImage:image];
}

+ (Photo *)photoWithFilePath:(NSString *)filePath {
    return [[Photo alloc] initWithFilePath:filePath];
}

+ (Photo *)photoWithURL:(NSURL *)url {
    return [[Photo alloc] initWithURL:url];
}

+ (NSArray *)photoWithImages:(NSArray *)images {
    NSMutableArray *photos = [[NSMutableArray alloc] initWithCapacity:images.count];
    for (UIImage *image in images) {
        if ([image isKindOfClass:[UIImage class]]) {
            Photo *photo = [[Photo alloc] initWithImage:image];
            [photos addObject:photo];
        }
    }
    return photos;
}

+ (NSArray *)photoWithFilePaths:(NSArray *)filePaths {
    NSMutableArray *photos = [[NSMutableArray alloc] initWithCapacity:filePaths.count];
    for (NSString *filePath in filePaths) {
        if ([filePath isKindOfClass:[NSString class]]) {
            Photo *photo = [[Photo alloc] initWithFilePath:filePath];
            [photos addObject:photo];
        }
    }
    return photos;
}

+ (NSArray *)photoWithURLs:(NSArray *)urls {
    NSMutableArray *photos = [[NSMutableArray alloc] initWithCapacity:urls.count];
    for (id url in urls) {
        if ([url isKindOfClass:[NSString class]]) {
            Photo *photo = [[Photo alloc] initWithURL:[NSURL URLWithString:url]];
            [photos addObject:photo];
        } else if ([url isKindOfClass:[NSURL class]]) {
            Photo *photo = [[Photo alloc] initWithURL:url];
            [photos addObject:photo];
        }
    }
    return photos;
}

#pragma mark -object
- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        self.underlyingImage = image;
    }
    return self;
}

- (instancetype)initWithFilePath:(NSString *)filePath {
    self = [super init];
    if (self) {
        self.photoURL = [NSURL fileURLWithPath:filePath];
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        self.photoURL = [url copy];
    }
    return self;
}

#pragma mark -PotoProtocol
- (UIImage *)underlyingImage {
    return _underlyingImage;
}

- (void)loadUnderlyingImageAndNotify {
    _loadingInProgress = YES;
    if (self.underlyingImage) {
        [self imageLoadingComplete];
    } else {
        if ([_photoURL isFileReferenceURL]) {
            [self performSelector:@selector(loadImageFromFileAsync) withObject:nil];
        } else if ([[[_photoURL scheme] lowercaseString] isEqualToString:@"assets-library"]) {
            @autoreleasepool {
                @try {
                    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
                    [assetsLibrary assetForURL:_photoURL resultBlock:^(ALAsset *asset) {
                        ALAssetRepresentation *rep = [asset defaultRepresentation];
                        CGImageRef iref = [rep fullScreenImage];
                        if (iref) {
                            self.underlyingImage = [UIImage imageWithCGImage:iref];
                        }
//                        self.underlyingImage = [self decodedImageWithImage:self.underlyingImage];
                        [self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
                    } failureBlock:^(NSError *error) {
                        self.underlyingImage = nil;
                        [self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
                    }];
                }
                @catch (NSException *exception) {
                    [self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
                }
            }
        }
    }
}

- (void)unloadUnderlyingImage {
    _loadingInProgress = NO;
    if (self.underlyingImage && _photoURL) {
        self.underlyingImage = nil;
    }
}

- (UIImage *)decodedImageWithImage:(UIImage *)image {
    if (image.images) {
        return image;
    }
    CGImageRef imageRef = image.CGImage;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    CGRect imageRect = (CGRect){.origin = CGPointZero,.size = imageSize};
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    
    int infoMask = (bitmapInfo & kCGBitmapAlphaInfoMask);
    BOOL anyNonAlpha = (infoMask == kCGImageAlphaNone || infoMask == kCGImageAlphaNoneSkipFirst || infoMask == kCGImageAlphaNoneSkipLast);
    
    if (infoMask == kCGImageAlphaNone && CGColorSpaceGetNumberOfComponents(colorSpace) > 1) {
        bitmapInfo &= ~kCGBitmapAlphaInfoMask;
        
        bitmapInfo |= kCGImageAlphaNoneSkipFirst;
    }
    else if (!anyNonAlpha && CGColorSpaceGetNumberOfComponents(colorSpace) == 3) {
        bitmapInfo &= ~kCGBitmapAlphaInfoMask;
        
        bitmapInfo |= kCGImageAlphaPremultipliedFirst;
    }
    CGContextRef context = CGBitmapContextCreate(NULL, imageSize.width, imageSize.height, CGImageGetBitsPerComponent(imageRef), 0, colorSpace, bitmapInfo);
    
    CGColorSpaceRelease(colorSpace);
    
    if (!context) {
        return image;
    }
    
    CGContextDrawImage(context, imageRect, imageRef);
    CGImageRef decompressedImageRef = CGBitmapContextCreateImage(context);
    
    CGContextRelease(context);
    
    UIImage *decompressedImage = [UIImage imageWithCGImage:decompressedImageRef scale:image.scale orientation:image.imageOrientation];
    
    CGImageRelease(decompressedImageRef);
    
    return decompressedImage;
}

- (void)loadImageFromFileAsync {
    @autoreleasepool {
        @try {
            self.underlyingImage = [UIImage imageWithContentsOfFile:[_photoURL path]];
            if (!_underlyingImage) {
                NSLog(@"Error loading photo from path: %@",[_photoURL path]);
            }
        }
        @finally {
            self.underlyingImage = [self decodedImageWithImage:self.underlyingImage];
            [self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
        }
    }
}

- (void)imageLoadingComplete {
    _loadingInProgress = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:PHOTO_LOADING_DID_END_NOTIFICATION object:self];
}

@end
