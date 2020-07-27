//
//  FlexiformsPage.m
//  emSigner
//
//  Created by Emudhra on 26/02/20.
//  Copyright © 2020 Emudhra. All rights reserved.
//

#import "FlexiformsPage.h"
#import "MBProgressHUD.h"
#import "NSObject+Activity.h"
#import "WebserviceManager.h"
#import "HoursConstants.h"
#import "MyAnnotation.h"
#import "SignatoriesListForFlexiforms.h"
#import "MPBSignatureViewController.h"

@interface FlexiformsPage ()
{
    CGRect    pageBounds;
    CGRect   annotationBounds;
    PDFAnnotation *annotation;
    int AssignedTo;
    PDFPage *pdfPage;
    UITextView *textfield;
    NSString *annotationNameForWidget;
    NSMutableArray *radioControls;
    NSMutableDictionary *dictionaryForGroupNames;
     NSString * groupName;
    NSMutableArray*  radioBtnarray;
   // NSMutableArray *arrayForControls;
}

@end

@implementation FlexiformsPage

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _signatoryArray = [[NSMutableArray alloc]init];
    radioControls = [[NSMutableArray alloc]init];
    dictionaryForGroupNames = [[NSMutableDictionary alloc]init];
    //arrayForControls= [[NSMutableArray alloc]init];
    self.title = _documentNameFlexiForms;
    [self.navigationController.navigationBar setTitleTextAttributes:
    @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
       
    UIBarButtonItem *adhocButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"addAdhocUserForSignatories.png"] style:UIBarButtonItemStylePlain target:self action:@selector(addAdhocSignatories:)];
    self.navigationItem.rightBarButtonItem = adhocButton;

    [self callForGetFlexiformControldetails];
    
    //notification for handling keyboard
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];

}

- (void) viewDidAppear: (BOOL)animated
{
    [super viewDidAppear:animated];
    
   
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PDFViewAnnotationHitNotification object:self.pdfView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PDFViewPageChangedNotification object:self.pdfView];

}

-(void)viewWillAppear:(BOOL)animated
{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PDFViewAnnotationHitNotification:) name:PDFViewAnnotationHitNotification object:self.pdfView];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PDFViewPageChangedNotification:) name:PDFViewPageChangedNotification object:self.pdfView];
}

