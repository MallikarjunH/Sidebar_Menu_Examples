//
//  ParallelSigning.m
//  emSigner
//
//  Created by Emudhra on 25/02/19.
//  Copyright © 2019 Emudhra. All rights reserved.
//

#import "ParallelSigning.h"
#import "WebserviceManager.h"
#import "HoursConstants.h"
#import "MBProgressHUD.h"
#import "NSObject+Activity.h"
#import "ShareVC.h"
#import "CompleteStatusVC.h"


#import "AppDelegate.h"
#import "ViewController.h"
#import "DelegateDocument.h"
#import "MyAnnotation.h"


@interface ParallelSigning ()
{
    CustomPopOverVC *popVC;
    CGRect   annotationBounds;
    
    PDFAnnotation * ann;
    PDFAnnotation* currentlySelectedAnnotation;
    PDFAnnotation *annotation;
    CGRect pBounds;
}

@end

@implementation ParallelSigning

enum
{
    ResourceCacheMaxSize = 128<<20    /**< use at most 128M for resource cache */
};

NSString *key;
NSString *_filePath;
BOOL reflowMode;
UIScrollView *canvasScrollView;
UIBarButtonItem *backButton;
int barmode;
int searchPage;
int cancelSearch;
int showLinks;
int width; // current screen size
int height;
int current; // currently visible page
int scroll_animating; // stop view updates during scrolling animations
float scale; // scale applied to views (only used in reflow mode)
BOOL _isRotating;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // Do any additional setup after loading the view.
    _addFile = [[NSMutableArray alloc] init];
    
    UIView *view = [[UIView alloc] initWithFrame: CGRectZero];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [view setAutoresizesSubviews: YES];
    view.backgroundColor = [UIColor grayColor];
    
    canvasScrollView = [[UIScrollView alloc] initWithFrame: CGRectMake(0,0,self.pdfView.bounds.size.width, self.pdfView.bounds.size.height)];
    canvasScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [canvasScrollView setPagingEnabled: YES];
    [canvasScrollView setShowsHorizontalScrollIndicator: NO];
    [canvasScrollView setShowsVerticalScrollIndicator: NO];
    canvasScrollView.delegate = self;
    [self.pdfView addSubview: canvasScrollView];
    
    [_Signatorylbl sizeToFit];
    if (self.signatoryString != nil) {
        _Signatorylbl.text =[NSString stringWithFormat:@"%@",self.signatoryString];
    }
    
    UIButton* customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [customButton setImage:[UIImage imageNamed:@"three-aligned-squares-in-vertical-line"] forState:UIControlStateNormal];
    [customButton sizeToFit];
    UIBarButtonItem* customBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:customButton];
    [customButton addTarget:self
                     action:@selector(flipView:)
           forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = customBarButtonItem;
    
    UIButton* customButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [customButton1 setImage:[UIImage imageNamed:@"ico-back-24.png"] forState:UIControlStateNormal];
    [customButton1 sizeToFit];
    UIBarButtonItem* customBarButtonItem1 = [[UIBarButtonItem alloc] initWithCustomView:customButton1];
    [customButton1 addTarget:self
                      action:@selector(popViewControllerAnimated:)
            forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = customBarButtonItem1;
    
    
//    if ([_documentCount intValue] > 1) {
//        customButton.hidden = NO;
//    }
//    else if ([_attachmentCount intValue] > 0)
//    {
//        customButton.hidden = NO;
//    }
//    else{
//        customButton.hidden = YES;
//    }
    
}

-(void) viewDidAppear: (BOOL)animated
{
    [super viewDidAppear:animated];
   
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.pdfView animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = [NSString stringWithFormat:@"Page %@ of %lu", self.pdfView.currentPage.label, (unsigned long)self.pdfDocument.pageCount];
    hud.margin = 10.f;
    hud.yOffset = 170;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:1];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [self.pdfView addGestureRecognizer:panRecognizer];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self preparePDFViewWithPageMode:kPDFDisplaySinglePage];

    current=0;
    self.title = _myTitle;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PDFViewPageChangedNotification:) name:PDFViewPageChangedNotification object:self.pdfView];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PDFViewAnnotationHitNotification object:self.pdfView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PDFViewPageChangedNotification object:self.pdfView];

}

#pragma mark - PDFViewAnnotationHitNotification

