//
//  AssetsGroupBottomView.h
//  PictureBrowser
//
//  Created by admin on 15/12/25.
//  Copyright (c) 2015年 Daniel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef NS_ENUM(NSInteger, AssetsGroupBottomViewMode) {
    AssetsGroupBottomViewModeNone = 0,
    AssetsGroupBottomViewModePreview,
    AssetsGroupBottomViewModeOriginShow,
};

@protocol AssetsGroupBottomViewDelegate;

@interface AssetsGroupBottomView : UIView

@property (nonatomic, assign) id <AssetsGroupBottomViewDelegate> delegate;

@property (nonatomic, assign) AssetsGroupBottomViewMode displayMode;
@property (nonatomic, assign) NSInteger currentIndex;

- (void)resetAllAssetURLs:(NSArray *)allAssetURLs;

- (void)insertAssetURL:(NSString *)assetURL;
- (void)removeAssetURL:(NSString *)assetURL;

- (NSArray *)allSelectedAssets;
- (NSInteger)numberOfSelectedAssets;

- (void)changeOriginalImageButtonState:(BOOL)selected;

@end


@protocol AssetsGroupBottomViewDelegate <NSObject>

- (void)assetsGroupBottomView:(AssetsGroupBottomView *)bottomView didTouchPreviewButton:(UIButton *)previewButton;
- (void)assetsGroupBottomView:(AssetsGroupBottomView *)bottomView didTouchFinishButton:(UIButton *)finishButton;

- (void)assetsGroupBottomView:(AssetsGroupBottomView *)bottomView didTouchUseOriginalImageButton:(UIButton *)button selected:(BOOL)selected;

@end
