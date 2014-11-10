//
//  PhotosCollectionViewController.m
//  DropboxPhotoApp
//
//  Created by Andrew R. Kinnie on 11/7/14.
//  Copyright (c) 2014 Loopland, LLC. All rights reserved.
//

#import "PhotosCollectionViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import "PhotoCell.h"
#import "CameraViewController.h"

@interface PhotosCollectionViewController () //<DBRestClientDelegate>

//@property(nonatomic, strong) NSMutableArray *photos;

@property (nonatomic, strong) NSString* currentPhotoPath;
//@property (nonatomic, strong) DBRestClient* restClient;

@property (nonatomic, assign) NSInteger currentSelectedIndex;

@end


@implementation PhotosCollectionViewController

- (void)viewDidLoad {
//    self.photos = [[NSMutableArray alloc] init];
    self.title = @"Dropbox Photos";
//    [self.restClient loadMetadata:@"/"];
    self.currentSelectedIndex = -1;
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    CameraViewController *cameraViewController = segue.destinationViewController;
//    NSString *photoPath = [self.photos objectAtIndex:self.currentSelectedIndex];

    cameraViewController.currentIndex = self.currentSelectedIndex;
    cameraViewController.photos = self.photos;
    
}

#pragma mark DBRestClientDelegate methods

//- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata {
//    
//    NSArray* validExtensions = [NSArray arrayWithObjects:@"jpg", @"jpeg", nil];
//
//    if (!self.photos) {
//        self.photos = [[NSMutableArray alloc] init];
//    }
//    for (DBMetadata* fileObject in metadata.contents) {
//        NSString* extension = [[fileObject.path pathExtension] lowercaseString];
//        if (!fileObject.isDirectory && [validExtensions indexOfObject:extension] != NSNotFound) {
//            [self.photos addObject:fileObject.path];
//            [self.restClient loadFile:fileObject.path intoPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[fileObject.path lastPathComponent]]];
//        }
//    }
//    [self.collectionView reloadData];
//}
//
//- (void)restClient:(DBRestClient*)client metadataUnchangedAtPath:(NSString*)path {
//    NSLog(@"metadata unchanged at path: %@", path);
//}
//
//- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error {
//    NSLog(@"restClient:loadMetadataFailedWithError: %@", [error localizedDescription]);
//    [self displayErrorWithTitle:@"Loading Failed" andMessage:[error localizedDescription]];
//}
//
//- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)localPath
//       contentType:(NSString *)contentType metadata:(DBMetadata *)metadata {
//    NSLog(@"File loaded into path: %@", localPath);
//}
//
//- (void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error {
//    NSLog(@"There was an error loading the file: %@", [error localizedDescription]);
//}
//
//- (DBRestClient*)restClient {
//    if (_restClient == nil) {
//        _restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
//        _restClient.delegate = self;
//    }
//    return _restClient;
//}


#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return self.photos.count;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    NSString *photoPath = [self.photos objectAtIndex:indexPath.row];

    cell.imageView.image = [UIImage imageWithContentsOfFile:[NSTemporaryDirectory() stringByAppendingPathComponent:[photoPath lastPathComponent]]];

    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [cell.imageView sizeToFit];

    cell.backgroundColor = self.collectionView.backgroundColor;
    return cell;
}


#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.currentSelectedIndex = indexPath.row;
    return YES;
}

- (void)collectionView:(UICollectionView*)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UIImage *image = [UIImage imageWithContentsOfFile:[NSTemporaryDirectory() stringByAppendingPathComponent:[self.photos[indexPath.row] lastPathComponent]]];

    CGFloat maxWidth = 100;
    CGSize imageSize = (image.size.width > 0 && image.size.width < maxWidth) ? image.size : CGSizeMake(100, 100);
    return imageSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

#pragma mark - Utility Methods

- (void)displayErrorWithTitle:(NSString*)titleString andMessage:(NSString*)messageString {
    [[[UIAlertView alloc]
       initWithTitle:titleString message:messageString
       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
     show];
}

@end