-(void)PDFViewAnnotationHitNotification:(NSNotification*)notification {
    PDFAnnotation *annotation = (PDFAnnotation*)notification.userInfo[@"PDFAnnotationHit"];
    NSUInteger pageNumber = [self.pdfDocument indexForPage:annotation.destination.page];
    NSLog(@"Page: %lu", (unsigned long)pageNumber);
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

#pragma mark - Prepare PDF View

-(void)move:(UIPanGestureRecognizer*)sender {
    
    CGPoint point = [sender locationInView:self.pdfView];
    PDFPage * anntPoint = [self.pdfView pageForPoint:point nearest:YES];
    CGPoint pointOnScreen = [self.pdfView convertPoint:point toPage:anntPoint];
    
    NSLog(@"Point - %f, %f", pointOnScreen.x, pointOnScreen.y);
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        
        ann = [anntPoint annotationAtPoint:pointOnScreen];
        
        if ([ann isKindOfClass:[MyAnnotation class]]) {
            currentlySelectedAnnotation = ann;
        }
    }
    
    if (sender.state == UIGestureRecognizerStateChanged) {
        
        if ([ann.type  isEqual: @"Widget"]) {
            
            NSLog(@"not stamp");
            
        }
        else{
            
            PDFAnnotation * anotation = currentlySelectedAnnotation;
            CGRect annBounds = anotation.bounds;
            pBounds = [[self.pdfView currentPage] boundsForBox: [self.pdfView displayBox]];
            CGRect pointscheck = CGRectMake(pointOnScreen.x - (annBounds.size.width)/2,pointOnScreen.y - (annBounds.size.height)/2,annBounds.size.width,annBounds.size.height);
            
            if(CGRectContainsRect(pBounds, pointscheck))
            {
                ann.bounds = CGRectMake(pointOnScreen.x - (annBounds.size.width/2), pointOnScreen.y - (annBounds.size.height/2), annBounds.size.width, annBounds.size.height);
            }
            else
            {
                
                if (pBounds.size.height < pointOnScreen.y + annBounds.size.height || pBounds.origin.y > pointOnScreen.y)
                    return;
                if (pBounds.size.width < pointOnScreen.x + annBounds.size.width || pBounds.origin.x > pointOnScreen.x)
                    return;
                
                //            if(pBounds.size.width - (annBounds.size.width) < annBounds.origin.x )
                //                //pBounds.origin.x = pBounds.size.width - (annBounds.size.width);
                //                ann.bounds = CGRectMake( pointOnScreen.x,  annBounds.origin.y, annBounds.size.width, annBounds.size.height);
                //
                //            else if(pBounds.size.height - (annBounds.size.height) < annBounds.origin.y )
                //                //pBounds.origin.y = pBounds.size.height - (annBounds.size.height);
                //                ann.bounds = CGRectMake( annBounds.origin.x,  pointOnScreen.y, annBounds.size.width, annBounds.size.height);
                
                // else
                ann.bounds = CGRectMake( pointOnScreen.x,  pointOnScreen.y, annBounds.size.width, annBounds.size.height);
                
            }
            NSLog(@"move to %ld",pointOnScreen);
            
        }
    }
    
    if ((sender.state == UIGestureRecognizerStateEnded) || (sender.state == UIGestureRecognizerStateCancelled)||(sender.state == UIGestureRecognizerStateFailed)) {
        
        currentlySelectedAnnotation = nil;
    }
    
}


