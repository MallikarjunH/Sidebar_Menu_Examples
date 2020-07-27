//
//  ShowPdfForImages.m
//  emSigner
//
//  Created by Emudhra on 03/01/19.
//  Copyright © 2019 Emudhra. All rights reserved.
//

#import "ShowPdfForImages.h"
#import "MBProgressHUD.h"

@interface ShowPdfForImages ()
{
    
}
@end


@implementation ShowPdfForImages

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0 green:96.0/255.0 blue:192.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.title = @"Preview Document";
    // self.title = self.navigationTitle;
    
    
    UIBarButtonItem* customBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismissViewController)];
    self.navigationItem.leftBarButtonItem = customBarButtonItem;
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(savebtnAction:)];
    
    self.navigationItem.rightBarButtonItem = saveButton;
   // [[NSNotificationCenter defaultCenter] addObserver:self
                                           //  selector:@selector(receiveDeleteNotification:)
                                            //     name:@"DeleteNotification"
                                            //   object:nil];

}


- (void) viewDidAppear: (BOOL)animated
{
    [super viewDidAppear:animated];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.showImagesView animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = [NSString stringWithFormat:@"Page %@ of %lu", self.showImagesView.currentPage.label, (unsigned long)self.pdfDocument.pageCount];
    hud.margin = 10.f;
    hud.yOffset = 170;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:1];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PDFViewAnnotationHitNotification object:self.showImagesView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PDFViewPageChangedNotification object:self.showImagesView];
    
}

-(void)viewWillAppear:(BOOL)animated
{
   int current=0;
   // self.title = _myTitle ;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    [self preparePDFViewWithPageMode:kPDFDisplaySinglePage];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PDFViewAnnotationHitNotification:) name:PDFViewAnnotationHitNotification object:self.showImagesView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PDFViewPageChangedNotification:) name:PDFViewPageChangedNotification object:self.showImagesView];
    
}

#pragma mark - PDFViewAnnotationHitNotification

-(void)PDFViewAnnotationHitNotification:(NSNotification*)notification {
    PDFAnnotation *annotation = (PDFAnnotation*)notification.userInfo[@"PDFAnnotationHit"];
    NSUInteger pageNumber = [self.pdfDocument indexForPage:annotation.destination.page];
    NSLog(@"Page: %lu", (unsigned long)pageNumber);
}

- (void)preparePDFViewWithPageMode:(PDFDisplayMode) displayMode {
    
    NSData *data = [[NSData alloc]initWithBase64EncodedString:_imgPdfString options:0];
    
    self.pdfDocument = [[PDFDocument alloc] initWithData:data];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//    if (self.passwordForPDF || [prefs valueForKey:@"Password"] ) {
//        
//        [self.pdfDocument unlockWithPassword:[[NSUserDefaults standardUserDefaults] valueForKey:@"Password"]];
//        
//    }
    self.showImagesView.displaysPageBreaks = NO;
    self.showImagesView.autoScales = YES;
    self.showImagesView.maxScaleFactor = 4.0;
    self.showImagesView.minScaleFactor = self.showImagesView.scaleFactorForSizeToFit;
    
    //load the document
    self.showImagesView.document = self.pdfDocument;
    
    //set the display mode
    self.showImagesView.displayMode = displayMode;
    
    self.showImagesView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    self.showImagesView.displayDirection = kPDFDisplayDirectionHorizontal;
    [self.showImagesView zoomIn:self];
    self.showImagesView.autoScales = true;
    self.showImagesView.backgroundColor = [UIColor  whiteColor];
    [self.view setNeedsDisplay];

    [self.showImagesView usePageViewController:(displayMode == kPDFDisplaySinglePage) ? YES :NO withViewOptions:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)savebtnAction:(UIButton *)sender
{
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    NSString *  CategoryId = [[prefs valueForKey:@"workflowCategoryId"]stringValue];
   // NSString * base64data = [self createPdfWithName:@"sam" array:[NSArray arrayWithArray:_showMultImages]];
    
   // NSData *convertToByrtes = [NSData dataWithContentsOfFile:base64data];
  //  NSString *base64image=[convertToByrtes base64EncodedStringWithOptions:0];
    
    NSMutableDictionary * senddict = [[NSMutableDictionary alloc]init];
    NSInteger categoryid = [CategoryId integerValue];
    [senddict setValue:[NSNumber numberWithLong:categoryid] forKey:@"CategoryID"];
    [senddict setValue:_imgPdfString forKey:@"Base64FileData"];
    [senddict setValue:_categoryname forKey:@"DocumentNumber"];
    [senddict setValue:_documentName forKey:@"DocumentName"];
    [senddict setValue:@"" forKey:@"OptionalParam1"];
  //  [_delegate sendDataToA:senddict];
    
    // parametersNotification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"parametersNotification" object:senddict];
    //[self.navigationController popViewControllerAnimated:true];
    [self dismissViewControllerAnimated:true completion:nil];
    NSLog(@"%@",self.navigationController.viewControllers);
}

-(void)PDFViewPageChangedNotification:(NSNotification*)notification{
    
    NSLog(@"%@",[NSString stringWithFormat:@"Page %@ of %lu", self.showImagesView.currentPage.label, (unsigned long)self.pdfDocument.pageCount]);
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.showImagesView animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = [NSString stringWithFormat:@"Page %@ of %lu", self.showImagesView.currentPage.label, (unsigned long)self.pdfDocument.pageCount];
    hud.margin = 10.f;
    hud.yOffset = 170;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:1];
    
}

-(void)dismissViewController{
    [self dismissViewControllerAnimated:true completion:nil];
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
