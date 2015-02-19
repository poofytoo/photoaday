//
//  ViewController.h
//  Snappy
//
//  Created by Victor Hung on 2/17/15.
//  Copyright (c) 2015 photoaday. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Firebase/Firebase.h>

@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UILabel *labelPrompt;
@property (strong, nonatomic) IBOutlet UIImageView *imagePrompt;
@property (strong, nonatomic) IBOutlet UILabel *labelBasePrompt;
@property (strong, nonatomic) IBOutlet UIImageView *imageBasePrompt;

@property (strong, nonatomic) Firebase *fb;
@property (strong, nonatomic) Firebase *currentFb;


@end

