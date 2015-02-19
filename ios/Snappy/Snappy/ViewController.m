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

@property (nonatomic) BOOL *hasTakenPhoto;
@property (nonatomic) NSString *U_ID;
@property (nonatomic) NSString *dayID;
@property (nonatomic) UIImage *activeImage;
@property (nonatomic) NSMutableArray *capturedImages;
@property (nonatomic) UIImagePickerController *imagePickerController;
@end

@implementation ViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.fb = [[Firebase alloc] initWithUrl: @"https://az.firebaseio.com/snappy"];
    self.currentFb = [[Firebase alloc] initWithUrl: @"https://az.firebaseio.com/snappy/currentDay"];
    self.U_ID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    NSLog(@"Device ID: %@", self.U_ID);
    [self checkHasTakenPhoto];
    
    NSLog(@"View Loaded");
}

- (void) viewDidAppear:(BOOL)animated {
    if (self.activeImage == nil) {
        if (!self.hasTakenPhoto) {
            [self openCameraPane];
        }
        
        [self.currentFb observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            NSLog(@"Fetching new Firebase Data...");
            self.labelBasePrompt.text = snapshot.value[@"textPrompt"];
            self.labelPrompt.text = snapshot.value[@"textPrompt"];
            NSURL * imageURL = [NSURL URLWithString:snapshot.value[@"imagePrompt"]];
            NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
            UIImage * image = [UIImage imageWithData:imageData];
            [self.imagePrompt setImage:image];
            [self.imageBasePrompt setImage:image];
            
            self.dayID = snapshot.value[@"dayID"];
        }];
    }
}

- (IBAction)camera:(id)sender {
}

- (IBAction)takePhoto:(id)sender {
    [self.imagePickerController takePicture];
    
    Firebase *userRef = [self.fb childByAppendingPath: [NSString stringWithFormat: @"userData/%@", self.U_ID]];
    
    NSLog(@"Day ID: %@", self.dayID);
    NSDictionary *entry = [[NSDictionary alloc] initWithObjectsAndKeys:@"uploaded", [NSString stringWithFormat: @"%@", self.dayID], nil];
    [userRef updateChildValues: entry];
    
}

- (IBAction)retakePhoto:(id)sender {
    [self openCameraPane];
    [self updatePrompt];
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
    // [self crop];
    [self.imagePreview setImage:self.activeImage];
    [self finishAndUpdate];
}

- (void)finishAndUpdate
{
    [self dismissViewControllerAnimated:NO completion:NULL];
    [self uploadPhoto];
    [self updatePrompt];
    self.imagePickerController = nil;
}

- (void) updatePrompt
{
    [self.currentFb observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"Fetching new Firebase Data...");
        self.labelBasePrompt.text = snapshot.value[@"textPrompt"];
        self.labelPrompt.text = snapshot.value[@"textPrompt"];
        NSURL * imageURL = [NSURL URLWithString:snapshot.value[@"imagePrompt"]];
        NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
        UIImage * image = [UIImage imageWithData:imageData];
        [self.imagePrompt setImage:image];
        [self.imageBasePrompt setImage:image];
        
        self.dayID = snapshot.value[@"dayID"];
    }];
}

- (void) checkHasTakenPhoto
{
    Firebase *userRef = [self.fb childByAppendingPath:@"userData"];
    [userRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSDictionary *data = snapshot.value[[NSString stringWithFormat: @"%@", self.U_ID]];
        NSLog(@"self.dayID %@", data);
        if ([data objectForKey:[NSString stringWithFormat: @"%@", self.dayID]] == nil) {
            NSLog(@"No Photo Taken Yet");
        } else {
            NSLog(@"User has Taken Photo");
            
            // TODO: make less jank.
            self.hasTakenPhoto = YES;
            [self dismissViewControllerAnimated:NO completion:NULL];
        }
    }];
}

- (void) uploadPhoto
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"--";
    NSString *contentType = [NSString stringWithFormat: @"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    NSString *FileParamConstant = @"photo-file.jpg";
    NSString *str = @"http://76.118.179.120:8000/api/photo";
    NSURL *requestURL = [NSURL URLWithString:[str stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    [request setURL:requestURL];
    
    NSData *imageData = UIImageJPEGRepresentation(self.activeImage, 1.0);
    
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", FileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithString:@"Content-Type: image/jpeg\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSString *params = @"x=1&y=bla&z=foo";
   // [body appendData:[params dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

- (void) crop {
    CGSize itemSize = CGSizeMake(320,320);
    UIGraphicsBeginImageContext(itemSize);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [self.activeImage drawInRect:imageRect];
    self.activeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
