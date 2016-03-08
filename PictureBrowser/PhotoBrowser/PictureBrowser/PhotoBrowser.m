//
//  PhotoBrowser.m
//  PictureBrowser
//
//  Created by admin on 15/6/9.
//  Copyright (c) 2015年 Daniel. All rights reserved.
//

#import "PhotoBrowser.h"
#import <QuartzCore/QuartzCore.h>
#import "ZoomingScrollView.h"
#import "UIViewController+ImagePicker.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "PhotoAssetCheckmarkView.h"
#import "AssetsGroupBottomView.h"
#import "ImagePickerModeProtocol.h"

#define PADDING                 10
#define PAGE_INDEX_TAG_OFFSET   1000
#define PAGE_INDEX(page)        ([(page) tag] - PAGE_INDEX_TAG_OFFSET)

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


@interface PhotoBrowser () <AssetsGroupBottomViewDelegate> {
    NSMutableArray *_photos;
    
    UIScrollView *_pagingScrollView;
    
    //paging
    NSMutableSet *_visiblePages, *_recycledPages;
    NSUInteger _currentPageIndex;
    
    //navigationBar
    UIBarButtonItem *_previousButton, *_nextButton, *_addedButton;
    UIBarButtonItem *_backButton;
    
    //present
    UIView *_senderViewForAnimation;
    
    //flag
    BOOL _performingLayout;
    BOOL _viewIsActive;
    NSInteger _initialPageIndex;
    
    CGRect _senderViewOriginalFrame;
    UIWindow *_applicationWindow;
    
    //NavigationBar
    BOOL _statusBarShouldBeHidden;
    BOOL _didSavePreviousStateOfNavBar;
    BOOL _viewHasAppearedInitially;
    
    BOOL _previousNavBarHidden;
    BOOL _previousNavBarTanslucent;
    UIBarStyle _previousNavBarStyle;
    UIStatusBarStyle _previousStatusBarStyle;
    UIColor *_previousNavBarTintColor;
    UIColor *_previousNavBarBarTintColor;
    UIBarButtonItem *_previousViewControllerBackButton;
    UIImage *_previousNavigatinBarBackgroundImageDefault;
    UIImage *_previousNavigationBarBackgroundImaeLandscapePhone;
    
    //选中图片
    NSMutableArray *_selectedPhotos;
}

@property (nonatomic, strong) AssetsGroupBottomView *bottomView;

//layout
- (void)performLayout;

//pages
- (void)titlePages;
- (BOOL)isDisplayingPageForIndex:(NSUInteger)index;
- (ZoomingScrollView *)pageDisplayedAtIndex:(NSUInteger)index;
- (ZoomingScrollView *)pageDisplayingPhoto:(id<PhotoProtocol>)photo;
//出栈
- (ZoomingScrollView *)dequeueRecycledPages;
- (void)configurePage:(ZoomingScrollView *)page forIndex:(NSUInteger)index;
- (void)didStartViewingPageAtIndex:(NSUInteger)index;

//frame
- (CGRect)frameForPagingScrollView;
- (CGRect)frameForPageAtIndex:(NSUInteger)index;
- (CGSize)contentSizeForPagingScrollView;
- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index;

//toolbar
- (void)updateNavigationBar;

- (void)jumpToPageAtIndex:(NSUInteger)index;
- (void)gotoPreviousPage;
- (void)gotoNextPage;

//control
- (void)setControlsHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)toggleControls;
- (BOOL)areControlsHidden;


//Data
- (NSUInteger)numberOfPhotos;
- (id<PhotoProtocol>)photoAtIndex:(NSUInteger)index;
- (UIImage *)imageForPhoto:(id<PhotoProtocol>)photo;
- (void)loadAdjacentPhotosIfNecessary:(id<PhotoProtocol>)photo;
- (void)releaseAllUnderlyingPhotos;

@end

@implementation PhotoBrowser

- (instancetype)init {
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        
        
        _currentPageIndex = 0;
        _performingLayout = NO;
        _viewIsActive = NO;
        
        _visiblePages = [[NSMutableSet alloc] init];
        _recycledPages = [[NSMutableSet alloc] init];
        _photos = [[NSMutableArray alloc] init];
        
        _initialPageIndex = 0;
        
        _useWhiteBackgroundColor = YES;
        
        _leftArrowImage = _leftArrowSelectedImage = _rightArrowImage = _rightArrowSelectedImage = nil;
        
        _arrowButtonsChangePhotosAnimated = YES;
        
        _animationDuration = 0.28;
        _senderViewForAnimation = nil;
        
        if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        
        _applicationWindow = [[[UIApplication sharedApplication] delegate] window];
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePhotoLoadingDidEndNotification:) name:PHOTO_LOADING_DID_END_NOTIFICATION object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(assetsChanged:) name:ALAssetsLibraryChangedNotification object:nil];
    }
    return self;
}