- (void)preparePDFViewWithPageMode:(PDFDisplayMode) displayMode {
    
    NSData *data = [[NSData alloc]initWithBase64EncodedString:_pdfImagedetail options:0];
    
    self.pdfDocument = [[PDFDocument alloc] initWithData:data];
    if (self.passwordForPDF) {
        //[self.pdfDocument unlockWithPassword: @(self.passwordForPDF)];
        [self.pdfDocument unlockWithPassword:[[NSUserDefaults standardUserDefaults] valueForKey:@"Password"]];
        
    }
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
    
    CGRect    pageBounds;
    
    long pnum = 0;
    //for getting type of placeholder.
    NSMutableArray *coordinatesArray;
    long pagecount =  self.pdfDocument.pageCount;
    for (int k=1; k<=pagecount; k++) {
        coordinatesArray = [[NSMutableArray alloc]init];
        for (int i = 0; i<_placeholderArray.count; i++) {
            
            if ([[_placeholderArray[i] valueForKey:@"SinaturePage"] isEqualToString:@"FIRST"]) {
                pnum = 1;
                [coordinatesArray  addObject:[NSValue valueWithCGRect:CGRectMake([[_placeholderArray[i] valueForKey:@"Left"]doubleValue], [[_placeholderArray[i]  valueForKey:@"Top"]doubleValue] - 58,112 , 58)]];
            }
            else if ([[_placeholderArray[i] valueForKey:@"SinaturePage"] isEqualToString:@"LAST"]) {
                pnum = pagecount;
                [coordinatesArray  addObject:[NSValue valueWithCGRect:CGRectMake([[_placeholderArray[i] valueForKey:@"Left"]doubleValue], [[_placeholderArray[i]  valueForKey:@"Top"]doubleValue] - 58,112 , 58)]];
                
            }
            else if ([[_placeholderArray[i] valueForKey:@"SinaturePage"] isEqualToString:@"EVEN PAGES"]) {
                if (k%2 == 0) {
                    pnum = k;
                    [coordinatesArray  addObject:[NSValue valueWithCGRect:CGRectMake([[_placeholderArray[i] valueForKey:@"Left"]doubleValue], [[_placeholderArray[i]  valueForKey:@"Top"]doubleValue] - 58,112 , 58)]];
                }
            }
            else if ([[_placeholderArray[i] valueForKey:@"SinaturePage"] isEqualToString:@"ODD PAGES"]) {
                if (k%2 != 0) {
                    pnum = k;
                    [coordinatesArray  addObject:[NSValue valueWithCGRect:CGRectMake([[_placeholderArray[i]  valueForKey:@"Left"]doubleValue], [[_placeholderArray[i]   valueForKey:@"Top"]doubleValue] - 58,112 , 58)]];
                }
            }
            else if ([[_placeholderArray[i] valueForKey:@"SinaturePage"] isEqualToString:@"ALL"]) {
                pnum = k;
                [coordinatesArray  addObject:[NSValue valueWithCGRect:CGRectMake([[_placeholderArray[i] valueForKey:@"Left"]doubleValue], [[_placeholderArray[i]  valueForKey:@"Top"]doubleValue] - 58,112 , 58)]];
            }
            else if ([[_placeholderArray[i] valueForKey:@"SinaturePage"] isEqualToString:@"SPECIFY"]) {
                NSArray* str = [[_placeholderArray[i] valueForKey:@"PageNo"]componentsSeparatedByString:@","];
                for (int j=0; j<str.count; j++) {
                    
                    if (k == [str[j]intValue])
                    {
                        pnum = k;
                        [coordinatesArray  addObject:[NSValue valueWithCGRect:CGRectMake([[_placeholderArray[i] valueForKey:@"Left"]doubleValue], [[_placeholderArray[i]  valueForKey:@"Top"]doubleValue] - 58,112 , 58)]];
                    }
                }
            }
            else if ([[_placeholderArray[i] valueForKey:@"SinaturePage"] isEqualToString:@"PAGE LEVEL"]) {
                
                if ([[_placeholderArray[i]valueForKey:@"PageNo"]intValue] == k) {
                    pnum = k;
                    [coordinatesArray  addObject:[NSValue valueWithCGRect:CGRectMake([[_placeholderArray[i] valueForKey:@"Left"]doubleValue], [[_placeholderArray[i]  valueForKey:@"Top"]doubleValue] - 58,112 , 58)]];
                }
            }
        }
       
        UIImage *img;
        
        if (self.signatureImage != nil) {
            img = self.signatureImage;
        }
        else{
            img = [UIImage imageNamed:@"signer.png"];//[self processImage:[UIImage imageNamed:@"signer.png"]];
        }
        if (k == pnum) {
            for (int i = 0; i<coordinatesArray.count; i++) {
                pageBounds = [[self.pdfView currentPage] boundsForBox: [self.pdfView displayBox]];
                annotationBounds = [coordinatesArray[i]CGRectValue];
                CGContextRef context = nil;
                annotation = [[MyAnnotation alloc]initWithImage:img withBounds:annotationBounds withProperties:nil];
                [annotation drawWithBox:kPDFDisplayBoxArtBox inContext:context];
                [[self.pdfView.document pageAtIndex:k-1]addAnnotation:annotation];
                [self.view setNeedsDisplay];
                [self.pdfView usePageViewController:(displayMode == kPDFDisplaySinglePage) ? YES :NO withViewOptions:nil];
                CGPDFContextEndPage(context);
                
            }
        }
        [self.pdfView usePageViewController:(displayMode == kPDFDisplaySinglePage) ? YES :NO withViewOptions:nil];
    }
}