- (void)preparePDFViewWithPageMode:(PDFDisplayMode) displayMode {
    
    [self notificationPageAndHit];
    
    NSData *data = [[NSData alloc]initWithBase64EncodedString:_base64String options:0];
    radioControls = [[NSMutableArray alloc]init];
    self.pdfDocument = [[PDFDocument alloc] initWithData:data];
//    if (self.passwordForPDF) {
//
//        [self.pdfDocument unlockWithPassword:[[NSUserDefaults standardUserDefaults] valueForKey:@"Password"]];
//
//    }
    
    self.pdfView.displaysPageBreaks = NO;
    self.pdfView.autoScales = YES;
    self.pdfView.maxScaleFactor = 4.0;
    self.pdfView.minScaleFactor = self.pdfView.scaleFactorForSizeToFit;
    
    //load the document
    self.pdfView.document = self.pdfDocument;
    
    //set the display mode
    self.pdfView.displayMode = displayMode;
    
    self.pdfView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    self.pdfView.displayDirection = kPDFDisplayDirectionHorizontal;
    [self.pdfView zoomIn:self];
    self.pdfView.autoScales = true;
    self.pdfView.backgroundColor = [UIColor  whiteColor];
    self.pdfView.document = self.pdfDocument;
    CGContextRef context = nil;
    
    //Add textField
    pageBounds = [[self.pdfView currentPage] boundsForBox: [self.pdfView displayBox]];
    NSMutableArray*  coordinatesArray = [[NSMutableArray alloc]init];
    
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    NSData *tempData = [[NSUserDefaults standardUserDefaults] valueForKey:@"UserProfile"];
    NSDictionary * userProfileDict = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSDictionary class] fromData:tempData error:nil];
    
   
    radioBtnarray  = [[NSMutableArray alloc]init];

    UIImage* img = [UIImage imageNamed:@"signer.png"];//[self processImage:[UIImage imageNamed:@"signer.png"]];

    long pagecount =  self.pdfDocument.pageCount;
    for (int k=1; k<=pagecount; k++) {
        for (int i = 0; i<_responseArray.count; i++) {
        
        if (k == [[_responseArray[i] valueForKey:@"PageNo"]intValue]) {

        if ([[_responseArray[i] valueForKey:@"ControlID"]intValue] == 4) {//signatory image
            
            [coordinatesArray  addObject:[NSValue valueWithCGRect:CGRectMake([[_responseArray[i] valueForKey:@"Left"]doubleValue], [[_responseArray[i]  valueForKey:@"Top"]doubleValue] - 58,112,58)]];
            annotationBounds = [coordinatesArray[i]CGRectValue];
            [annotation setCaption:[_responseArray[i] valueForKey:@"IsMandatory"]];
            [annotation setWidgetDefaultStringValue:[_responseArray[i] valueForKey:@"AssignedTo"]];

            annotation = [[MyAnnotation alloc]initWithImage:img withBounds:annotationBounds withProperties:nil];
            [annotation drawWithBox:kPDFDisplayBoxArtBox inContext:context];
        
        }
        else if ([[_responseArray[i] valueForKey:@"ControlID"]intValue] == 3) {//radio buttons
            
            [coordinatesArray  addObject:[NSValue valueWithCGRect:CGRectMake([[_responseArray[i] valueForKey:@"Left"]doubleValue], [[_responseArray[i]  valueForKey:@"Top"]doubleValue] - 30,30,30)]];
            annotationBounds = [coordinatesArray[i]CGRectValue];
            annotation = [[PDFAnnotation alloc]initWithBounds:annotationBounds forType:PDFAnnotationSubtypeWidget withProperties:nil];
            [annotation setWidgetFieldType:PDFAnnotationWidgetSubtypeButton];
            [annotation setWidgetControlType:kPDFWidgetRadioButtonControl];
            [annotation setFieldName:[_responseArray[i] valueForKey:@"GroupName"]];
            [annotation setCaption:[_responseArray[i] valueForKey:@"IsMandatory"]];
            [annotation setWidgetDefaultStringValue:[_responseArray[i] valueForKey:@"AssignedTo"]];
            
             dictionaryForGroupNames = [NSMutableDictionary new];
             [dictionaryForGroupNames setValue:[_responseArray[i] valueForKey:@"DataControlID"] forKey:@"DataControlID"];
             [dictionaryForGroupNames setValue:[_responseArray[i] valueForKey:@"GroupName"] forKey:@"GroupName"];
            [radioBtnarray addObject:dictionaryForGroupNames];
            [annotation setButtonWidgetStateString:[_responseArray[i] valueForKey:@"DataControlID"]];
                        
            if (![radioControls containsObject:[_responseArray[i] valueForKey:@"GroupName"]]){
                [radioControls addObject:[_responseArray[i] valueForKey:@"GroupName"]];
                //[annotation setButtonWidgetStateString:@"ON"];
                [annotation setButtonWidgetState:kPDFWidgetOnState];

            }
            else{
                [annotation setButtonWidgetState:kPDFWidgetOffState];
                //[annotation setButtonWidgetStateString:@"OFF"];
            }
            
            if ([[_responseArray[i] valueForKey:@"AssignedTo"]intValue] == AssignedTo) {
                [annotation setReadOnly:false];
            }
            else{
                [annotation setReadOnly:true];
            }
          //  [radioControls addObject:dictionaryForGroupNames];
//            for (int rad = 0; rad<radioControls.count; rad++) {
//
//                if ([radioControls[rad] valueForKey:@"GroupName"] == [_responseArray[rad] valueForKey:@"GroupName"]) {
//                    groupName = [_responseArray[rad] valueForKey:@"GroupName"];
//                }
//            }
           // [annotation setButtonWidgetStateString:@"Yes"];
                
        }
        else if ([[_responseArray[i] valueForKey:@"ControlID"]intValue] == 2) { //checkbox
            
            [coordinatesArray  addObject:[NSValue valueWithCGRect:CGRectMake([[_responseArray[i] valueForKey:@"Left"]doubleValue], [[_responseArray[i]  valueForKey:@"Top"]doubleValue] - 24,24,24)]];
            annotationBounds = [coordinatesArray[i]CGRectValue];
            annotation = [[PDFAnnotation alloc]initWithBounds:annotationBounds forType:PDFAnnotationSubtypeWidget withProperties:nil];
            [annotation setWidgetFieldType:PDFAnnotationWidgetSubtypeButton];
            [annotation setCaption:[_responseArray[i] valueForKey:@"IsMandatory"]];

            [annotation setWidgetControlType:kPDFWidgetCheckBoxControl];
            [annotation setButtonWidgetStateString:[_responseArray[i] valueForKey:@"DataControlID"]];
            [annotation setWidgetDefaultStringValue:[_responseArray[i] valueForKey:@"AssignedTo"]];

            
            if ([[_responseArray[i] valueForKey:@"AssignedTo"]intValue] == AssignedTo) {
             
                //[annotation setReadOnly:false];
                [annotation setShouldDisplay:YES];
            }
            else{
                [annotation setShouldDisplay:YES];
               // [annotation setShouldDisplay:NO];

            }
           
        }
        else  if ([[_responseArray[i] valueForKey:@"ControlID"]intValue] == 5){//labels
            [coordinatesArray  addObject:[NSValue valueWithCGRect:CGRectMake([[_responseArray[i] valueForKey:@"Left"]doubleValue], [[_responseArray[i]  valueForKey:@"Top"]doubleValue] - 30,112,30)]];
                   annotationBounds = [coordinatesArray[i]CGRectValue];
            annotation = [[PDFAnnotation alloc]initWithBounds:annotationBounds forType:PDFAnnotationSubtypeWidget withProperties:nil];
            [annotation setWidgetFieldType:PDFAnnotationWidgetSubtypeText];
            [annotation setBackgroundColor:[UIColor colorWithRed:200.0/255.0 green:191.0/255.0 blue:231.0 /255.0 alpha:1.0]];
            [annotation setWidgetStringValue:[_responseArray[i] valueForKey:@"PlaceHolder"]];
            [annotation setCaption:[_responseArray[i] valueForKey:@"IsMandatory"]];
            [annotation setWidgetDefaultStringValue:[_responseArray[i] valueForKey:@"AssignedTo"]];

            if ([[_responseArray[i] valueForKey:@"AssignedTo"]intValue] == AssignedTo) {
                [annotation setReadOnly:false];
                
                if ([[_responseArray[i] valueForKey:@"PlaceHolder"]  isEqual: @"Name"]) {
                    [annotation setWidgetStringValue:[userProfileDict valueForKey:@"FullName"]];
                }
                else if ([[_responseArray[i] valueForKey:@"PlaceHolder"]  isEqual: @"Department"]){
                    [annotation setWidgetStringValue:[userProfileDict valueForKey:@"Department"]];
                }
                else if ([[_responseArray[i] valueForKey:@"PlaceHolder"]  isEqual: @"Email ID"]){
                    [annotation setWidgetStringValue:[userProfileDict valueForKey:@"Email_Id"]];
                }
            }else{
                [annotation setReadOnly:true];
            }
            [annotation setFieldName:[_responseArray[i] valueForKey:@"DataControlID"]];
            [annotation setFontColor:[UIColor redColor]];
            [annotation setFont:[UIFont fontWithName:@"TimesNewRomanPS-ItalicMT" size:10.0f]];
        }
        else  if ([[_responseArray[i] valueForKey:@"ControlID"]intValue] == 1){ // textfield
            [coordinatesArray  addObject:[NSValue valueWithCGRect:CGRectMake([[_responseArray[i] valueForKey:@"Left"]doubleValue], [[_responseArray[i]  valueForKey:@"Top"]doubleValue] - 30,112,30)]];
            annotationBounds = [coordinatesArray[i]CGRectValue];
            annotation = [[PDFAnnotation alloc]initWithBounds:annotationBounds forType:PDFAnnotationSubtypeWidget withProperties:nil];
            [annotation setWidgetFieldType:PDFAnnotationWidgetSubtypeText];
            [annotation setCaption:[_responseArray[i] valueForKey:@"IsMandatory"]];
            [annotation setWidgetDefaultStringValue:[_responseArray[i] valueForKey:@"AssignedTo"]];

            [annotation setBackgroundColor:[UIColor colorWithRed:200.0/255.0 green:191.0/255.0 blue:231.0 /255.0 alpha:1.0]];
            [annotation setWidgetStringValue:[_responseArray[i] valueForKey:@"PlaceHolder"]];
                       
            if ([[_responseArray[i] valueForKey:@"AssignedTo"]intValue] == AssignedTo) {
                [annotation setReadOnly:false];
                }else{
                [annotation setReadOnly:true];
            }
            [annotation setFieldName:[_responseArray[i] valueForKey:@"DataControlID"]];
            [annotation setFontColor:[UIColor redColor]];
            [annotation setFont:[UIFont fontWithName:@"TimesNewRomanPS-ItalicMT" size:10.0f]];
        }
        [[self.pdfView.document pageAtIndex:k-1] addAnnotation:annotation];
       }
      }
    }
    
    [self.view setNeedsDisplay];
    [self.pdfView usePageViewController:(displayMode == kPDFDisplaySinglePage) ? YES :NO withViewOptions:nil];
    
    CGPDFContextEndPage(context);
    
}