- (instancetype)initWithPhotos:(NSArray *)photos {
    self = [self init];
    if (self) {
        _photos = [[NSMutableArray alloc] initWithArray:photos];
    }
    return self;
}

- (instancetype)initWithPhotos:(NSArray *)photos animatedFromView:(UIView *)view {
    self = [self init];
    if (self) {
        _photos = [[NSMutableArray alloc] initWithArray:photos];
        _senderViewForAnimation = view;
    }
    return self;
}

- (instancetype)initWithURLs:(NSArray *)urls {
    self = [self init];
    if (self) {
        NSArray *photos = [Photo photoWithURLs:urls];
        _photos = [[NSMutableArray alloc] initWithArray:photos];
    }
    return self;
}

- (instancetype)initWithURLs:(NSArray *)urls animaedFromView:(UIView *)view {
    self = [self init];
    if (self) {
        NSArray *photos = [Photo photoWithURLs:urls];
        _photos = [[NSMutableArray alloc] initWithArray:photos];
        _senderViewForAnimation = view;
    }
    return self;
}

- (void)dealloc {
    _pagingScrollView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ALAssetsLibraryChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self releaseAllUnderlyingPhotos];
}

- (void)releaseAllUnderlyingPhotos {
    for (id photo in _photos) {
        if (photo != [NSNull null]) {
            [photo unloadUnderlyingImage];
        }
    }
}


- (void)didReceiveMemoryWarning {
    [self releaseAllUnderlyingPhotos];
    [_recycledPages removeAllObjects];
    [super didReceiveMemoryWarning];
}

#pragma mark -animation
- (UIImage *)rotateImageToCurrentOrientation:(UIImage *)image {
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        UIImageOrientation orientation = ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft) ? UIImageOrientationLeft : UIImageOrientationRight;
        UIImage *orientationImage = [UIImage imageWithCGImage:image.CGImage scale:1.0 orientation:orientation];
        image = orientationImage;
    }
    return image;
}

- (void)performPresentAnimation {
    self.view.alpha = 0.0f;
    
    UIImage *imageFromView = [self getImageFromView:_senderViewForAnimation];
    imageFromView = [self rotateImageToCurrentOrientation:imageFromView];
    
    _senderViewOriginalFrame = [_senderViewForAnimation.superview convertRect:_senderViewForAnimation.frame toView:nil];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenBounds.size.width;
    CGFloat screenHeight = screenBounds.size.height;
    
    UIView *fadeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    fadeView.backgroundColor = [UIColor clearColor];
    [_applicationWindow addSubview:fadeView];
    
    
    UIImageView *resizableImageView = [[UIImageView alloc] initWithImage:imageFromView];
    resizableImageView.frame = _senderViewOriginalFrame;
    resizableImageView.clipsToBounds = YES;
    resizableImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizableImageView.backgroundColor = [UIColor colorWithWhite:(_useWhiteBackgroundColor ? 1 : 0) alpha:1.0];
    [_applicationWindow addSubview:resizableImageView];
    
    _senderViewForAnimation.hidden = YES;
    
    void (^complection)() = ^() {
        self.view.alpha = 1.0;
        resizableImageView.backgroundColor = [UIColor colorWithWhite:(_useWhiteBackgroundColor ? 1 : 0) alpha:1.0];
        [fadeView removeFromSuperview];
        [resizableImageView removeFromSuperview];
    };
    [UIView animateWithDuration:_animationDuration animations:^{
        fadeView.backgroundColor = _useWhiteBackgroundColor ? [UIColor whiteColor] : [UIColor blackColor];
    }];
    
    float scaleFactor = (imageFromView ? imageFromView.size.width : screenWidth) / screenWidth;
    CGRect finalImageViewFrame = CGRectMake(0, (screenHeight / 2) - ((imageFromView.size.height / scaleFactor) / 2), screenWidth, imageFromView.size.height / scaleFactor);
    
    [UIView animateWithDuration:_animationDuration animations:^{
        resizableImageView.layer.frame = finalImageViewFrame;
    } completion:^(BOOL finished) {
        complection();
    }];
    
}