-(void)flipView:(UIButton*)sender
{
    
    UIAlertController * view=   [[UIAlertController
                                     alloc]init];
    
       UIAlertAction* Document = [UIAlertAction
                                actionWithTitle:@"Documents "
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    //tag = 0;
                                    [self dissmissCellPopup:0];
                                    
                                }];
        UIAlertAction* attachment  = [UIAlertAction
                                   actionWithTitle:@"View/Add Attachments"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
                                   {
                                        //tag = 1;
                                       [self dissmissCellPopup:1];

                                   }];
    UIAlertAction* cancel = [UIAlertAction
                                actionWithTitle:@"Cancel"
                                style:UIAlertActionStyleDestructive
                                handler:^(UIAlertAction * action)
                                {
                                    
                                }];
    
    if ([_documentCount intValue] > 1){
        [view addAction:Document];
    }
        [view addAction:attachment];
        [view addAction:cancel];
       
       [self presentViewController:view animated:YES completion:nil];
       
    
//    if ([_documentCount isEqualToString:@"1"] && _attachmentCount>0) {
//        UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        popVC = [newStoryBoard instantiateViewControllerWithIdentifier:@"CustomPopOverVC"];
//        UINavigationController *popNav = [[UINavigationController alloc]initWithRootViewController: popVC];
//        popVC.delegate = self;
//        popVC.preferredContentSize = CGSizeMake(200,8);
//        popVC.attachmentCount = _attachmentCount;
//        popVC.documentCount = _documentCount;
//        popVC.workflowID =_workflowID;
//        popNav.modalPresentationStyle = UIModalPresentationPopover;
//        _popover = popNav.popoverPresentationController;
//        _popover.delegate = self;
//        _popover.sourceView = self.view;
//        CGRect frame = [sender frame];
//        frame.origin.y = self.view.frame.origin.y - frame.size.height + 40;
//        frame.origin.x =  self.view.frame.size.width - frame.size.width +20;
//        _popover.sourceRect = frame;
//        popNav.navigationBarHidden = YES;
//        [self presentViewController: popNav animated:YES completion:nil];
//    }
//
//    else{
//        if ([_attachmentCount intValue] > 0) {
//            UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//            popVC = [newStoryBoard instantiateViewControllerWithIdentifier:@"CustomPopOverVC"];
//            UINavigationController *popNav = [[UINavigationController alloc]initWithRootViewController: popVC];
//            popVC.delegate = self;
//            popVC.preferredContentSize = CGSizeMake(200,60);
//            popVC.attachmentCount = _attachmentCount;
//            popVC.documentCount = _documentCount;
//            popVC.workflowID =_workflowID;
//            popNav.modalPresentationStyle = UIModalPresentationPopover;
//            _popover = popNav.popoverPresentationController;
//            _popover.delegate = self;
//            _popover.sourceView = self.view;
//            CGRect frame = [sender frame];
//            frame.origin.y = self.view.frame.origin.y - frame.size.height + 40;
//            frame.origin.x =  self.view.frame.size.width - frame.size.width +20;
//            _popover.sourceRect = frame;
//            popNav.navigationBarHidden = YES;
//            [self presentViewController: popNav animated:YES completion:nil];
//        }
//        else{
//            UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//            popVC = [newStoryBoard instantiateViewControllerWithIdentifier:@"CustomPopOverVC"];
//            UINavigationController *popNav = [[UINavigationController alloc]initWithRootViewController: popVC];
//            popVC.delegate = self;
//            popVC.preferredContentSize = CGSizeMake(200,8);
//            popVC.attachmentCount = _attachmentCount;
//            popVC.documentCount = _documentCount;
//            popVC.workflowID =_workflowID;
//            popNav.modalPresentationStyle = UIModalPresentationPopover;
//            _popover = popNav.popoverPresentationController;
//            _popover.delegate = self;
//            _popover.sourceView = self.view;
//            CGRect frame = [sender frame];
//            frame.origin.y = self.view.frame.origin.y - frame.size.height + 40;
//            frame.origin.x =  self.view.frame.size.width - frame.size.width +20;
//            _popover.sourceRect = frame;
//            popNav.navigationBarHidden = YES;
//            [self presentViewController: popNav animated:YES completion:nil];
//        }
//
//    }
    
}



