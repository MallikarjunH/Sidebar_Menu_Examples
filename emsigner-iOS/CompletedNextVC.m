//
//  CompletedNextVC.m
//  emSigner
//
//  Created by Administrator on 12/21/16.
//  Copyright © 2016 Emudhra. All rights reserved.
//

#import "CompletedNextVC.h"
#import "WebserviceManager.h"
#import "HoursConstants.h"
#import "MBProgressHUD.h"
#import "NSObject+Activity.h"
#import "ShareVC.h"
#import "CompleteStatusVC.h"
#import "CommentsController.h"
#import "AppDelegate.h"
#import "ViewController.h"

@interface CompletedNextVC ()<CellPopUp>
{
    CustomPopOverVC *popVC;
}

@property (nonatomic, strong) UITextView *shareTextView;
@end

@implementation CompletedNextVC

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
    // Do any additional setup after loading the view.
    
   _addFile = [[NSMutableArray alloc] init];
    
    UIView *view = [[UIView alloc] initWithFrame: CGRectZero];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [view setAutoresizesSubviews: YES];
    view.backgroundColor = [UIColor grayColor];
    
    self.completedTabbar.delegate = self;
    canvasScrollView = [[UIScrollView alloc] initWithFrame: CGRectMake(0,0,self.pdfView.bounds.size.width, self.pdfView.bounds.size.height)];
    canvasScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [canvasScrollView setPagingEnabled: YES];
    [canvasScrollView setShowsHorizontalScrollIndicator: NO];
    [canvasScrollView setShowsVerticalScrollIndicator: NO];
    canvasScrollView.delegate = self;
    [self.pdfView addSubview: canvasScrollView];

    [self.signatorylbl sizeToFit];
    if (self.signatoryString != nil) {
        self.signatorylbl.text =[NSString stringWithFormat:@"%@",self.signatoryString];
    }
    
//      UIBarButtonItem* customBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(flipView:)];
//      self.navigationItem.rightBarButtonItem = customBarButtonItem;
//
//    self.navigationItem.rightBarButtonItem = customBarButtonItem;
    
    UIButton* customButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [customButton1 setImage:[UIImage imageNamed:@"ico-back-24.png"] forState:UIControlStateNormal];
    [customButton1 sizeToFit];
    UIBarButtonItem* customBarButtonItem1 = [[UIBarButtonItem alloc] initWithCustomView:customButton1];
    [customButton1 addTarget:self
                     action:@selector(popViewControllerAnimated:)
                     forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = customBarButtonItem1;
    
    
//    if ([_documentCount intValue] > 1) {
        //customButton.hidden = NO;
//    }
//    else if ([_attachmentCount intValue] > 0)
//    {
//        customButton.hidden = NO;
//    }
//    else{
//        customButton.hidden = YES;
//    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void) viewWillLayoutSubviews
{
    CGSize size = canvasScrollView.frame.size;
    width = size.width;
    height = size.height;
    
    canvasScrollView
    .contentInset = UIEdgeInsetsZero;
    canvasScrollView.contentOffset = CGPointMake(current * width, 0);
}

- (void) viewDidAppear: (BOOL)animated
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
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PDFViewAnnotationHitNotification object:self.pdfView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PDFViewPageChangedNotification object:self.pdfView];

}

-(void)viewWillAppear:(BOOL)animated
{
    current=0;
    self.title = _myTitle ;
    [self.navigationController.navigationBar setTitleTextAttributes:
    @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    [self preparePDFViewWithPageMode:kPDFDisplaySinglePage];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PDFViewAnnotationHitNotification:) name:PDFViewAnnotationHitNotification object:self.pdfView];
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PDFViewPageChangedNotification:) name:PDFViewPageChangedNotification object:self.pdfView];
    
}


- (void)preparePDFViewWithPageMode:(PDFDisplayMode) displayMode {
    
    NSData *data = [[NSData alloc]initWithBase64EncodedString:_pdfImagedetail options:0];
    
    self.pdfDocument = [[PDFDocument alloc] initWithData:data];
    if (self.passwordForPDF) {
        
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
    self.pdfView.document = self.pdfDocument;
    [self.pdfView usePageViewController:(displayMode == kPDFDisplaySinglePage) ? YES :NO withViewOptions:nil];
    
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
            CompleteMultipleDocumentVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"CompleteMultipleDocumentVC"];
            objTrackOrderVC.delegate = self;
            objTrackOrderVC.workFlowId = _workflowID;
            objTrackOrderVC.currentSelectedRow = _selectedIndex;
            objTrackOrderVC.strExcutedFrom = _strExcutedFrom;
            //objTrackOrderVC.strExcutedFrom = @"DocsStore";
            objTrackOrderVC.document = @"Documents";
            objTrackOrderVC.workFlowType = _workFlowType;
            //            self.definesPresentationContext = YES;
            //            //self is presenting view controller
            //            objTrackOrderVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            [self.navigationController pushViewController:objTrackOrderVC animated:YES];
        }
            
            break;
        case 1:
        {
            [self dismissViewControllerAnimated:NO completion:nil];
            UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            AttachedVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"AttachedVC"];
            objTrackOrderVC.workFlowId = _workflowID;
            objTrackOrderVC.documentID = _documentID;

            objTrackOrderVC.currentSelectedRow = _selectedIndex;
            objTrackOrderVC.document = @"Attached Documents";
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

- (void)download
{
    
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


- (void)documentLog
{
    UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DocumentLogVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"DocumentLogVC"];
    objTrackOrderVC.workflowID = _workflowID ;
    [self.navigationController pushViewController:objTrackOrderVC animated:YES];

}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {

    if (item.tag == 0){
      // decline
        [self download];
    }
    else if (item.tag == 1){
        [self documentLog];
    }
    else if (item.tag == 2){
        [self flipView];
    }
    else if (item.tag == 3){
           [self MoreAction];
       }
   
}


-(void)popViewControllerAnimated:(UIButton*)sender
{
//    if ([self.strExcutedFrom isEqualToString:@"DocsStore"])
//    {
//        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
//    }
//    else{
        [self.navigationController popViewControllerAnimated:YES];
    //}
    
}


-(void)MoreAction
{
    
    UIAlertController * view=   [[UIAlertController
                                  alloc]init];
    
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
    UIAlertAction* Comments = [UIAlertAction
                               actionWithTitle:@"Comments"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                   CommentsController *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"CommentsController"];
                                   
                                   objTrackOrderVC.workflowID = _workflowID;
                                   [self.navigationController pushViewController:objTrackOrderVC animated:YES];
                               }];

    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction * action)
                             {
                                 
                             }];
    
     [Share setValue:[[UIImage imageNamed:@"share-variant.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
     [Comments setValue:[[UIImage imageNamed:@"comments"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    
    [Share setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    [Comments setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];

    view.view.tintColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
    [view addAction:Share];
    [view addAction:Comments];
    [view addAction:cancel];
    
    [self presentViewController:view animated:YES completion:nil];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
