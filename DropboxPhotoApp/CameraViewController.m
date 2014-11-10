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

- (void)imageNotUploaded:(BOOL)notUploaded;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    self.restClient.delegate = self;
    self.activityIndicator.hidesWhenStopped = YES;
    
    if (self.currentIndex != NSNotFound) {
            self.imageView.image = [UIImage imageWithContentsOfFile:[NSTemporaryDirectory() stringByAppendingPathComponent:[self.photos objectAtIndex:self.currentIndex]]];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.imageView sizeToFit];
    }
    self.imageNotUploadedLabel.hidden = YES;
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
                    [self imageNotUploaded:YES];
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

    [self.restClient loadMetadata:@"/"];
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    [self displayAlertWithTitle:@"OOPS!" andMessage:[NSString stringWithFormat:@"File uploaded failed with error: %@!", error.localizedDescription]];
    [self.activityIndicator stopAnimating];
    self.uploadButton.enabled = YES;
    self.imageView.alpha = 1.0;
    
    [self imageNotUploaded:YES];

}

- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata {
    
    NSArray* validExtensions = [NSArray arrayWithObjects:@"jpg", @"jpeg", nil];
    
    if (!self.photos) {
        self.photos = [[NSMutableArray alloc] init];
    }
    for (DBMetadata* fileObject in metadata.contents) {
        NSString* extension = [[fileObject.path pathExtension] lowercaseString];
        if (!fileObject.isDirectory && [validExtensions indexOfObject:extension] != NSNotFound) {
            if ([self.photos indexOfObject:fileObject.path] == NSNotFound) {
                [self.photos addObject:fileObject.path];
                [self.restClient loadFile:fileObject.path intoPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[fileObject.path lastPathComponent]]];
            }
        }
    }
    [self imageNotUploaded:NO];
}

#pragma mark - IBAction Methods

- (IBAction)backAction:(id)sender {
    
    if (self.currentIndex < self.photos.count -1) {
        self.currentIndex++;
    } else {
        self.currentIndex = 0;
    }
    self.imageView.image = [UIImage imageWithContentsOfFile:[NSTemporaryDirectory() stringByAppendingPathComponent:[self.photos objectAtIndex:self.currentIndex]]];
}

- (IBAction)forwardAction:(id)sender {

    if (self.currentIndex > 0) {
        self.currentIndex--;
    } else {
        self.currentIndex = self.photos.count -1;
    }
    self.imageView.image = [UIImage imageWithContentsOfFile:[NSTemporaryDirectory() stringByAppendingPathComponent:[self.photos objectAtIndex:self.currentIndex]]];

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

- (void)imageNotUploaded:(BOOL)notUploaded {
    self.backButton.enabled = (notUploaded) ? NO : YES;
    self.forwardButton.enabled = (notUploaded) ? NO : YES;
    self.imageNotUploadedLabel.hidden = (notUploaded) ? NO : YES;
}

-(IBAction)shareButtonTapped:(id)sender {
    NSArray* arrayWithImage = @[self.imageView.image];
    
    UIActivityViewController* activityViewController = [[UIActivityViewController alloc] initWithActivityItems:arrayWithImage applicationActivities:nil];
    if ([activityViewController respondsToSelector:@selector(popoverPresentationController)]) {
        activityViewController.popoverPresentationController.barButtonItem = self.uploadButton;
    }
    [self.navigationController presentViewController:activityViewController animated:YES completion:^{
        NSLog(@"share completed...");
    }];
}

@end
