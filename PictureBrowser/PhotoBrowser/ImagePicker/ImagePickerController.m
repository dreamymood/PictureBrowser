//
//  ImagePickerController.m
//  ImagePickerNew
//
//  Created by admin on 15/6/1.
//  Copyright (c) 2015年 admin. All rights reserved.
//

#import "ImagePickerController.h"
#import "ImagePickerGroupCell.h"
#import "PhotoAccessDeniedView.h"
#import "NoPhotoFoundTableCell.h"
#import "UIViewController+ImagePicker.h"

//版本支持
#define IOS_VERSION_MORE_THAN(__VERSIONSTRING) ([[[UIDevice currentDevice]systemVersion]compare:__VERSIONSTRING options:NSNumericSearch]==NSOrderedDescending)

#define IMAGE_PICKER_GROUP_CELL_HEIGHT  86.0

static const int itemSpacing = 2;

ALAssetsFilter *ALAssetFilterFromImagePickerControllerFilterType(ImagePickerControllerFilterType type) {
    switch (type) {
        case ImagePickerControllerFilterTypeNone:
            return [ALAssetsFilter allAssets];
        case ImagePickerControllerFilterTypePhotos:
            return [ALAssetsFilter allPhotos];
        case ImagePickerControllerFilterTypeVideos:
            return [ALAssetsFilter allVideos];
            
        default:
            return [ALAssetsFilter allAssets];
    }
}

@interface ImagePickerController () <UIAlertViewDelegate,UITableViewDelegate,UITableViewDataSource,AssetsGroupViewControllerDelegate>

@property (nonatomic,copy)NSArray *groupTypes;
@property (nonatomic,strong)ALAssetsLibrary *assetsLibrary;
@property (nonatomic,copy,readwrite)NSArray *assetsGroups;

@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)PhotoAccessDeniedView *genericPhotoAccessDeniedView;
@property (nonatomic,strong)UIView *currentPhotoAccessDeniedView;

@property (nonatomic,assign)BOOL firstLoad;
@property (nonatomic,assign)BOOL viewDidAppear;
@property (nonatomic,strong,readwrite)NSSet *selectedAssetURLs;

@property (nonatomic)NSInteger assetsGroupIndex;

- (void)showDeniedView;
- (void)hideDeniedView;

- (void)selectedAssetURLsAddAsset:(ALAsset *)asset;
- (void)selectedAssetURLsRemoveAsset:(ALAsset *)asset;

@end

@implementation ImagePickerController

//+ (BOOL)isAuthorized __unused {
//    return [ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized;
//}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.photoPermissionMessage = @"Enable Photo Access?";
        self.filterType = ImagePickerControllerFilterTypePhotos;
        self.viewDidAppear = NO;
        
        self.selectedAssetURLs = [NSSet set];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(assetsGroupChanged:) name:ALAssetsLibraryChangedNotification object:nil];
    }
    return self;
}

