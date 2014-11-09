//
//  ViewController.h
//  DropboxPhotoApp
//
//  Created by Andrew R. Kinnie on 11/7/14.
//  Copyright (c) 2014 Loopland, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (weak, nonatomic) IBOutlet UIButton *takePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *viewPhotosButton;

- (IBAction)loginAction:(id)sender;

@end