- (void)performCloseAnimationWithScrollView:(ZoomingScrollView *)scrollView {
    float fadeAlpha = 1 - fabs(scrollView.frame.origin.y) / scrollView.frame.size.height;
    
    UIImage *imageFromView = [scrollView.photo underlyingImage];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenBounds.size.width;
    CGFloat screenHeight = screenBounds.size.height;
    
    float scaleFactor = imageFromView.size.width / screenWidth;
    
    UIView *fadeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    fadeView.backgroundColor = _useWhiteBackgroundColor ? [UIColor whiteColor] : [UIColor blackColor];
    fadeView.alpha = fadeAlpha;
    [_applicationWindow addSubview:fadeView];
    
    UIImageView *resizableImageView = [[UIImageView alloc] initWithImage:imageFromView];
    resizableImageView.frame = imageFromView ? CGRectMake(0, (screenHeight / 2) - ((imageFromView.size.height / scaleFactor) / 2) + scrollView.frame.origin.y, screenWidth, imageFromView.size.height / scaleFactor) : CGRectZero;
    resizableImageView.contentMode = UIViewContentModeScaleAspectFit;
    resizableImageView.clipsToBounds = YES;
    resizableImageView.backgroundColor = [UIColor clearColor];
    [_applicationWindow addSubview:resizableImageView];
    self.view.hidden = YES;
    
    void (^complection)() = ^() {
        _senderViewForAnimation.hidden = NO;
        _senderViewForAnimation = nil;
        
        [fadeView removeFromSuperview];
        [resizableImageView removeFromSuperview];
        
        [self prepareForClosePhotoBrowser];
        [self dismissPhotoBrowserAnimated:YES];
    };
    
    [UIView animateWithDuration:_animationDuration animations:^{
        fadeView.alpha = 0.0;
        self.view.backgroundColor = [UIColor clearColor];
    }];
    
    [UIView animateWithDuration:_animationDuration animations:^{
        resizableImageView.layer.frame = _senderViewOriginalFrame;
    } completion:^(BOOL finished) {
        complection();
    }];
}

#pragma mark -Genaral
- (void)prepareForClosePhotoBrowser {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)dismissPhotoBrowserAnimated:(BOOL)animated {
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController popViewControllerAnimated:animated];
    if (_delegate && [_delegate respondsToSelector:@selector(photoBrowser:didDismissAtPageIndex:)]) {
        [_delegate photoBrowser:self didDismissAtPageIndex:_currentPageIndex];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(photoBrowser:didDismissAtPageIndex:withSelectedPhotoURLs:)]) {
        [_delegate photoBrowser:self didDismissAtPageIndex:_currentPageIndex withSelectedPhotoURLs:[_selectedPhotos copy]];
    }
}


- (UIButton *)customNavBarButtonImage:(UIImage *)image imageSelected:(UIImage *)selectedImage action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setBackgroundImage:selectedImage forState:UIControlStateDisabled];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [button setContentMode:UIViewContentModeCenter];
    [button setFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    return button;
}

- (UIButton *)customNavButtonText:(NSString *)text textUnselected:(UIColor *)unselectedColor textSelected:(UIColor *)selectedColor action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:text forState:UIControlStateNormal];
    [button setTitleColor:unselectedColor forState:UIControlStateNormal];
    [button setTitleColor:selectedColor forState:UIControlStateHighlighted];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [button setContentMode:UIViewContentModeCenter];
    [button setFrame:CGRectMake(0, 0, 64, 34)];
    button.titleLabel.font = [button.titleLabel.font fontWithSize:15];
    [button sizeToFit];
    
    return button;
}

//截图
- (UIImage *)getImageFromView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 2);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark -View Lifecycle
- (void)viewDidLoad {
//    [self performPresentAnimation];
    self.view.backgroundColor = [UIColor colorWithWhite:(_useWhiteBackgroundColor ? 1 : 0) alpha:1.0];
    self.view.clipsToBounds = YES;
    
    CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
    _pagingScrollView = [[UIScrollView alloc] initWithFrame:pagingScrollViewFrame];
    _pagingScrollView.pagingEnabled = YES;
    _pagingScrollView.delegate = self;
    _pagingScrollView.showsHorizontalScrollIndicator = NO;
    _pagingScrollView.showsVerticalScrollIndicator = NO;
    _pagingScrollView.backgroundColor = [UIColor clearColor];
    _pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    [self.view addSubview:_pagingScrollView];
    
    UIImage *leftButtonImage = (_leftArrowImage == nil) ? [UIImage imageNamed:@"PhotoBrowser_arrowLeft.png"] : _leftArrowImage;
    UIImage *rightButtonImage = (_rightArrowImage == nil) ? [UIImage imageNamed:@"PhotoBrowser_arrowRight.png"] : _rightArrowImage;
    UIImage *leftButtonSelectedImage = (_leftArrowSelectedImage == nil) ? [UIImage imageNamed:@"PhotoBrowser_arrowLeftSelected.png"] : _leftArrowSelectedImage;
    UIImage *rightButtonSelectedImage = (_rightArrowSelectedImage == nil) ? [UIImage imageNamed:@"PhotoBrowser_arrowRightSelected.png"] : _rightArrowSelectedImage;
    
    //Arrows
    _previousButton = [[UIBarButtonItem alloc] initWithCustomView:[self customNavBarButtonImage:leftButtonImage imageSelected:leftButtonSelectedImage action:@selector(gotoPreviousPage)]];
    _nextButton = [[UIBarButtonItem alloc] initWithCustomView:[self customNavBarButtonImage:rightButtonImage imageSelected:rightButtonSelectedImage action:@selector(gotoNextPage)]];
    
    //actionButton
//    _addedButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonPressed:)];
    PhotoAssetCheckmarkView *checkmarkView = [[PhotoAssetCheckmarkView alloc] init];
    [checkmarkView sizeToFit];
    [checkmarkView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCheckmarkView:)]];
    _addedButton = [[UIBarButtonItem alloc] initWithCustomView:checkmarkView];
    
    //backButton
    _backButton = [[UIBarButtonItem alloc] initWithCustomView:[self customNavButtonText:self.backButtonTitle textUnselected:[UIColor whiteColor] textSelected:[UIColor blackColor] action:@selector(backButtonAction:)]];
    
    [self initializeBottomView];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [self reloadData];
    
    [super viewWillAppear:animated];
    
    //statusbar
    _previousStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:animated];
    if (!_viewIsActive && [self.navigationController.viewControllers objectAtIndex:0] != self) {
        [self storePreviousNavBarAppearance];
    }
    [self setNavBarAppearance:animated];
    if (!_viewHasAppearedInitially) {
        _viewHasAppearedInitially = YES;
    }
    //刷新顶部选中MarkView
    [self changeTopMarkviewState];
}

