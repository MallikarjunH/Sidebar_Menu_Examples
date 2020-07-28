//
//  PendingVC.m
//  emSigner
//
//  Created by Administrator on 12/1/16.
//  Copyright © 2016 Emudhra. All rights reserved.
//

#import "PendingVC.h"
#import "MPBSignatureViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "WebserviceManager.h"
#import "HoursConstants.h"
#import "SingletonAPI.h"
#import "MBProgressHUD.h"
#import "NSObject+Activity.h"
#import "CoSignPendingListVC.h"
#import "DocumentInfoNames.h"
#import "Reachability.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "RecallVC.h"
#import "LMNavigationController.h"
#import "CompletedNextVC.h"
#import "CommentsController.h"
#import "BulkDocVC.h"

//#import "CheckDocInfoController.h"

#import "NSString+DateAsAppleTime.h"


@interface PendingVC ()
{
    BOOL hasPresentedAlert;
    UILabel *noDataLabel ;
    NSMutableString * mstrXMLString;
    NSString *dateCategoryString;
    BOOL isPageRefreshing;
    NSString* searchSting;
    const char *password;
    
}

@property BOOL fieldShown;
@property (strong, nonatomic) UIImageView* backgroundView;
@property (strong,nonatomic)   NSString *path ;
@property (strong,nonatomic)   NSString *pdfFilePathForSignatures ;

@end

@implementation PendingVC

- (id)init
{
    self = [super init];
    if (self) {
        self.fieldShown = false;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBar.topItem.title = @" ";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    noDataLabel.hidden = YES;
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    _addFile = [[NSMutableArray alloc] init];
    
    //Empty cell keep blank
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    _coSignPendingArray = [[NSMutableArray alloc] init];
    [self.tableView registerNib:[UINib nibWithNibName:@"PendingVCTableViewCell" bundle:nil] forCellReuseIdentifier:@"PendingVCTableViewCell"];
    _mySignatureToolbar.hidden = YES;
    
    //Refresh control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]init];
    refreshControl.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:241.0/255.0 alpha:1.0];
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    
}


- (void)makeServieCallWithPageNumaber:(NSUInteger)pageNumber:(NSString*)search
{
    /*************************Web Service*******************************/
    
    //Network Check
    if (![self connected])
    {
        if(hasPresentedAlert == false){
            
            // not connected
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No internet connection!" message:@"Check internet connection!" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alert show];
            hasPresentedAlert = true;
        }
    }
    else{
        if (self.searchResults == nil) {
            self.searchResults = [[NSMutableArray alloc] init];
        }
        
        [self startActivity:@"Refreshing"];
        NSString *requestURL =[NSString stringWithFormat:@"%@GetDocumentsByStatus?statusId=%@&PageSize=%lu&searchFilter=%@",kAllDocumetStatusUrl,@"cosign",(unsigned long)pageNumber,search];
        // [NSString stringWithFormat:@"%@GetDocumentsByStatus?statusId=%@&PageSize=%lu&searchFilter=%@",kAllDocumetStatusUrl,@"Pending",(unsigned long)pageNumber,search]
        
        [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
            
            //  if(status)
            if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])
                
            {
                
                dispatch_async(dispatch_get_main_queue(),
                               ^{
                    
                    _coSignPendingArray = [responseValue valueForKey:@"Response"];
                    
                    if (_coSignPendingArray != (id)[NSNull null])
                    {
                        isPageRefreshing=NO;
                        _filterSecondArray  = [[NSMutableArray alloc]initWithArray:(NSMutableArray*)_coSignPendingArray];
                        [_searchResults addObjectsFromArray:_filterSecondArray];
                        [self.tableView reloadData];
                        
                        [self stopActivity];
                    }
                    else{
                        
                        //  noDataLabel.hidden = NO;
                        
                        if (_searchResults.count == 0) {
                            
                            UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
                            noDataLabel.text             = @"You do not have any files";
                            noDataLabel.textColor        = [UIColor grayColor];
                            noDataLabel.textAlignment    = NSTextAlignmentCenter;
                            self.tableView.backgroundView = noDataLabel;
                            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                            
                            //hide right bar button item if there is no data
                            self.navigationItem.rightBarButtonItem = nil;
                            
                            [_searchResults removeAllObjects];
                            [self.tableView reloadData];
                        }
                        [self stopActivity];
                    }
                    
                });
                
            }
            else{
                dispatch_async(dispatch_get_main_queue(),
                               ^{
                    if (_searchResults.count == 0) {
                        
                        UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
                        noDataLabel.text             = @"You do not have any files";
                        noDataLabel.textColor        = [UIColor grayColor];
                        noDataLabel.textAlignment    = NSTextAlignmentCenter;
                        self.tableView.backgroundView = noDataLabel;
                        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                        
                        //hide right bar button item if there is no data
                        self.navigationItem.rightBarButtonItem = nil;
                        
                        [_searchResults removeAllObjects];
                        [self.tableView reloadData];
                    }
                    [self stopActivity];
                });
            }
        }];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationItem.title = @"Waiting for Others";
    [self startActivity:@"Refreshing"];
    [super viewWillAppear:animated];
    _searchResults = [[NSMutableArray alloc]init];
    
    searchSting = @"";
    _currentPage = 1;
    [self makeServieCallWithPageNumaber:_currentPage :searchSting];
    // [self stopActivity];
}


