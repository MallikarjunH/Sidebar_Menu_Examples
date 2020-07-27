//
//  PreviewerController.m
//  emSigner
//
//  Created by EMUDHRA on 05/12/18.
//  Copyright © 2018 Emudhra. All rights reserved.
//

#import "PreviewerController.h"
#import "ImageFileCrop.h"
#import "ShowEditImagesFromImageList.h"

@interface PreviewerController ()

@end

@implementation PreviewerController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0 green:96.0/255.0 blue:192.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem* customBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismissViewController)];
    
    self.navigationItem.leftBarButtonItem = customBarButtonItem;

    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(savebtnAction:)];
    self.navigationItem.rightBarButtonItem = saveButton;
 
    self.previewimage.image = self.Previewimg;
   // self.title = @"Document";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:@"renameDocument"
                                               object:nil];
    
    self.title = @"Preview";
    
  
}

- (void)receiveNotification:(NSNotification *)notification
{
   if ([[notification name] isEqualToString:@"renameDocument"])
    {
        NSString *myString = (NSString *)notification.object;
        
        self.title = myString;
    }
}


- (void)ImageCropViewControllerSuccess:(UIViewController* )controller didFinishCroppingImage:(UIImage *)croppedImage{
    UIImage * image = croppedImage;
    self.Previewimg = image;
    self.previewimage.image =image;

    [self.navigationController popViewControllerAnimated:true];
}
- (void)ImageCropViewControllerDidCancel:(UIViewController *)controller{
    [self.navigationController popViewControllerAnimated:true];
}
- (void)dismissViewController{
  //  [self dismissViewControllerAnimated:true completion:nil];
      [[NSNotificationCenter defaultCenter] postNotificationName:@"imageCancelNotification" object:self.sourceImageArray];

      [self.navigationController popViewControllerAnimated:true];
}

- (void)savebtnAction:(UIButton *)sender {
    self.imageArray = [[NSMutableArray alloc]init];
    //Adarsha
    NSDateFormatter *form = [[NSDateFormatter alloc] init];
    form.dateFormat = @"yyyy:MM:dd HH:mm:ss";
    NSString* date = [form stringFromDate:[NSDate date]];
    
   // [self.imageArray addObject:@{@"Image":self.previewimage.image,@"Date":[[self.sourceImageArray objectAtIndex:0]objectForKey:@"Date"]}];
   
    self.imageArray = [self.sourceImageArray mutableCopy];
    long i = [self.imageArray count];
    //Convert PreviwImageTo Data then send
    
    
    
    // for change of cropped image we used replace
    [self.imageArray replaceObjectAtIndex:i-1 withObject:@{@"Image":self.Previewimg,@"Date":date}];
   // [_imageupdateDelegate sendDataToShowEdit:self.imageArray];
    
    NSLog(@"%@",self.navigationController.viewControllers);
    
    ShowEditImagesFromImageList *objTrackOrderVC= [[ShowEditImagesFromImageList alloc] initWithNibName:@"ShowEditImagesFromImageList" bundle:nil];
   //objTrackOrderVC.showMultImages = self.imageArray;
    objTrackOrderVC.categoryname = self.categoryname;
    objTrackOrderVC.documentName = self.documentName;
    objTrackOrderVC.documentId = self.documentId;
    objTrackOrderVC.uploadAttachment = self.uploadAttachment;
    objTrackOrderVC.workFlowId = self.workflowId;
    objTrackOrderVC.post = self.post;
     
    objTrackOrderVC.isDocStore = true;
    [self.navigationController pushViewController:objTrackOrderVC animated:YES];
    
    //changes images for showedit
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"imageNotification" object:self.imageArray];
    });
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)CotrollerAction:(UIBarButtonItem *)sender {
    
    if (sender.tag == 1) {
        //Delete
     
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:nil
                                     message:@"Are you sure you want delete the document"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        //Add Buttons
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Ok"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        //Handle your yes please button action here
                                        [[NSNotificationCenter defaultCenter]
                                         postNotificationName:@"DeleteNotification"
                                         object:self];
                                        [self.navigationController popViewControllerAnimated:true];
                                    }];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleDestructive
                                 handler:^(UIAlertAction * action)
                                 {
                                     // [self.view dis]
                                 }];
        
        [alert addAction:yesButton];
        [alert addAction:cancel];
        //[self stopActivity];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    else if (sender.tag == 2) {
        //Crop
        ImageCropViewController *controller = [[ImageCropViewController alloc] initWithImage:self.Previewimg];
                controller.delegate = self;
                controller.blurredBackground = YES;
                // set the cropped area
                // controller.cropArea = CGRectMake(0, 0, 100, 200);
                [[self navigationController] pushViewController:controller animated:YES];
      //  [self presentViewController:controller animated:true completion:nil];
    }
    else if (sender.tag == 3) {
        //Rotate
        UIImage *rotatedImage = [self rotateImage:self.Previewimg clockwise:YES];
        
        [UIView animateWithDuration:0.5f delay:0.0 options:UIViewAnimationOptionTransitionNone animations:^
         {
             CGAffineTransform transform = self.previewimage.transform;
             CGAffineTransform transform_new = CGAffineTransformRotate(transform, M_PI_2);
             self.previewimage.transform = transform_new;
             
         } completion:NULL];
        
        // UIImage  *rotated2 = [self upsideDownBunny:90 withImage:self.previewimage.image];
        self.Previewimg = rotatedImage;
    }
}
- (UIImage*)rotateImage:(UIImage*)sourceImage clockwise:(BOOL)clockwise
{
    CGSize size = sourceImage.size;
    UIGraphicsBeginImageContext(CGSizeMake(size.height, size.width));
    [[UIImage imageWithCGImage:[sourceImage CGImage]
                         scale:1.0
                   orientation:clockwise ? UIImageOrientationRight : UIImageOrientationLeft]
     drawInRect:CGRectMake(0,0,size.height ,size.width)];
    
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
