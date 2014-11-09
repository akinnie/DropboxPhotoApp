//
//  PhotoViewController.m
//  DropboxPhotoApp
//
//  Created by Andrew R. Kinnie on 11/7/14.
//  Copyright (c) 2014 Loopland, LLC. All rights reserved.
//

#import "PhotoViewController.h"
#import <DropboxSDK/DropboxSDK.h>

@interface PhotoViewController () <DBRestClientDelegate>

@property (nonatomic, strong) DBRestClient* restClient;

@property (nonatomic, weak) IBOutlet UIImageView* imageView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView* activityIndicator;

@property (nonatomic, assign) BOOL networkActivity;

- (void)setNetworkActive:(BOOL)active;

@end

@implementation PhotoViewController

#pragma mark - DB Rest Client

- (void)restClient:(DBRestClient*)client loadedThumbnail:(NSString*)destPath {
    [self setNetworkActive:NO];
    
    self.imageView.image = [UIImage imageWithContentsOfFile:destPath];
}

- (void)restClient:(DBRestClient*)client metadataUnchangedAtPath:(NSString*)path {
    NSLog(@"metadata unchanged at path: %@", path);
}

- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error {
    NSLog(@"restClient:loadMetadataFailedWithError: %@", [error localizedDescription]);
    [self displayErrorWithTitle:@"Loading Failed" andMessage:[error localizedDescription]];
    [self setNetworkActive:NO];
}

- (void)restClient:(DBRestClient*)client loadThumbnailFailedWithError:(NSError*)error {
    [self setNetworkActive:NO];
    [self displayErrorWithTitle:@"Loading Failed" andMessage:[error localizedDescription]];
}

#pragma mark - Utility Methods

- (void)setNetworkActive:(BOOL)active {
    if (self.networkActivity != active) {
        
        self.networkActivity = active;
        if (self.networkActivity) {
            [self.activityIndicator startAnimating];
        } else {
            [self.activityIndicator stopAnimating];
        }
    }
}

- (void)displayErrorWithTitle:(NSString*)titleString andMessage:(NSString*)messageString {
    [[[UIAlertView alloc]
      initWithTitle:titleString message:messageString
      delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
     show];
}

@end