- (void)viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers objectAtIndex:0] != self && ![self.navigationController.viewControllers containsObject:self]) {
        _viewIsActive = NO;
        [self restorePreviousNavBarAppearance:animated];
    }
    [self.navigationController.navigationBar.layer removeAllAnimations];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self setControlsHidden:NO animated:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:_previousStatusBarStyle animated:animated];
    
    [super viewWillDisappear:animated];
}

- (void)storePreviousNavBarAppearance {
    _didSavePreviousStateOfNavBar = YES;
    _previousNavBarTanslucent = self.navigationController.navigationBar.translucent;
    _previousNavBarTintColor = self.navigationController.navigationBar.tintColor;
    _previousNavBarHidden = self.navigationController.navigationBarHidden;
    _previousNavBarStyle = self.navigationController.navigationBar.barStyle;
    if ([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
        _previousNavigatinBarBackgroundImageDefault = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
        _previousNavigationBarBackgroundImaeLandscapePhone = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsLandscapePhone];
    }
}

- (void)restorePreviousNavBarAppearance:(BOOL)animated {
    if (_didSavePreviousStateOfNavBar) {
        [self.navigationController setNavigationBarHidden:_previousNavBarHidden animated:animated];
        UINavigationBar *navBar = self.navigationController.navigationBar;
        navBar.tintColor = _previousNavBarTintColor;
        navBar.translucent = _previousNavBarTanslucent;
        navBar.barStyle = _previousNavBarStyle;
        if ([[UINavigationBar class]respondsToSelector:@selector(appearance)]) {
            [navBar setBackgroundImage:_previousNavigatinBarBackgroundImageDefault forBarMetrics:UIBarMetricsDefault];
            [navBar setBackgroundImage:_previousNavigationBarBackgroundImaeLandscapePhone forBarMetrics:UIBarMetricsLandscapePhone];
        }
        if (_previousViewControllerBackButton) {
            UIViewController *previousViewController = [self.navigationController topViewController];
            previousViewController.navigationItem.backBarButtonItem = _previousViewControllerBackButton;
            _previousViewControllerBackButton = nil;
        }
    }
}

