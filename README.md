# PictureBrowser
PictureBrowser

It is a photos picker that can select photos from own photo album and look up in the browser.
It is simular to weixin's picture picker.

You can use it like that:

ImagePickerNavViewController *imagePicker = [[ImagePickerNavViewController alloc]initWithImagePickerMode:ImagePickerModeUseOriginalImage];
 imagePicker.pickerDelegate = self;

It also has two call-back.

- (NSInteger)numberOfSelectedImageOfImagePickerNavViewControllerDelegate:(ImagePickerNavViewController *)imagePickerController;
- (void)imagePickerNavViewControllerDelegate:(ImagePickerNavViewController *)imagePickerController didFinishPickingMedias:(NSArray *)medias useOriginalImage:(BOOL)useOriginalImage;