- (instancetype)initWithFlag:(BOOL)flag {
    self = [super init];
    if (self) {
        self.photoPermissionMessage = @"Enable Photo Access?";
        self.filterType = ImagePickerControllerFilterTypePhotos;
        self.firstLoad = YES;
        self.viewDidAppear = NO;
        
        self.selectedAssetURLs = [NSSet set];
        self.flag = flag;
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(assetsGroupChanged:) name:ALAssetsLibraryChangedNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ALAssetsLibraryChangedNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"相册";
    self.assetsLibrary = [[ALAssetsLibrary alloc]init];
    [self.assetsLibrary writeImageToSavedPhotosAlbum:nil metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
    }];
    self.groupTypes = @[@(ALAssetsGroupSavedPhotos),@(ALAssetsGroupLibrary),@(ALAssetsGroupAlbum)];
    
    [self.view addSubview:self.tableView];
    
    self.view.backgroundColor = [UIColor colorWithRed:242.0 / 255.0 green:242.0 / 255.0 blue:242.0 / 255.0 alpha:1.0];
    
    [self createBarButtonItemAtPositon:NavigationBarButtonPositionRight text:@"取消" action:@selector(cancelAction)];
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tableView.frame = self.view.bounds;
    [self loadAssetsGroups];
//    if (IOS_VERSION_MORE_THAN(@"6.0")) {
//        if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusNotDetermined) {
//            [self showAskForPermissionDialog];
//        } else if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusDenied) {
//            [self showDeniedView];
//        }else if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized) {
//            [self loadAssetsGroups];
//        } else {
//            NSLog(@"unknown");
//        }
//    } else {
//        [self loadAssetsGroups];
//    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.viewDidAppear = YES;
    ALAssetsGroup *assetsGroup = [self.assetsGroups firstObject];
    if (self.firstLoad && assetsGroup && self.flag == YES) {
        self.firstLoad = NO;
        [self displayAssetsGroupViewController:assetsGroup animated:NO push:YES];
    } else if (self.firstLoad && assetsGroup && self.flag == NO) {
        self.firstLoad = NO;
        [self loadAssetsGroups];
    }
//    if (IOS_VERSION_MORE_THAN(@"6.0")) {
//        if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized && self.firstLoad && assetsGroup) {
//            self.firstLoad = NO;
//            [self displayAssetsGroupViewController:assetsGroup animated:NO push:YES];
//        }
//    } else {
//        if (self.firstLoad && assetsGroup) {
//            self.firstLoad = NO;
//            [self displayAssetsGroupViewController:assetsGroup animated:NO push:YES];
//        }
//    }
}

//ALAssetsLibraryChangedNotification
- (void)assetsGroupChanged:(NSNotification *)notification {
    if (IOS_VERSION_MORE_THAN(@"6.0")) {
        NSDictionary *userInfo = notification.userInfo;
        NSSet *groupURLs = userInfo[ALAssetLibraryUpdatedAssetGroupsKey];
        BOOL isContain = NO;
        for (ALAssetsGroup *assetsGroup in self.assetsGroups) {
            if ([groupURLs containsObject:[assetsGroup valueForProperty:ALAssetsGroupPropertyURL]]) {
                isContain = YES;
            }
        }
        if (isContain == NO) {
            return;
        }
    }
    [self loadAssetsGroups];
}

//buttonAction
- (void)cancelAction {
    if (_delegate && [_delegate respondsToSelector:@selector(didCancelImagePickerController:)]) {
        [_delegate didCancelImagePickerController:self];
    }
}

- (BOOL)flag {
    if (!_flag) {
        _flag = NO;
    }
    return _flag;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.frame];
        _tableView.backgroundColor = [UIColor colorWithRed:242.0 / 255.0 green:242.0 / 255.0 blue:242.0 / 255.0 alpha:1.0];
        _tableView.allowsMultipleSelection = NO;
        _tableView.clipsToBounds = YES;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        
        if (IOS_VERSION_MORE_THAN(@"6.0")) {
            [_tableView registerClass:[ImagePickerGroupCell class] forCellReuseIdentifier:NSStringFromClass([ImagePickerGroupCell class])];
            [_tableView registerClass:[NoPhotoFoundTableCell class] forCellReuseIdentifier:NSStringFromClass([NoPhotoFoundTableCell class])];
        }
    }
    return _tableView;
}

- (PhotoAccessDeniedView *)genericPhotoAccessDeniedView {
    if (!_genericPhotoAccessDeniedView) {
        _genericPhotoAccessDeniedView = [PhotoAccessDeniedView new];
    }
    return _genericPhotoAccessDeniedView;
}

- (void)showDeniedView {
    [self.tableView removeFromSuperview];
    self.title = @"Permissions";
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(imagePickerController:viewForCameraRollAccesResuingView:)]) {
        self.currentPhotoAccessDeniedView = [self.delegate imagePickerController:self viewForCameraRollAccesResuingView:self.currentPhotoAccessDeniedView];
    } else {
        self.currentPhotoAccessDeniedView = self.genericPhotoAccessDeniedView;
    }
    
    self.currentPhotoAccessDeniedView.frame = self.view.bounds;
    [self.view addSubview:self.currentPhotoAccessDeniedView];
}

