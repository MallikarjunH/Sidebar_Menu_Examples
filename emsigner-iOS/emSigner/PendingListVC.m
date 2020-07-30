//
//  PendingListVC.m
//  emSigner
//
//  Created by Administrator on 12/2/16.
//  Copyright © 2016 Emudhra. All rights reserved.
//

#import "PendingListVC.h"
#import "MPBSignatureViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"
#import "NSObject+Activity.h"
#import "HoursConstants.h"
#import "WebserviceManager.h"
#import "UITextView+Placeholder.h"
#import "LMNavigationController.h"
#import "ListPdfViewer.h"
#import "MultiplePdfViewerVC.h"
#import "DocStoreVC.h"
#import "delegationFlow.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "DelegateDocument.h"
#import "MyAnnotation.h"
#import "CommentsController.h"
#include "ReviewerController.h"
#import <Intents/Intents.h>
#import "HomeNewDashBoardVC.h"
//#import <NotificationBannerSwift/NotificationBannerSwift-Swift.h>
//#import <NotificationBannerSwift-Swift.h>
#import "GlobalVariables.h"

#import "emSigner-Swift.h"
//#import "emSigner-Bridging-Header.h"

@interface PendingListVC ()<CellPopUp>
{
    int currentPreviewIndex;
    CustomPopOverVC *popVC;
    SPUserResizableView *currentlyEditingView;
    SPUserResizableView *lastEditedView;
    UIImage *imageForPlaceholders;
    BOOL statusCheck;
    
   // GlobalVariables *globalVariables;
    UIImage*img;
    CGRect   annotationBounds;
    
    PDFAnnotation * ann;
    PDFAnnotation* currentlySelectedAnnotation;
    PDFAnnotation *annotation;
    CGRect pBounds;
    
    CGPoint beginningPoint;
    CGPoint beginningCenter;
    
    CGPoint touchLocation;
    CGRect beginBounds;
    BOOL setEnableMoveRestriction;
    PDFPage * anntPoint;
    CGPoint pointOnScreen;
    
    CGSize pdfFrameRect;
    NSString* reviewerComments;
    
}

@property BOOL fieldShown;
@property (strong, nonatomic) UIImageView* backgroundView;
@property (nonatomic, strong) UITextView *shareTextView;
@property (weak, nonatomic) IBOutlet PDFView *MainpdfView;
@property (weak, nonatomic) IBOutlet UILabel *signlabel;
@property (nonatomic, strong) UITextView *declineTextView;
@property (weak, nonatomic) IBOutlet UITabBar *pendingTabbar;

//for siri shortcuts signing
@property(strong,nonatomic) SigningSiri *cntroller;
@end

//Save the first touch point
CGPoint firstTouchPoint;
float xd;
float yd;
@implementation PendingListVC

enum
{
    ResourceCacheMaxSize = 128<<20	/**< use at most 128M for resource cache */
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
    _addFile = [[NSMutableArray alloc] init];
    //globalVariables = [[GlobalVariables alloc] init];
    
    setEnableMoveRestriction = NO;
    NSLog(@"%s",_passwordForPDF);
    statusCheck = false;
    self.navigationController.navigationBar.topItem.title = @"";
    if (self.signatoryString != nil) {
        self.signatorylbl.text =[NSString stringWithFormat:@"%@",self.signatoryString];
    }
    //EMIOS1107
           if (_isReviewer == true) {
               _pendingTabbar.items[1].title = @"Review";
           } else {
                _pendingTabbar.items[1].title = @"Sign";
           }
    //EMIOS1107
    
    
    self.pendingTabbar.delegate = self;
    
    [self.signatorylbl sizeToFit];
    
    //    UIBarButtonItem* customBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(flipView:)];
    //    self.navigationItem.rightBarButtonItem = customBarButtonItem;
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0 green:96.0/255.0 blue:192.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    // if ([_documentCount intValue] > 1) {
    // customButton.hidden = NO;
    //    }
    //    else if ([_attachmentCount intValue] > 0)
    //    {
    //        customButton.hidden = NO;
    //    }
    //    else{
    //        customButton.hidden = YES;
    //    }
    
    [[self signatureImageView]setUserInteractionEnabled:YES];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:@"ReviewerComments"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(SiriNotification:)
                                                 name:@"SiriContent"
                                               object:nil];
    
    
    ///
   /* UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:sel
                                            action:@selector(handleSingleTap:)];
    [self.customViewForSiri addGestureRecognizer:singleFingerTap];*/
    
}
- (void)SiriNotification:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:@"SiriContent"])
    {
        
        [self showPopForSign];
        
    }
}

- (void) viewDidAppear: (BOOL)animated
{
    [self.pendingTabbar setSelectedItem:nil];
    
    [super viewDidAppear:animated];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.MainpdfView animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = [NSString stringWithFormat:@"Page %@ of %lu", self.MainpdfView.currentPage.label, (unsigned long)self.pdfDocument.pageCount];
    hud.margin = 10.f;
    hud.yOffset = 170;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:1];
    
    //        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    //        [panRecognizer setMinimumNumberOfTouches:1];
    //        [panRecognizer setMaximumNumberOfTouches:1];
    //        [self.MainpdfView addGestureRecognizer:panRecognizer];
}




- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PDFViewAnnotationHitNotification object:self.MainpdfView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PDFViewPageChangedNotification object:self.MainpdfView];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    if (self.isSignatory == true && self.isReviewer == true) {
        self.signlabel.text = @"Sign & Review";
    }
    else if (self.isSignatory == true)
    {
        self.signlabel.text = @"Sign";
    }
    else if (self.isReviewer == true)
    {
        self.signlabel.text = @"Reviewer";
    }
    [self  isAdminAccess];
    NSUserDefaults *signOrReviewerText = [NSUserDefaults standardUserDefaults];
    [signOrReviewerText setObject:self.signlabel.text forKey:@"signOrReviewerText"];
    [signOrReviewerText synchronize];
    
    [self preparePDFViewWithPageMode:kPDFDisplaySinglePage];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PDFViewAnnotationHitNotification:) name:PDFViewAnnotationHitNotification object:self.MainpdfView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PDFViewPageChangedNotification:) name:PDFViewPageChangedNotification object:self.MainpdfView];
    
    
    current=0;
    self.title = _myTitle;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([userDefaults valueForKey:@"pdfpath"] && [userDefaults valueForKey:@"saveSignature"]) {
        self.Sign.hidden = false;
        self.pendingTabbar.hidden = true;
    }
    else
    {
        self.Sign.hidden = true;
        self.pendingTabbar.hidden = false;
    }
}