-(void)notificationPageAndHit
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PDFViewAnnotationHitNotification:) name:PDFViewAnnotationHitNotification object:self.pdfView];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PDFViewPageChangedNotification:) name:PDFViewPageChangedNotification object:self.pdfView];
}

-(void)showPageNummbers{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.pdfView animated:YES];
       
       // Configure for text only and offset down
       hud.mode = MBProgressHUDModeText;
       hud.labelText = [NSString stringWithFormat:@"Page %@ of %lu", self.pdfView.currentPage.label, (unsigned long)self.pdfDocument.pageCount];
       hud.margin = 10.f;
       hud.yOffset = 170;
       hud.removeFromSuperViewOnHide = YES;
       
       [hud hide:YES afterDelay:1];
}

-(void)PDFViewPageChangedNotification:(NSNotification*)notification{
    
    NSLog(@"%@",[NSString stringWithFormat:@"Page %@ of %lu", self.pdfView.currentPage.label, (unsigned long)self.pdfDocument.pageCount]);
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.pdfView animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = [NSString stringWithFormat:@"Page %@ of %lu", self.pdfView.currentPage.label, (unsigned long)self.pdfDocument.pageCount];
    hud.margin = 10.f;
    hud.yOffset = 170;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:1];
    
}


-(void)PDFViewAnnotationHitNotification:(NSNotification*)notification {

    PDFAnnotation *annotation = (PDFAnnotation*)notification.userInfo[@"PDFAnnotationHit"];
    NSLog(@"%@,%@,%@",[annotation widgetStringValue],[annotation contents],[annotation fieldName]);

    NSLog(@"%@,%@,%@,%ld,%@",annotation.type,annotation.widgetFieldType,annotation.contents,(long)[annotation buttonWidgetState],[annotation caption]);
    annotationNameForWidget = [annotation fieldName];
    
    NSUInteger pageNumber = [self.pdfDocument indexForPage:annotation.destination.page];
    NSLog(@"Page: %lu", (unsigned long)pageNumber);
}


// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
     //NSDictionary* info = [aNotification userInfo];
//     NSUInteger pageNumber = [self.pdfDocument indexForPage:[self.pdfView currentPage]];
//     PDFPage *pdfPage = [self.pdfDocument pageAtIndex:pageNumber];
//     NSArray* annotations = [pdfPage annotations];
//     NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
//     for (int j = 0; j<annotations.count;j++)
//    {
//        if ([annotations[j] fieldName] == annotationNameForWidget && [annotations[j] isReadOnly] == false) {
//        NSLog(@"%@",[annotations[j] widgetStringValue]);
//        [dict setValue:[annotations[j] fieldName] forKey:@"DataControlId"];
//        [dict setValue:[annotations[j] widgetStringValue] forKey:@"ControlValue"];
//        [_ControlInfoArray addObject:dict];
//        }
//    }
//    NSLog(@"%@",_ControlInfoArray);
}


-(void)callForGetFlexiformControldetails{
   
    [self startActivity:@"Refreshing"];
    NSString *requestURL = [NSString stringWithFormat:@"%@GetFlexiformControldetails?pfDocumentId=%@",kGetFlexiformControldetails,_documentIdFlexiForms];
   
    [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
       
       if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])
       {
           dispatch_async(dispatch_get_main_queue(),
                          ^{
                                _responseArray=[[responseValue valueForKey:@"Response"]valueForKey:@"PfConfigList"];
                                _signatoryArray = [[responseValue valueForKey:@"Response"]valueForKey:@"SignatoryList"];
                                [self preparePDFViewWithPageMode:kPDFDisplaySinglePage];
                                [self showPageNummbers];
                                [self stopActivity];
                              
                          });
           
       }
       else{
           
       }
       
   }];
}