-(void)refresh:(UIRefreshControl *)refreshControl
{
    
    /*************************Web Service*******************************/
    
    //Network Check
    if (![self connected])
    {
        if(hasPresentedAlert == false){
            
            // not connected
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No internet connection!" message:@"Check internet connection!" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alert show];
            hasPresentedAlert = true;
            [refreshControl endRefreshing];
        }
    }
    else
    {
        
        refreshControl.attributedTitle = [dateCategoryString refreshForDate];
        // [self makeServieCallWithPageNumaber:0];
        [self makeServieCallWithPageNumaber:0 :searchSting];
        
        [_tableView reloadData];
        [refreshControl endRefreshing];
        /******************************************************************/
        
    }
    
}

//Network Connection Checks
- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//implementation of delegate method
- (void)showModal:(UIModalPresentationStyle) style style:(MPBCustomStyleSignatureViewController*) controller
{
    
    MPBCustomStyleSignatureViewController* signatureViewController = [controller initWithConfiguration:[MPBSignatureViewControllerConfiguration configurationWithFormattedAmount:@""]];
    signatureViewController.modalPresentationStyle = style;
    signatureViewController.preferredContentSize = CGSizeMake(800, 500);
    signatureViewController.configuration.scheme = MPBSignatureViewControllerConfigurationSchemeAmex;
    
    signatureViewController.continueBlock = ^(UIImage *signature) {
        [self showImage: signature];
    };
    signatureViewController.cancelBlock = ^ {
        
    };
    
    [self presentViewController:signatureViewController animated:YES completion:nil];
}

- (void) showImage: (UIImage*) signature {
    self.signatureImageView.image = signature;
    self.signatureImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.signatureImageView.layer.borderColor = [UIColor yellowColor].CGColor;
    self.signatureImageView.layer.borderWidth = 2.0f;
}