-(void)dissmissCellPopup:(NSInteger)row{
    switch (row) {
        case 0:
        {
            
            [self dismissViewControllerAnimated:NO completion:nil];
            UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            MultiplePdfViewerVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"MultiplePdfViewerVC"];
            objTrackOrderVC.delegate = self;
            objTrackOrderVC.workFlowId = _workflowID;
            objTrackOrderVC.currentSelectedRow = _selectedIndex;
            objTrackOrderVC.strExcutedFrom = _strExcutedFrom;
            objTrackOrderVC.document = @"Documents";
            objTrackOrderVC.parallel = @"1";
            objTrackOrderVC.signatoryHolderArray = _matchSignersList;

            [self.navigationController pushViewController:objTrackOrderVC animated:YES];
        }
            
            break;
        case 1:
        {
            [self dismissViewControllerAnimated:NO completion:nil];
            UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            AttachedVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"AttachedVC"];
            objTrackOrderVC.workFlowId = _workflowID;
            objTrackOrderVC.currentSelectedRow = _selectedIndex;
            objTrackOrderVC.document = @"Attached Documents";
            UINavigationController *objNavigationController = [[UINavigationController alloc]initWithRootViewController:objTrackOrderVC];
            [self presentViewController:objNavigationController animated:true completion:nil];
           // [self.navigationController pushViewController:objTrackOrderVC animated:YES];
        }
            
            break;
            
            
        default:
            break;
    }
    
}


#pragma mark == UIPopoverPresentationControllerDelegate ==
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

-(void)dataFromControllerTwo:(NSString *)data
{
    _multiplePdfImagedetail=data;
}

-(void)documentNameControllerTwo:(NSString *)dName
{
    _myTitle = dName;
}

-(void)dataForWorkflowId:(NSString *)dWorkflowid
{
    _documentID = dWorkflowid;
}

-(void)selectedCellIndexTwo:(int)iIndex
{
    _selectedIndex = iIndex;
}

-(void)popViewControllerAnimated:(UIButton*)sender
{
    
    //    if ([self.strExcutedFrom isEqualToString:@"DocsStore"])
    //    {
    //        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    //
    //    }
    //    else{
    //[self.navigationController popToRootViewControllerAnimated:YES];
    [self.navigationController popViewControllerAnimated:YES];
    //}
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    
    /*****************************Download**************************************/
    
    if (alertView.tag == 36)
    {
        if (buttonIndex == 0)
        {
            
            [self startActivity:@"Loading..."];
            
            NSString *requestURL = [NSString stringWithFormat:@"%@DownloadWorkFlowDocumentsByWorkflowId?WorkFlowId=%@",kDownloadPdf,_workflowID];
            [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
                
                //if(status)
                    if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        _pdfImageArray=[responseValue valueForKey:@"Response"];
                        
                        if (_pdfImageArray != (id)[NSNull null])
                        {
                            [_addFile removeAllObjects];
                            for(int i=0; i<[_pdfImageArray count];i++)
                            {
                                
                                _pdfFileName = [[_pdfImageArray objectAtIndex:i] objectForKey:@"DocumentName"];
                                _pdfFiledata = [[_pdfImageArray objectAtIndex:i] objectForKey:@"FileData"];
                                
                                NSData *data = [[NSData alloc]initWithBase64EncodedString:_pdfFiledata options:0];
                                NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
                                CFUUIDRef uuid = CFUUIDCreate(NULL);
                                CFStringRef uuidString = CFUUIDCreateString(NULL, uuid);
                                CFRelease(uuid);
                                NSString *uniqueFileName = [NSString stringWithFormat:@"%@%@%@%@",_pdfFileName,@"                                                 ",(__bridge NSString *)uuidString, _pdfFileName];
                                
                                
                                NSString *path = [documentsDirectory stringByAppendingPathComponent:uniqueFileName];
                                [_addFile addObject:path];
                                
                                [data writeToFile:path atomically:YES];
                                
                                
                                
                                if (i==_pdfImageArray.count-1)
                                {
                                    [self stopActivity];
                                    QLPreviewController *previewController=[[QLPreviewController alloc]init];
                                    previewController.delegate=self;
                                    previewController.dataSource=self;
                                    //[self presentModalViewController:previewController animated:YES];
                                    [self presentViewController:previewController animated:YES completion:nil];
                                    [previewController.navigationItem setRightBarButtonItem:nil];
                                }
                                
                            }
                        }
                        else{
                            return ;
                        }
                        
                    });
                    
                }
                else{
                    
                }
                
            }];
            
            
        }
        else if (buttonIndex == 1)
        {
            
        }
    }
    /****************************Open Downloaded file*******************************/
    //    else if (alertView.tag == 28)
    //    {
    //        if (buttonIndex == 0)
    //        {
    //            //currentPreviewIndex=[(UIButton *)sender tag]-1;
    //
    //            QLPreviewController *previewController=[[QLPreviewController alloc]init];
    //            previewController.delegate=self;
    //            previewController.dataSource=self;
    //            //[self presentModalViewController:previewController animated:YES];
    //            [self presentViewController:previewController animated:YES completion:nil];
    //            [previewController.navigationItem setRightBarButtonItem:nil];
    //        }
    //
    //    }
    /******************************************************************************/
}