- (void)setNavBarAppearance:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.tintColor = [UIColor clearColor];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        if ([navBar respondsToSelector:@selector(setBarTintColor:)]) {
            navBar.tintColor = nil;
            navBar.shadowImage = nil;
        }
    }
    navBar.translucent = YES;
    navBar.barStyle = UIBarStyleBlackTranslucent;
    if ([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
        [navBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [navBar setBackgroundImage:[UIImage imageNamed:@"choosePlus.png"] forBarMetrics:UIBarMetricsCompact];
    }
}

- (BOOL)prefersStatusBarHidden {
    return _statusBarShouldBeHidden;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _viewIsActive = YES;
    
}

- (void)viewDidUnload {
    _currentPageIndex = 0;
    _pagingScrollView = nil;
    _visiblePages = nil;
    _recycledPages = nil;
    _previousButton = nil;
    _nextButton = nil;
    [super viewDidUnload];
}

#pragma mark -status bar
- (UIStatusBarStyle)preferredStatusBarStyle {
    return _useWhiteBackgroundColor ? 1 : 0;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

#pragma mark -layout
- (void)viewWillLayoutSubviews {
    _performingLayout = YES;
    
    NSUInteger indexPriorToLayout = _currentPageIndex;
    
    CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
    
    _pagingScrollView.frame = pagingScrollViewFrame;
    
    _pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    
    for (ZoomingScrollView *page in _visiblePages) {
        NSUInteger index = PAGE_INDEX(page);
        page.frame = [self frameForPageAtIndex:index];
        [page setMaxMinZoomScaleForCurrentBounds];
        
    }
    
    _pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:indexPriorToLayout];
    [self didStartViewingPageAtIndex:_currentPageIndex];
    
    _currentPageIndex = indexPriorToLayout;
    _performingLayout = NO;
    
    [super viewWillLayoutSubviews];
}

- (void)performLayout {
    _performingLayout = YES;
    
    //setup pages
    [_recycledPages removeAllObjects];
    [_visiblePages removeAllObjects];
    
    [self updateNavigationBar];
    
    //ContentOffset
    _pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:_currentPageIndex];
    [self titlePages];
    
    _performingLayout = NO;
    
    //toolbar item
    UIBarButtonItem *fixedLeftSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    fixedLeftSpace.width = 10;
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    NSMutableArray *leftItems = [NSMutableArray array];
    
    [leftItems addObject:_backButton];
    [leftItems addObject:flexSpace];
    
    if ([self numberOfPhotos] > 1) {
//        [leftItems addObject:_previousButton];
    }
    [leftItems addObject:flexSpace];
    
    [self.navigationItem setLeftBarButtonItems:leftItems];
    
    UIBarButtonItem *fixedRightSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    fixedRightSpace.width = 10;
    
    NSMutableArray *rightItems = [NSMutableArray array];
    
    [rightItems addObject:fixedRightSpace];
    [rightItems addObject:_addedButton];
    [rightItems addObject:flexSpace];
    if ([self numberOfPhotos] > 1) {
//        [rightItems addObject:_nextButton];
    }
    [rightItems addObject:flexSpace];
    
    [self.navigationItem setRightBarButtonItems:rightItems];
    

}

#pragma mark - Data
- (void)reloadData {
    //Get Data
    [self releaseAllUnderlyingPhotos];
    
    //update
    [self performLayout];
    
    [self.view setNeedsLayout];
}

- (NSUInteger)numberOfPhotos {
    return _photos.count;
}

- (id<PhotoProtocol>)photoAtIndex:(NSUInteger)index {
    if ((NSInteger)index > (NSInteger)(_photos.count - 1)) {
        return nil;
    }
    return _photos[index];
}

- (UIImage *)imageForPhoto:(id<PhotoProtocol>)photo {
    if (photo) {
        if ([photo underlyingImage]) {
            return [photo underlyingImage];
        } else {
            [photo loadUnderlyingImageAndNotify];
        }
    }
    return nil;
}

- (void)loadAdjacentPhotosIfNecessary:(id<PhotoProtocol>)photo {
    ZoomingScrollView *page = [self pageDisplayingPhoto:photo];
    if (page) {
        NSUInteger pageIndex = PAGE_INDEX(page);
        
        if (_currentPageIndex == pageIndex) {
            if (pageIndex > 0) {
                //reload index-1
                id <PhotoProtocol> photo = [self photoAtIndex:pageIndex - 1];
                if (![photo underlyingImage]) {
                    [photo loadUnderlyingImageAndNotify];
                }
            }
            if (pageIndex < [self numberOfPhotos] - 1) {
                //reload index + 1;
                id <PhotoProtocol> photo = [self photoAtIndex:pageIndex + 1];
                if (![photo underlyingImage]) {
                    [photo loadUnderlyingImageAndNotify];
                }
            }
        }
    }
}

#pragma mark - photo loading notification
- (void)handlePhotoLoadingDidEndNotification:(NSNotification *)notification {
    id <PhotoProtocol> photo = (id <PhotoProtocol>)[notification object];
    ZoomingScrollView *page = [self pageDisplayingPhoto:photo];
    
    if (page) {
        if ([photo underlyingImage]) {
            //loading Successful
            [page displayImage];
            //load index-1 and index+1
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self loadAdjacentPhotosIfNecessary:photo];
            });
//            [self loadAdjacentPhotosIfNecessary:photo];
        } else {
            //loading failure
            [page displayImageFailure];
        }
    }
}

- (void)assetsChanged:(NSNotification *)notification {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        NSDictionary *userInfo = notification.userInfo;
        
        NSSet *groupURLs = userInfo[ALAssetLibraryUpdatedAssetGroupsKey];
        
        if (![groupURLs containsObject:[self.assetsGroup valueForProperty:ALAssetsGroupPropertyURL]]) {
            return;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadPages];
    });
}