- (void)hideDeniedView __unused {
    [self.currentPhotoAccessDeniedView removeFromSuperview];
    self.title = @"Albums";
}

- (void)showAskForPermissionDialog __unused {
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"Let %@ Access Photos?",appName] message:self.photoPermissionMessage delegate:self cancelButtonTitle:@"Not Now" otherButtonTitles:@"Give Access", nil];
    [alert show];
}

//UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self showDeniedView];
    } else if (buttonIndex == 1) {
        [self loadAssetsGroups];
    }
}

- (void)loadAssetsGroups {
    [self loadAssetsGroupsWithTypes:self.groupTypes completion:^(NSArray *assetsGroups) {
        self.assetsGroups = assetsGroups;
        if (self.viewDidAppear && self.firstLoad) {
            ALAssetsGroup *assetsGroup = [assetsGroups firstObject];
            self.firstLoad = NO;
            if (assetsGroup) {
                [self displayAssetsGroupViewController:assetsGroup animated:NO push:YES];
            } else {
                [self.tableView reloadData];
            }
            [self.tableView reloadData];
        } else if (self.assetsGroups.count == 0) {
            self.firstLoad = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        } else if (!self.firstLoad) {
            [self.tableView reloadData];
        } else {
            [self.tableView reloadData];
        }
    }];
}

- (void)loadAssetsGroupsWithTypes:(NSArray *)types completion:(void(^)(NSArray *assetsGroups))completion {
    __block NSMutableArray *assetsGroups = [NSMutableArray array];
    __block NSUInteger numberOfFinishedTypes = 0;
    
    for (NSNumber *type in types) {
        __weak ImagePickerController *weakSelf = self;
        [self.assetsLibrary enumerateGroupsWithTypes:[type unsignedIntegerValue] usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group) {
                [group setAssetsFilter:ALAssetFilterFromImagePickerControllerFilterType(weakSelf.filterType)];
                
                if (group.numberOfAssets > 0) {
                    [assetsGroups addObject:group];
                }
            }else {
                numberOfFinishedTypes ++;
            }
            if (numberOfFinishedTypes == types.count) {
//                NSArray *sortedAssetsGroups = [self sortAssetsGroups:assetsGroups typesOrder:types];
                
                if (completion) {
//                    completion(sortedAssetsGroups);
                    completion(assetsGroups);
                }
            }
        } failureBlock:^(NSError *error) {
            NSLog(@"rror: %@",error.localizedDescription);
            [weakSelf showDeniedView];
        }];
    }
}

- (NSArray *)sortAssetsGroups:(NSArray *)assetsGroups typesOrder:(NSArray *)typesOrder {
    NSMutableArray *sortedAssetsGroups = [NSMutableArray array];
    
    for (ALAssetsGroup *assetsGroup in assetsGroups) {
        if (sortedAssetsGroups.count == 0) {
            [sortedAssetsGroups addObject:assetsGroup];
            continue;
        }
        ALAssetsGroupType assetsGroupType = [[assetsGroup valueForProperty:ALAssetsGroupPropertyType]unsignedIntegerValue];
        NSUInteger indexOfAssetsGroupType = [typesOrder indexOfObject:@(assetsGroupType)];
        
        for (NSUInteger i = 0; i < sortedAssetsGroups.count; i ++) {
            if (i == sortedAssetsGroups.count) {
                [sortedAssetsGroups addObject:assetsGroup];
                break;
            }
            
            ALAssetsGroup *assetsGroup = sortedAssetsGroups[i];
            ALAssetsGroupType assetsGroupType = [[assetsGroup valueForProperty:ALAssetsGroupPropertyType]unsignedIntegerValue];
            NSUInteger indexOfSortedAssetsGroupType = [typesOrder indexOfObject:@(assetsGroupType)];
            
            if (indexOfAssetsGroupType < indexOfSortedAssetsGroupType) {
                [sortedAssetsGroups insertObject:assetsGroup atIndex:i];
                break;
            }
        }
    }
    return [sortedAssetsGroups copy];
}