- (IBAction)changeHeightForCustomView:(id)sender {
    
    [self handleSingleTap];
    
    /*for (NSLayoutConstraint *constraint in self.customViewForSiri.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            self.heightConstraint = constraint;
            break;
        }
    }
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionTransitionCrossDissolve  animations:^{
        self.heightConstraint.constant = 0;
        [self.customViewForSiri layoutIfNeeded];
    }
                     completion:^(BOOL finished){
        self.customViewForSiri.hidden = true;
    }];*/
    
}

//The event handling method
- (void)handleSingleTap
{
    _cntroller = [[SigningSiri alloc]init];
    _cntroller.addSiri;
}


#pragma mark - PDFViewAnnotationHitNotification

-(void)PDFViewAnnotationHitNotification:(NSNotification*)notification {
    PDFAnnotation *annotation = (PDFAnnotation*)notification.userInfo[@"PDFAnnotationHit"];
    NSUInteger pageNumber = [self.pdfDocument indexForPage:annotation.destination.page];
    NSLog(@"Page: %lu", (unsigned long)pageNumber);
}

-(void)PDFViewPageChangedNotification:(NSNotification*)notification{
    
    NSLog(@"%@",[NSString stringWithFormat:@"Page %@ of %lu", self.MainpdfView.currentPage.label, (unsigned long)self.pdfDocument.pageCount]);
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.MainpdfView animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = [NSString stringWithFormat:@"Page %@ of %lu", self.MainpdfView.currentPage.label, (unsigned long)self.pdfDocument.pageCount];
    hud.margin = 10.f;
    hud.yOffset = 170;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:0.3];
    
}

#pragma mark - Prepare PDF View

-(void)move:(UIPanGestureRecognizer*)sender {
    
    CGPoint point = [sender locationInView:self.MainpdfView];
    PDFPage * anntPoint = [self.MainpdfView pageForPoint:point nearest:YES];
    CGPoint pointOnScreen = [self.MainpdfView convertPoint:point toPage:anntPoint];
    
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
            pBounds = [[self.MainpdfView currentPage] boundsForBox: [self.MainpdfView displayBox]];
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
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if (self.passwordForPDF || [prefs valueForKey:@"Password"] ) {
        
        [self.pdfDocument unlockWithPassword:[[NSUserDefaults standardUserDefaults] valueForKey:@"Password"]];
        
    }
    self.MainpdfView.displaysPageBreaks = NO;
    self.MainpdfView.autoScales = YES;
    self.MainpdfView.maxScaleFactor = 4.0;
    self.MainpdfView.minScaleFactor = self.MainpdfView.scaleFactorForSizeToFit;
    
    //load the document
    self.MainpdfView.document = self.pdfDocument;
    
    //set the display mode
    self.MainpdfView.displayMode = displayMode;
    
    self.MainpdfView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    self.MainpdfView.displayDirection = kPDFDisplayDirectionHorizontal;
    [self.MainpdfView zoomIn:self];
    self.MainpdfView.autoScales = true;
    self.MainpdfView.backgroundColor = [UIColor  whiteColor];
    
    //placeholders
    CGRect    pageBounds;
    
    long pnum = 0;
    //for getting type of placeholder.
    NSMutableArray *coordinatesArray;
    long pagecount =  self.pdfDocument.pageCount;
    for (int k=1; k<=pagecount; k++) {
        
        //  fromLabel.text = [NSString stringWithFormat:@"%@/%lu", self.MainpdfView.currentPage.label, (unsigned long)self.pdfDocument.pageCount];
        coordinatesArray = [[NSMutableArray alloc]init];
        for (int i = 0; i<_placeholderArray.count; i++) {
            
            if ([[_placeholderArray[i] valueForKey:@"SinaturePage"] isEqual:(id)[NSNull null]]) {
                
                //pnum = [[_placeholderArray[i] valueForKey:@"PageNo"]intValue];
                // [coordinatesArray  addObject:[NSValue valueWithCGRect:CGRectMake([[_placeholderArray[i] valueForKey:@"Left"]doubleValue], [[_placeholderArray[i]  valueForKey:@"Top"]doubleValue] - 58,112 , 58)]]
            }
            
            else if ([[_placeholderArray[i] valueForKey:@"SinaturePage"] isEqualToString:@"FIRST"]) {
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
                if([_placeholderArray[i] valueForKey:@"PageNo"] == (id)[NSNull null]) {
        
                } else {
                    NSArray* str = [[_placeholderArray[i] valueForKey:@"PageNo"]componentsSeparatedByString:@","];
                                   for (int j=0; j<str.count; j++) {
                                       
                                       if (k == [str[j]intValue])
                                       {
                                           pnum = k;
                                           [coordinatesArray  addObject:[NSValue valueWithCGRect:CGRectMake([[_placeholderArray[i] valueForKey:@"Left"]doubleValue], [[_placeholderArray[i]  valueForKey:@"Top"]doubleValue] - 58,112 , 58)]];
                                       }
                                   }
                }
               
            }
            else if ([[_placeholderArray[i] valueForKey:@"SinaturePage"] isEqualToString:@"PAGE LEVEL"]) {
                
                if ([[_placeholderArray[i]valueForKey:@"PageNo"]intValue] == k) {
                    pnum = k;
                    [coordinatesArray  addObject:[NSValue valueWithCGRect:CGRectMake([[_placeholderArray[i] valueForKey:@"Left"]doubleValue], [[_placeholderArray[i]  valueForKey:@"Top"]doubleValue] - 58,112 , 58)]];
                }
            }
            else if ([[_placeholderArray[i] valueForKey:@"SinaturePage"] isEqualToString:@"CURRENT"]) {
                pnum = [[_placeholderArray[i] valueForKey:@"PageNo"]intValue];
                [coordinatesArray  addObject:[NSValue valueWithCGRect:CGRectMake([[_placeholderArray[i] valueForKey:@"Left"]doubleValue], [[_placeholderArray[i]  valueForKey:@"Top"]doubleValue] - 58,112 , 58)]];
            }
        }
        UIImage *img;
        
        if (self.signatureImage != nil || [[NSUserDefaults standardUserDefaults] valueForKey:@"saveSignature"]) {
            img = [UIImage imageWithData:[[NSUserDefaults standardUserDefaults] valueForKey:@"saveSignature"]];//self.signatureImage;
        }
        else{
            img = [UIImage imageNamed:@"signer.png"];//[self processImage:[UIImage imageNamed:@"signer.png"]];
        }
        
        if (k == pnum) {
            for (int i = 0; i<coordinatesArray.count; i++) {
                pageBounds = [[self.MainpdfView currentPage] boundsForBox: [self.MainpdfView displayBox]];
                annotationBounds = [coordinatesArray[i]CGRectValue];
                
                CGContextRef context = nil;
                
                annotation = [[MyAnnotation alloc]initWithImage:img withBounds:annotationBounds withProperties:nil];
                
                [annotation drawWithBox:kPDFDisplayBoxArtBox inContext:context];
                [[self.MainpdfView.document pageAtIndex:k-1] addAnnotation:annotation];
                
                [self.view setNeedsDisplay];
                [self.MainpdfView usePageViewController:(displayMode == kPDFDisplaySinglePage) ? YES :NO withViewOptions:nil];
                
                CGPDFContextEndPage(context);
                
            }
        }
        [self.MainpdfView usePageViewController:(displayMode == kPDFDisplaySinglePage) ? YES :NO withViewOptions:nil];
    }
}