- (void)reloadPages {
    Photo *currentPhoto = [self photoAtIndex:_currentPageIndex];
    
    [self.assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
    NSMutableArray *assets = [[NSMutableArray alloc]init];
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    [self.assetsGroup enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            [assets addObject:result];
        }
    }];
    for (ALAsset *asset in [[assets reverseObjectEnumerator] allObjects]) {
        Photo * photo = [[Photo alloc] initWithURL:asset.defaultRepresentation.url];
        [photos addObject:photo];
        if ([photo.photoURL.absoluteString isEqualToString:currentPhoto.photoURL.absoluteString]) {
            _currentPageIndex = [photos indexOfObject:photo];
        }
    }
    _photos = photos;
    if (_currentPageIndex > _photos.count -1) {
        _currentPageIndex = _photos.count -1;
    }
    if (_photos.count == 0) {
        _currentPageIndex = 0;
    }
    for (UIView *view in _pagingScrollView.subviews) {
        if ([view isKindOfClass:[ZoomingScrollView class]]) {
            [view removeFromSuperview];
        }
    }
    [self reloadData];
}

#pragma mark - paging
- (void)titlePages {
    CGRect visibleBounds = _pagingScrollView.bounds;
    NSInteger iFirstIndex = (NSInteger)floorf((CGRectGetMinX(visibleBounds) + 2 * PADDING) / CGRectGetWidth(visibleBounds));
    NSInteger iLastIndex = (NSInteger)floorf((CGRectGetMaxX(visibleBounds) - 2 * PADDING - 1) / CGRectGetWidth(visibleBounds));
    
    if (iFirstIndex < 0) {
        iFirstIndex = 0;
    }
    if (iFirstIndex > [self numberOfPhotos] - 1) {
        iFirstIndex = [self numberOfPhotos] - 1;
    }
    if (iLastIndex < 0) {
        iLastIndex = 0;
    }
    if (iLastIndex > [self numberOfPhotos] - 1) {
        iLastIndex = [self numberOfPhotos] - 1;
    }
    
    //回收不再需要的页面
    NSInteger pageIndex;
    for (ZoomingScrollView *page in _visiblePages) {
        pageIndex = PAGE_INDEX(page);
        if (pageIndex < (NSUInteger)iFirstIndex || pageIndex > (NSUInteger)iLastIndex) {
            [_recycledPages addObject:page];
            [page prepareForReuse];
            [page removeFromSuperview];
            
        }
    }
    
    [_visiblePages minusSet:_recycledPages];
    
    while (_recycledPages.count > 2) { //保持只有两个回收页面
        [_recycledPages removeObject:[_recycledPages anyObject]];
    }
    
    for (NSUInteger index = (NSUInteger)iFirstIndex; index <= (NSUInteger)iLastIndex; index ++) {
        if (![self isDisplayingPageForIndex:index]) {
            //添加新的页面
            ZoomingScrollView *page;
            page = [[ZoomingScrollView alloc] initWithPhotoBrowser:self];
            page.backgroundColor = [UIColor clearColor];
            page.opaque = YES;
            
            [self configurePage:page forIndex:index];
            
            [_visiblePages addObject:page];
            [_pagingScrollView addSubview:page];
        }
    }
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index {
    for (ZoomingScrollView *page in _visiblePages) {
        if (PAGE_INDEX(page) == index) {
            return YES;
        }
    }
    return NO;
}

- (ZoomingScrollView *)pageDisplayedAtIndex:(NSUInteger)index {
    ZoomingScrollView *thePage = nil;
    for (ZoomingScrollView *page in _visiblePages) {
        if (PAGE_INDEX(page) == index) {
            thePage = page;
            break;
        }
    }
    return thePage;
}

- (ZoomingScrollView *)pageDisplayingPhoto:(id<PhotoProtocol>)photo {
    ZoomingScrollView *thePage = nil;
    for (ZoomingScrollView *page in _visiblePages) {
        if (page.photo == photo) {
            thePage = page;
            break;
        }
    }
    return thePage;
}

- (void)configurePage:(ZoomingScrollView *)page forIndex:(NSUInteger)index {
    page.frame = [self frameForPageAtIndex:index];
    page.tag = PAGE_INDEX_TAG_OFFSET + index;
    page.photo = [self photoAtIndex:index];
}

- (ZoomingScrollView *)dequeueRecycledPages {
    ZoomingScrollView *page = [_recycledPages anyObject];
    if (page) {
        [_recycledPages removeObject:page];
    }
    return page;
}

//处理页面变化
- (void)didStartViewingPageAtIndex:(NSUInteger)index {
    //加载如果需要相邻的图像和照片已经加载。也称为后照片已经加载到背景中
    id <PhotoProtocol> currentPhoto = [self photoAtIndex:index];
    if ([currentPhoto underlyingImage]) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self loadAdjacentPhotosIfNecessary:currentPhoto];
        });
