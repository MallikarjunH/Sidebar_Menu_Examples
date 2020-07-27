/*
 * Payment Signature View: http://www.payworks.com
 *
 * Copyright (c) 2015 Payworks GmbH
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "MPBCustomStyleSignatureViewController.h"
#import "PPSSignatureView.h"
#import "WebserviceManager.h"
#import "HoursConstants.h"
#import "SingletonAPI.h"
#import "LMNavigationController.h"
#import "MBProgressHUD.h"
#import "NSObject+Activity.h"
#import "SignatoriesPage.h"
#import "QuartzCore/QuartzCore.h"
#import "SignatureImagesCell.h"
#import "ReviewerController.h"
#import "AttachedVC.h"
#import "OverlayTransitioningDelegate.h"
#import "UploadDocuments.h"



NSString *const MPBSignatureViewBundleName = @"MPBSignatureViewResources";

@interface MPBCustomStyleSignatureViewController () <PPSSignatureViewDelegate>
{
    CGFloat btnX ;
    int counter;
    SignatureImagesCell *cell ;
    UIImage *imgCompressed;
    NSString *dataPaths ;
    long indexpth;
    NSString* path;
    int currentPreviewIndex;
    
   
}

@property (nonatomic, weak) UIView *viewToAdd;
@property (nonatomic, strong) PPSSignatureView *signatureViewInternal;
@property (nonatomic, strong) OverlayTransitioningDelegate* overlaydelegate;

@end

@implementation MPBCustomStyleSignatureViewController

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (instancetype)initWithConfiguration:(MPBSignatureViewControllerConfiguration *)configuration {
    self = [super init];
    self.configuration = configuration;
    return self;
}

+ (instancetype)controllerWithConfiguration:(MPBSignatureViewControllerConfiguration *)configuration {
    id controller = [[self alloc] initWithConfiguration:configuration];
    return controller;
}

- (void)checkIfRequiredComponentsAreAvailable {
    if (self.configuration == nil) {
        [NSException raise:@"You did not supply a configuration! Assign a configuration with controller.configuration = [MPBSignatureViewControllerConfigurationWithMerchantName:(NSString *)merchantName formattedAmount:(NSString *)formattedAmount]" format:nil];
    }
    
    if (self.signatureView == nil) {
        [NSException raise:@"signatureView is nil! Create a UIView in your storyboard and wire it with the property 'signatureView'" format:nil];
    }
    
    if (self.cancelBlock == nil) {
        [NSException raise:@"You did not define a block for when the signature is cancelled! Assign a cancel block with controller.cancelBlock = ^(){ };" format:nil];
    }
    
    if (self.legalTextLabel == nil) {
        [NSException raise:@"legalTextLabel is nil! Create a UILabel in your storyboard and wire it with the property 'legalTextLabel'" format:nil];
    }
    
    if (self.clearButton == nil) {
        [NSException raise: @"clearButton is nil! Create a UIButton in your storyboard and wire it with the property 'clearButton'" format:nil];
    }
    
    if (self.cancelButton == nil) {
        [NSException raise: @"cancelButton is nil! Create a UIButton in your storyboard and wire it with the property 'cancelButton'" format:nil];
    }
    
    if (self.continueButton == nil) {
        [NSException raise: @"continueButton is nil! Create a UIButton in your storyboard and wire it with the property 'continueButton'" format:nil];
    }
    
    //for more and save button
    
    if (self.moreButton == nil) {
        [NSException raise: @"moreButton is nil! Create a UIButton in your storyboard and wire it with the property 'moreButton'" format:nil];
    }
    if (self.saveButton == nil) {
        [NSException raise: @"saveButton is nil! Create a UIButton in your storyboard and wire it with the property 'saveButton'" format:nil];
    }
    
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.signersArray = [[NSMutableArray alloc]init];
    [self checkIfRequiredComponentsAreAvailable];
    [self setupSignatureField];
    [self setupViews];
    [self loadimages];
    [self setupTargets];
    btnX=0.0;
    counter = 0;
//    NSMutableDictionary* empty = [[NSMutableDictionary alloc]init];
//
//    for (int i = 0; i<_subscriberIdarray.count; i++) {
//        NSArray * signersArray = _subscriberIdarray[i];
//        NSMutableArray * arr = [[NSMutableArray alloc]init];
//        for (int j= 0; j<signersArray.count; j++) {
//            [arr addObject:empty];
//        }
//        [self.signersArray addObject:arr];
//    }
    
  
}

-(void)viewDidAppear:(BOOL)animated
{
    self.clearButton.alpha = 0;
    [self disableContinueAndClearButtonsAnimated:NO];
//    self.saveButton.enabled = NO;
//    self.continueButton.enabled = NO;
    if (_imageArrayForSignature.count != 0) {
        
        //Collectionview default selection
        
        NSIndexPath *indexPathForFirstRow = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.collectionOfSignatures selectItemAtIndexPath:indexPathForFirstRow animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        [self collectionView:self.collectionOfSignatures didSelectItemAtIndexPath:indexPathForFirstRow];
        
    }
 
}


- (void) viewDidLayoutSubviews {
    self.signatureViewInternal.frame = self.signatureView.frame;
    self.imgCapture.frame = self.signatureView.frame;
}


- (void)setupSignatureField {
    self.signatureViewInternal = [[PPSSignatureView alloc] initWithFrame:self.signatureView.frame context:nil];
    self.signatureViewInternal.signatureDelegate = self;
    self.signatureViewInternal.backgroundColor = self.signatureView.backgroundColor;
    // remove the original view
    [self.view insertSubview:self.signatureViewInternal belowSubview:self.signatureView];
    [self.signatureView removeFromSuperview];
    self.signatureView = self.signatureViewInternal;
}

- (void)setupImageCapture {
    self.imgCapture = [[PPSSignatureView alloc] initWithFrame:self.signatureView.frame context:nil];
   // self.signatureViewInternal.signatureDelegate = self;
    self.imgCapture.backgroundColor = self.signatureView.backgroundColor;
    // remove the original view
    [self.view insertSubview:self.imgCapture belowSubview:self.signatureView];
    [self.signatureView removeFromSuperview];
    self.signatureView = self.imgCapture;
}

- (NSString*) legalText {
    if (self.configuration.merchantName != nil) {
        return [NSString stringWithFormat:[self localizedString:@"MPBSignatureViewSignatureTextFormat"], self.configuration.formattedAmount, self.configuration.merchantName];
    } else {
        return [NSString stringWithFormat:[self localizedString:@""], self.configuration.formattedAmount];
    }
}

- (void) setupViews {
    self.legalTextLabel.text = [self legalText];
    if (_signBtnTitle) {
        [self.continueButton  setTitle:[self localizedString:@"Preview Signature"] forState:UIControlStateNormal];
    }
    else{
         [self.continueButton  setTitle:[self localizedString:@"SIGN"] forState:UIControlStateNormal];
    }
    [self.cancelButton setTitle:[self localizedString:@"Cancel"] forState:UIControlStateNormal];
    [self.clearButton setTitle:[self localizedString:@"Clear"] forState:UIControlStateNormal];
    [self.showSignaturePadButton setTitle:[self localizedString:@"SignPad"] forState:UIControlStateNormal];
    [self.moreButton setTitle:[self localizedString:@"More"] forState:UIControlStateNormal];
    [self.saveButton setTitle:[self localizedString:@"Save"] forState:UIControlStateNormal];

    [[NSUserDefaults standardUserDefaults] setObject:_signatureWorkFlowID forKey:@"_signatureWorkFlowIDForMultiple"];
    
    // Sync user defaults
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self disableContinueAndClearButtonsAnimated:NO];

}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

-(void)loadimages {

    NSError* error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    dataPaths = [documentsDirectory stringByAppendingPathComponent:[[NSUserDefaults standardUserDefaults]
                                                                             valueForKey:@"Name"]];

    if ([[NSFileManager defaultManager] fileExistsAtPath:dataPaths] || _imageArrayForSignature.count !=0)
    {
        NSString *imgFile1=[dataPaths stringByAppendingPathComponent:@"FirstImg.png"];
        NSString *imgFile2=[dataPaths stringByAppendingPathComponent:@"SecondImg.png"];
        NSString *imgFile3=[dataPaths stringByAppendingPathComponent:@"ThirdImg.png"];
  
    //show the first image
        self.imgCapture.image = [UIImage imageWithContentsOfFile:[dataPaths stringByAppendingPathComponent:@"FirstBigImg.png"]];
        [self enableContinueAndClearButtons];
    
        UIImage *firstImg = [UIImage imageWithData:[NSData dataWithContentsOfFile:imgFile1]];
        UIImage *secondImg = [UIImage imageWithData:[NSData dataWithContentsOfFile:imgFile2]];
        UIImage *thirdImg = [UIImage imageWithData:[NSData dataWithContentsOfFile:imgFile3]];
    
        _imageArrayForSignature = [[NSMutableArray alloc]init];
        _BigimageArrayForSignature = [[NSMutableArray alloc]init];
        
            if (firstImg != nil ) {
                 [_imageArrayForSignature addObject:firstImg];
                 [_BigimageArrayForSignature addObject:[UIImage imageWithContentsOfFile:[dataPaths stringByAppendingPathComponent:@"FirstBigImg.png"]]];
            }
            if (secondImg != nil ) {
                [_imageArrayForSignature addObject:secondImg];
                [_BigimageArrayForSignature addObject:[UIImage imageWithContentsOfFile:[dataPaths stringByAppendingPathComponent:@"SecondBigImg.png"]]];
            }
            if (thirdImg != nil ) {
                
                [_imageArrayForSignature addObject:thirdImg];
                [_BigimageArrayForSignature addObject:[UIImage imageWithContentsOfFile:[dataPaths stringByAppendingPathComponent:@"ThirdBigImg.png"]]];
        
            }

   
    }
    else NSLog(@"157");
}

-(void)handleSingleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self.signatureViewInternal erase];

    [self enableContinueAndClearButtons];
    NSLog(@"%ld", tapGestureRecognizer.view.tag);
    
    self.imgCapture.hidden =NO;
    
    self.imageView.contentMode=UIViewContentModeScaleToFill;
    _img.userInteractionEnabled = YES;
    
    if (tapGestureRecognizer.view.tag ==0) {
        self.imgCapture.image = [UIImage imageWithContentsOfFile:[[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"FirstImg.png"]];
    }
    else if (tapGestureRecognizer.view.tag == 1)
    {
        self.imgCapture.image = [UIImage imageWithContentsOfFile:[[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"SecondImg.png"]];
    }
    else if (tapGestureRecognizer.view.tag == 2)
    {
        self.imgCapture.image = [UIImage imageWithContentsOfFile:[[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"ThirdBigImg.png"]];
    }
}

- (UIImage*) imageForScheme: (MPBSignatureViewControllerConfigurationScheme) scheme {
    switch (scheme) {
        case MPBSignatureViewControllerConfigurationSchemeMaestro:
            return [self imageWithName:@"maestro_image"];
        case MPBSignatureViewControllerConfigurationSchemeMastercard:
            return [self imageWithName:@"mastercard_image"];
        case MPBSignatureViewControllerConfigurationSchemeVisa:
        case MPBSignatureViewControllerConfigurationSchemeVpay:
            return [self imageWithName:@"visacard_image"];
        case MPBSignatureViewControllerConfigurationSchemeAmex:
            return [self imageWithName:@"amex"];
        case MPBSignatureViewControllerConfigurationSchemeDinersClub:
            return [self imageWithName:@"diners_image"];
        case MPBSignatureViewControllerConfigurationSchemeDiscover:
            return [self imageWithName:@"discover_image"];
        case MPBSignatureViewControllerConfigurationSchemeJCB:
            return [self imageWithName:@"jcb_image"];
        case MPBSignatureViewControllerConfigurationSchemeUnionPay:
            return [self imageWithName:@"unionpay_image"];
        default:
            return nil;
    }
}

- (void) setupTargets {
    
    [self.clearButton addTarget:self action:@selector(clearSignature) forControlEvents:UIControlEventTouchUpInside];
    [self.showSignaturePadButton addTarget:self action:@selector(showSignaturePadScreenForSignature) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton addTarget:self action:@selector(cancelSignature) forControlEvents:UIControlEventTouchUpInside];
    [self.continueButton addTarget:self action:@selector(continueWithSignature) forControlEvents:UIControlEventTouchUpInside];
    [self.saveButton addTarget:self action:@selector(saveSignature) forControlEvents:UIControlEventTouchUpInside];
    [self.moreButton addTarget:self action:@selector(moreSignature) forControlEvents:UIControlEventTouchUpInside];

}

-(void)saveSignature{
    counter++;

    NSData *imageData = UIImagePNGRepresentation([self signature]);
    UIImage *image = [UIImage imageWithData:imageData];
    imgCompressed = [self compressImage:image];
 
    if (imageData == nil) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Please sign a valid signature."
                              message:nil
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }

    else if (_imageArrayForSignature.count < 3 || ![[NSFileManager defaultManager] fileExistsAtPath:dataPaths])
    {

        NSError* error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
        NSString *dataPaths = [documentsDirectory stringByAppendingPathComponent:[[NSUserDefaults standardUserDefaults]
                                                                                 valueForKey:@"Name"]];

      
            [[NSFileManager defaultManager] createDirectoryAtPath:dataPaths withIntermediateDirectories:NO attributes:nil error:&error]; //Will Create folder
        if (self.imageArrayForSignature.count == 0) {
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
            NSString *dataPath = [dataPaths stringByAppendingPathComponent:@"FirstImg.png"];
            NSData *imData = UIImagePNGRepresentation(imgCompressed);
            [imData writeToFile:dataPath atomically:YES];
            
            NSString *dataPathBigImage = [dataPaths stringByAppendingPathComponent:@"FirstBigImg.png"];
            [imageData writeToFile:dataPathBigImage atomically:YES];
        }
        
     
        if (_imageArrayForSignature.count == 1) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
            NSString *dataPath = [dataPaths stringByAppendingPathComponent:@"SecondImg.png"];
            NSData *imData = UIImagePNGRepresentation(imgCompressed);
            [imData writeToFile:dataPath atomically:YES];
            
            NSString *dataPathBigImage = [dataPaths stringByAppendingPathComponent:@"SecondBigImg.png"];
            [imageData writeToFile:dataPathBigImage atomically:YES];
            
        }
        
        if (_imageArrayForSignature.count == 2) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
            NSString *dataPath = [dataPaths stringByAppendingPathComponent:@"ThirdImg.png"];
            NSData *imData = UIImagePNGRepresentation(imgCompressed);
            [imData writeToFile:dataPath atomically:YES];
            
            NSString *dataPathBigImage = [dataPaths stringByAppendingPathComponent:@"ThirdBigImg.png"];
            [imageData writeToFile:dataPathBigImage atomically:YES];
            
        }
        
        [_imageArrayForSignature addObject:imgCompressed];
        [self loadimages];
        [self.collectionOfSignatures reloadData];
        
    }
    else if (_imageArrayForSignature.count >=3) {

                         NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                         NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
                         NSString *dataPath = [dataPaths stringByAppendingPathComponent:@"ThirdImg.png"];
                         NSData *imageDataa = UIImagePNGRepresentation(imgCompressed);

                         [imageDataa writeToFile:dataPath atomically:YES];

                         NSString *dataPathBigImage = [dataPaths stringByAppendingPathComponent:@"ThirdBigImg.png"];
                         [imageData writeToFile:dataPathBigImage atomically:YES];

                         [self.imageArrayForSignature removeObjectAtIndex:2];
                         [self.imageArrayForSignature insertObject:imgCompressed atIndex:2];

        indexpth = 2;
         [self.collectionOfSignatures reloadData];
                     }
}

-(void)addImagesToScrollView
{
    long count = _imageArrayForSignature.count-1;
    for (long i=count;i>=0;i--)
    {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(btnX, 5, 100.0, 40)];

        self.imageView.contentMode=UIViewContentModeScaleToFill;
        [ self.imageView setImage:_imageArrayForSignature[i]];
        self.imageView.tag=i;
        _img.userInteractionEnabled = YES;
     
        [_scrollViewForSignature addSubview: self.imageView];
        btnX = btnX + 110.0;
        
    }
    _scrollViewForSignature.contentSize = CGSizeMake(btnX + 50, 150);    
}

-(UIImage *)compressImage:(UIImage *)image{
    
    NSData *imgData = UIImagePNGRepresentation(image);//(image, 3.5); //1 it represents the quality of the image.
    NSLog(@"Size of Image(bytes):%ld",(unsigned long)[imgData length]);
    
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float maxHeight = 200.0;
    float maxWidth = 270.0;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = maxWidth/maxHeight;
    float compressionQuality = 0.0;//50 percent compression
    
    if (actualHeight > maxHeight || actualWidth > maxWidth){
        if(imgRatio < maxRatio){
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxHeight;
        }
        else if(imgRatio > maxRatio){
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = maxWidth;
        }
        else{
            actualHeight = maxHeight;
            actualWidth = maxWidth;
        }
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImageJPEGRepresentation(img, compressionQuality);
    UIGraphicsEndImageContext();
    
    NSLog(@"Size of Image(bytes):%ld",(unsigned long)[imageData length]);
    
    return [UIImage imageWithData:imageData];
}

-(void)moreSignature
{
    
    UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SignatoriesPage *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"SignatoriesPage"];
    self.definesPresentationContext = YES; //self is presenting view controlle
    objTrackOrderVC.title = @"";
    [self presentViewController:objTrackOrderVC animated:YES completion:nil];
    
}

-(void)clearSignature {
    
    [self.signatureViewInternal erase];
    self.imgCapture.hidden = YES;
    cell.addCheckImage.image = [UIImage imageNamed:@""];
    self.signatureViewInternal.userInteractionEnabled = YES; // or YES, as you desire.
    
}


- (void)continueWithSignature {
    
    if (_isFromSignerView == true) {
        if (_gotParametersForInitiateWorkFlow.count != 0) {
        NSString* WorkflowType = [[NSUserDefaults standardUserDefaults]valueForKey:@"WorkflowType"];

         int insertPosition = 0;
         NSData *initWorkFlowImage;
         
         if ([self signature] == nil) {
             initWorkFlowImage = UIImagePNGRepresentation(self.imgCapture.image);
         }else
         {
             initWorkFlowImage = UIImagePNGRepresentation([self signature]);
         }
        
         NSString *base64image=[initWorkFlowImage base64EncodedStringWithOptions:0];
            
            for (int i = 0; i<_gotParametersForInitiateWorkFlow.count; i++) {
                NSArray * signatories = [_gotParametersForInitiateWorkFlow[i]valueForKey:@"Signatories"];
                [signatories setValue:base64image forKey:@"SignatureImage"];
            
            }
            
            UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                      AttachedVC  *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"AttachedVC"];

            objTrackOrderVC.parametersForWorkflow = _gotParametersForInitiateWorkFlow;
            objTrackOrderVC.modalPresentationStyle = UIModalPresentationFullScreen;
            
                       UINavigationController *objNavigationController = [[UINavigationController alloc]initWithRootViewController:objTrackOrderVC];
                         self.continueBlock([self signature]);
                       [self presentViewController:objNavigationController animated:true completion:nil];
         NSLog(@"%@",_subscriberIdarray);
          NSLog(@"%@",_d);
        }
    } else {
          
            
            if (_gotParametersForInitiateWorkFlow.count != 0) {
            NSString* WorkflowType = [[NSUserDefaults standardUserDefaults]valueForKey:@"WorkflowType"];

                int insertPosition = 0;
                NSData *initWorkFlowImage;
                
                if ([self signature] == nil) {
                    initWorkFlowImage = UIImagePNGRepresentation(self.imgCapture.image);
                }else
                {
                    initWorkFlowImage = UIImagePNGRepresentation([self signature]);
                }
               
                NSString *base64image=[initWorkFlowImage base64EncodedStringWithOptions:0];
                NSLog(@"%@",_subscriberIdarray);
                 NSLog(@"%@",_d);
                
                for (int i = 0; i<_gotParametersForInitiateWorkFlow.count; i++) {
                    NSMutableDictionary* sendingvalues = [[NSMutableDictionary alloc]init];
                    _signersArray = [NSMutableArray new];
                    NSArray * signatories = [_gotParametersForInitiateWorkFlow[i]valueForKey:@"Signatories"];
                    
                    [sendingvalues setObject:[_gotParametersForInitiateWorkFlow[i]valueForKey:@"TemplateId"] forKey:@"TemplateId"];
                   // [sendingvalues setObject:[_gotParametersForInitiateWorkFlow[i]valueForKey:@"CategoryName"] forKey:@"CategoryName"];
                    [sendingvalues setObject:[_gotParametersForInitiateWorkFlow[i]valueForKey:@"DocumentName"] forKey:@"DocumentName"];
                    //[sendingvalues setObject:[_gotParametersForInitiateWorkFlow[i]valueForKey:@"ConfigId"] forKey:@"ConfigId"];
                    [sendingvalues setValue:[_gotParametersForInitiateWorkFlow[i]valueForKey:@"DocumentId"] forKey:@"DocumentId"];
                    [sendingvalues setValue:WorkflowType forKey:@"WorkflowType"];
                    
                    if ([_subscriberIdarray[i]isEqualToString:@"Signer"]) {
                        
                        [sendingvalues setObject:@"true" forKey:@"IsSign"];
                        [sendingvalues setObject:@"false" forKey:@"IsReviewer"];
                    }
                    else if ([_subscriberIdarray[i]isEqualToString:@"Reviewer"]){
                        [sendingvalues setObject:@"false" forKey:@"IsSign"];
                        [sendingvalues setObject:@"true" forKey:@"IsReviewer"];
                    }
                    else if ([_subscriberIdarray[i]isEqualToString:@"Internal"]){
                        [sendingvalues setObject:@"false" forKey:@"IsSign"];
                        [sendingvalues setObject:@"false" forKey:@"IsReviewer"];
                    }
                    
                    
                    for (int j= 0; j<signatories.count; j++) {
                        NSMutableDictionary * signatoriesDict = [[NSMutableDictionary alloc]init];
                        [_signersArray addObject:signatoriesDict];
                        if ([[_d[i] objectAtIndex:j]isEqualToString:@"ME"]&&[_subscriberIdarray[i]isEqualToString:@"Signer"]) {
                            
                            [signatoriesDict setObject:@"" forKey:@"ReviewerComment"];
                            [signatoriesDict setObject:[signatories[j]valueForKey:@"SubscriberId"] forKey:@"SubscriberId"];
                            [signatoriesDict setObject:base64image forKey:@"SignatureImage"];
                            [signatoriesDict setObject:[signatories[j]valueForKey:@"pageId"] forKey:@"pageId"];
                             insertPosition = j;
                            [_signersArray replaceObjectAtIndex:j withObject:signatoriesDict];
                        }
                        else if([[_d[i] objectAtIndex:j]isEqualToString:@"ME"]&&[_subscriberIdarray[i]isEqualToString:@"Reviewer"]){
                            [signatoriesDict setObject:[signatories[j]valueForKey:@"ReviewerComment"] forKey:@"ReviewerComment"];
                            [signatoriesDict setObject:[signatories[j]valueForKey:@"SubscriberId"] forKey:@"SubscriberId"];
                            [signatoriesDict setObject:@"" forKey:@"SignatureImage"];
                            [signatoriesDict setObject:[signatories[j]valueForKey:@"pageId"] forKey:@"pageId"];
                            insertPosition = j;
                            [_signersArray replaceObjectAtIndex:j withObject:signatoriesDict];
                        }
                        else{
                            [signatoriesDict setObject:@"" forKey:@"ReviewerComment"];
                            [signatoriesDict setObject:[signatories[j]valueForKey:@"SubscriberId"] forKey:@"SubscriberId"];
                            [signatoriesDict setObject:@"" forKey:@"SignatureImage"];
                            [signatoriesDict setObject:[signatories[j]valueForKey:@"pageId"] forKey:@"pageId"];
                            
                            [_signersArray replaceObjectAtIndex:j withObject:signatoriesDict];
                        }
                        // [_subscriberidarray replaceObjectAtIndex:j withObject:signatoriesDict];
                        //move ME position to first
                        
                    }
                    _signersArray = [self InsertIndex:_signersArray Index:insertPosition];
                    [sendingvalues setObject:_signersArray  forKey:@"Signatories"];
                    [_gotParametersForInitiateWorkFlow replaceObjectAtIndex:i withObject:sendingvalues];
                    
                }
                 if ([self signature] != nil) {
                     [[NSNotificationCenter defaultCenter] postNotificationName:@"signersParameters" object:_gotParametersForInitiateWorkFlow];

                     self.continueBlock([self signature]);
                     
                 }else{
                     [[NSNotificationCenter defaultCenter] postNotificationName:@"signersParameters" object:_gotParametersForInitiateWorkFlow];

                     self.continueBlock(self.imgCapture.image);
                     
                 }

               // [self dismissViewControllerAnimated:YES completion:nil];
                //UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        //        AttachedVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"AttachedVC"];
        //        [[[[UIApplication sharedApplication] delegate] window] setRootViewController:objTrackOrderVC];
                
        //        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        //        LMNavigationController *objTrackOrderVC= [sb  instantiateViewControllerWithIdentifier:@"AttachedVC"];
        //        [[[[UIApplication sharedApplication] delegate] window] setRootViewController:objTrackOrderVC];
            }
            else
            {
                NSData *dataImage;
            
                if ([self signature] != nil) {
                     dataImage=UIImagePNGRepresentation([self signature]);
                    NSString *base64image=[dataImage base64EncodedStringWithOptions:0];
                    //save signature
                    NSUserDefaults * saveSignature = [NSUserDefaults standardUserDefaults];
                    [saveSignature setObject:dataImage forKey:@"saveSignature"];
                    [saveSignature synchronize];
                    
                    NSString*  PendingVcYes = [[NSUserDefaults standardUserDefaults]valueForKey:@"PendingVcYes"];
                    //[PendingVcYes boolValue] == YES &&
                    if( _reviewerComments != nil){
                        [self callForPendinglIst];
                        return;
                    }
                    
                    if (_isBulk) {[self BulkSign:base64image];} else { self.continueBlock([self signature]);}
    
                }
                else
                {
                    dataImage = UIImagePNGRepresentation(self.imgCapture.image);
             
                                       NSString *base64image=[dataImage base64EncodedStringWithOptions:0];
                    NSUserDefaults * saveSignature = [NSUserDefaults standardUserDefaults];
                    [saveSignature setObject:dataImage forKey:@"saveSignature"];
                    [saveSignature synchronize];
                    
                    NSString*  PendingVcYes = [[NSUserDefaults standardUserDefaults]valueForKey:@"PendingVcYes"];
                    //[PendingVcYes boolValue] == YES &&
                    if( _reviewerComments != nil){
                        [self callForPendinglIst];
                        return;
                    }
                    
                    if (_isBulk) {[self BulkSign:base64image];} else { self.continueBlock([self signature]);}
                }

                NSString * path = [[NSUserDefaults standardUserDefaults]valueForKey:@"pdfpath"];
                [self dismissViewControllerAnimated:true completion:nil];

            }

    }
    
  
}

-(void)BulkSign:(NSString*)base64ImageString {
    NSMutableDictionary * post = [[NSMutableDictionary alloc]init];
    [post setObject:_LotId forKey:@"LotId"];
    [post setObject:base64ImageString forKey:@"SignatureImage"];
    [post setObject:@"" forKey:@"ReviewerComments"];
  
    NSString *requestURL = [NSString stringWithFormat:@"%@BulkSign",kbulkSign];
    
    [WebserviceManager sendSyncRequestWithURLDocument:requestURL method:SAServiceReqestHTTPMethodPOST body:post completionBlock:^(BOOL status, id responseValue) {
        
        if (status) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Password"];
        
        NSNumber * isSuccessNumber = (NSNumber *)[responseValue valueForKey:@"IsSuccess"];
        if([isSuccessNumber boolValue] == YES)
        {
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               
                               UIAlertView * alert15 =[[UIAlertView alloc ] initWithTitle:@"" message:[[responseValue valueForKey:@"Messages"] objectAtIndex:0] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert15 show];
                [self stopActivity];
            });} else {
                 dispatch_async(dispatch_get_main_queue(),
                                           ^{
                                               
                                               UIAlertView * alert15 =[[UIAlertView alloc ] initWithTitle:@"" message:[[responseValue valueForKey:@"Messages"] objectAtIndex:0] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                                [alert15 show];
                                [self stopActivity];
                            });
                
            }

        }

    }];
}
- (void)prepareOverlay:(UIViewController*)viewController {
    self.overlaydelegate = [[OverlayTransitioningDelegate alloc]init];
    viewController.transitioningDelegate = self.overlaydelegate;
    viewController.modalPresentationStyle = UIModalPresentationCustom;
}
- (NSMutableArray *)InsertIndex:(NSMutableArray *)signatoryArray Index:(int)indexvalue{
    
    NSMutableArray *insertedArray  = [[NSMutableArray alloc]init];
    [insertedArray addObjectsFromArray:signatoryArray];
    [insertedArray removeObjectAtIndex:indexvalue];
    [insertedArray insertObject:signatoryArray[indexvalue] atIndex:0];
    
    return insertedArray;
}

//- (BOOL)shouldAutorotate {
//    return NO;
//}

//-(NSUInteger)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskPortrait;
//}

#pragma mark - quicklook

-(NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller
{
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    
    NSURL *localDocumentsDirectoryURL = [NSURL fileURLWithPath:path];
    NSURL *fileURL =localDocumentsDirectoryURL;//[localDocumentsDirectoryURL URLByAppendingPathComponent:fileName isDirectory:NO];
    return fileURL;
    
    return path;
    //[NSURL fileURLWithPath:self.pdfFilePath]; // here is self.pdfFilePath its a path of you pdf
}

- (CGRect)previewController:(QLPreviewController *)controller frameForPreviewItem:(id <QLPreviewItem>)item inSourceView:(UIView **)view
{
    
    //Rectangle of the button which has been pressed by the user
    //Zoom in and out effect appears to happen from the button which is pressed.
    UIView *view1 = [self.view viewWithTag:currentPreviewIndex+1];
    return self.view .frame;
}

-(void)callForPendinglIst
{
    //   if ([self signature] != nil) {
    [self startActivity:@"loading"];
    
    NSData *pp = [[NSUserDefaults standardUserDefaults] valueForKey:@"saveSignature"];
    NSString* PasswordForMultiplePdf = [[NSUserDefaults standardUserDefaults] valueForKey:@"Password"];

    NSData *dataImage = UIImagePNGRepresentation([self signature]);
    NSString *base64image=[pp base64EncodedStringWithOptions:0];
    
    NSString *post = [NSString stringWithFormat:@"WorkflowId=%@&SignatureImage=%@&Password=%@&workflowType=%@&ReviewerComment=%@",_signatureWorkFlowID,base64image,PasswordForMultiplePdf,_signatureWorkFlowType,_reviewerComments];
    post = [[post stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
            stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    [WebserviceManager sendSyncRequestWithURL:kSignatureImage method:SAServiceReqestHTTPMethodPOST body:post completionBlock:^(BOOL status, id responseValue){
        
        if (status) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Password"];
            
            NSNumber * isSuccessNumber = (NSNumber *)[responseValue valueForKey:@"IsSuccess"];
            if([isSuccessNumber boolValue] == YES)
            {
                dispatch_async(dispatch_get_main_queue(),
                               ^{
                                   [self stopActivity];
                                   UIAlertView * alert15 =[[UIAlertView alloc ] initWithTitle:@"" message:[[responseValue valueForKey:@"Messages"] objectAtIndex:0] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                                   [alert15 show];
                                   
                                   UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                   LMNavigationController *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"HomeNavController"];
                                   [self presentViewController:objTrackOrderVC animated:YES completion:nil];
                                   
                                   
                               });
                
            }
        }
        
    }];
    
}

//-(void)callinitWorkFlowApi:(NSMutableArray*)post
//{
//
//    [self startActivity:@""];
//    [WebserviceManager sendSyncRequestWithURLDocument:kInitiateWorkflow method:SAServiceReqestHTTPMethodPOST body:post completionBlock:^(BOOL status, id responseValue){
//
//        if (status) {
//            int   issucess = [[responseValue valueForKey:@"IsSuccess"]intValue];
//
//            if (issucess != 0) {
//
//                NSNumber * isSuccessNumber = (NSNumber *)[responseValue valueForKey:@"IsSuccess"];
//                if([isSuccessNumber boolValue] == YES)
//                {
//                    dispatch_async(dispatch_get_main_queue(),
//                                   ^{
//
//                                       [self stopActivity];
//
//
//                                       UIAlertView * alert15 =[[UIAlertView alloc ] initWithTitle:@"" message:[[responseValue valueForKey:@"Messages"]objectAtIndex:0] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//                                       [alert15 show];
//
//                                       UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//                                       LMNavigationController *objTrackOrderVC= [sb  instantiateViewControllerWithIdentifier:@"HomeNavController"];
//                                       [[[[UIApplication sharedApplication] delegate] window] setRootViewController:objTrackOrderVC];
//
//                                   });
//
//                }
//                else
//                {
//                    dispatch_async(dispatch_get_main_queue(),
//                                   ^{
//                                       UIAlertController * alert = [UIAlertController
//                                                                    alertControllerWithTitle:@""
//                                                                    message:[[responseValue valueForKey:@"Messages"]objectAtIndex:0]
//                                                                    preferredStyle:UIAlertControllerStyleAlert];
//
//                                       //Add Buttons
//
//                                       UIAlertAction* yesButton = [UIAlertAction
//                                                                   actionWithTitle:@"OK"
//                                                                   style:UIAlertActionStyleDefault
//                                                                   handler:^(UIAlertAction * action) {
//                                                                       //Handle your yes please button action here
//                                                                        [self dismissViewControllerAnimated:YES completion:nil];
//                                                                   }];
//
//                                       //Add your buttons to alert controller
//
//                                       [alert addAction:yesButton];
//
//                                       [self presentViewController:alert animated:YES completion:nil];
//
//                                       [self stopActivity];
//                                   });
//
//                }
//
//            }
//            else
//            {
//                dispatch_async(dispatch_get_main_queue(),
//                               ^{
//
//                                   [self dismissViewControllerAnimated:YES completion:nil];
//                                   [self stopActivity];
//
//                                   UIAlertView * alert15 =[[UIAlertView alloc ] initWithTitle:@"" message:[[responseValue valueForKey:@"Messages"]objectAtIndex:0] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//                                   [alert15 show];
//                               });
//
//            }
//
//        }
//        else{
//            [self dismissViewControllerAnimated:YES completion:nil];
//            [self stopActivity];
//
//            UIAlertView * alert15 =[[UIAlertView alloc ] initWithTitle:@"" message:@"Failed to intitiating the workFlow." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//            [alert15 show];
//        }
//    }];
//
//}

- (void) cancelSignature {
    self.cancelBlock();
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _imageArrayForSignature.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
 
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.signatureImages.contentMode = UIViewContentModeScaleAspectFit;
    cell.signatureImages.image = _imageArrayForSignature[indexPath.row];
    cell.signatureImages.userInteractionEnabled = true;
    cell.deleteBtn.tag = indexPath.row;

    [cell.deleteBtn addTarget:self action:@selector(deleteSignatures:) forControlEvents:UIControlEventTouchUpInside];
    
//    if(_imageArrayForSignature.count == 0)
//    {
//        [self disableContinueAndClearButtonsAnimated:NO];
//    }
//    
//
//    NSUInteger *token = _imageArrayForSignature.count;
//    [[NSUserDefaults standardUserDefaults] setInteger:token forKey:@"_imageArrayForSignature"];
//    [[NSUserDefaults standardUserDefaults] synchronize];

    
  //  if (indexpth != nil) {
   // if (indexpth == indexPath.row) {
            [cell.deleteBtn setImage:[UIImage imageNamed:@"cross"] forState:UIControlStateNormal];

  //  }
  //  else
    //  {
           // cell.addCheckImage.image = [UIImage imageNamed:@""];
        //    [cell.deleteBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];

      //  }

  //  }
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(100, 50);
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.signatureViewInternal erase];
    [self enableContinueAndClearButtons];
    self.signatureViewInternal.userInteractionEnabled = NO; // or YES, as you desire.
    self.saveButton.userInteractionEnabled= NO;

    cell.addCheckImage.image = [UIImage imageNamed:@""];
   
    
  // [cell.deleteBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];

    self.imgCapture.hidden =NO;
    self.imageView.contentMode=UIViewContentModeScaleToFill;
    cell = [collectionView cellForItemAtIndexPath:indexPath];
    if (indexPath.row ==0) {
        //self.imgCapture.image = [UIImage imageWithContentsOfFile: _BigimageArrayForSignature[indexPath.row];

        
        
        self.imgCapture.image = [UIImage imageWithContentsOfFile:[dataPaths stringByAppendingPathComponent:@"FirstBigImg.png"]];
      // self.imgCapture.image = [UIImage imageWithContentsOfFile:self.BigimageArrayForSignature[indexPath.item]];
        self.imageView.contentMode=UIViewContentModeScaleToFill;
        cell.addCheckImage.hidden = NO;
        [cell.deleteBtn setImage:[UIImage imageNamed:@"cross"] forState:UIControlStateNormal];
        indexpth = indexPath.row;
    }
    else if (indexPath.row == 1)
    {
       self.imgCapture.image = [UIImage imageWithContentsOfFile:[dataPaths stringByAppendingPathComponent:@"SecondBigImg.png"]];
       // self.imgCapture.image = _BigimageArrayForSignature[indexPath.row];
       // self.imgCapture.image = [UIImage imageWithContentsOfFile:self.BigimageArrayForSignature[indexPath.item]];
        [cell.deleteBtn setImage:[UIImage imageNamed:@"cross"] forState:UIControlStateNormal];
        cell.addCheckImage.hidden = NO;
        indexpth = indexPath.row;

    }
    else if (indexPath.row == 2)
    {
        //self.imgCapture.image = _BigimageArrayForSignature[indexPath.row];

       self.imgCapture.image = [UIImage imageWithContentsOfFile:[dataPaths stringByAppendingPathComponent:@"ThirdBigImg.png"]];
       // self.imgCapture.image = [UIImage imageWithContentsOfFile:self.BigimageArrayForSignature[indexPath.item]];
       [cell.deleteBtn setImage:[UIImage imageNamed:@"cross"] forState:UIControlStateNormal];
        cell.addCheckImage.hidden = NO;
        indexpth = indexPath.row;
    }
}

-(void)deleteSignatures:(UIButton*)sender
{
    
    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:self.collectionOfSignatures];
    NSIndexPath *indexPath = [self.collectionOfSignatures indexPathForItemAtPoint:touchPoint];
    
    UIButton *button = (UIButton *)sender;
    int row = button.tag;

    cell = [self.collectionOfSignatures cellForItemAtIndexPath:indexPath];
    NSLog(@"%ld",cell.deleteBtn.tag);
    [cell.deleteBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [_imageArrayForSignature removeObjectAtIndex:indexPath.item];
    [_BigimageArrayForSignature removeObjectAtIndex:indexPath.item];
    
    self.imgCapture.image = [UIImage imageWithContentsOfFile:[dataPaths stringByAppendingPathComponent:@""]];
    [self.collectionOfSignatures deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:indexPath.item inSection:0]]];

    NSError *error = nil;
    
   // if (cell.deleteBtn.tag == 0) {
    if (indexPath.row == 0) {
         for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dataPaths error:&error]) {
             [[NSFileManager defaultManager] removeItemAtPath:[dataPaths stringByAppendingPathComponent:@"FirstImg.png"] error:&error];
             [[NSFileManager defaultManager] removeItemAtPath:[dataPaths stringByAppendingPathComponent:@"FirstBigImg.png"] error:&error];
          }
        if (_imageArrayForSignature.count == 2) {
            
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
                NSString *dataPath = [dataPaths stringByAppendingPathComponent:@"FirstImg.png"];
                NSString *dataPath2 = [dataPaths stringByAppendingPathComponent:@"SecondImg.png"];
                NSData *imData = UIImagePNGRepresentation(_BigimageArrayForSignature[0]);
                NSData *imData2 = UIImagePNGRepresentation(_BigimageArrayForSignature[1]);

                [imData writeToFile:dataPath atomically:YES];
                [imData2 writeToFile:dataPath2 atomically:YES];

                NSString *dataPathBigImage = [dataPaths stringByAppendingPathComponent:@"FirstBigImg.png"];
                NSString *dataPathBigImage2 = [dataPaths stringByAppendingPathComponent:@"SecondBigImg.png"];

                [imData writeToFile:dataPathBigImage atomically:YES];
                [imData2 writeToFile:dataPathBigImage2 atomically:YES];
            
            for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dataPaths error:&error]) {
                [[NSFileManager defaultManager] removeItemAtPath:[dataPaths stringByAppendingPathComponent:@"ThirdBigImg.png"] error:&error];
                [[NSFileManager defaultManager] removeItemAtPath:[dataPaths stringByAppendingPathComponent:@"ThirdImg.png"] error:&error];
            }
        }
       
        else if(_imageArrayForSignature.count == 1){
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
            NSString *dataPath = [dataPaths stringByAppendingPathComponent:@"FirstImg.png"];
            NSData *imData = [NSData dataWithContentsOfFile:[dataPaths stringByAppendingPathComponent:@"SecondBigImg.png"]];
            [imData writeToFile:dataPath atomically:YES];
            
            NSString *dataPathBigImage = [dataPaths stringByAppendingPathComponent:@"FirstBigImg.png"];
            [imData writeToFile:dataPathBigImage atomically:YES];
            
            for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dataPaths error:&error]) {
                [[NSFileManager defaultManager] removeItemAtPath:[dataPaths stringByAppendingPathComponent:@"SecondBigImg.png"] error:&error];
                [[NSFileManager defaultManager] removeItemAtPath:[dataPaths stringByAppendingPathComponent:@"SecondImg.png"] error:&error];
            }
         
        }else
        {
            for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dataPaths error:&error]) {
                [[NSFileManager defaultManager] removeItemAtPath:[dataPaths stringByAppendingPathComponent:@"ThirdBigImg.png"] error:&error];
                [[NSFileManager defaultManager] removeItemAtPath:[dataPaths stringByAppendingPathComponent:@"ThirdImg.png"] error:&error];
            }
        }
       // [self disableContinueAndClearButtonsAnimated:NO];

    }

    else if (indexPath.row == 1)
    {
         for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dataPaths error:&error]) {
             [[NSFileManager defaultManager] removeItemAtPath:[dataPaths stringByAppendingPathComponent:@"SecondBigImg.png"] error:&error];
             [[NSFileManager defaultManager] removeItemAtPath:[dataPaths stringByAppendingPathComponent:@"SecondImg.png"] error:&error];
         }
        if (_imageArrayForSignature.count == 2) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
            NSString *dataPath = [dataPaths stringByAppendingPathComponent:@"SecondImg.png"];
            NSData *imData = UIImagePNGRepresentation(_BigimageArrayForSignature[1]);
            [imData writeToFile:dataPath atomically:YES];
            
            NSString *dataPathBigImage = [dataPaths stringByAppendingPathComponent:@"SecondBigImg.png"];
            [imData writeToFile:dataPathBigImage atomically:YES];
            
            for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dataPaths error:&error]) {
                [[NSFileManager defaultManager] removeItemAtPath:[dataPaths stringByAppendingPathComponent:@"ThirdBigImg.png"] error:&error];
                [[NSFileManager defaultManager] removeItemAtPath:[dataPaths stringByAppendingPathComponent:@"ThirdImg.png"] error:&error];
            }
        }
        else if(_imageArrayForSignature.count == 0){
            for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dataPaths error:&error]) {
                [[NSFileManager defaultManager] removeItemAtPath:[dataPaths stringByAppendingPathComponent:@"FirstImg.png"] error:&error];
                [[NSFileManager defaultManager] removeItemAtPath:[dataPaths stringByAppendingPathComponent:@"FirstBigImg.png"] error:&error];
            }
        }
       // [self disableContinueAndClearButtonsAnimated:NO];

    }

    else if (indexPath.row == 2)
    {
         for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dataPaths error:&error]) {
             [[NSFileManager defaultManager] removeItemAtPath:[dataPaths stringByAppendingPathComponent:@"ThirdImg.png"] error:&error];
             [[NSFileManager defaultManager] removeItemAtPath:[dataPaths stringByAppendingPathComponent:@"ThirdBigImg.png"] error:&error];
             
        }
       // [self disableContinueAndClearButtonsAnimated:NO];

    }
    
    NSLog(@"%lu",(unsigned long)_imageArrayForSignature.count);


//    if (self.signatureViewInternal != nil) {
//        [self enableContinueAndClearButtons];
//
//    }
//    else
//    {
//        [self disableContinueAndClearButtonsAnimated:NO];
//
//    }
//    if ( _imageArrayForSignature.count <[[NSUserDefaults standardUserDefaults] valueForKey:@"_imageArrayForSignature"] || _imageArrayForSignature == nil){
//        [self disableContinueAndClearButtonsAnimated:NO];
//
//    }
    [self.signatureViewInternal erase];
    self.imgCapture.hidden = YES;
    self.signatureViewInternal.userInteractionEnabled = YES; // or YES, as you desire.

}

- (void) enableContinueAndClearButtons {
    self.clearButton.enabled = YES;
    self.continueButton.enabled = YES;
    self.moreButton.enabled = YES;
}

- (void) disableContinueAndClearButtonsAnimated: (BOOL) animated {
    self.clearButton.enabled = NO;
    self.continueButton.enabled = NO;
    self.moreButton.enabled = NO;
}


- (void)signatureAvailable:(BOOL)signatureAvailable {
    if (signatureAvailable) {
        [self enableContinueAndClearButtons];
    } else {
        [self disableContinueAndClearButtonsAnimated: YES];
    }
}

-(UIImage *)signature {
    return [self.signatureViewInternal signatureImage];
}

- (BOOL) shouldAutorotate {
    // we're autorotating only if the app supports landscape mode
    // else we'd get into trouble because of an exception that says 'Don't set autorotate YES if the view controller does not share orientation with the app'
    NSArray *supportedOrientations = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UISupportedInterfaceOrientations"];
    if ([supportedOrientations containsObject:@"UIInterfaceOrientationLandscapeLeft"] || [supportedOrientations containsObject:@"UIInterfaceOrientationLandscapeRight"]) {
        return YES;
    } else {
        return NO;
        
    }
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    NSArray *supportedOrientations = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UISupportedInterfaceOrientations"];
    // in the special case that the app runs in landscape already, we don't want to change the orientation
    // and force the user to flip the phone.
    if (([supportedOrientations containsObject:@"UIInterfaceOrientationLandscapeLeft"] || [supportedOrientations containsObject:@"UIInterfaceOrientationLandscapeRight"]) && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        return [UIApplication sharedApplication].statusBarOrientation; // current orientation
    } else {
        return UIInterfaceOrientationLandscapeLeft;
    }
}


- (NSBundle *)resourceBundle{
    static NSBundle *MPSignatureViewBundle = nil;
    static dispatch_once_t MPSignatureViewBundleOnce;
    dispatch_once(&MPSignatureViewBundleOnce, ^{
        NSString *mainBundleResourcePath = [[NSBundle mainBundle] resourcePath];
        NSString *signatureViewBundlePath = [mainBundleResourcePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.bundle", MPBSignatureViewBundleName]];
        MPSignatureViewBundle = [NSBundle bundleWithPath:signatureViewBundlePath];
        NSLog(@"bundle path: %@", signatureViewBundlePath);
    });
    return MPSignatureViewBundle;
}

- (NSString *)localizedString:(NSString *)token{
    if (!token) return @"";
    
    //here we check for three different occurances where it can be found
    
    //first up is the app localization
    NSString *appSpecificLocalizationString = NSLocalizedString(token, @"");
    if (![token isEqualToString:appSpecificLocalizationString])
    {
        return appSpecificLocalizationString;
    }
    
    //second is the app localization with specific table
    NSString *appSpecificLocalizationStringFromTable = NSLocalizedStringFromTable(token, @"MPBSignatureView", @"");
    if (![token isEqualToString:appSpecificLocalizationStringFromTable])
    {
        return appSpecificLocalizationStringFromTable;
    }
    
    //third time is the charm, looking in our resource bundle
    if ([self resourceBundle])
    {
        NSString *bundleSpecificLocalizationString = NSLocalizedStringFromTableInBundle(token, @"MPBSignatureView", [self resourceBundle], @"");
        if (![token isEqualToString:bundleSpecificLocalizationString])
        {
            return bundleSpecificLocalizationString;
        }
    }
    
    //and as a fallback, we just return the token itself
    NSLog(@"could not find any localization files. please check that you added the resource bundle and/or your own localizations");
    return token;
}

- (UIImage *)imageWithName:(NSString *)name{
    if (!name) return nil;
    
    if ([self resourceBundle])
    {
        NSString *bundleImagePath = [[self resourceBundle] pathForResource:name ofType:@"tiff"];
        UIImage *bundleImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:bundleImagePath] scale:[[UIScreen mainScreen] scale]];
        if (bundleImage != nil) {
            return bundleImage;
        }
        
        bundleImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.bundle/%@", MPBSignatureViewBundleName, name]];
        if (bundleImage != nil) {
            return bundleImage;
        }
    }
    
    NSLog(@"could not find the resource image. please check that you added the resource bundle.");
    return nil;
}

@end
