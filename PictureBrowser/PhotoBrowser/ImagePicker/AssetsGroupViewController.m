//
//  AssetsGroupViewController.m
//  ImagePickerNew
//
//  Created by admin on 15/6/1.
//  Copyright (c) 2015年 admin. All rights reserved.
//

#import "AssetsGroupViewController.h"
#import "PhotoAssetCell.h"
#import "NoPhotoFoundCell.h"
#import "PhotoBrowser.h"
#import "PhotoAssetCheckmarkView.h"
#import "AssetsGroupBottomView.h"
#import "UIViewController+ImagePicker.h"

//版本支持
#define IOS_VERSION_MORE_THAN(__VERSIONSTRING) ([[[UIDevice currentDevice]systemVersion]compare:__VERSIONSTRING options:NSNumericSearch]==NSOrderedDescending)

@interface AssetsGroupViewController () <PhotoAssetCellDelegate, AssetsGroupBottomViewDelegate, PhotoBrowserDelegate>

@property (nonatomic, strong) AssetsGroupBottomView *bottomView;

@property (nonatomic,strong) NSArray *assets;
@property (nonatomic,strong) NSArray *assetURLs;
//@property (nonatomic,strong) PhotoBrowser *photoBrowser;
//原图发送
@property (nonatomic, assign) BOOL useOriginalImage;

- (void)reloadAssets;
- (void)swipeLeft:(UISwipeGestureRecognizer *)recognizer;
- (void)swipeRight:(UISwipeGestureRecognizer *)recognizer;

@end

@implementation AssetsGroupViewController

- (instancetype)initWithCollectionViewLayout:(UICollectionViewFlowLayout *)layout {
    self = [super initWithCollectionViewLayout:layout];
    
    if (self) {
        self.collectionView.backgroundColor = [UIColor colorWithRed:242.0 / 255.0 green:242.2 / 255.0 blue:242.0 / 255.0 alpha:1.0];
        self.collectionView.allowsMultipleSelection = YES;
        self.collectionView.clipsToBounds = YES;
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.showsVerticalScrollIndicator = NO;
        
        [self.collectionView registerClass:[PhotoAssetCell class] forCellWithReuseIdentifier:NSStringFromClass([PhotoAssetCell class])];
        [self.collectionView registerClass:[NoPhotoFoundCell class] forCellWithReuseIdentifier:NSStringFromClass([NoPhotoFoundCell class])];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(assetsChanged:) name:ALAssetsLibraryChangedNotification object:nil];
        
        UILongPressGestureRecognizer *longPressGresture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
        longPressGresture.minimumPressDuration = .3;
        longPressGresture.delaysTouchesBegan = YES;
        [self.collectionView addGestureRecognizer:longPressGresture];
        
        UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeLeft:)];
        swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.collectionView addGestureRecognizer:swipeLeft];
        
        UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
        swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
        [self.collectionView addGestureRecognizer:swipeRight];
        
        [self initializeBottomView];
        
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:242.0 / 255.0 green:242.0 / 255.0 blue:242.0 / 255.0 alpha:1.0];
    
    [self createBarButtonItemAtPositon:NavigationBarButtonPositionRight text:@"取消" action:@selector(cancelAction)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_delegate && [_delegate respondsToSelector:@selector(assetsGroupViewController:didAppear:)]) {
        [_delegate assetsGroupViewController:self didAppear:self.assetGroup];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:ALAssetsLibraryChangedNotification object:nil];
}

- (void)setAssetGroup:(ALAssetsGroup *)assetGroup {
    _assetGroup = assetGroup;
    self.title = [self.assetGroup valueForProperty:ALAssetsGroupPropertyName];
    
    [self reloadAssets];
}

- (void)reloadAssets {
    [self reloadAssetsAnimated:NO];
}

- (void)reloadAssetsAnimated:(BOOL)animated {
    [self.assetGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
    NSMutableArray *assets = [[NSMutableArray alloc]init];
    [self.assetGroup enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            [assets addObject:result];
        }
    }];
    [self setItems:assets animated:animated];
}