- (void)selectAsset:(ALAsset *)asset __unused {
    [self selectedAssetURLsAddAsset:asset];
    
    if (self.assetsGroupViewController) {
        [self.assetsGroupViewController selectAsset:asset];
    }
}

- (void)deselectAsset:(ALAsset *)asset __unused {
    [self selectedAssetURLsAddAsset:asset];
    
    if (self.assetsGroupViewController) {
        [self.assetsGroupViewController deselectAsset:asset];
    }
}

- (void)displayAssetsGroupViewController:(ALAssetsGroup *)assetGroup animated:(BOOL)animated push:(BOOL)push {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumInteritemSpacing = itemSpacing;
    layout.minimumLineSpacing = itemSpacing;
    layout.sectionInset = UIEdgeInsetsZero;
    
    self.assetsGroupViewController = [[AssetsGroupViewController alloc]initWithCollectionViewLayout:layout];
    
    self.assetsGroupViewController.assetsLibrary = self.assetsLibrary;
    self.assetsGroupViewController.assetGroup = assetGroup;
    self.assetsGroupViewController.delegate = self;
    
    [self.assetsGroupViewController selectAssetsHavingURLs:self.selectedAssetURLs];
    
    if (push) {
        [self.navigationController pushViewController:self.assetsGroupViewController animated:animated];
    } else {
        [self.navigationController popViewControllerAnimated:animated];
    }
}

//AssetsGroupViewController delegate
- (void)assetsGroupViewController:(AssetsGroupViewController *)assetsGroupViewController didSelectAsset:(ALAsset *)asset {
    [self selectedAssetURLsAddAsset:asset];
    
    if (_delegate && [_delegate respondsToSelector:@selector(imagePickerController:didSelectAsset:)]) {
        [self.delegate imagePickerController:self didSelectAsset:asset];
    }
}

- (void)assetsGroupViewController:(AssetsGroupViewController *)assetsGroupViewController didDeselectAsset:(ALAsset *)asset {
    [self selectedAssetURLsRemoveAsset:asset];
    
    if (_delegate && [_delegate respondsToSelector:@selector(imagePickerController:didDeselectAsset:)]) {
        [self.delegate imagePickerController:self didDeselectAsset:asset];
    }
}

- (void)assetsGroupViewController:(AssetsGroupViewController *)assetsGroupViewController didSwipeLeft:(UISwipeGestureRecognizer *)recognizer {
    NSInteger newIndex = self.assetsGroupIndex + 1;
    if (newIndex <= self.assetsGroups.count - 1) {
        ALAssetsGroup *assetsGroup = self.assetsGroups[(NSUInteger)newIndex];
        [self displayAssetsGroupViewController:assetsGroup animated:YES push:YES];
    }
}

- (void)assetsGroupViewController:(AssetsGroupViewController *)assetsGroupViewController didSwipeRight:(UISwipeGestureRecognizer *)recognizer {
    NSInteger newIndex = self.assetsGroupIndex - 1;
    if (newIndex >= 0) {
        ALAssetsGroup *assetsGroup = self.assetsGroups[(NSUInteger)newIndex];
        [self displayAssetsGroupViewController:assetsGroup animated:YES push:NO];
    }
}

- (void)assetsGroupViewController:(AssetsGroupViewController *)assetsGroupViewController didAppear:(ALAssetsGroup *)assetsGroup {
    self.assetsGroupIndex = [self.assetsGroups indexOfObject:assetsGroup];
}

- (void)assetsGroupViewController:(AssetsGroupViewController *)assetsGroupViewController didLongTouch:(ALAsset *)asset inView:(UIView *)cell {
    if (_delegate && [_delegate respondsToSelector:@selector(imagePickerController:didLongTouch:inView:)]) {
        [self.delegate imagePickerController:self didLongTouch:asset inView:cell];
    }
}