//- (UIImage*) processImage :(UIImage*) image
//{
//    CGFloat colorMasking[6]={222,248,222,248,222,248};
//    CGImageRef imageRef = CGImageCreateWithMaskingColors(image.CGImage, colorMasking);
//    UIImage* imageB = [UIImage imageWithCGImage:imageRef];
//    CGImageRelease(imageRef);
//    return imageB;
//}


#pragma mark - Delegate Helper Method

-(void)didSelectPdfOutline:(PDFOutline *)pdfOutline {
    
    [self.MainpdfView goToPage:pdfOutline.destination.page];
}

-(void)didSelectPdfSelection:(PDFSelection *)pdfSelection {
    
    pdfSelection.color = [UIColor yellowColor];
    self.MainpdfView.currentSelection  = pdfSelection;
    [self.MainpdfView goToSelection:pdfSelection];
}

-(void)didSelectPdfPageFromBookmark:(PDFPage *)pdfPage {
    [self.MainpdfView goToPage:pdfPage];
}


-(void)flipView//:(UIButton*)sender
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
    
    //if ([_documentCount isEqualToString:@"1"] && _attachmentCount>0) {
    //        UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //        popVC = [newStoryBoard instantiateViewControllerWithIdentifier:@"CustomPopOverVC"];
    //        UINavigationController *popNav = [[UINavigationController alloc]initWithRootViewController: popVC];
    //        popVC.delegate = self;
    //        popVC.preferredContentSize = CGSizeMake(200,8);
    //        popVC.attachmentCount = _attachmentCount;
    //        popVC.documentCount = _documentCount;
    //        popVC.workflowID =_workFlowID;
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
    //       if ([_attachmentCount intValue ]>0) {
    //            UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //            popVC = [newStoryBoard instantiateViewControllerWithIdentifier:@"CustomPopOverVC"];
    //            UINavigationController *popNav = [[UINavigationController alloc]initWithRootViewController: popVC];
    //            popVC.delegate = self;
    //            popVC.preferredContentSize = CGSizeMake(200,60);
    //            popVC.attachmentCount = _attachmentCount;
    //            popVC.documentCount = _documentCount;
    //            popVC.workflowID =_workFlowID;
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
    //
    //        }
    //        else{
    //            UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //            popVC = [newStoryBoard instantiateViewControllerWithIdentifier:@"CustomPopOverVC"];
    //            UINavigationController *popNav = [[UINavigationController alloc]initWithRootViewController: popVC];
    //            popVC.delegate = self;
    //            popVC.preferredContentSize = CGSizeMake(200,8);
    //            popVC.attachmentCount = _attachmentCount;
    //            popVC.documentCount = _documentCount;
    //            popVC.workflowID =_workFlowID;
    //            popNav.modalPresentationStyle = UIModalPresentationPopover;
    //            _popover = popNav.popoverPresentationController;
    //            _popover.delegate = self;
    //            _popover.sourceView = self.view;
    //            CGRect frame = [sender frame];
    //            frame.origin.y = self.view.frame.origin.y - frame.size.height + 40;
    //            frame.origin.x =  self.view.frame.size.width - frame.size.width +20;
    //
    //            _popover.sourceRect = frame;
    //            popNav.navigationBarHidden = YES;
    //            [self presentViewController: popNav animated:YES completion:nil];
    
    //}
    
    // }
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

//-(void) setUpPlaceholder
//{
//    CGRect gripFrame = CGRectMake(50, 50, 100, 100);
//    SPUserResizableView *userResizableView = [[SPUserResizableView alloc] initWithFrame:gripFrame];
//    //    UIView *contentView = [[UIView alloc] initWithFrame:gripFrame];
//    //    [contentView setBackgroundColor:[UIColor redColor]];
//    //    userResizableView.contentView = contentView;
//    userResizableView.delegate = self;
//    [userResizableView showEditingHandles];
//    currentlyEditingView = userResizableView;
//    lastEditedView = userResizableView;
//    [self.pdfView addSubview:userResizableView];
//
//}
//
//
# pragma MARK Placeholder delegates
//
//- (void)userResizableViewDidBeginEditing:(SPUserResizableView *)userResizableView {
//    [currentlyEditingView hideEditingHandles];
//    currentlyEditingView = userResizableView;
//}
//
//- (void)userResizableViewDidEndEditing:(SPUserResizableView *)userResizableView {
//    lastEditedView = userResizableView;
//}
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//    if ([currentlyEditingView hitTest:[touch locationInView:currentlyEditingView] withEvent:nil]) {
//        return NO;
//    }
//    return YES;
//}
//
//- (void)hideEditingHandles {
//    // We only want the gesture recognizer to end the editing session on the last
//    // edited view. We wouldn't want to dismiss an editing session in progress.
//    [lastEditedView hideEditingHandles];
//}



-(void)dissmissCellPopup:(NSInteger)row{
    
    GlobalVariables.sharedInstance.documentId = _documentID;
    
    switch (row) {
        case 0:
        {
            [self dismissViewControllerAnimated:NO completion:nil];
            UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            MultiplePdfViewerVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"MultiplePdfViewerVC"];
            objTrackOrderVC.delegate = self;
            objTrackOrderVC.workFlowId = _workFlowID;
            objTrackOrderVC.currentSelectedRow = _selectedIndex;
            objTrackOrderVC.strExcutedFrom = _strExcutedFrom;
            objTrackOrderVC.workFlowType = _workFlowType;
            objTrackOrderVC.document = @"Documents";
            objTrackOrderVC.signatureImage = self.signatureImage;
            objTrackOrderVC.placeholderArray = _placeholderArray;
            objTrackOrderVC.signatoryHolderArray = _signatoryHolderArray;
            [self.navigationController pushViewController:objTrackOrderVC animated:YES];
        }
            
            break;
        case 1:
        {
            [self dismissViewControllerAnimated:NO completion:nil];
            
            UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            AttachedVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"AttachedVC"];
            objTrackOrderVC.workFlowId = _workFlowID;
            objTrackOrderVC.documentID = _documentID;
            objTrackOrderVC.documentName = _myTitle;
            objTrackOrderVC.base64Image = _pdfImagedetail;
            objTrackOrderVC.currentSelectedRow = _selectedIndex;
            objTrackOrderVC.document = @"Attached Documents";
            objTrackOrderVC.isAttached = true;
            objTrackOrderVC.isDocStore = true;
            UINavigationController *objNavigationController = [[UINavigationController alloc]initWithRootViewController:objTrackOrderVC];
            [self presentViewController:objNavigationController animated:true completion:nil];
            //[self.navigationController pushViewController:objTrackOrderVC animated:YES];
        }
            
            break;
            
            
        default:
            break;
    }
    
}