- (void)setItems:(NSMutableArray *)items animated:(BOOL)animated {
    if (_assets == items || [_assets isEqualToArray:items]) {
        return;
    }
    
    if (!animated) {
        //反序显示
//        _assets = [items copy];
        _assets = [[items reverseObjectEnumerator] allObjects];
        _assetURLs = [self assetURLsForAssets:_assets];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
            [self notifyAssetsReloaded];
            //从底部显示
            if (self.collectionView.contentSize.height > self.collectionView.frame.size.height) {
                self.collectionView.contentOffset = CGPointMake(0, self.collectionView.contentSize.height - self.collectionView.frame.size.height);
            }
        });
        return;
    }
    
    NSOrderedSet *oldItemSet = [NSOrderedSet orderedSetWithArray:_assetURLs];
    NSOrderedSet *newItemSet = [NSOrderedSet orderedSetWithArray:[self assetURLsForAssets:items]];
    
    NSMutableOrderedSet *deletedItems = [oldItemSet mutableCopy];
    [deletedItems minusOrderedSet:newItemSet];
    
    NSMutableOrderedSet *newItems = [newItemSet mutableCopy];
    [newItems minusOrderedSet:oldItemSet];
    
    NSMutableOrderedSet *movedItems = [newItemSet mutableCopy];
    [movedItems minusOrderedSet:oldItemSet];
    
    NSMutableArray *deletedIndexPaths = [NSMutableArray arrayWithCapacity:[deletedItems count]];
    for (id deletedItem in deletedItems) {
        [deletedIndexPaths addObject:[NSIndexPath indexPathForItem:[oldItemSet indexOfObject:deletedItem] inSection:0]];
    }
    
    NSMutableArray *insertedIndexPaths = [NSMutableArray arrayWithCapacity:[newItems count]];
    for (id newItem in newItems) {
        [insertedIndexPaths addObject:[NSIndexPath indexPathForItem:[newItemSet indexOfObject:newItem] inSection:0]];
    }
    
    NSMutableArray *fromMovedIndexPaths = [NSMutableArray arrayWithCapacity:[movedItems count]];
    NSMutableArray *toMovedIndexPaths = [NSMutableArray arrayWithCapacity:[movedItems count]];
    for (id movedItem in movedItems) {
        [fromMovedIndexPaths addObject:[NSIndexPath indexPathForItem:[oldItemSet indexOfObject:movedItem] inSection:0]];
        [toMovedIndexPaths addObject:[NSIndexPath indexPathForItem:[newItemSet indexOfObject:movedItem] inSection:0]];
    }
    
    _assets = [items copy];
    _assetURLs = [self assetURLsForAssets:_assets];
    dispatch_async(dispatch_get_main_queue(), ^{
        __weak AssetsGroupViewController *weakSelf = self;
        [self.collectionView performBatchUpdates:^{
            if ([deletedIndexPaths count]) {
                [weakSelf.collectionView deleteItemsAtIndexPaths:deletedIndexPaths];
            }
            if ([insertedIndexPaths count]) {
                [weakSelf.collectionView insertItemsAtIndexPaths:insertedIndexPaths];
            }
            NSUInteger count = [fromMovedIndexPaths count];
            for (NSUInteger i = 0; i < count; i++) {
                NSIndexPath *fromIndexPath = fromMovedIndexPaths[i];
                NSIndexPath *toIndexPath = toMovedIndexPaths[i];
                if (fromIndexPath != nil && toIndexPath != nil) {
                    [weakSelf.collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
                }
            }
        } completion:^(BOOL finished) {
            [self notifyAssetsReloaded];
        }];
    });
    
}

- (void)assetsChanged:(NSNotification *)notification {
    if (IOS_VERSION_MORE_THAN(@"6.0")) {
        NSDictionary *userInfo = notification.userInfo;
        
        NSSet *groupURLs = userInfo[ALAssetLibraryUpdatedAssetGroupsKey];
        
        if (![groupURLs containsObject:[self.assetGroup valueForProperty:ALAssetsGroupPropertyURL]]) {
            return;
        }
    }
    
    [self reloadAssetsAnimated:YES];
}

- (NSArray *)assetURLsForAssets:(NSArray *)assets {
    NSMutableArray *result = [[NSMutableArray alloc]initWithCapacity:assets.count];
    
    for (ALAsset *asset in assets) {
        if (IOS_VERSION_MORE_THAN(@"6.0")) {
            NSURL *url = [asset valueForProperty:ALAssetPropertyAssetURL];
            if (url) {
                [result addObject:url];
            }
        } else {
            //获取资源图片的详细资源信息
            ALAssetRepresentation *representation = [asset defaultRepresentation];
            NSURL *url = [representation url];
            if (url) {
                [result addObject:url];
            }
        }
    }
    return result;
}

