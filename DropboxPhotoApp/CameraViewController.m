//
//  CameraViewController.m
//  DropboxPhotoApp
//
//  Created by Andrew R. Kinnie on 11/9/14.
//  Copyright (c) 2014 Loopland, LLC. All rights reserved.
//

#import "CameraViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import "AssetsLibrary/AssetsLibrary.h"

@interface CameraViewController () <DBRestClientDelegate>

@property (nonatomic, strong) DBRestClient *restClient;
@property (nonatomic, strong) NSString *currentImageURL;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    self.restClient.delegate = self;
    self.activityIndicator.hidesWhenStopped = YES;
    
    self.imageView.image = [UIImage imageWithContentsOfFile:[NSTemporaryDirectory() stringByAppendingPathComponent:self.currentImage]];
}

- (IBAction)takePhoto:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker
                           animated:YES
                         completion:nil];
        self.newImage = YES;
    }
}

#pragma mark - UIImagePickerControllerDelegate Methods

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        
        self.imageView.image = image;
        
        if (self.newImage) {
            
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];

            [library writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
                if (error) {
                    NSLog(@"error");
                } else {
                    NSLog(@"url %@", assetURL);
                    self.currentImageURL = [assetURL absoluteString];
                }  
            }];

        }
    }
}



-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - Dropbox Rest Client

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath
              from:(NSString *)srcPath metadata:(DBMetadata *)metadata {
    [self displayAlertWithTitle:@"Success!" andMessage:[NSString stringWithFormat:@"File uploaded successfully to %@!", metadata.path]];
    [self.activityIndicator stopAnimating];
    self.uploadButton.enabled = YES;
    self.imageView.alpha = 1.0;

}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    [self displayAlertWithTitle:@"OOPS!" andMessage:[NSString stringWithFormat:@"File uploaded failed with error: %@!", error.localizedDescription]];
    [self.activityIndicator stopAnimating];
    self.uploadButton.enabled = YES;
    self.imageView.alpha = 1.0;

}

#pragma mark - IBAction Methods

- (IBAction)backAction:(id)sender {
}

- (IBAction)forwardAction:(id)sender {
}

- (IBAction)uploadButton:(id)sender {
    [self uploadImageToDropbox];
}

#pragma mark - Utility Methods

- (void)uploadImageToDropbox {
    // uniquely id the photo
    NSDate *date = [NSDate date];
    NSString *filename = [NSString stringWithFormat:@"Photo%lu.jpg", (unsigned long)[date timeIntervalSince1970]];

    NSString *localPath = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
    [UIImageJPEGRepresentation(self.imageView.image, 1.0) writeToFile:localPath atomically:YES];
    
//  if we decided to save as PNG and support PNG, change the filename and use this:
//  [UIImagePNGRepresentation(image) writeToFile:pngPath atomically:YES];
    
//  Debug:
//    NSError *error;
//    NSFileManager *fileMgr = [NSFileManager defaultManager];
//    NSLog(@"Temp directory: %@", [fileMgr contentsOfDirectoryAtPath:NSTemporaryDirectory() error:&error]);

    NSString *destDir = @"/";
    [self.restClient uploadFile:filename toPath:destDir withParentRev:nil fromPath:localPath];
    [self.activityIndicator startAnimating];
    self.uploadButton.enabled = NO;
    self.imageView.alpha = 0.5;
}

- (void)displayAlertWithTitle:(NSString*)titleString andMessage:(NSString*)messageString {
    [[[UIAlertView alloc]
      initWithTitle:titleString message:messageString
      delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
     show];
}

@end