-(void)isAdminAccess {
    [self startActivity:@"Loading..."];
    NSString *requestURL = [NSString stringWithFormat:@"%@AccountProfile",kMyProfile];
    
    [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
        
        //if(status)
            if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

        {
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               
                               //[_profileArray removeAllObjects];
                            NSMutableArray *profileArray = [responseValue valueForKey:@"Response"];
                _isAdmin = [profileArray valueForKey:@"isAdmin"];
                          
                               //[self.profileTableView reloadData];
                               [self stopActivity];
                           });
        }
        else{
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:nil
                                         message:[[responseValue valueForKey:@"Messages"]objectAtIndex:0]
                                         preferredStyle:UIAlertControllerStyleAlert];}}];
}

#pragma mark == UIPopoverPresentationControllerDelegate ==
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* bTouch = [touches anyObject];
    if ([bTouch.view isEqual:[self signatureImageView]]) {
        firstTouchPoint = [bTouch locationInView:[self view]];
        xd = firstTouchPoint.x - [[bTouch view]center].x;
        yd = firstTouchPoint.y - [[bTouch view]center].y;
    }
}


-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* mTouch = [touches anyObject];
    if (mTouch.view == [self signatureImageView]) {
        CGPoint cp = [mTouch locationInView:[self view]];
        [[mTouch view]setCenter:CGPointMake(cp.x-xd, cp.y-yd)];
        [[self signatureImageView]setUserInteractionEnabled:NO];
    }
}
//
- (void)dataFromController:(NSString *)data
{
    
    _multiplePdfImagedetail=data;
}

-(void)dataFordocumentName:(NSString *)dName
{
    _myTitle=dName;
}

-(void)dataForWorkflowId:(NSString *)dWorkflowid
{
    _documentID = dWorkflowid;
}

-(void)selectedCellIndex:(int)iIndex
{
    _selectedIndex = iIndex;
    NSLog(@"Selcted Index is %lu",(unsigned long)iIndex);
}
//



- (void)dataFromControllerAttachOne:(NSString *)data{
    _multiplePdfImagedetail=data;
}
-(void)dataFordocumentNameAttachOne:(NSString *)dName{
    _myTitle=dName;
}
-(void)dataForWorkflowIdAttachOne:(NSString *)dWorkflowid{
    _documentID = dWorkflowid;
}


//implementation of delegate method
- (void)showModal:(UIModalPresentationStyle) style style:(MPBCustomStyleSignatureViewController*) controller
{
    MPBCustomStyleSignatureViewController* signatureViewController = [controller initWithConfiguration:[MPBSignatureViewControllerConfiguration configurationWithFormattedAmount:@""]];
    signatureViewController.modalPresentationStyle = style;
    signatureViewController.strExcutedFrom=@"Waiting for Others";
    signatureViewController.preferredContentSize = CGSizeMake(800, 500);
    signatureViewController.configuration.scheme = MPBSignatureViewControllerConfigurationSchemeAmex;
    signatureViewController.signatureWorkFlowID = _workFlowID;
    signatureViewController.signBtnTitle = @"SIGN";
    signatureViewController.continueBlock = ^(UIImage *signature) {
        [self showImage: signature];
        //  NSData *saveSignature = [NSData dat]
        
        
        NSData *data = [[NSData alloc]initWithBase64EncodedString:_pdfImagedetail options:0];
        NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:@"outputPDF"];
        [data writeToFile:path atomically:YES];
        
        NSString* createPdfString;
        if (_placeholderArray.count != 0) {
            createPdfString = [NSString string];
            
        }
        NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:path forKey:@"pdfpath"];
        [prefs synchronize];
        statusCheck = true;
        
    };
    signatureViewController.cancelBlock = ^ {
        
    };
    [self presentViewController:signatureViewController animated:YES completion:nil];
    
}

- (void) showImage: (UIImage*) signature {
    self.signatureImage = signature;
    
    self.signatureImageView.image = signature;
    self.signatureImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.signatureImageView.layer.borderColor = [UIColor yellowColor].CGColor;
    self.signatureImageView.layer.borderWidth = 2.0f;
}

-(BOOL)IsValidEmail:(NSString *)checkString
{
    BOOL isvalidate;
    NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    //Valid email address
    
    if ([emailTest evaluateWithObject:checkString] == YES)
    {
        isvalidate = YES;
        //Do Something
    }
    else
    {
        isvalidate = NO;
        //NSLog(@"email not in proper format");
    }
    return isvalidate;
}

- (IBAction)Send:(id)sender {
    //   if ([self signature] != nil) {
    
    [self callForSendDocument];
    
}