//        [self loadAdjacentPhotosIfNecessary:currentPhoto];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(photoBrowser:didShowPhotoAtIndex:)]) {
        [_delegate photoBrowser:self didShowPhotoAtIndex:index];
    }
}

#pragma mark - frame calculation
- (CGRect)frameForPagingScrollView {
    CGRect frame = self.view.bounds;
    frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);
    return frame;
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    CGRect bounds = _pagingScrollView.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 * PADDING);
    pageFrame.origin.x = (bounds.size.width * index) + PADDING;
    return pageFrame;
}

- (CGSize)contentSizeForPagingScrollView {
    CGRect bounds = _pagingScrollView.bounds;
    return CGSizeMake(bounds.size.width * [self numberOfPhotos], bounds.size.height);
}

- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index {
    CGFloat pageWidth = _pagingScrollView.bounds.size.width;
    CGFloat newOffset = pageWidth * index;
    return CGPointMake(newOffset, 0);
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //check
    if (!_viewIsActive || _performingLayout) {
        return;
    }
    
    [self titlePages];
    
    //calculate current page
    CGRect visibleBounds = _pagingScrollView.bounds;
    NSInteger index = (NSInteger)(floorf((CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds))));
    if (index < 0) {
        index = 0;
    }
    if (index > [self numberOfPhotos] - 1) {
        index = [self numberOfPhotos] - 1;
    }
    
    NSUInteger previousCurrentPage = _currentPageIndex;
    _currentPageIndex = index;
    if (_currentPageIndex != previousCurrentPage) {
        [self didStartViewingPageAtIndex:_currentPageIndex];
        
        if (_arrowButtonsChangePhotosAnimated) {
            [self updateNavigationBar];
        }
    }
    
    [self changeTopMarkviewState];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self setControlsHidden:NO animated:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (!_arrowButtonsChangePhotosAnimated) {
        [self updateNavigationBar];
    }
}

#pragma mark - toolbar
- (void)updateNavigationBar {
    if ([self numberOfPhotos] > 1) {
        self.title = [NSString stringWithFormat:@"%u/%lu",_currentPageIndex + 1,(unsigned long)[self numberOfPhotos]];
    } else {
        self.title = nil;
    }
    
    //buttons
    _previousButton.enabled = (_currentPageIndex > 0);
    _nextButton.enabled = (_currentPageIndex < [self numberOfPhotos] - 1);
    
    //改变底部工具栏
    self.bottomView.currentIndex = _currentPageIndex;
}

- (void)jumpToPageAtIndex:(NSUInteger)index {
    if (index < [self numberOfPhotos]) {
        CGRect pageFrame = [self frameForPageAtIndex:index];
        if (_arrowButtonsChangePhotosAnimated) {
            [_pagingScrollView setContentOffset:CGPointMake(pageFrame.origin.x - PADDING, 0) animated:YES];
        } else {
            _pagingScrollView.contentOffset = CGPointMake(pageFrame.origin.x - PADDING, 0);
            [self updateNavigationBar];
        }
    }
}

- (void)gotoPreviousPage {
    [self jumpToPageAtIndex:_currentPageIndex - 1];
}

- (void)gotoNextPage {
    [self jumpToPageAtIndex:_currentPageIndex + 1];
}

#pragma mark - Controls Hide/show
- (void)setControlsHidden:(BOOL)hidden animated:(BOOL)animated {
    if ([self numberOfPhotos] == 0) {
        hidden = NO;
    }
    //hide / show bars
    _statusBarShouldBeHidden = hidden;
    [UIView animateWithDuration:(animated ? 0.1 : 0) animations:^{
        CGFloat alpha = hidden ? 0 : 1;
        [self.navigationController.navigationBar setAlpha:alpha];
    } completion:^(BOOL finished) {
    }];
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (BOOL)areControlsHidden {
    return self.navigationController.navigationBar.alpha == 0;
}

- (void)hideControls {
    [self setControlsHidden:YES animated:YES];
}

- (void)toggleControls {
    [self setControlsHidden:![self areControlsHidden] animated:YES];
}

#pragma mark - properties
- (void)setInitialPageIndex:(NSUInteger)index {
    if (index > [self numberOfPhotos] - 1) {
        index = [self numberOfPhotos] - 1;
    }
    _initialPageIndex = index;
    _currentPageIndex = index;
    if ([self isViewLoaded]) {
        [self jumpToPageAtIndex:index];
        if (!_viewIsActive) {
            [self titlePages];
        }
    }
}

- (void)setUseOriginalImage:(BOOL)useOriginalImage {
    _useOriginalImage = useOriginalImage;
}

#pragma mark - Buttons
- (void)backButtonAction:(id)sender {
    if (_senderViewForAnimation && _currentPageIndex == _initialPageIndex) {
        ZoomingScrollView *scrollView = [self pageDisplayedAtIndex:_currentPageIndex];
        [self performCloseAnimationWithScrollView:scrollView];
    } else {
        _senderViewForAnimation.hidden = NO;
        [self prepareForClosePhotoBrowser];
        [self dismissPhotoBrowserAnimated:YES];
    }
}

#pragma mark - TapCheckmarkView
- (void)tapCheckmarkView:(UITapGestureRecognizer *)tapGesture {
    PhotoAssetCheckmarkView *checkmarkView = (PhotoAssetCheckmarkView *)tapGesture.view;
    
    if (_selectedPhotos.count >= self.maxNumberOfImages && !checkmarkView.selected) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"你最多只能选择%lld张图片", (long long)self.maxNumberOfImages] delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    scaleAnimation.toValue = [NSNumber numberWithFloat:0.85];
    scaleAnimation.duration = .15f;
    scaleAnimation.autoreverses = YES;
    scaleAnimation.repeatCount = 1;
    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [checkmarkView.layer addAnimation:scaleAnimation forKey:@"photoAssetCell"];
    checkmarkView.selected = !checkmarkView.selected;

    Photo *currentPhoto = [self photoAtIndex:_currentPageIndex];
    if (checkmarkView.selected) {
        [self insertSelectedPhotoURL:currentPhoto.photoURL.absoluteString];
    } else {
        [self removeSelectedPhotoURL:currentPhoto.photoURL.absoluteString];
    }
}