- (void)selectAsset:(ALAsset *)asset {
    for (NSUInteger i = 0; i < _assets.count; i ++) {
        if (IOS_VERSION_MORE_THAN(@"6.0")) {
            NSURL *url = [_assets[i] valueForProperty:ALAssetPropertyAssetURL];
            if ([url isEqual:[asset valueForProperty:ALAssetPropertyAssetURL]]) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [self.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
            }
        } else {
            //获取资源图片的详细资源信息
            ALAssetRepresentation *representation = [_assets[i] defaultRepresentation];
            NSURL *url = [representation url];
            //获取资源图片的详细资源信息
            ALAssetRepresentation *newRepresentation = [asset defaultRepresentation];
            NSURL *newURL = [newRepresentation url];
            if ([url isEqual:newURL]) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [self.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
            }
        }
    }
}

- (void)deselectAsset:(ALAsset *)asset {
    for (NSUInteger i = 0; i < _assets.count; i ++) {
        if (IOS_VERSION_MORE_THAN(@"6.0")) {
            NSURL *url = [_assets[i]valueForProperty:ALAssetPropertyAssetURL];
            if ([url isEqual:[asset valueForProperty:ALAssetPropertyAssetURL]]) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
            }
        } else {
            //获取资源图片的详细资源信息
            ALAssetRepresentation *representation = [_assets[i] defaultRepresentation];
            NSURL *url = [representation url];
            //获取资源图片的详细资源信息
            ALAssetRepresentation *newRepresentation = [asset defaultRepresentation];
            NSURL *newURL = [newRepresentation url];
            if ([url isEqual:newURL]) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
            }
        }
    }
}

- (void)notifyAssetsReloaded {
    if (_delegate && [_delegate respondsToSelector:@selector(assetsGroupViewControllerDidReloadAssets:)]) {
        [_delegate assetsGroupViewControllerDidReloadAssets:self];
    }
}

//Asset Selection
- (void)selectAssetsHavingURLs:(NSSet *)assetURLs {
    for (NSUInteger i = 0; i < _assets.count; i++) {
        ALAsset *asset = _assets[i];
        if (IOS_VERSION_MORE_THAN(@"6.0")) {
            NSURL *assetURL = [asset valueForProperty:ALAssetPropertyAssetURL];
            if ([assetURLs containsObject:assetURL]) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            }else {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
            }
        } else {
            //获取资源图片的详细资源信息
            ALAssetRepresentation *representation = [asset defaultRepresentation];
            NSURL *assetURL = [representation url];
            if ([assetURLs containsObject:assetURL]) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            }else {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
            }
        }
    }
}

//Long press gesture action
- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint p = [recognizer locationInView:self.collectionView];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:p];
        if (indexPath) {
            ALAsset *asset = self.assets[(NSUInteger)indexPath.row];
            PhotoAssetCell *cell = (PhotoAssetCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            if (_delegate && [_delegate respondsToSelector:@selector(assetsGroupViewController:didLongTouch:inView:)]) {
                [_delegate assetsGroupViewController:self didLongTouch:asset inView:cell];
            }
        }
    }
}

- (void)swipeLeft:(UISwipeGestureRecognizer *)recognizer {
    if (_delegate && [_delegate respondsToSelector:@selector(assetsGroupViewController:didSwipeLeft:)]) {
        [_delegate assetsGroupViewController:self didSwipeLeft:recognizer];
    }
}

- (void)swipeRight:(UISwipeGestureRecognizer *)recognizer {
    if (_delegate && [_delegate respondsToSelector:@selector(assetsGroupViewController:didSwipeRight:)]) {
        [_delegate assetsGroupViewController:self didSwipeRight:recognizer];
    }
}

- (BOOL)showNoPhotosFound {
//    return self.assets.count == 0;
    return NO;
}


//PSTCollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self showNoPhotosFound]) {
        return 1;
    } else {
        return self.assets.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self showNoPhotosFound]) {
        NoPhotoFoundCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([NoPhotoFoundCell class]) forIndexPath:indexPath];
        return cell;
    } else {
        PhotoAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([PhotoAssetCell class]) forIndexPath:indexPath];
        
        ALAsset *asset = self.assets[(NSUInteger)indexPath.row];
        [cell updateWithAsset:asset];
        cell.selected = NO;
        
        //选中状态
        for (NSString *selectedURL in self.bottomView.allSelectedAssets) {
            if ([selectedURL isEqualToString:asset.defaultRepresentation.url.absoluteString]) {
                cell.selected = YES;
            }
        }
        
        cell.delegate = self;
        return cell;
    }
}

//PSTCollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ALAsset *asset = self.assets[(NSUInteger)indexPath.row];
    if (_delegate && [_delegate respondsToSelector:@selector(assetsGroupViewController:didSelectAsset:)]) {
        [_delegate assetsGroupViewController:self didSelectAsset:asset];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    ALAsset *asset = self.assets[(NSUInteger)indexPath.row];
    if (_delegate && [_delegate respondsToSelector:@selector(assetsGroupViewController:didDeselectAsset:)]) {
        [_delegate assetsGroupViewController:self didDeselectAsset:asset];
    }
}

//UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = CGRectGetWidth(self.view.bounds) / 4 - 1.86f;
    return CGSizeMake(width, width);
}

- (void)photoAssetCell:(PhotoAssetCell *)photoAssetCell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:photoAssetCell];
    ALAsset *asset = self.assets[(NSUInteger)indexPath.row];
    if (_delegate && [_delegate respondsToSelector:@selector(assetsGroupViewController:didTouchAsset:)]) {
        [_delegate assetsGroupViewController:self didTouchAsset:asset];
    }
    
    NSMutableArray *photos = [NSMutableArray array];
    for (ALAsset *asset in self.assets) {
        [photos addObject:[Photo photoWithURL:asset.defaultRepresentation.url]];
    }
    PhotoBrowser *browser = [[PhotoBrowser alloc] initWithPhotos:photos];
    browser.delegate = self;
    browser.maxNumberOfImages = _delegate && [_delegate respondsToSelector:@selector(numberOfSelectedImageOfAssetsGroupViewController:)] ? [_delegate numberOfSelectedImageOfAssetsGroupViewController:self] : DEFAULT_NUMBER_OF_SELECTED_IMAGE;
    browser.assetsGroup = self.assetGroup;
    browser.useWhiteBackgroundColor = NO;
    [browser setInitialPageIndex:(NSUInteger)indexPath.row];
    browser.backButtonTitle = [self.assetGroup valueForProperty:ALAssetsGroupPropertyName];
    //传进去已选中的图片的URL
    NSMutableArray *selectedPhotos = [NSMutableArray array];
    for (NSString *assetURL in self.bottomView.allSelectedAssets) {
        [selectedPhotos addObject:assetURL];
    }
    [browser insertSelectedPhotos:selectedPhotos];
    browser.useOriginalImage = self.useOriginalImage;

    [self.navigationController pushViewController:browser animated:YES];
}

- (void)photoAssetCell:(PhotoAssetCell *)photoAssetCell didTouchCheckmark:(PhotoAssetCheckmarkView *)checkmarkView {
    NSInteger numberOfSelectedImage = _delegate && [_delegate respondsToSelector:@selector(numberOfSelectedImageOfAssetsGroupViewController:)] ? [_delegate numberOfSelectedImageOfAssetsGroupViewController:self] : DEFAULT_NUMBER_OF_SELECTED_IMAGE;
    if (self.bottomView.allSelectedAssets.count >= numberOfSelectedImage && !checkmarkView.selected) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"你最多只能选择%lld张图片", (long long)numberOfSelectedImage] delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles: nil];
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
    
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:photoAssetCell];
    ALAsset *asset = self.assets[(NSUInteger)indexPath.row];
    if (_delegate && [_delegate respondsToSelector:@selector(assetsGroupViewController:didTouchCheckmark:asset:)]) {
        [_delegate assetsGroupViewController:self didTouchCheckmark:checkmarkView asset:asset];
    }
    
    //XXXXXXXXXXXXXXXXXXXXXXXX
//    PhotoBrowser *photoBrowser = [[PhotoBrowser alloc] initWithPhotoAssets:self.assets currentIndex:(NSUInteger)indexPath.row];
//    photoBrowser.delegate = self;
//    photoBrowser.dataSource = self;
//    [photoBrowser reloadData];
//    [photoBrowser moveToPageAtIndexPath:indexPath animated:NO];
//    photoBrowser.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:photoBrowser animated:YES];
    //XXXXXXXXXXXXXXXXXXXXXXXX
    
//    NSMutableArray *photos = [NSMutableArray array];
//    for (ALAsset *asset in self.assets) {
//        [photos addObject:[Photo photoWithURL:asset.defaultRepresentation.url]];
//    }
//    PhotoBrowser *browser = [[PhotoBrowser alloc] initWithPhotos:photos];
//    browser.assetsGroup = self.assetGroup;
//    browser.useWhiteBackgroundColor = NO;
//    [browser setInitialPageIndex:(NSUInteger)indexPath.row];
//    browser.backButtonTitle = [self.assetGroup valueForProperty:ALAssetsGroupPropertyName];
//    [self.navigationController pushViewController:browser animated:YES];
    
    //XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