-(void) callForSendDocument{
    [self startActivity:@""];
    
    NSData *pp = [[NSUserDefaults standardUserDefaults] valueForKey:@"saveSignature"];
    NSData *dataImage = UIImagePNGRepresentation(self.signatureImage);
    NSString *base64image=[pp base64EncodedStringWithOptions:0];
    
    NSString *checkPassword  = [[NSUserDefaults standardUserDefaults] valueForKey:@"Password"];
    NSString * workFlowType = self.workFlowType;
    
    workFlowType = [[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",self.workFlowType]];
    if ([workFlowType isEqualToString:@"0"] || [workFlowType isEqualToString:@""]) {
        workFlowType = @"1";
    }else{
        workFlowType = self.workFlowType;
    }
    
    checkPassword = [[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",checkPassword]];
    reviewerComments = [[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",reviewerComments]];
    
    NSString *post = [NSString stringWithFormat:@"WorkflowId=%@&SignatureImage=%@&Password=%@&workflowType=%@&ReviewerComment=%@",_workFlowID,base64image,checkPassword,workFlowType,reviewerComments];
    post = [[post stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
            stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    [WebserviceManager sendSyncRequestWithURL:kSignatureImage method:SAServiceReqestHTTPMethodPOST body:post completionBlock:^(BOOL status, id responseValue){
        
        if (status) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Password"];
            
            //[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:checkPassword];
            NSNumber * isSuccessNumber = (NSNumber *)[responseValue valueForKey:@"IsSuccess"];
            if([isSuccessNumber boolValue] == YES && ![[responseValue valueForKey:@"Messages"][0]isEqualToString:@"Failed To Sign Documents"])
            {
                dispatch_async(dispatch_get_main_queue(),
                               ^{
                    [self stopActivity];
                    UIAlertView * alert15 =[[UIAlertView alloc ] initWithTitle:@"" message:[[responseValue valueForKey:@"Messages"] objectAtIndex:0] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert15 show];
                    
                    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    LMNavigationController *objTrackOrderVC= [sb  instantiateViewControllerWithIdentifier:@"HomeNavController"];
                    [[[[UIApplication sharedApplication] delegate] window] setRootViewController:objTrackOrderVC];
                    
                });
                
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),
                               ^{
                    [self stopActivity];
                    UIAlertView * alert15 =[[UIAlertView alloc ] initWithTitle:@"" message:[[responseValue valueForKey:@"Messages"] objectAtIndex:0] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert15 show];
                    
                });
            }
        }
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)SignBtnClicked
{
    
    NSUserActivity *theActivity = [[NSUserActivity alloc]initWithActivityType:@"com.emudhra.emSigner.SignDocument"];
    theActivity.title = @"Sign";
    [theActivity setEligibleForSearch:true];
    [theActivity setEligibleForPrediction:true];
    theActivity.persistentIdentifier = @"com.emudhra.emSigner.SignDocument";
    //theActivity.suggestedInvocationPhrase = @"Sign";
    self.view.userActivity = theActivity;
    [theActivity becomeCurrent];
    
    if (_isReviewer ==true) {
        UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ReviewerController *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"ReviewerController"];
        self.definesPresentationContext = YES; //self is presenting view controller
        objTrackOrderVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        objTrackOrderVC.workflowID = _workFlowID;
        objTrackOrderVC.workFlowType =  _workFlowType;
        objTrackOrderVC.passwordForPDF = _passwordForPDF;
        objTrackOrderVC.isReviewer = _isReviewer;
        objTrackOrderVC.isSignatory = _isSignatory;
        objTrackOrderVC.pendingvc = @"PendingVcYes";
        [self.navigationController presentViewController:objTrackOrderVC animated:YES completion:nil];
    }
    else{
        [self showModal:UIModalPresentationFullScreen style:[MPBDefaultStyleSignatureViewController alloc]];
    }
}



-(void)showPopForSign{
    
    [self startActivity:@""];
    //NSString *str = [[NSUserDefaults standardUserDefaults] valueForKey:@"PendingWorkflowID"];
    
    NSError* error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString* dataPaths = [documentsDirectory stringByAppendingPathComponent:[[NSUserDefaults standardUserDefaults]
                                                                              valueForKey:@"Name"]];
    
    if (_isReviewer ==true) {
        UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ReviewerController *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"ReviewerController"];
        self.definesPresentationContext = YES; //self is presenting view controller
        objTrackOrderVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        objTrackOrderVC.workflowID = _workFlowID;
        objTrackOrderVC.workFlowType =  _workFlowType;
        objTrackOrderVC.passwordForPDF = _passwordForPDF;
        objTrackOrderVC.isReviewer = _isReviewer;
        objTrackOrderVC.isSignatory = _isSignatory;
        objTrackOrderVC.pendingvc = @"PendingVcYes";
        [self.navigationController presentViewController:objTrackOrderVC animated:YES completion:nil];
    }
    else{
        
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:[dataPaths stringByAppendingPathComponent:@"FirstBigImg.png"]])
        {
            NSString *imgFile1=[dataPaths stringByAppendingPathComponent:@"FirstImg.png"];
            
            
            //show the first image
            UIImage * firstBigImage = [UIImage imageWithContentsOfFile:[dataPaths stringByAppendingPathComponent:@"FirstBigImg.png"]];
            
            UIImage *firstImg = [UIImage imageWithData:[NSData dataWithContentsOfFile:imgFile1]];
            
            
            NSData *dataImage;
            
            
            dataImage=UIImagePNGRepresentation(firstImg);
            //save signature
            NSUserDefaults * saveSignature = [NSUserDefaults standardUserDefaults];
            [saveSignature setObject:dataImage forKey:@"saveSignature"];
            [saveSignature synchronize];
            
            NSString*  PendingVcYes = [[NSUserDefaults standardUserDefaults]valueForKey:@"PendingVcYes"];
            
            //self.continueBlock(firstImg);
            NSData *data = [[NSData alloc]initWithBase64EncodedString:_pdfImagedetail options:0];
            NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
            NSString *path = [documentsDirectory stringByAppendingPathComponent:@"outputPDF"];
            [data writeToFile:path atomically:YES];
            
            NSString* createPdfString;
            if (_placeholderArray.count != 0) {
                createPdfString = [NSString string];
                
            }
            NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
            [prefs setObject:path forKey:@"pdfpath"];
            [prefs synchronize];
            statusCheck = true;
            
            [self callForSendDocument ];
            
            
        }
        else{
            [self showModal:UIModalPresentationFullScreen style:[MPBDefaultStyleSignatureViewController alloc]];
            
        }
    }
    
    //    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"PendingWorkflowID"] != nil && _isReviewer != true) {
    //         UIActionSheet *actionSheet3 = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"eSignature", nil];
    //         actionSheet3.tag = 103;
    //         [actionSheet3 showInView:self.view];
    //    }
    
}



- (void)declineBtnClicked
{
    UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DeclineVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"DeclineVC"];
    self.definesPresentationContext = YES; //self is presenting view controller
    objTrackOrderVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    objTrackOrderVC.workflowID = _workFlowID;
    [self.navigationController presentViewController:objTrackOrderVC animated:YES completion:nil];
}



- (void)receiveNotification:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:@"ReviewerComments"])
    {
        reviewerComments = (NSString *)notification.object;
        
        NSLog(@"%@",reviewerComments);
        if (_isSignatory == true) {
            [self showModal:UIModalPresentationFullScreen style:[MPBDefaultStyleSignatureViewController alloc]];
        }
        else{
            self.Sign.hidden = false;
            self.toolbar.hidden = true;
        }
    }
}


