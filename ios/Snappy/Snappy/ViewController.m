//
//  ViewController.m
//  snappy
//
//  Created by Victor Hung on 2/17/15.
//  Copyright (c) 2015 photoaday. All rights reserved.
//

#import "ViewController.h"
#import <Firebase/Firebase.h>

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIButton *cameraButton;
@property (nonatomic) IBOutlet UIView *overlayView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *doneButton;
@property (strong, nonatomic) IBOutlet UIImageView *imagePreview;

@property (nonatomic) UIImage *activeImage;
@property (nonatomic) NSMutableArray *capturedImages;
@property (nonatomic) UIImagePickerController *imagePickerController;
@end

@implementation ViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.fb = [[Firebase alloc] initWithUrl: @"https://az.firebaseio.com/snappy"];
    
    NSLog(@"View Loaded");
}

- (void) viewDidAppear:(BOOL)animated {
    if (self.activeImage == nil) {
        [self openCameraPane];
        
        [self.fb observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            NSLog(@"Fetching new Firebase Data...");
            self.labelPrompt.text = snapshot.value[@"textPrompt"];
            NSURL * imageURL = [NSURL URLWithString:snapshot.value[@"imagePrompt"]];
            NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
            UIImage * image = [UIImage imageWithData:imageData];
            [self.imagePrompt setImage:image];
        }];
    }
}

- (IBAction)camera:(id)sender {
}

- (IBAction)takePhoto:(id)sender {
    [self.imagePickerController takePicture];
}

- (IBAction)retakePhoto:(id)sender {
    [self openCameraPane];
    [self.fb observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"Fetching new Firebase Data...");
        self.labelPrompt.text = snapshot.value[@"textPrompt"];
        NSURL * imageURL = [NSURL URLWithString:snapshot.value[@"imagePrompt"]];
        NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
        UIImage * image = [UIImage imageWithData:imageData];
        [self.imagePrompt setImage:image];
    }];
    
}

- (void)openCameraPane {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.delegate = self;
    imagePickerController.showsCameraControls = NO;
    [[NSBundle mainBundle] loadNibNamed:@"OverlayView" owner:self options:nil];
    self.overlayView.frame = imagePickerController.cameraOverlayView.frame;
    
    imagePickerController.cameraOverlayView = self.overlayView;
    self.imagePickerController = imagePickerController;
    [self presentViewController:self.imagePickerController animated:NO completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    self.activeImage = image;
    [self.imagePreview setImage:self.activeImage];
    [self finishAndUpdate];
}

- (void)finishAndUpdate
{
    [self dismissViewControllerAnimated:NO completion:NULL];
    //[self.imageView setImage:[self.capturedImages objectAtIndex:0]];
    
    self.imagePickerController = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
