//
//  ViewController.m
//  DropboxPhotoApp
//
//  Created by Andrew R. Kinnie on 11/7/14.
//  Copyright (c) 2014 Loopland, LLC. All rights reserved.
//

#import "RootViewController.h"
#import <DropboxSDK/DropboxSDK.h>

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    [self setupButtons];
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
    self.viewPhotosButton.enabled = accountLinked ? YES : NO;
    
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

//- (IBAction)didPressPhotos {
//    [self.navigationController pushViewController:photoViewController animated:YES];
//}



//- (void)viewDidLoad {
//    [super viewDidLoad];
//    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
//                                               initWithTitle:@"Photos" style:UIBarButtonItemStylePlain
//                                               target:self action:@selector(didPressPhotos)] autorelease];
//    self.title = @"Link Account";
//}

//- (void)viewDidUnload {
//    linkButton = nil;
//}

//- (void)dealloc {
//    [linkButton release];
//    [photoViewController release];
//    [super dealloc];
//}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
//        return toInterfaceOrientation == UIInterfaceOrientationPortrait;
//    } else {
//        return YES;
//    }
//}

@end