- (IBAction)addSignatories:(id)sender {
    _ControlInfoArray = [[NSMutableArray alloc]init];//for controls

    long pagecount =  self.pdfDocument.pageCount;
       for (int k=1; k<=pagecount; k++) {
           pdfPage = [self.pdfDocument pageAtIndex:k-1];
           NSArray* annotations = [pdfPage annotations];
           for (int j = 0; j<annotations.count;j++){
               
               if ([[annotations[j] caption]intValue] == 1 && [[annotations[j] widgetDefaultStringValue]intValue] == AssignedTo) { //check for mandatory fields
                   
                   //1. check for text annotation
                   if ([[annotations[j] widgetFieldType]  isEqual: @"/Tx"]) {
                       if ([annotations[j] widgetStringValue] == nil) {
                            NSLog(@"Beer: %d", j);
                            [self alertForMandatoryFields];
                            return;
                       }
                       else{
                       NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];

                       NSLog(@"%@",[annotations[j] widgetStringValue]);
                       [dict setValue:[annotations[j] fieldName] forKey:@"DataControlId"];
                       [dict setValue:[annotations[j] widgetStringValue] forKey:@"ControlValue"];
                       [_ControlInfoArray addObject:dict];
                        }
                   }
               
                   //2. check for radio buttons
                   else if ([annotations[j] widgetControlType] == kPDFWidgetRadioButtonControl ) {
                       if ((long)[annotation buttonWidgetState] == 0) {
                            [self alertForMandatoryFields];
                            return;
                       }
                      
                       else{
                        NSMutableDictionary * raddict = [[NSMutableDictionary alloc]init];

                        NSLog(@"%@",[annotations[j] widgetStringValue]);
                        [raddict setValue:[annotations[j] widgetStringValue] forKey:@"DataControlId"];

                        if ([annotations[j] buttonWidgetState] == kPDFWidgetOnState) {
                            [raddict setValue:@"Checked" forKey:@"ControlValue"];
                            [_ControlInfoArray addObject:raddict];
                        }else{
                            [raddict setValue:@"" forKey:@"ControlValue"];
                            [_ControlInfoArray addObject:raddict];
                        }
                   }
                   }
                   
                   //3. check for checkbox
                   else if ([annotations[j] widgetControlType] == kPDFWidgetCheckBoxControl){
                       if ([annotations[j] buttonWidgetState] == 0) {
                            [self alertForMandatoryFields];
                            return;
                       }
                       else{
                       NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];

                        NSLog(@"%@",[annotations[j] widgetStringValue]);
                        [dict setValue:[annotations[j] widgetStringValue] forKey:@"DataControlId"];
                        if ([annotations[j] buttonWidgetState] == kPDFWidgetOnState) {
                            [dict setValue:@"Checked" forKey:@"ControlValue"];
                            [_ControlInfoArray addObject:dict];
                        }else{
                            [dict setValue:@"" forKey:@"ControlValue"];
                            [_ControlInfoArray addObject:dict];
                        }
                   }
                }
            }
        }
    }
    
    NSString* signerString = @"AssignedTo";
    for (int i=0; i<_responseArray.count; i++) {
        if ([[_responseArray[i] valueForKey:@"ControlID"]intValue] == 4 && [[_responseArray[i] valueForKey:@"AssignedTo"]intValue] == AssignedTo) {
            signerString = @"Signer";
        }
    }
   // if ([signerString isEqualToString:@"Signer"]) {
        
        [self showModal:UIModalPresentationFullScreen style:[MPBDefaultStyleSignatureViewController alloc]];
   // }
        
}