- (void)assetsGroupViewControllerDidReloadAssets:(AssetsGroupViewController *)assetsGroupViewController {
    [self.assetsGroupViewController selectAssetsHavingURLs:self.selectedAssetURLs];
}

- (void)assetsGroupViewController:(AssetsGroupViewController *)assetsGroupViewController didFinishPickingMedias:(NSArray *)medias useOriginalImage:(BOOL)useOriginalImage {
    if (_delegate && [_delegate respondsToSelector:@selector(imagePickerController:didFinishPickingMedias:useOriginalImage:)]) {
        [_delegate imagePickerController:self didFinishPickingMedias:medias useOriginalImage:useOriginalImage];
    }
}

- (void)selectedAssetURLsAddAsset:(ALAsset *)asset {
    NSMutableSet *mSet = [self.selectedAssetURLs mutableCopy];
    if (IOS_VERSION_MORE_THAN(@"6.0")) {
        NSURL *assetURL = [asset valueForProperty:ALAssetPropertyAssetURL];
        [mSet addObject:assetURL];
        self.selectedAssetURLs = mSet;
    } else {
        //获取资源图片的详细资源信息
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        NSURL *assetURL = [representation url];
        [mSet addObject:assetURL];
        self.selectedAssetURLs = mSet;
    }
}

- (void)selectedAssetURLsRemoveAsset:(ALAsset *)asset {
    NSMutableSet *mSet = [self.selectedAssetURLs mutableCopy];
    if (IOS_VERSION_MORE_THAN(@"6.0")) {
        NSURL *assetURL = [asset valueForProperty:ALAssetPropertyAssetURL];
        [mSet removeObject:assetURL];
        self.selectedAssetURLs = mSet;
    } else {
        //获取资源图片的详细资源信息
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        NSURL *assetURL = [representation url];
        [mSet removeObject:assetURL];
        self.selectedAssetURLs = mSet;
    }
}

- (BOOL)showNoPhotosFound {
    return !self.firstLoad && self.assetsGroups.count == 0;
}

//TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self showNoPhotosFound]) {
        return 1;
    } else {
        return self.assetsGroups.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self showNoPhotosFound]) {
        NoPhotoFoundTableCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NoPhotoFoundTableCell class]) forIndexPath:indexPath];
        return cell;
    } else {
        ImagePickerGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ImagePickerGroupCell class]) forIndexPath:indexPath];
        ALAssetsGroup *assetsGroup = self.assetsGroups[(NSUInteger)indexPath.row];
        
        cell.selectedBackgroundView = [[UIView alloc] init];
        cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:137.0 / 255.0 green:153.0 / 255.0 blue:167.0 / 255.0 alpha:0.3];
        [cell updateAssetsGroup:assetsGroup];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self showNoPhotosFound]) {
        return IMAGE_PICKER_GROUP_CELL_HEIGHT * 2;
    } else {
        return IMAGE_PICKER_GROUP_CELL_HEIGHT;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self showNoPhotosFound]) {
        return;
    } else {
        ALAssetsGroup *assetGroup = self.assetsGroups[(NSUInteger)indexPath.row];
        [self displayAssetsGroupViewController:assetGroup animated:YES push:YES];
    }
}

//AssetsGroupViewController
- (void)assetsGroupViewController:(AssetsGroupViewController *)assetsGroupViewController didTouchAsset:(ALAsset *)asset {
    if (_delegate && [_delegate respondsToSelector:@selector(imagePickerController:didTouchAsset:)]) {
        [_delegate imagePickerController:self didTouchAsset:asset];
    }
}

- (void)didCancelAssetsGroupViewController:(AssetsGroupViewController *)assetsGroupViewController {
    [self cancelAction];
}

- (NSInteger)numberOfSelectedImageOfAssetsGroupViewController:(AssetsGroupViewController *)assetsGroupViewController {
    if (_delegate && [_delegate respondsToSelector:@selector(numberOfSelectedImageOfImagePickerController:)]) {
        return [_delegate numberOfSelectedImageOfImagePickerController:self];
    }
    return DEFAULT_NUMBER_OF_SELECTED_IMAGE;
}

@end
