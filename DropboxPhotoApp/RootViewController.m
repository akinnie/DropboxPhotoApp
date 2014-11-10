//
//  ViewController.m
//  DropboxPhotoApp
//
//  Created by Andrew R. Kinnie on 11/7/14.
//  Copyright (c) 2014 Loopland, LLC. All rights reserved.
//

#import "RootViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import "CameraViewController.h"
#import "PhotosCollectionViewController.h"

@interface RootViewController () <DBRestClientDelegate>

@property (nonatomic, strong) DBRestClient* restClient;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    self.photos = [[NSMutableArray alloc] init];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupButtons) name:@"DropboxLinkedNotification" object:nil];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupButtons];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupButtons {
    BOOL accountLinked = [[DBSession sharedSession] isLinked];
    self.takePhotoButton.enabled = accountLinked ? YES : NO;
    self.viewPhotosButton.enabled = (accountLinked && self.photos.count > 0)? YES : NO;
    
    if (self.photos.count == 0 &&  accountLinked) {
        [self.restClient loadMetadata:@"/"];
    } else if (!accountLinked) {
        self.photos = nil;
        self.photos = [[NSMutableArray alloc] init];
    }
    
    NSString *loginButtonTitle = accountLinked ? @"Logout" : @"Link to Dropbox";
    [self.loginButton setTitle: loginButtonTitle forState: UIControlStateNormal];
}

- (IBAction)loginAction:(id)sender {
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
    } else {
        [[DBSession sharedSession] unlinkAll];
        [[[UIAlertView alloc]
           initWithTitle:@"Warning" message:@"You have logged out of Dropbox"
           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
         show];
    }
    [self setupButtons];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if (sender == self.takePhotoButton) {
        CameraViewController *cameraViewController = segue.destinationViewController;
        cameraViewController.photos = self.photos;

        cameraViewController.currentIndex = (self.photos.count > 0) ? 0 : NSNotFound;

    } else if (sender == self.viewPhotosButton) {
        PhotosCollectionViewController *photosCollectionViewController = segue.destinationViewController;
        photosCollectionViewController.photos = self.photos;
    }

}

- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata {
    
    NSArray* validExtensions = [NSArray arrayWithObjects:@"jpg", @"jpeg", nil];
    
    if (!self.photos) {
        self.photos = [[NSMutableArray alloc] init];
    }
    for (DBMetadata* fileObject in metadata.contents) {
        NSString* extension = [[fileObject.path pathExtension] lowercaseString];
        if (!fileObject.isDirectory && [validExtensions indexOfObject:extension] != NSNotFound) {
            [self.photos addObject:fileObject.path];
            [self.restClient loadFile:fileObject.path intoPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[fileObject.path lastPathComponent]]];
        }
    }
    
    [self setupButtons];

}

- (void)restClient:(DBRestClient*)client metadataUnchangedAtPath:(NSString*)path {
    NSLog(@"metadata unchanged at path: %@", path);
}

- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error {
    NSLog(@"restClient:loadMetadataFailedWithError: %@", [error localizedDescription]);
}

- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)localPath
       contentType:(NSString *)contentType metadata:(DBMetadata *)metadata {
    NSLog(@"File loaded into path: %@", localPath);
}

- (void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error {
    NSLog(@"There was an error loading the file: %@", [error localizedDescription]);
}

- (DBRestClient*)restClient {
    if (_restClient == nil) {
        _restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        _restClient.delegate = self;
    }
    return _restClient;
}

@end