-(void)alertForMandatoryFields{
   
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.pdfView animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"Mandatory fields cannot be empty!";
    hud.margin = 10.f;
    hud.yOffset = 170;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2];
    
}

-(void)sendDataTosigners:(NSMutableArray *) array
{
    
    [self startActivity:@""];
    for (int i = 0; i<array.count; i++) {
        if ([[array[i] valueForKey:@"Name"]isEqualToString:@"ME"]) {
            AssignedTo = i+1;
        }
    }
    
    [self preparePDFViewWithPageMode:kPDFDisplaySinglePage];
    [self showPageNummbers];
    [self stopActivity];
    
}

-(void)addAdhocSignatories:(UIButton* )sender
{
    NSMutableArray *empty = [[NSMutableArray alloc]init];
     empty = [NSMutableArray arrayWithArray:_signatoryArray];

    SignatoriesListForFlexiforms *objTrackOrderVC= [[SignatoriesListForFlexiforms alloc] initWithNibName:@"SignatoriesListForFlexiforms" bundle:nil];
    objTrackOrderVC.signersCount = [_signatoryArray count];
    objTrackOrderVC.delegate = self;
    objTrackOrderVC.sectionArray = empty;
    UINavigationController *objNavigationController = [[UINavigationController alloc]initWithRootViewController:objTrackOrderVC];
    [self presentViewController:objNavigationController animated:true completion:nil];
}

- (void)showModal:(UIModalPresentationStyle) style style:(MPBCustomStyleSignatureViewController*) controller
{
    
    MPBCustomStyleSignatureViewController* signatureViewController = [controller initWithConfiguration:[MPBSignatureViewControllerConfiguration configurationWithFormattedAmount:@""]];
    signatureViewController.modalPresentationStyle = style;
    signatureViewController.strExcutedFrom=@"Waiting for Others";
    signatureViewController.gotParametersForInitiateWorkFlow =[NSMutableArray arrayWithObject:@"ME"];
    
//    signatureViewController.CategoryId = _CategoryId;
//    signatureViewController.Documentname =  _Documentname;
//    signatureViewController.CategoryName = _CategoryName;
//    signatureViewController.ConfigId = _ConfigId;
//    signatureViewController.DocumentID = *(&(_DocumentID));
//    signatureViewController.subscriberIdarray =_subscriberIdarray;
//    signatureViewController.d = _d;

    signatureViewController.preferredContentSize = CGSizeMake(800, 500);
    signatureViewController.configuration.scheme = MPBSignatureViewControllerConfigurationSchemeAmex;
    // signatureViewController.signatureWorkFlowID = _workFlowID;
    signatureViewController.continueBlock = ^(UIImage *signature) {
        //[self showImage: signature];
                
    };
    signatureViewController.cancelBlock = ^ {
        
    };
    signatureViewController.delegate = self;
    [self presentViewController:signatureViewController animated:YES completion:nil];
    //[self.navigationController pushViewController:signatureViewController animated:true];
    
}


@end