- (void)moreBtnClicked
{
    //    UIActionSheet *actionSheet4 = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share Document",@"Download Document",@"Document Log", nil];
    //     [Share setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    //    actionSheet4.tag = 104;
    //    [actionSheet4 showInView:self.view];
    
    UIAlertController * view=   [[UIAlertController
                                  alloc]init];
    UIAlertAction* Doclog = [UIAlertAction
                             actionWithTitle:@"Document log"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
        UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        DocumentLogVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"DocumentLogVC"];
        
        objTrackOrderVC.workflowID = _workFlowID;
        [self.navigationController pushViewController:objTrackOrderVC animated:YES];
    }];
    UIAlertAction* Download = [UIAlertAction
                               actionWithTitle:@"Download Document"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
        
        UIAlertController * alert=[UIAlertController alertControllerWithTitle:@"Download"
                                                                      message:@"Do you want to download document"
                                                               preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction actionWithTitle:@"Yes"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action)
                                    {
            /** What we write here???????? **/
            NSLog(@"you pressed Yes, please button");
            
            
            [self startActivity:@"Loading..."];
            NSString *requestURL = [NSString stringWithFormat:@"%@DownloadWorkflowDocuments?WorkFlowId=%@",kDownloadPdf,_workFlowID];
            [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
                
                //  if(status)
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
                                _pdfFiledata = [[_pdfImageArray objectAtIndex:i] objectForKey:@"Base64FileData"];
                                
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
                                    [self presentViewController:previewController animated:YES completion:nil];
                                    [previewController.navigationItem setRightBarButtonItem:nil];
                                }
                                
                            }
                            
                        }
                        else{
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[[responseValue valueForKey:@"Messages"]objectAtIndex:0] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                            [alert show];
                        }
                        
                    });
                    
                }
                else{
                    [self stopActivity];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[[responseValue valueForKey:@"Messages"]objectAtIndex:0] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [alert show];
                    });
                }
                
            }];
            
            // call method whatever u need
        }];
        
        UIAlertAction* noButton = [UIAlertAction actionWithTitle:@"No"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action)
                                   {
            /** What we write here???????? **/
            NSLog(@"you pressed No, thanks button");
            // call method whatever u need
        }];
        
        [alert addAction:yesButton];
        [alert addAction:noButton];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }];
    UIAlertAction* Share = [UIAlertAction
                            actionWithTitle:@"Share Document"
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action)
                            {
        NSString *pendingdocumentName =_myTitle;
        NSString *pendingWorkflowID =_workFlowID;
        UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ShareVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"ShareVC"];
        objTrackOrderVC.documentName = pendingdocumentName;
        objTrackOrderVC.workflowID = pendingWorkflowID;
        [self.navigationController pushViewController:objTrackOrderVC animated:YES];
        
    }];
    
    UIAlertAction* delegateDocument = [UIAlertAction
                                       actionWithTitle:@"Delegate Document"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action)
                                       {
        
        DelegateDocument *temp = [[DelegateDocument alloc]initWithNibName:@"DelegateDocument" bundle:nil];
        temp.workflowID = _workFlowID;
        temp.matchSignersList = _signatoryHolderArray;
        [self.navigationController pushViewController:temp animated:YES];
        
    }];
    
    UIAlertAction* Comments = [UIAlertAction
                               actionWithTitle:@"Comments"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
        UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CommentsController *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"CommentsController"];
        
        objTrackOrderVC.workflowID = _workFlowID;
        [self.navigationController pushViewController:objTrackOrderVC animated:YES];
    }];
    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction * action)
                             {
        
    }];
    
    [Share setValue:[[UIImage imageNamed:@"share-variant.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [Download setValue:[[UIImage imageNamed:@"download.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [Doclog setValue:[[UIImage imageNamed:@"stack-exchange.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [delegateDocument setValue:[[UIImage imageNamed:@"DelegationIcon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [Comments setValue:[[UIImage imageNamed:@"comments"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    
    [Share setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    [Download setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    [Doclog setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    [delegateDocument setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    [Comments setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    
    view.view.tintColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
    
    
    if (_isAdmin == true) {
        [view addAction:delegateDocument];
        [view addAction:Share];
        [view addAction:Download];
        [view addAction:Doclog];
        [view addAction:Comments];
    } else {
        [view addAction:Share];
        [view addAction:Download];
        [view addAction:Doclog];
        [view addAction:Comments];
    }
    
    [view addAction:cancel];
    
    [self presentViewController:view animated:YES completion:nil];
    
}


- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    
    if (item.tag == 0){
        // decline
        [self declineBtnClicked];
    }
    else if (item.tag == 1){
        /* UIAlertController * view = [[UIAlertController
                                        alloc]init];
           UIAlertAction* emSigner = [UIAlertAction
                                  actionWithTitle:@"eSignature"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action)
                                  {
               ;
               
           }];
        UIAlertAction* eSign = [UIAlertAction
                               actionWithTitle:@"eSign"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
            //After API
            
        }];
       UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleDestructive
                                 handler:^(UIAlertAction * action)
                                 {
            [view dismissViewControllerAnimated:YES completion:nil];
            
        }];
        view.view.tintColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
        [view addAction:eSign];
        [view addAction:emSigner];
        [view addAction:cancel];
        [self presentViewController:view animated:true completion:nil];*/
       
        [self SignBtnClicked];
    
    }
    else if (item.tag == 2){
        [self flipView];
        
    }
    else if (item.tag == 3){
        [self moreBtnClicked];
        
    }
    
}




/*****************************AlertView********************************/

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    UIAlertViewStyle style = alertView.alertViewStyle;
    
    if ((style == UIAlertViewStyleSecureTextInput) ||
        (style == UIAlertViewStylePlainTextInput) ||
        (style == UIAlertViewStyleLoginAndPasswordInput))
    {
        UITextField *textField = [alertView textFieldAtIndex:0];
        if ([textField.text length] == 0)
        {
            return NO;
        }
    }
    
    return YES;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    /*********************************GetOTP***********************************/
    
    if (alertView.tag == 12)
    {
        if (buttonIndex == 1)
        {
            
            //Login
            UITextField *aadharNumber = [alertView textFieldAtIndex:0];
            NSLog(@"Aadhar Number: %@", aadharNumber.text);
            
            //Saving Aadhaar Number
            NSString *aadhaar = aadharNumber.text;
            [[NSUserDefaults standardUserDefaults] setObject:aadhaar forKey:@"Aadhaar Number"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            
            /*************************Web Service Get OTP*******************************/
            
            if ([aadharNumber text].length > 1)
            {
                [self startActivity:@"Loading..."];
                NSString *requestURL = [NSString stringWithFormat:@"%@GetOTP?AadhaarNumber=%@",kGetOTP,aadharNumber.text];
                
                [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
                    
                    //if(status)
                    if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])
                        
                    {
                        dispatch_async(dispatch_get_main_queue(),
                                       ^{
                            NSNumber * isSuccessNumber = (NSNumber *)[responseValue valueForKey:@"IsSuccess"];
                            if([isSuccessNumber boolValue] == YES)
                            {
                                _otpArray =responseValue;
                                
                                UIAlertView *alert9 = [[UIAlertView alloc] initWithTitle:@"OTP"
                                                                                 message:@""
                                                                                delegate:self
                                                                       cancelButtonTitle:@"Cancel"
                                                                       otherButtonTitles:@"Sign", nil];
                                alert9.alertViewStyle = UIAlertViewStylePlainTextInput;
                                [[alert9 textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
                                [[alert9 textFieldAtIndex:0] becomeFirstResponder];
                                [alert9 textFieldAtIndex:0].placeholder = @"Please enter OTP";
                                [alert9 textFieldAtIndex:0].delegate = self;
                                
                                alert9.tag = 9;
                                [alert9 show];
                                [self stopActivity];
                            }
                            else{
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[[responseValue valueForKey:@"Messages"] objectAtIndex:0] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                [alert show];
                                [self stopActivity];
                            }
                            
                            
                        });
                        
                    }
                    else{
                        NSError *error = (NSError *)responseValue;
                        if (error) {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Error from KSA Server" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                            //_adharText.text = nil;
                            [alert show];
                            [self stopActivity];
                            return;
                        }
                        
                        
                        
                    }
                    [self stopActivity];
                }];
                /****************************************************************/
            }
            
            else{
                UIAlertView *ErrorAlert = [[UIAlertView alloc] initWithTitle:@""
                                                                     message:@"Please Enter Aadhaar Number" delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil, nil];
                [ErrorAlert show];
                
            }
            
            
        }
        else if (buttonIndex == 1)
        {
            
        }
    }
    /***************************Aadhar based Sign**************************************/
    else if(alertView.tag == 9)
    {
        if (buttonIndex == 0) {
            UITextField *otp = [alertView textFieldAtIndex:0];
            NSLog(@"OTP: %@", otp.text);
            
            /*************************Web Service Get OTP*******************************/
            
            if ([otp text].length > 1)
            {
                [self startActivity:@"Refreshing"];
                
                NSString *post = [NSString stringWithFormat:@"AdhaarNumber=%@&OTP=%@&WorkFlowId=%@",[[NSUserDefaults standardUserDefaults]
                                                                                                     valueForKey:@"Aadhaar Number"],otp.text,_workFlowID];
                [WebserviceManager sendSyncRequestWithURL:keSign method:SAServiceReqestHTTPMethodPOST body:post completionBlock:^(BOOL status, id responseValue)
                 {
                    
                    // if(status)
                    if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])
                        
                    {
                        NSNumber * isSuccessNumber = (NSNumber *)[responseValue valueForKey:@"IsSuccess"];
                        if([isSuccessNumber boolValue] == YES)
                        {
                            dispatch_async(dispatch_get_main_queue(),
                                           ^{
                                _signArray =[[responseValue valueForKey:@"Messages"] objectAtIndex:0];
                                
                                /*******************/
                                UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                LMNavigationController *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"HomeNavController"];
                                [self presentViewController:objTrackOrderVC animated:YES completion:nil];
                                //
                                
                                
                                UIAlertView * alert15 =[[UIAlertView alloc ] initWithTitle:@"" message:[[responseValue valueForKey:@"Messages"] objectAtIndex:0] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                                [alert15 show];
                                
                                [self stopActivity];
                                
                            });
                            
                            
                        }
                        
                        
                    }
                    else{
                        
                        
                    }
                    
                }];
                /****************************************************************/
                
            }
            else
            {
                UIAlertView *ErrorAlert = [[UIAlertView alloc] initWithTitle:@""
                                                                     message:@"Please Enter OTP" delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil, nil];
                [ErrorAlert show];
            }
            
        }
        else if (buttonIndex == 1)
        {
            
        }
        
    }
    
    
    
    /**********************Aadhar based Sign with Saved Aadhar*************************/
    else if(alertView.tag == 10)
    {
        if (buttonIndex == 0) {
            UITextField *otp = [alertView textFieldAtIndex:0];
            NSLog(@"OTP: %@", otp.text);
            
            /*************************Web Service Get OTP*******************************/
            
            if ([otp text].length > 1)
            {
                [self startActivity:@"Refreshing"];
                
                NSString *post = [NSString stringWithFormat:@"AdhaarNumber=%@&OTP=%@&WorkFlowId=%@",[[NSUserDefaults standardUserDefaults]
                                                                                                     valueForKey:@"SavedAadhaarNumber"],otp.text,_workFlowID];
                [WebserviceManager sendSyncRequestWithURL:keSign method:SAServiceReqestHTTPMethodPOST body:post completionBlock:^(BOOL status, id responseValue)
                 {
                    
                    //if(status)
                    if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])
                        
                    {
                        NSNumber * isSuccessNumber = (NSNumber *)[responseValue valueForKey:@"IsSuccess"];
                        if([isSuccessNumber boolValue] == YES)
                        {
                            dispatch_async(dispatch_get_main_queue(),
                                           ^{
                                _signArray =[[responseValue valueForKey:@"Messages"] objectAtIndex:0];
                                
                                /*******************/
                                UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                LMNavigationController *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"HomeNavController"];
                                [self presentViewController:objTrackOrderVC animated:YES completion:nil];
                                //
                                
                                
                                UIAlertView * alert15 =[[UIAlertView alloc ] initWithTitle:@"" message:[[responseValue valueForKey:@"Messages"] objectAtIndex:0] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                                [alert15 show];
                                
                                [self stopActivity];
                                
                            });
                            
                            
                        }
                        
                        
                    }
                    else{
                        
                        
                    }
                    
                }];
                /****************************************************************/
                
            }
            else
            {
                UIAlertView *ErrorAlert = [[UIAlertView alloc] initWithTitle:@""
                                                                     message:@"Please Enter OTP" delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil, nil];
                [ErrorAlert show];
            }
            
        }
        else if (buttonIndex == 1)
        {
            
        }
        
    }
    
    
    /*****************************Download**************************************/
    
    else if (alertView.tag == 32)
    {
        if (buttonIndex == 0)
        {
            
            
            [self startActivity:@"Loading..."];
            
            NSString *requestURL = [NSString stringWithFormat:@"%@DownloaWorkflowDocuments?WorkFlowId=%@",kDownloadPdf,_workFlowID];
            [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
                
                
                //    if(status)
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
                                    [self presentViewController:previewController animated:YES completion:nil];
                                    [previewController.navigationItem setRightBarButtonItem:nil];
                                }
                                
                            }
                            
                        }
                        else{
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[[responseValue valueForKey:@"Messages"]objectAtIndex:0] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                            [alert show];
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
            
            
        }
        else if (buttonIndex == 1)
        {
            
        }
    }
    
}



#pragma mark - data source(Preview)
//Data source methods

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return [_addFile count];
    
    
    
    //return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    NSString *fileName = [_addFile objectAtIndex:index];
    
    return [NSURL fileURLWithPath:fileName];
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

/**********************ActionSheet Delegate****************************/
-(void) actionSheet: (UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(actionSheet.tag == 104) {
            //do something
            switch (buttonIndex) {
                case 0: {
                    
                    NSString *pendingdocumentName =_myTitle;
                    NSString *pendingWorkflowID =_workFlowID;
                    UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    ShareVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"ShareVC"];
                    objTrackOrderVC.documentName = pendingdocumentName;
                    objTrackOrderVC.workflowID = pendingWorkflowID;
                    [self.navigationController pushViewController:objTrackOrderVC animated:YES];
                    
                    //                    UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    //                    ShareVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"ShareVC"];
                    //                    self.definesPresentationContext = YES;
                    //                    objTrackOrderVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
                    //                    objTrackOrderVC.documentName = _myTitle;
                    //                    objTrackOrderVC.workflowID = _workFlowID;
                    //                    [self.navigationController presentViewController:objTrackOrderVC animated:YES completion:nil];
                    break;
                }
                case 1:
                {
                    UIAlertView *alertView32 = [[UIAlertView alloc] initWithTitle:@"Download"
                                                                          message:@"Do you want to download document?"
                                                                         delegate:self
                                                                cancelButtonTitle:@"Yes"
                                                                otherButtonTitles:@"No", nil];
                    alertView32.tag = 32;
                    [alertView32 show];
                    
                    break;
                }
                case 2:
                {
                    UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    DocumentLogVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"DocumentLogVC"];
                    
                    objTrackOrderVC.workflowID = _workFlowID;
                    [self.navigationController pushViewController:objTrackOrderVC animated:YES];
                    //[self presentViewController:objTrackOrderVC animated:YES completion:nil];
                    break;
                }
                    
                default:
                    break;
            }
            
            
        }
        else if(actionSheet.tag == 103) {
            //do something else
            switch (buttonIndex) {
                    //                case 0: {    ///// for esign
                    //
                    //                    //http://localhost:54975/api/BulkDocumentSigningWithEsignOnline
                    //
                    //                    NSString * aadhaarNumber = [[NSUserDefaults standardUserDefaults]
                    //                                                valueForKey:@"SavedAadhaarNumber"];
                    //                    if ([aadhaarNumber isEqualToString:@"<null>"] || [aadhaarNumber isEqualToString:@""] || [aadhaarNumber length] == 0 )
                    //                    {
                    //
                    //                        [self eSignCall];
                    ////                        UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    ////                        GetOTPVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"GetOTPVC"];
                    ////                        self.definesPresentationContext = YES; //self is presenting view controller
                    ////                        objTrackOrderVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
                    ////                        [self.navigationController presentViewController:objTrackOrderVC animated:YES completion:nil];
                    //
                    //
                    //                    }
                    //                    else
                    //                    {
                    //
                    //                        //SavedAadhaarNumber
                    //
                    //                        [self startActivity:@"Loading..."];
                    //                        NSString *requestURL = [NSString stringWithFormat:@"%@GetOTP?AadhaarNumber=%@",kGetOTP,[[NSUserDefaults standardUserDefaults]valueForKey:@"SavedAadhaarNumber"]];
                    //
                    //                        [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
                    //
                    //                            if(status)
                    //                            {
                    //                                dispatch_async(dispatch_get_main_queue(),
                    //                                               ^{
                    //                                                   NSNumber * isSuccessNumber = (NSNumber *)[responseValue valueForKey:@"IsSuccess"];
                    //                                                   if([isSuccessNumber boolValue] == YES)
                    //                                                   {
                    //                                                       _otpArray = responseValue;
                    //                                                       UIAlertController * alert = [UIAlertController
                    //                                                                                    alertControllerWithTitle:@""
                    //                                                                                    message:[[responseValue valueForKey:@"Messages"] objectAtIndex:0]
                    //                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                    //
                    //                                                       //Add Buttons
                    //
                    //                                                       UIAlertAction* yesButton = [UIAlertAction
                    //                                                                                   actionWithTitle:@"Ok"
                    //                                                                                   style:UIAlertActionStyleDefault
                    //                                                                                   handler:^(UIAlertAction * action) {
                    //                                                                                       //Handle your yes please button action here
                    //                                                                                       //[self clearAllData];
                    //                                                                                       UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    //                                                                                       CustomSignVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"CustomSignVC"];
                    //                                                                                       objTrackOrderVC.aadhaarString = [[NSUserDefaults standardUserDefaults]valueForKey:@"SavedAadhaarNumber"];
                    //                                                                                       self.definesPresentationContext = YES; //self is presenting view controller
                    //                                                                                       objTrackOrderVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
                    //                                                                                       [self presentViewController:objTrackOrderVC animated:YES completion:nil];
                    //                                                                                   }];
                    //
                    //                                                       //Add your buttons to alert controller
                    //
                    //                                                       [alert addAction:yesButton];
                    //                                                       //[alert addAction:noButton];
                    //
                    //                                                       [self presentViewController:alert animated:YES completion:nil];
                    //
                    //                                                       [self stopActivity];
                    //                                                   }
                    //                                                   else{
                    //                                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[[responseValue valueForKey:@"Messages"] objectAtIndex:0] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    //                                                       [alert show];
                    //                                                       [self stopActivity];
                    //                                                   }
                    //
                    //
                    //                                               });
                    //
                    //                            }
                    //                            else{
                    //
                    //
                    //                            }
                    //
                    //                        }];
                    //
                    //                        [self stopActivity];
                    //
                    //
                    //                    }
                    //
                    //
                    //                    break;
                    //                }
                case 0:
                {
                    //[self showModal:UIModalPresentationFullScreen style:[MPBDefaultStyleSignatureViewController alloc]];
                    // [self showPopForSign];
                    break;
                }
                    
                default:
                    break;
            }
            
        }
    });
}

-(void)eSignCall
{
    
    NSString *post = [NSString stringWithFormat:@"WorkflowId=%@&Password=%s",_workFlowID,_passwordForPDF];
    post = [[post stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
            stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    [WebserviceManager sendSyncRequestWithURL:keSign method:SAServiceReqestHTTPMethodPOST body:post completionBlock:^(BOOL status, id responseValue){
        
        if (status) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Password"];
            
            //[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:checkPassword];
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
- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    NSString *resultText = [textField.text stringByReplacingCharactersInRange:range
                                                                   withString:string];
    return resultText.length <= 12;
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