- (void)insertSelectedPhotos:(NSArray *)selectedPhotos {
    if (_selectedPhotos) {
        [_selectedPhotos removeAllObjects];
        _selectedPhotos = nil;
    }
    _selectedPhotos = [[NSMutableArray alloc] initWithArray:selectedPhotos];
}

- (void)changeTopMarkviewState {
    Photo *currentPhoto = [self photoAtIndex:_currentPageIndex];
    BOOL hasSelected = NO;
    for (NSString *selectedURL in _selectedPhotos) {
        if ([selectedURL isEqualToString:currentPhoto.photoURL.absoluteString]) {
            hasSelected = YES;
        }
    }
    if (hasSelected) {
        ((PhotoAssetCheckmarkView *)_addedButton.customView).selected = YES;
    } else {
        ((PhotoAssetCheckmarkView *)_addedButton.customView).selected = NO;
    }
}

- (void)insertSelectedPhotoURL:(NSString *)photoURL {
    for (NSString *selectedURL in _selectedPhotos) {
        if ([selectedURL isEqualToString:photoURL]) {
            return;
        }
    }
    [_selectedPhotos addObject:photoURL];
    
    [self.bottomView insertAssetURL:photoURL];
}

- (void)removeSelectedPhotoURL:(NSString *)photoURL {
    NSString *existPhotoURL = nil;
    for (NSString *selectedURL in _selectedPhotos) {
        if ([selectedURL isEqualToString:photoURL]) {
            existPhotoURL = selectedURL;
        }
    }
    if (existPhotoURL) {
        [_selectedPhotos removeObject:existPhotoURL];
    }
    
    [self.bottomView removeAssetURL:photoURL];
}

#pragma mark - AssetsGroupBottomViewDelegate
- (void)initializeBottomView {
    _bottomView = [[AssetsGroupBottomView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds) - 44, CGRectGetWidth(self.view.frame), 44)];
    switch ([[ImagePickerModeProtocol sharedInstance] imagePickerMode]) {
        case ImagePickerModeNone:
            _bottomView.displayMode = AssetsGroupBottomViewModeNone;
            break;
        case ImagePickerModeUseOriginalImage:
            _bottomView.displayMode = AssetsGroupBottomViewModeOriginShow;
            break;
        default:
            _bottomView.displayMode = AssetsGroupBottomViewModeNone;
            break;
    }
//    _bottomView.displayMode = AssetsGroupBottomViewModeOriginShow;
    _bottomView.delegate = self;
    [_bottomView resetAllAssetURLs:_selectedPhotos];
    _bottomView.currentIndex = _currentPageIndex;
    [_bottomView changeOriginalImageButtonState:self.useOriginalImage];
    [self.view addSubview:_bottomView];
}

- (void)assetsGroupBottomView:(AssetsGroupBottomView *)bottomView didTouchFinishButton:(UIButton *)finishButton {
    if (_delegate && [_delegate respondsToSelector:@selector(photoBrowser:didFinishWithSelectedPhotoURLs:useOriginalImage:)]) {
        [_delegate photoBrowser:self didFinishWithSelectedPhotoURLs:_selectedPhotos useOriginalImage:self.useOriginalImage];
    }
}

- (void)assetsGroupBottomView:(AssetsGroupBottomView *)bottomView didTouchUseOriginalImageButton:(UIButton *)button selected:(BOOL)selected {
    self.useOriginalImage = selected;
}

@end
