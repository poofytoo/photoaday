//
//  ViewController.m
//  snappy
//
//  Created by Victor Hung on 2/17/15.
//  Copyright (c) 2015 photoaday. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIButton *cameraButton;
@property (nonatomic) IBOutlet UIView *overlayView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *doneButton;


@property (nonatomic) UIImagePickerController *imagePickerController;

@end

@implementation ViewController




- (void) viewDidAppear:(BOOL)animated {

    
    NSLog(@"deep breath - trying to open camera now");
   
}

- (IBAction)camera:(id)sender {


    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.delegate = self;
    
    
    /*
     The user wants to use the camera interface. Set up our custom overlay view for the camera.
     */
    imagePickerController.showsCameraControls = NO;
    
    /*
     Load the overlay view from the OverlayView nib file. Self is the File's Owner for the nib file, so the overlayView outlet is set to the main view in the nib. Pass that view to the image picker controller to use as its overlay view, and set self's reference to the view to nil.
     */
    [[NSBundle mainBundle] loadNibNamed:@"OverlayView" owner:self options:nil];
    self.overlayView.frame = imagePickerController.cameraOverlayView.frame;
    imagePickerController.cameraOverlayView = self.overlayView;
    //self.overlayView = nil;
    
    
    self.imagePickerController = imagePickerController;
    [self presentViewController:self.imagePickerController animated:NO completion:nil];
}

- (void)finishAndUpdate
{
    [self dismissViewControllerAnimated:NO completion:NULL];
    //[self.imageView setImage:[self.capturedImages objectAtIndex:0]];
    
    self.imagePickerController = nil;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    // self.camera = [[CameraViewController alloc] init];
    NSLog(@"View Appeared");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
