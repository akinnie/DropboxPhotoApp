//
//  CameraViewController.h
//  DropboxPhotoApp
//
//  Created by Andrew R. Kinnie on 11/9/14.
//  Copyright (c) 2014 Loopland, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface CameraViewController : UIViewController <UIImagePickerControllerDelegate,
UINavigationControllerDelegate>

@property BOOL newImage;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *uploadButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) NSString *currentImage;

- (IBAction)takePhoto:(id)sender;
- (IBAction)backAction:(id)sender;
- (IBAction)forwardAction:(id)sender;
- (IBAction)uploadButton:(id)sender;

@end