-(void)docInfoBtnClickedWaiting:(UIButton*)sender
{
    
    UIAlertController * view = [[UIAlertController
                                 alloc]init];
    UIAlertAction* Info = [UIAlertAction
                           actionWithTitle:@"View Document Information"
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
                           {
        //Do some thing here
        
        //                               UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        //                               DocumentInfoVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"DocumentInfoVC"];
        //                               objTrackOrderVC.docInfoWorkflowId = [[_searchResults objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"];
        //                               objTrackOrderVC.status = @"Cosign-Pending";
        //                               [self.navigationController pushViewController:objTrackOrderVC animated:YES];
        
        [self getDocumentInfo:[[_searchResults objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"]];
        
        //                               CheckDocInfoController *docinfo = [[CheckDocInfoController alloc]init];
        //                               [docinfo getDocumentInfo:[[_searchResults objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"] ];
        //
        //                               DocumentInfoNames *objTrackOrderVC= [[DocumentInfoNames alloc] initWithNibName:@"DocumentInfoNames" bundle:nil];
        //                               objTrackOrderVC.docInfoWorkflowId = [[_searchResults objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"];
        //                                objTrackOrderVC.status = @"Cosign-Pending";
        //                               [self.navigationController pushViewController:objTrackOrderVC animated:YES];
    }];
    UIAlertAction* Inactive = [UIAlertAction
                               actionWithTitle:@"Mark Inactive"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
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
            NSString *requestURL = [NSString stringWithFormat:@"%@MarkAsInactive?WorkflowId=%@&status=%@",kInactive,[[_searchResults objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"],@"pending"];
            
            [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
                
                // if(status)
                if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])
                    
                {
                    dispatch_async(dispatch_get_main_queue(),
                                   ^{
                        
                        
                        NSArray* _inactiveArray =responseValue;
                        /*******************/
                        
                        UIAlertController * alert = [UIAlertController
                                                     alertControllerWithTitle:@""
                                                     message:@"Document got inactive successfully"
                                                     preferredStyle:UIAlertControllerStyleAlert];
                        
                        //Add Buttons
                        
                        UIAlertAction* yesButton = [UIAlertAction
                                                    actionWithTitle:@"Ok"
                                                    style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                            //Handle your yes please button action here
                            // [self.navigationController popViewControllerAnimated:YES];
                            
                            UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                            LMNavigationController *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"HomeNavController"];
                            [self presentViewController:objTrackOrderVC animated:YES completion:nil];
                            
                        }];
                        
                        
                        //Add your buttons to alert controller
                        
                        [alert addAction:yesButton];
                        //[alert addAction:noButton];
                        
                        [self presentViewController:alert animated:YES completion:nil];
                        [self stopActivity];
                        
                    });
                    
                }
                else{
                    
                    
                }
                
            }];
        }];
        [alert addAction:yesButton];
        //Add your buttons to alert controller
        
        
        UIAlertAction* noButton = [UIAlertAction
                                   actionWithTitle:@"No"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
            //Handle your yes please button action here
            
        }];
        
        //Add your buttons to alert controller
        
        [alert addAction:noButton];
        [self presentViewController:alert animated:YES completion:nil];
        
    }];
    UIAlertAction* Recall = [UIAlertAction
                             actionWithTitle:@"Recall Document"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
        UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        RecallVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"RecallVC"];
        self.definesPresentationContext = YES; //self is presenting view controller
        objTrackOrderVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        objTrackOrderVC.workflowID = [[_searchResults objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"];
        objTrackOrderVC.strExcutedFrom=@"WaitingForOther";
        [self.navigationController presentViewController:objTrackOrderVC animated:YES completion:nil];
        
    }];
    UIAlertAction* DocLog = [UIAlertAction
                             actionWithTitle:@"Document Log"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
        UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        DocumentLogVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"DocumentLogVC"];
        
        objTrackOrderVC.workflowID = [[_searchResults objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"];
        [self.navigationController pushViewController:objTrackOrderVC animated:YES];
    }];
    UIAlertAction* Comments = [UIAlertAction
                               actionWithTitle:@"Comments"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
        UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CommentsController *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"CommentsController"];
        
        objTrackOrderVC.workflowID = [[_searchResults objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"];
        [self.navigationController pushViewController:objTrackOrderVC animated:YES];
    }];
    UIAlertAction* Download = [UIAlertAction
                               actionWithTitle:@"Download Document"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
        
        //{
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
            NSString *requestURL = [NSString stringWithFormat:@"%@DownloadWorkflowDocuments?WorkFlowId=%@",kDownloadPdf,[[_searchResults objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"]];
            [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
                
                //   if(status)
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
                                //EMIOS1109
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
        
        // }
    }];
    
    
    
    
    UIAlertAction* Share = [UIAlertAction
                            actionWithTitle:@"Share Document"
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action)
                            {
        
        NSString *pendingdocumentName =[[_searchResults objectAtIndex:sender.tag] valueForKey:@"DisplayName"];
        NSString *pendingWorkflowID =[[_searchResults objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"];
        NSString* documentId = [[_searchResults objectAtIndex:sender.tag] valueForKey:@"DocumentId"];
        UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ShareVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"ShareVC"];
        objTrackOrderVC.documentName = pendingdocumentName;
        objTrackOrderVC.documentID = documentId;
        
        objTrackOrderVC.workflowID = pendingWorkflowID;
        [self.navigationController pushViewController:objTrackOrderVC animated:YES];
        
    }];
    
    
    
    
    UIAlertAction* BulkSign = [UIAlertAction
                               actionWithTitle:@"BulkSign"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
        
        [self showModals:UIModalPresentationFullScreen style:[MPBDefaultStyleSignatureViewController alloc] Lot:[[_searchResults objectAtIndex:sender.tag] valueForKey:@"LotId"]];
    }];
    UIAlertAction* BulkDocuments = [UIAlertAction
                                    actionWithTitle:@"BulkDownload"
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
            NSString *requestURL = [NSString stringWithFormat:@"%@BulkDownload?lotId=%@",kbulkDownload,[[_searchResults objectAtIndex:sender.tag] valueForKey:@"LotId"]];
            [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodPOST body:requestURL completionBlock:^(BOOL status, id responseValue) {
                
                //  if(status)
                if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])
                    
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self stopActivity];
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[[responseValue valueForKey:@"Messages"]objectAtIndex:0] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [alert show];
                    });
                    
                } else{
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
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction * action)
                             {
        [view dismissViewControllerAnimated:YES completion:nil];
        
    }];
    [BulkDocuments setValue:[[UIImage imageNamed:@"download.png"]
                             imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [BulkSign setValue:[[UIImage imageNamed:@"signatories.png"]
                        imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [BulkDocuments setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    [BulkSign setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    [Info setValue:[[UIImage imageNamed:@"information-outline-2.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [Inactive setValue:[[UIImage imageNamed:@"minus-circle.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [Recall setValue:[[UIImage imageNamed:@"tumblr-reblog.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [DocLog setValue:[[UIImage imageNamed:@"stack-exchange.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [Download setValue:[[UIImage imageNamed:@"download.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [Share setValue:[[UIImage imageNamed:@"share-variant.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [Comments setValue:[[UIImage imageNamed:@"comments"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    
    [Info setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    [Inactive setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    [Recall setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    [DocLog setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    [Download setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    [Share setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    [Comments setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    
    view.view.tintColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
    
    if ([[[_searchResults objectAtIndex:sender.tag] valueForKey:@"LotId"]intValue] != 0){
        // [view addAction:BulkSign];
        [view addAction:BulkDocuments];
    } else {
        if ([[[_searchResults objectAtIndex:sender.tag] valueForKey:@"Status"] isEqualToString:@"Pending"]) {
            [view addAction:Info];
            [view addAction:DocLog];
            [view addAction:Download];
            [view addAction:Share];
            [view addAction:Comments];
        }
        else{
            [view addAction:Info];
            [view addAction:Inactive];
            [view addAction:Recall];
            [view addAction:DocLog];
            [view addAction:Download];
            [view addAction:Comments];
            [view addAction:Share];
            
        }
        
    }
    [view addAction:cancel];
    [self presentViewController:view animated:YES completion:nil];
    
}
- (void)showModals:(UIModalPresentationStyle) style style:(MPBCustomStyleSignatureViewController*) controller Lot:(NSString*) lotId
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //Saving token
        
        MPBCustomStyleSignatureViewController* signatureViewController = [controller initWithConfiguration:[MPBSignatureViewControllerConfiguration configurationWithFormattedAmount:@""]];
        signatureViewController.modalPresentationStyle = style;
        signatureViewController.strExcutedFrom=@"Waiting for Others";
        signatureViewController.preferredContentSize = CGSizeMake(800, 500);
        signatureViewController.configuration.scheme = MPBSignatureViewControllerConfigurationSchemeAmex;
        signatureViewController.signatureWorkFlowID = [[NSUserDefaults standardUserDefaults] valueForKey:@"PendingWorkflowID"];
        signatureViewController.LotId = lotId;
        signatureViewController.isBulk = true;
        signatureViewController.continueBlock = ^(UIImage *signature) {
            [self showImage: signature];
        };
        signatureViewController.cancelBlock = ^ {
            
        };
        [self presentViewController:signatureViewController animated:YES completion:nil];
        
    });
}
-(void)getDocumentInfo:(NSString*)workflowId

{
    
    [self startActivity:@"Loading.."];
    NSString *requestURL = [NSString stringWithFormat:@"%@GetDocumentInfo?WorkFlowId=%@",kDocumentInfo,workflowId];
    
    [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
        
        //if(status)
        if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])
            
        {
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                _docInfoArray = [responseValue valueForKey:@"Response"];
                
                if (_docInfoArray != (id)[NSNull null])
                {
                    // [self.documentInfoTable reloadData];
                    
                    
                    if(_docInfoArray.count == 1)
                    {
                        UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                        DocumentInfoVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"DocumentInfoVC"];
                        objTrackOrderVC.documentInfoArray = _docInfoArray[0];
                        
                        NSString *names = [[_docInfoArray objectAtIndex:0]valueForKey:@"DocumentName"];
                        
                        objTrackOrderVC.titleString = names;
                        
                        // objTrackOrderVC.status = self.status;
                        [self.navigationController pushViewController:objTrackOrderVC animated:YES];
                        
                    }
                    else{
                        DocumentInfoNames *objTrackOrderVC= [[DocumentInfoNames alloc] initWithNibName:@"DocumentInfoNames" bundle:nil];
                        objTrackOrderVC.docInfoWorkflowId = workflowId;
                        objTrackOrderVC.status = @"Pending";
                        [self.navigationController pushViewController:objTrackOrderVC animated:YES];
                        
                        // [self.documentInfoTable reloadData];
                    }
                    //Check Null Originator
                    
                    [self stopActivity];
                }
                else
                {
                    UIAlertController * alert = [UIAlertController
                                                 alertControllerWithTitle:@""
                                                 message:[[responseValue valueForKey:@"Messages"] objectAtIndex:0]
                                                 preferredStyle:UIAlertControllerStyleAlert];
                    
                    //Add Buttons
                    
                    UIAlertAction* yesButton = [UIAlertAction
                                                actionWithTitle:@"Ok"
                                                style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * action) {
                        [self.navigationController popViewControllerAnimated:YES];
                    }];
                    
                    //Add your buttons to alert controller
                    
                    [alert addAction:yesButton];
                    [self presentViewController:alert animated:YES completion:nil];
                    [self stopActivity];
                }
                
            });
        }
        else{
            //if ([responseValue isKindOfClass:[NSString class]]) {
            // if ([responseValue isEqualToString:@"Invalid token Please Contact Adminstrator"]) {
            
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
            //}
            //}
        }
    }];
    
    
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    NSInteger numOfSections = 0;
    if ([self.searchResults count]>0)
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        numOfSections                = 1;
        self.tableView.backgroundView = nil;
    }
    else
    {
        //        noDataLabel.hidden = NO;
        //        UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
        //        noDataLabel.text             = @"No documents available";
        //        noDataLabel.textColor        = [UIColor grayColor];
        //        noDataLabel.textAlignment    = NSTextAlignmentCenter;
        //        self.tableView.backgroundView = noDataLabel;
        //        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        //        [self stopActivity];
        //        //hide right bar button item if there is no data
        //        self.navigationItem.rightBarButtonItem = nil;
    }
    
    return numOfSections;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PendingVCTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PendingVCTableViewCell" forIndexPath:indexPath];
    //PendingVCTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PendingVCTableViewCell"];
    
    _totalRow = [[[_searchResults objectAtIndex:indexPath.row] objectForKey:@"TotalRows"]integerValue];
    
    cell.documentName.text = [[_searchResults objectAtIndex:indexPath.row] objectForKey:@"DisplayName"];
    
    cell.pdfImage.translatesAutoresizingMaskIntoConstraints = YES;
    cell.pdfImage.frame = CGRectMake(0, 0, 0, 0);
    cell.documentName.translatesAutoresizingMaskIntoConstraints = YES;
    
    CGRect frame = cell.documentName.frame;
    frame.origin.x=  cell.pdfImage.frame.origin.x+8;//pass the X cordinate
    cell.documentName.frame= frame;
    
    NSString *numberOfAttachmentString = [[[_searchResults objectAtIndex:indexPath.row] objectForKey:@"NoofAttachment"]stringValue];
    
    if ([numberOfAttachmentString isEqualToString:@"0"]) {
        cell.attachmentsImage.image = [UIImage imageNamed:@""];
    }
    else {
        cell.attachmentsImage.image = [UIImage imageNamed:@"attachment-1x"];
    }
    
    cell.ownerName.text = [[_searchResults objectAtIndex:indexPath.row] objectForKey:@"Name"];
    cell.pdfImage.image = [UIImage imageNamed: @"ico-waiting-32.png"];
    
    
    
    //hide images for workflows and reviewer
    
    if ([[[_searchResults objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue] == 2 || [[[_searchResults objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue] == 5 )
    {
        cell.docInfoBtn.hidden = YES;
        
    }
    else{
        cell.docInfoBtn.hidden = NO;
        
    }
    
    
    
    
    NSArray* date= [[[_searchResults objectAtIndex:indexPath.row] objectForKey:@"UploadTime"] componentsSeparatedByString: @" "];
    
    NSString *dateFromArray = [[_searchResults objectAtIndex:indexPath.row] objectForKey:@"UploadTime"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    NSDate *dates = [formatter dateFromString:dateFromArray];
    
    dateCategoryString = [NSString string];
    cell.dateLable.text = [dateCategoryString transformedValue:dates];
    cell.timeLabel.text = [date objectAtIndex:1];
    //InfoButton
    cell.docInfoBtn.tag = indexPath.row;
    [cell.docInfoBtn addTarget:self action:@selector(docInfoBtnClickedWaiting:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

//- (id)transformedValue:(NSDate *)date
//{
//    // Initialize the formatter.
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateStyle:NSDateFormatterShortStyle];
//    [formatter setTimeStyle:NSDateFormatterNoStyle];
//
//    // Initialize the calendar and flags.
//    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSWeekdayCalendarUnit;
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//
//    // Create reference date for supplied date.
//    NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
//    [comps setHour:0];
//    [comps setMinute:0];
//    [comps setSecond:0];
//    NSDate *suppliedDate = [calendar dateFromComponents:comps];
//
//    // Iterate through the eight days (tomorrow, today, and the last six).
//    int i;
//    for (i = -1; i < 7; i++)
//    {
//        // Initialize reference date.
//        comps = [calendar components:unitFlags fromDate:[NSDate date]];
//        [comps setHour:0];
//        [comps setMinute:0];
//        [comps setSecond:0];
//        [comps setDay:[comps day] - i];
//        NSDate *referenceDate = [calendar dateFromComponents:comps];
//        // Get week day (starts at 1).
//        int weekday = [[calendar components:unitFlags fromDate:referenceDate] weekday] - 1;
//
//        if ([suppliedDate compare:referenceDate] == NSOrderedSame && i == -1)
//        {
//            // Tomorrow
//            return @"";
//        }
//        else if ([suppliedDate compare:referenceDate] == NSOrderedSame && i == 0)
//        {
//            // Today's time (a la iPhone Mail)
//            formatter.dateFormat = @"HH:mm:ss";
//            NSString *convertedString = [formatter stringFromDate:date];
//            // [formatter setDateStyle:NSDateFormatterNoStyle];
//            //[formatter setTimeStyle:NSDateFormatterShortStyle];
//            return convertedString;
//        }
//        else if ([suppliedDate compare:referenceDate] == NSOrderedSame && i == 1)
//        {
//            // Today
//            return @"Yesterday";
//        }
//        else if ([suppliedDate compare:referenceDate] == NSOrderedSame)
//        {
//            // Day of the week
//            NSString *day = [[formatter weekdaySymbols] objectAtIndex:weekday];
//            return day;
//        }
//    }
//
//    // It's not in those eight days.
//    NSString *defaultDate = [formatter stringFromDate:date];
//    return defaultDate;
//}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    /*************************Web Service*******************************/
    
    [self startActivity:@"Loading..."];
    
    if ([[[_searchResults objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue] == 2)
    {
        [self alertForFlexiforms];
        return ;
    }
    
    //workflow type 4
    
    if ([[[_searchResults objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue] == 4 ) {
        //Call API
        //EMIOS-1098
         [self GetBulkDocuments:[NSString stringWithFormat:@"%ld",(long)[[[_searchResults objectAtIndex:indexPath.row] valueForKey:@"LotId"]integerValue]] workflowType:[NSString stringWithFormat:@"%ld",(long)[[[_searchResults objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue]]];
        return;
    }
    
    //workflow type 5
    if ([[[_searchResults objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue] == 5)
    {
        [self alertForCollaborative];
        return;
    }
    
    _workFlowType = [[_searchResults objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"];
    
    NSString *requestURL = [NSString stringWithFormat:@"%@GetDocumentDetailsById?workFlowId=%@&workflowType=%@",kOpenPDFImage,[[_searchResults objectAtIndex:indexPath.row] valueForKey:@"WorkFlowId"],[[_searchResults objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]];
    [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(status && [responseValue valueForKey:@"Response"]!= [NSNull null])
            {
                
                _pdfImageArray=[[responseValue valueForKey:@"Response"] valueForKey:@"Document"];
                NSLog(@"%@",[[responseValue valueForKey:@"Response"] valueForKey:@"DocumentName"]);
                
                mstrXMLString = [[NSMutableString alloc]init];
                NSArray *arr =  [[responseValue valueForKey:@"Response"] valueForKey:@"Signatory"];
                
                if (arr.count > 0) {
                    NSString * ischeck = @"ischeck";
                    [mstrXMLString appendString:@"Signed By:"];
                    
                    for (int i = 0; arr.count>i; i++) {
                        NSDictionary * dict = arr[i];
                        if ([dict[@"StatusID"]intValue] == 13) {
                            NSString* emailid = dict[@"EmailID"];
                            NSString* name = dict[@"Name"];
                            NSString * totalstring = [NSString stringWithFormat:@"%@[%@]",name,emailid];
                            
                            if ([mstrXMLString containsString:[NSString stringWithFormat:@"%@",totalstring]]) {
                                
                            }
                            else
                            {
                                [mstrXMLString appendString:[NSString stringWithFormat:@" %@",totalstring]];
                            }
                            
                            //[mstrXMLString appendString:[NSString stringWithFormat:@"Signed By: %@",totalstring]];
                            ischeck = @"Signatory";
                            NSLog(@"%@",mstrXMLString);
                        }
                    }
                    if ([ischeck  isEqual: @"ischeck"])
                    {
                        NSArray *arr1 =  [[responseValue valueForKey:@"Response"] valueForKey:@"Originatory"];
                        mstrXMLString = [NSMutableString string];
                        [mstrXMLString appendString:@"Originated By:"];
                        for (int i = 0; arr1.count > i; i++) {
                            NSDictionary * dict = arr1[i];
                            
                            NSString* emailid = dict[@"EmailID"];
                            NSString* name = dict[@"Name"];
                            NSString * totalstring = [NSString stringWithFormat:@"%@[%@]",name,emailid];
                            [mstrXMLString appendString:[NSString stringWithFormat:@" %@",totalstring]];
                            NSLog(@"%@",mstrXMLString);
                        }
                    }
                    //}
                }
                
                else
                {
                    NSArray *arr1 =  [[responseValue valueForKey:@"Response"] valueForKey:@"Originatory"];
                    [mstrXMLString appendString:@"Originated By:"];
                    
                    for (int i = 0; arr1.count > i; i++) {
                        NSDictionary * dict = arr1[i];
                        
                        NSString* emailid = dict[@"EmailID"];
                        NSString* name = dict[@"Name"];
                        NSString * totalstring = [NSString stringWithFormat:@"%@[%@]",name,emailid];
                        [mstrXMLString appendString:[NSString stringWithFormat:@"%@",totalstring]];
                        NSLog(@"%@",mstrXMLString);
                    }
                }
                
                
                if (_pdfImageArray != (id)[NSNull null])
                {
                    
                    if ([[[responseValue valueForKey:@"Response"] valueForKey:@"IsPasswordProtected"] boolValue]==YES) {
                        
                        NSString *checkPassword = [[responseValue valueForKey:@"Response"] valueForKey:@"IsPasswordProtected"];
                        [[NSUserDefaults standardUserDefaults] setObject:checkPassword forKey:@"checkPassword"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        [[NSUserDefaults standardUserDefaults] setObject:[[_searchResults objectAtIndex:indexPath.row] objectForKey:@"Status"] forKey:@"checkStatus"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        NSLog(@"%@",[[responseValue valueForKey:@"Response"] valueForKey:@"DocumentName"]);
                        
                        //NSData *data = [[NSData alloc]initWithBase64EncodedString:_pdfImageArray options:0];
                        
                        NSData *data = [[NSData alloc]initWithBase64EncodedString:_pdfImageArray options:0];
                        
                        self.pdfDocument = [[PDFDocument alloc] initWithData:data];
                        
                        
                        
                        
                        // from your converted Base64 string
                        NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
                        NSString *path = [documentsDirectory stringByAppendingPathComponent:@"test.pdf"];
                        [data writeToFile:path atomically:YES];
                        
                        [[NSUserDefaults standardUserDefaults] setObject:path forKey:@"pathForDoc"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        NSString *displayName = [[_searchResults objectAtIndex:indexPath.row] objectForKey:@"DisplayName"];
                        [[NSUserDefaults standardUserDefaults] setObject:displayName forKey:@"displayName"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        NSString *docCount = [[[responseValue valueForKey:@"Response"] valueForKey:@"NoOfDocuments"] stringValue];
                        [[NSUserDefaults standardUserDefaults] setObject:docCount forKey:@"docCount"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        NSString *attachmentCount = [[[responseValue valueForKey:@"Response"] valueForKey:@"NoOfAttachments"] stringValue];
                        [[NSUserDefaults standardUserDefaults] setObject:attachmentCount forKey:@"attachmentCount"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        NSString *workflowId = [[_searchResults objectAtIndex:indexPath.row] valueForKey:@"WorkFlowId"];
                        [[NSUserDefaults standardUserDefaults] setObject:workflowId forKey:@"workflowId"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        
                        if ([self.pdfDocument isLocked]) {
                            UIAlertView *passwordAlertView = [[UIAlertView alloc]initWithTitle: @"Password Protected"
                                                                                       message: [NSString stringWithFormat: @"%@ %@", displayName, @"is password protected"]
                                                                                      delegate: self
                                                                             cancelButtonTitle: @"Cancel"
                                                                             otherButtonTitles: @"Done", nil];
                            passwordAlertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
                            [passwordAlertView show];
                            return ;
                            
                        }
                        [self stopActivity];
                        return;
                    }
                    
                    NSData *data = [[NSData alloc]initWithBase64EncodedString:_pdfImageArray options:0];
                    // from your converted Base64 string
                    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
                    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"test.pdf"];
                    [data writeToFile:path atomically:YES];
                    
                    if ([[[_searchResults objectAtIndex:indexPath.row] objectForKey:@"Status"] isEqualToString: @"Pending"]) {
                        
                        CompletedNextVC *temp = [[CompletedNextVC alloc] init];
                        temp._pathForDoc = path;
                        temp.pdfImagedetail = _pdfImageArray;
                        temp.myTitle = [[_searchResults objectAtIndex:indexPath.row] objectForKey:@"DisplayName"];
                        temp.strExcutedFrom=@"Completed";
                        temp.workflowID = [[_searchResults objectAtIndex:indexPath.row] valueForKey:@"WorkFlowId"];
                        temp.documentCount = [[[responseValue valueForKey:@"Response"] valueForKey:@"NoOfDocuments"] stringValue];
                        temp.signatoryString = mstrXMLString;
                        
                        temp.attachmentCount = [[[responseValue valueForKey:@"Response"] valueForKey:@"NoOfAttachments"] stringValue];
                        
                        [self.navigationController pushViewController:temp animated:YES];
                        [self stopActivity];
                        
                    }
                    else {
                        CoSignPendingListVC *temp = [[CoSignPendingListVC alloc] init];//WithFilename:path path:path document: doc];
                        temp.pathForDoc = path;
                        temp.pdfImagedetail = _pdfImageArray;
                    
                        temp.myTitle = [[_searchResults objectAtIndex:indexPath.row] objectForKey:@"DisplayName"];
                        temp.documentCount = [[[responseValue valueForKey:@"Response"] valueForKey:@"NoOfDocuments"] stringValue];
                        temp.attachmentCount = [[[responseValue valueForKey:@"Response"] valueForKey:@"NoOfAttachments"] stringValue];
                        temp.strExcutedFrom=@"WaitingForOther";
                        temp.signatoryString = mstrXMLString;
                        temp.passwordForPDF = password;
                        
                        temp.workflowID = [[_searchResults objectAtIndex:indexPath.row] valueForKey:@"WorkFlowId"];
                        temp.documentID = [[[responseValue valueForKey:@"Response"] valueForKey:@"DocumentId"]objectAtIndex:0];
                        temp.workFlowType = _workFlowType;
                        [self.navigationController pushViewController:temp animated:YES];
                        [self stopActivity];
                        
                    }
                }
                else{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message: @"This file is corrupted." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alert show];
                    [self stopActivity];
                }
                
            }
            else{
                
                //Alert at the time of no server connection
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message: @"This file is corrupted." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
                [self stopActivity];
                
            }
            
        });
        
    }];
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat yOffset = _tableView.contentOffset.y;
    CGFloat height = _tableView.contentSize.height - _tableView.bounds.size.height;
    if(yOffset >= height)
    {
        if(isPageRefreshing==NO){
            isPageRefreshing=YES;
            _currentPage+=1;
            // [self makeServieCallWithPageNumaber:_currentPage];
            [self makeServieCallWithPageNumaber:_currentPage :searchSting];
            
            //[self callPageNumbers:_currentPage];
        }
    }
    
}



-(void) alertForFlexiforms
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@""
                                 message:@"Flexiforms can't be opened as of now."
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    //Add Buttons
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Ok"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
        //Handle your yes please button action here
        
        [self stopActivity];
        
        
    }];
    
    //Add your buttons to alert controller
    
    [alert addAction:yesButton];
    
    [self presentViewController:alert animated:YES completion:nil];
    [self stopActivity];
}

- (void) alertForBulkDocuments
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@""
                                 message:@"Bulk documents can't be opened as of now."
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    //Add Buttons
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Ok"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
        //Handle your yes please button action here
        
        [self stopActivity];
        
        
    }];
    
    //Add your buttons to alert controller
    
    [alert addAction:yesButton];
    
    [self presentViewController:alert animated:YES completion:nil];
    [self stopActivity];
}

-(void) alertForCollaborative
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@""
                                 message:@"Collaborative documents can't be opened as of now."
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    //Add Buttons
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Ok"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
        //Handle your yes please button action here
        
        [self stopActivity];
        
        
    }];
    
    //Add your buttons to alert controller
    
    [alert addAction:yesButton];
    
    [self presentViewController:alert animated:YES completion:nil];
    [self stopActivity];
}

#pragma mark - Search Bar

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    // Do the search...
}
-(void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    //This'll Show The cancelButton with Animation
    [searchBar setShowsCancelButton:YES animated:YES];
    //remaining Code'll go here
}
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    //This'll Hide The cancelButton with Animation
    _searchResults = [NSMutableArray array];
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    _currentPage = 1;
    searchSting = @"";
    [self makeServieCallWithPageNumaber:_currentPage :searchSting];
    
    //remaining Code'll go here
}


-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //    if ([searchText length] == 0) {
    //        [_searchResults removeAllObjects];
    //            if (_pendingArray != (id)[NSNull null])
    //            {
    //                [_searchResults addObjectsFromArray:(NSMutableArray*)_pendingArray];
    //            }
    //    [searchBar resignFirstResponder];
    //    }
    if ([searchText length] >= 3)
    {
        
        //  if (_pendingArray != (id)[NSNull null])
        // {
        //            NSArray *arrayTemp = [(NSArray *)self.pendingArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"DisplayName CONTAINS [cd] %@ OR Name CONTAINS [cd] %@", searchBar.text,searchBar.text]];
        //            _searchResults = [[NSMutableArray alloc]initWithArray:(NSMutableArray*)arrayTemp];
        if(isPageRefreshing==NO){
            isPageRefreshing=YES;
            [_searchResults removeAllObjects];
            
            _currentPage = 1;
            searchSting = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            //searchSting = searchText;
            [self makeServieCallWithPageNumaber:_currentPage :searchSting];
            
        }
        [_tableView reloadData];
    }
    
}

//EMIOS-1098
-(void)GetBulkDocuments:(NSString *)lotId workflowType:(NSString *)workflowType  {
    //BulkDocVC
    
    UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BulkDocVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"BulkDocVC"];
    objTrackOrderVC.lotId = lotId;
    objTrackOrderVC.type = @"Me";
    objTrackOrderVC.workflowType = workflowType;
    [self.navigationController pushViewController:objTrackOrderVC animated:YES];
}
-(void) actionSheet: (UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(actionSheet.tag == 101) {
            //do something
            switch (buttonIndex) {
                case 0: {
                    
                    
                    break;
                }
                case 1:
                {
                    UIAlertView *alertView3 = [[UIAlertView alloc] initWithTitle:@"Download"
                                                                         message:@"Do you want to download document?"
                                                                        delegate:self
                                                               cancelButtonTitle:@"Yes"
                                                               otherButtonTitles:@"No", nil];
                    alertView3.tag = 3;
                    [alertView3 show];
                    
                    //                NSString *iTunesLink = @"https://itunes.apple.com/us/app/11th-hours/id1066691881?ls=1&mt=8";
                    //                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
                    break;
                }
                    
                default:
                    break;
            }
            
            
        } else if(actionSheet.tag == 102) {
            //do something else
            switch (buttonIndex) {
                case 0: {
                    UIAlertView * alert4 =[[UIAlertView alloc ] initWithTitle:@"Aadhar Number" message:@"Please enter aadhar card number" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
                    alert4.alertViewStyle = UIAlertViewStylePlainTextInput;
                    [alert4 addButtonWithTitle:@"Get OTP"];
                    alert4.tag = 4;
                    [alert4 show];
                    
                    break;
                }
                case 1:
                {
                    [self showModal:UIModalPresentationFullScreen style:[MPBDefaultStyleSignatureViewController alloc]];
                    //                NSString *iTunesLink = @"https://itunes.apple.com/us/app/11th-hours/id1066691881?ls=1&mt=8";
                    //                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
                    break;
                }
                    
                default:
                    break;
            }
            
        }
    });
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    UITextField *emailInput = [alertView textFieldAtIndex:0].text;
    
    [[NSUserDefaults standardUserDefaults] setObject:emailInput forKey:@"Password"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    password = [alertView textFieldAtIndex: 0].text.UTF8String;
    [alertView dismissWithClickedButtonIndex: buttonIndex animated: TRUE];
    if (buttonIndex == 1) {
        if ([self.pdfDocument isLocked])
            
            [self onPasswordOK];
        else
            [self askForPassword: @"Wrong password. Try again:"];
    }
    else
    {
        [self stopActivity];
        if (alertView.tag == 4)
        {
            if (buttonIndex == 1)
            {  //Login
                UITextField *aadharNumber = [alertView textFieldAtIndex:0];
                NSLog(@"Aadhar Number: %@", aadharNumber.text);
                UIAlertView * alert5 =[[UIAlertView alloc ] initWithTitle:@"OTP" message:@"Please enter OTP" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
                alert5.alertViewStyle = UIAlertViewStylePlainTextInput;
                [alert5 addButtonWithTitle:@"Sign"];
                alert5.tag = 5;
                [alert5 show];
                
            }
            else if (buttonIndex == 0)
            {
                
            }
        }
    }
    
}

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

#pragma mark ask password

- (void)openDocument:(NSString *)file
{
    if ([self.pdfDocument isLocked]) {
        NSString *path  = [[NSUserDefaults standardUserDefaults] valueForKey:@"pathForDoc"];
        
        UIAlertView *passwordAlertView = [[UIAlertView alloc]initWithTitle: @"Password Protected"
                                                                   message: [NSString stringWithFormat: @"bbu", path.lastPathComponent]
                                                                  delegate: self
                                                         cancelButtonTitle: @"Cancel"
                                                         otherButtonTitles: @"Done", nil];
        passwordAlertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
        [passwordAlertView show];
        
    }
    else {
        [self onPasswordOK];
    }
    
}

- (void)askForPassword:(NSString *)prompt
{
    NSString *path  = [[NSUserDefaults standardUserDefaults] valueForKey:@"pathForDoc"];
    UIAlertView *passwordAlertView = [[UIAlertView alloc]
                                      initWithTitle: @"Password Protected"
                                      message: [NSString stringWithFormat: prompt, path.lastPathComponent]
                                      delegate: self
                                      cancelButtonTitle: @"Cancel"
                                      otherButtonTitles: @"Done", nil];
    passwordAlertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [passwordAlertView show];
    
}

- (void)onPasswordOK
{
    NSString *path  = [[NSUserDefaults standardUserDefaults] valueForKey:@"pathForDoc"];
    NSString *displayName = [[NSUserDefaults standardUserDefaults] valueForKey:@"displayName"];
    NSString *docCount = [[NSUserDefaults standardUserDefaults] valueForKey:@"docCount"];
    NSString *attachmentCount = [[NSUserDefaults standardUserDefaults] valueForKey:@"attachmentCount"];
    NSString *workflowId = [[NSUserDefaults standardUserDefaults] valueForKey:@"workflowId"];
    NSString *checkstatus = [[NSUserDefaults standardUserDefaults] valueForKey:@"checkStatus"];
    
    if (![self.pdfDocument unlockWithPassword:[[NSUserDefaults standardUserDefaults] valueForKey:@"Password"]]) {
        [self askForPassword: @"Wrong password. Try again:"];
        [self stopActivity];
        return;
    }
    
    if ([checkstatus isEqualToString: @"Pending"]) {
        CompletedNextVC *temp = [[CompletedNextVC alloc] init];//WithFilename:path path:path document: doc];
        temp._pathForDoc = path;
        temp.pdfImagedetail = _pdfImageArray;
        temp.myTitle = displayName;
        temp.strExcutedFrom=@"Completed";
        temp.workflowID = workflowId;
        temp.documentCount = docCount;
        temp.signatoryString = mstrXMLString;
        temp.passwordForPDF = password;
        temp.attachmentCount = attachmentCount;
        [self.navigationController pushViewController:temp animated:YES];
        [self stopActivity];
        
    }
    else {
        
        CoSignPendingListVC *temp = [[CoSignPendingListVC alloc] init];//WithFilename:path path:path document: doc];
        
        temp.pdfImagedetail = _pdfImageArray;
        temp.myTitle = displayName;
        temp.documentCount = docCount;
        temp.attachmentCount = attachmentCount;
        temp.strExcutedFrom=@"WaitingForOther";
        temp.workflowID = workflowId;
        temp.signatoryString = mstrXMLString;
        temp.passwordForPDF = password;
        [self.navigationController pushViewController:temp animated:YES];
        [self stopActivity];
    }
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
    //    NSString *path = [[[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject] path];
    //    //You'll need an additional '/'
    //    NSString *fileName = [self.pdfImageArray[index] valueForKey:@"DocumentName"];
    NSString *fileName = [_addFile objectAtIndex:index];
    //NSString *fullPath = [path stringByAppendingFormat:@"/%@", fileName];
    return [NSURL fileURLWithPath:fileName];
}

#pragma mark - delegate methods


- (BOOL)previewController:(QLPreviewController *)controller shouldOpenURL:(NSURL *)url forPreviewItem:(id <QLPreviewItem>)item
{
    return YES;
}

- (CGRect)previewController:(QLPreviewController *)controller frameForPreviewItem:(id <QLPreviewItem>)item inSourceView:(UIView **)view
{

    UIView *view1 = [self.view viewWithTag:currentPreviewIndex+1];
    return view1.frame;
}


@end
