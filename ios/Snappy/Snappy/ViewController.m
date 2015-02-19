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
            self.labelBasePrompt.text = snapshot.value[@"textPrompt"];
            self.labelPrompt.text = snapshot.value[@"textPrompt"];
            NSURL * imageURL = [NSURL URLWithString:snapshot.value[@"imagePrompt"]];
            NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
            UIImage * image = [UIImage imageWithData:imageData];
            [self.imagePrompt setImage:image];
            [self.imageBasePrompt setImage:image];
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

-(void) updatePrompt
{
    
    [self.fb observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"Fetching new Firebase Data...");
        self.labelBasePrompt.text = snapshot.value[@"textPrompt"];
        self.labelPrompt.text = snapshot.value[@"textPrompt"];
        NSURL * imageURL = [NSURL URLWithString:snapshot.value[@"imagePrompt"]];
        NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
        UIImage * image = [UIImage imageWithData:imageData];
        [self.imagePrompt setImage:image];
        [self.imageBasePrompt setImage:image];
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
