//
//  DraftInactiveVC.m
//  emSigner
//
//  Created by Administrator on 12/29/16.
//  Copyright © 2016 Emudhra. All rights reserved.
//

#import "DraftInactiveVC.h"
#import "WebserviceManager.h"
#import "HoursConstants.h"
#import "MBProgressHUD.h"
#import "NSObject+Activity.h"
#import "LMNavigationController.h"
#import "CoSignPendingVC.h"
#import "ShareVC.h"

@interface DraftInactiveVC ()

@end

@implementation DraftInactiveVC

NSString *key;
NSString *_filePath;
BOOL reflowMode;
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
    
    UIView *view = [[UIView alloc] initWithFrame: CGRectZero];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [view setAutoresizesSubviews: YES];
    view.backgroundColor = [UIColor grayColor];
}

-(void)viewWillAppear:(BOOL)animated
{
    current=0;

    self.title = _myTitle;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    [self preparePDFViewWithPageMode:kPDFDisplaySinglePage];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PDFViewAnnotationHitNotification:) name:PDFViewAnnotationHitNotification object:self.pdfView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PDFViewPageChangedNotification:) name:PDFViewPageChangedNotification object:self.pdfView];

    
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PDFViewAnnotationHitNotification object:self.pdfView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PDFViewPageChangedNotification object:self.pdfView];

}


- (void) viewWillLayoutSubviews
{
    
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

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



#pragma mark - data source(Preview)
//Data source methods
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    NSString *path = [[[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject] path];
    //You'll need an additional '/'
    NSString *fullPath = [path stringByAppendingFormat:@"/%@", [_myTitle  stringByAppendingPathExtension:@"pdf"]];
    return [NSURL fileURLWithPath:fullPath];
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
- (IBAction)inactiveBtn:(id)sender
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@""
                                 message:@"Do you want to mark document as inactive?"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    //Add Buttons
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Yes"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                    [self startActivity:@"Processing..."];
                                    NSString *requestURL = [NSString stringWithFormat:@"%@MarkAsInactive?documentId=%@&status=%@",kInactive,_workflowID,@"Draft"];
                                    
                                    [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
                                        
                                       // if(status)
                                            if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

                                        {
                                            dispatch_async(dispatch_get_main_queue(),
                                                           ^{
                                                               
                                                               
                                                               _inactiveArray =responseValue;
                                                               if (_inactiveArray != (id)[NSNull null])
                                                               {

                                                           [self.navigationController popToRootViewControllerAnimated:YES];
                                                                   [self stopActivity];
                                                               }
                                                               else{
                                                                   return ;
                                                               }
                                                           });
                                        }
                                        else{
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

- (IBAction)downloadBtn:(id)sender
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
                                    
                                    NSString *requestURL = [NSString stringWithFormat:@"%@GetDraftFileData?workFlowId=%@",kDraftPDFImage,_workflowID];
                                    [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
                                        
                                        
                                        
                                      //  if(status)
                                            if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

                                        {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                
                                                _pdfImageArray=[[responseValue valueForKey:@"Response"] valueForKey:@"FileData"];
                                                int Count;
                                                NSData *data = [[NSData alloc]initWithBase64EncodedString:[[responseValue valueForKey:@"Response"] valueForKey:@"FileData"] options:0];
                                                NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
                                                NSString *path = [documentsDirectory stringByAppendingPathComponent:[_myTitle stringByAppendingPathExtension:@"pdf"]];
                                                NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
                                                for (Count = 0; Count < (int)[directoryContent count]; Count++)
                                                {
                                                    NSLog(@"File %d: %@", (Count + 1), [directoryContent objectAtIndex:Count]);
                                                }
                                                [data writeToFile:path atomically:YES];
                                                
                                                                                QLPreviewController *previewController=[[QLPreviewController alloc]init];
                                                                                previewController.delegate=self;
                                                                                previewController.dataSource=self;
                                                                                [self stopActivity];
                                                
                                                                                [self presentViewController:previewController animated:YES completion:nil];
                                                                                [previewController.navigationItem setRightBarButtonItem:nil];
                                          
                                                
                                            });
                                        }
                                        else{
                                            
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

- (IBAction)shareBtn:(id)sender {
    UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ShareVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"ShareVC"];
    
    self.definesPresentationContext = YES; //self is presenting view controller
    //objTrackOrderVC.view.backgroundColor = [UIColor clearColor];
    objTrackOrderVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
   // objTrackOrderVC.pdfLable.text = _myTitle;
     objTrackOrderVC.documentName = _myTitle;
    objTrackOrderVC.workflowID = _workflowID;
    //objTrackOrderVC.strExcutedFrom=@"WaitingForOther";
    [self.navigationController pushViewController:objTrackOrderVC animated:YES];
}

@end