//    [self presentViewController:browser animated:YES completion:nil];
    
    //底部Bottom
    if (checkmarkView.selected) {
        [self.bottomView insertAssetURL:asset.defaultRepresentation.url.absoluteString];
    } else {
        [self.bottomView removeAssetURL:asset.defaultRepresentation.url.absoluteString];
    }
}

- (void)photoBrowser:(PhotoBrowser *)photoBrowser didFinishWithSelectedPhotoURLs:(NSArray *)selectedPhotoURLs useOriginalImage:(BOOL)useOriginalImage {
    if (_delegate && [_delegate respondsToSelector:@selector(assetsGroupViewController:didFinishPickingMedias: useOriginalImage:)]) {
        [_delegate assetsGroupViewController:self didFinishPickingMedias:selectedPhotoURLs useOriginalImage:useOriginalImage];
    }
}

#pragma mark - bottomView
- (void)initializeBottomView {
    _bottomView = [[AssetsGroupBottomView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds) - 44, CGRectGetWidth(self.view.frame), 44)];
    _bottomView.delegate = self;
    _bottomView.displayMode = AssetsGroupBottomViewModePreview;
    [self.view addSubview:_bottomView];
    
    self.collectionView.frame = CGRectMake(CGRectGetMinX(self.collectionView.frame), CGRectGetMinY(self.collectionView.frame), CGRectGetWidth(self.collectionView.frame), CGRectGetHeight(self.collectionView.frame) - 44);
}

- (void)assetsGroupBottomView:(AssetsGroupBottomView *)bottomView didTouchFinishButton:(UIButton *)finishButton {
    if (_delegate && [_delegate respondsToSelector:@selector(assetsGroupViewController:didFinishPickingMedias:useOriginalImage:)]) {
        [_delegate assetsGroupViewController:self didFinishPickingMedias:bottomView.allSelectedAssets useOriginalImage:self.useOriginalImage];
    }
}

- (void)assetsGroupBottomView:(AssetsGroupBottomView *)bottomView didTouchPreviewButton:(UIButton *)previewButton {
    NSMutableArray *photos = [NSMutableArray array];
    for (NSString *assetURL in bottomView.allSelectedAssets) {
        [photos addObject:[Photo photoWithURL:[NSURL URLWithString:assetURL]]];
    }
    PhotoBrowser *browser = [[PhotoBrowser alloc] initWithPhotos:photos];
    browser.delegate = self;
    browser.maxNumberOfImages = _delegate && [_delegate respondsToSelector:@selector(numberOfSelectedImageOfAssetsGroupViewController:)] ? [_delegate numberOfSelectedImageOfAssetsGroupViewController:self] : DEFAULT_NUMBER_OF_SELECTED_IMAGE;
    browser.assetsGroup = self.assetGroup;
    browser.useWhiteBackgroundColor = NO;
    [browser setInitialPageIndex:0];
    browser.backButtonTitle = [self.assetGroup valueForProperty:ALAssetsGroupPropertyName];
    //传进去已选中的图片的URL
    NSMutableArray *selectedPhotos = [NSMutableArray array];
    for (NSString *assetURL in self.bottomView.allSelectedAssets) {
        [selectedPhotos addObject:assetURL];
    }
    [browser insertSelectedPhotos:selectedPhotos];
    browser.useOriginalImage = self.useOriginalImage;
    [self.navigationController pushViewController:browser animated:YES];
}

#pragma mark - PhotoBrowserDelegate
- (void)photoBrowser:(PhotoBrowser *)photoBrowser didDismissAtPageIndex:(NSInteger)index withSelectedPhotoURLs:(NSArray *)selectedPhotoURLs {
    NSLog(@"选中的全部图片路径:%@",selectedPhotoURLs);
    
    [self.bottomView resetAllAssetURLs:selectedPhotoURLs];
    [self.collectionView reloadData];
    
    self.useOriginalImage = photoBrowser.useOriginalImage;
}

- (void)cancelAction {
    if (_delegate && [_delegate respondsToSelector:@selector(didCancelAssetsGroupViewController:)]) {
        [_delegate didCancelAssetsGroupViewController:self];
    }
}

@end