#pragma mark - data source(Preview)
//Data source methods
//– numberOfPreviewItemsInPreviewController:
//– previewController:previewItemAtIndex:
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return [_addFile count];
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    //You'll need an additional '/'
    NSString *fileName = [_addFile objectAtIndex:index];
    //NSString *fullPath = [path stringByAppendingFormat:@"/%@", fileName];
    return [NSURL fileURLWithPath:fileName];
    
}

- (IBAction)delegateDocument:(id)sender {
    
    DelegateDocument *temp = [[DelegateDocument alloc]initWithNibName:@"DelegateDocument" bundle:nil];
    temp.workflowID = _workflowID;
    temp.matchSignersList = _matchSignersList;
    [self.navigationController pushViewController:temp animated:YES];
    
}

- (IBAction)Download:(id)sender {
    //    UIAlertView *alertView36 = [[UIAlertView alloc] initWithTitle:@"Download"
    //                                                        message:@"Do you really want to download?"
    //                                                       delegate:self
    //                                              cancelButtonTitle:@"Yes"
    //                                              otherButtonTitles:@"No", nil];
    //    alertView36.tag = 36;
    //    [alertView36 show];
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Download"
                                 message:@"Do you want to download document?"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    //Add Buttons
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Yes"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                    [self startActivity:@"Loading..."];
                                    
                                    NSString *requestURL = [NSString stringWithFormat:@"%@DownloadWorkflowDocuments?WorkFlowId=%@",kDownloadPdf,_workflowID];
                                    [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
                                        
                                       // if(status)
                                            if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

                                        {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                
                                                _pdfImageArray=[responseValue valueForKey:@"Response"];
                                                
                                                if (_pdfImageArray != (id)[NSNull null])
                                                {
                                                    [_addFile removeAllObjects];
                                                    for(int i=0; i<[_pdfImageArray count];i++)
                                                    {
                                                        
                                                        _pdfFileName = [[_pdfImageArray objectAtIndex:i] objectForKey:@"DocumentName"];
                                                        _pdfFiledata = [[_pdfImageArray objectAtIndex:i] objectForKey:@"Document"];
                                                        
                                                        NSData *data = [[NSData alloc]initWithBase64EncodedString:_pdfFiledata options:0];
                                                        NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
                                                        CFUUIDRef uuid = CFUUIDCreate(NULL);
                                                        CFStringRef uuidString = CFUUIDCreateString(NULL, uuid);
                                                        CFRelease(uuid);
                                                        NSString *uniqueFileName = [NSString stringWithFormat:@"%@%@%@%@",_pdfFileName,@"                                                 ",(__bridge NSString *)uuidString, _pdfFileName];
                                                        
                                                        
                                                        NSString *path = [documentsDirectory stringByAppendingPathComponent:uniqueFileName];
                                                        [_addFile addObject:path];
                                                        
                                                        [data writeToFile:path atomically:YES];
                                                        
                                                        
                                                        
                                                        if (i==_pdfImageArray.count-1)
                                                        {
                                                            [self stopActivity];
                                                            QLPreviewController *previewController=[[QLPreviewController alloc]init];
                                                            previewController.delegate=self;
                                                            previewController.dataSource=self;
                                                            //[self presentModalViewController:previewController animated:YES];
                                                            [self presentViewController:previewController animated:YES completion:nil];
                                                            [previewController.navigationItem setRightBarButtonItem:nil];
                                                        }
                                                        
                                                    }
                                                }
                                                else{
                                                    return ;
                                                }
                                                
                                            });
                                            
                                        }
                                        else{
                                            // if ([responseValue isKindOfClass:[NSString class]]) {
                                            // if ([responseValue isEqualToString:@"Invalid token Please Contact Adminstrator"]) {
                                            
                                            [self stopActivity];
                                            UIAlertController * alert = [UIAlertController
                                                                         alertControllerWithTitle:nil
                                                                         message:[[responseValue valueForKey:@"Messages"]objectAtIndex:0]
                                                                         preferredStyle:UIAlertControllerStyleAlert];
                                            
                                            //Add Buttons
                                            
                                            UIAlertAction* yesButton = [UIAlertAction
                                                                        actionWithTitle:@"Ok"
                                                                        style:UIAlertActionStyleDefault
                                                                        handler:^(UIAlertAction * action) {
                                                                            //Handle your yes please button action here
                                                                            //Logout
                                                                            AppDelegate *theDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                                                                            theDelegate.isLoggedIn = NO;
                                                                            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:theDelegate.isLoggedIn] forKey:@"isLogin"];
                                                                            [NSUserDefaults resetStandardUserDefaults];
                                                                            [NSUserDefaults standardUserDefaults];
                                                                            UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                                            ViewController *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"ViewController"];
                                                                            [self presentViewController:objTrackOrderVC animated:YES completion:nil];
                                                                        }];
                                            
                                            [alert addAction:yesButton];
                                            
                                            [self presentViewController:alert animated:YES completion:nil];
                                            
                                            return;
                                        }
                                        
                                    }];
                                }];
    
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"No"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   //Handle no, thanks button
                               }];
    
    //Add your buttons to alert controller
    
    [alert addAction:yesButton];
    [alert addAction:noButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)More:(id)sender {
    
    UIAlertController * view=   [[UIAlertController
                                  alloc]init];
    UIAlertAction* Doclog = [UIAlertAction
                             actionWithTitle:@"Document log"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                 DocumentLogVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"DocumentLogVC"];
                                 
                                 objTrackOrderVC.workflowID = _workflowID;
                                 [self.navigationController pushViewController:objTrackOrderVC animated:YES];
                             }];
    UIAlertAction* Share = [UIAlertAction
                            actionWithTitle:@"Share Document"
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action)
                            {
                                NSString *pendingdocumentName =_myTitle;
                                NSString *pendingWorkflowID =_workflowID;
                                UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                ShareVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"ShareVC"];
                                objTrackOrderVC.documentName = pendingdocumentName;
                                objTrackOrderVC.workflowID = pendingWorkflowID;
                                [self.navigationController pushViewController:objTrackOrderVC animated:YES];
                                
                            }];
    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction * action)
                             {
                                 // [self.view dis]
                             }];
    
    
    
    [Share setValue:[[UIImage imageNamed:@"share-variant.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [Doclog setValue:[[UIImage imageNamed:@"stack-exchange.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [Share setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    [Doclog setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    view.view.tintColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];

    [view addAction:Share];
    [view addAction:Doclog];
    [view addAction:cancel];
    
    [self presentViewController:view animated:YES completion:nil];
}





#pragma mark - delegate methods


- (BOOL)previewController:(QLPreviewController *)controller shouldOpenURL:(NSURL *)url forPreviewItem:(id <QLPreviewItem>)item
{
    return YES;
}

- (CGRect)previewController:(QLPreviewController *)controller frameForPreviewItem:(id <QLPreviewItem>)item inSourceView:(UIView **)view
{
    
    //Rectangle of the button which has been pressed by the user
    //Zoom in and out effect appears to happen from the button which is pressed.
    UIView *view1 = [self.view viewWithTag:currentPreviewIndex+1];
    return view1.frame;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
