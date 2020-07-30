//
//  MultiplePdfViewerVC.m
//  emSigner
//
//  Created by Administrator on 5/24/17.
//  Copyright © 2017 Emudhra. All rights reserved.
//

#import "MultiplePdfViewerVC.h"
#import "MBProgressHUD.h"
#import "NSObject+Activity.h"
#import "WebserviceManager.h"
#import "HoursConstants.h"
#import "PendingListVC.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import "DocumentInfoVC.h"
#import "CustomPopOverVC.h"
#import "ParallelSigning.h"
#import "GlobalVariables.h"

@interface MultiplePdfViewerVC ()<CellPopUp>
{
    CustomPopOverVC *popCellVC;
    int yPosition;
    NSString *descriptionStr;
    NSMutableArray * lstOriginatory;
    NSMutableArray * lstSignatory;
    NSString* pdfFilePathForSignatures;
    NSString* createPdfString;
    NSData *data;
    NSMutableArray * coordinatesArray;
    NSArray *arr;
    NSString* path;
    NSArray *SignatoryArray;
    const char *password;
   // GlobalVariables * globalVariables;
}

@end

@implementation MultiplePdfViewerVC

enum
{
    ResourceCacheMaxSize = 128<<20	/**< use at most 128M for resource cache */
};

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    createPdfString = [NSString string];
    //Empty cell keep blank
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 65, 0);
    self.selectedRow = 0;

    //Empty cell keep blank
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 65, 0);
    [self.tableView setContentOffset:CGPointMake(0.0, self.tableView.tableHeaderView.frame.size.height) animated:YES];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.title = _document;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MultiplePdfTableViewCell" bundle:nil] forCellReuseIdentifier:@"MultiplePdfTableViewCell"];
    
    _listArray = [[NSMutableArray alloc]init];
   // globalVariables = [[GlobalVariables alloc] init];
    
    //    /*************************Web Service*******************************/
    
    [self startActivity:@"Refreshing"];
    NSLog(@"WorkFlowType: %@",_workFlowType);
    
   // NSString *requestURL = [NSString stringWithFormat:@"%@GetDocumentidsByWorkflowid?WorkflowID=%@",kMultipleDoc,_workFlowId]; //old
    NSString *requestURL = [NSString stringWithFormat:@"%@DownloadWorkflowDocuments?WorkflowId=%@",kMultipleDoc,_workFlowId];
    
    [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
        
     //   if(status)
            if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

        {
            self->_listArray = [responseValue valueForKey:@"Response"];
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                              // _listArray=[responseValue valueForKey:@"Response"];
                               if (_listArray != (id)[NSNull null])
                               {
                                   [self->_tableView reloadData];
                                   [self stopActivity];
                               }
                               else{
                                   
                               }
                               [self stopActivity];
                           });
        }
        else{
           [self stopActivity];
        }
        
    }];
   // [self stopActivity];
    /*******************************************************************************/
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_listArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MultiplePdfTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MultiplePdfTableViewCell" forIndexPath:indexPath];

    cell.documentNameLable.text = [[_listArray objectAtIndex:indexPath.row] objectForKey:@"DocumentName"];
   //
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:250.0/255.0 alpha:1.0];
    [cell setSelectedBackgroundView:bgColorView];
    
//
    if(indexPath.row == _currentSelectedRow)
    {
        
        [tableView
         selectRowAtIndexPath:indexPath
         animated:TRUE
         scrollPosition:UITableViewScrollPositionNone
         ];
        
    }
    
    //InfoButton
    cell.docInfoBtn.tag = indexPath.row;
    [cell.docInfoBtn addTarget:self action:@selector(docInfoBtnClicked1:) forControlEvents:UIControlEventTouchUpInside];
    

    
 /*   [self startActivity:@"Loading.."];
   // NSString *requestURL = [NSString stringWithFormat:@"%@GetSignerDetails?DocumentId=%@",kMultipleSignatory,[[_listArray objectAtIndex:indexPath.row] valueForKey:@"DocumentID"]];
    NSString *requestURL = [NSString stringWithFormat:@"%@GetSignerDetails?DocumentId=%@",kMultipleSignatory,[[_listArray objectAtIndex:indexPath.row] valueForKey:@"DocumentId"]];
    
    [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
        
       // if(status)
            if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

        {
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               _documentInfoArray = [responseValue valueForKey:@"Response"];
                               
                               if (_documentInfoArray != (id)[NSNull null])
                               {
                                   
                                   NSArray* sign = [[_documentInfoArray valueForKey:@"SignerDetails"] componentsSeparatedByString: @"$"];
                                   
                                   float xCoordinate=1.0,yCoordinate=1.0,width=100,height=30;
                                   float ver_space=10.0;
                                   
                                   
                                   for (int i= 0; i<[sign count]-1; i++) {
                                       
                                       NSString *signatory= [sign objectAtIndex:i];
                                       NSArray *signatory1 = [signatory componentsSeparatedByString: @"-"];
                                       NSString *name = [signatory1 objectAtIndex:0];
                                       NSString *signatoryDetail = [signatory1 objectAtIndex:1];
                                       
                                       UILabel *label =  [[UILabel alloc] initWithFrame: CGRectMake(xCoordinate,yCoordinate,width,height)];
                                       label.text = name;
                                       label.baselineAdjustment = YES;
                                       label.font=[label.font fontWithSize:20];

                                       label.adjustsFontSizeToFitWidth = YES;
                                       label.textAlignment = NSTextAlignmentCenter;
                                       label.textColor = [UIColor whiteColor];
                                       [label sizeToFit];
                                       label.layer.masksToBounds = YES;
                                       label.layer.cornerRadius = 10.0;
                                       xCoordinate=xCoordinate+label.frame.size.width+ver_space;
                                       [cell.signatoryScrollView addSubview:label];
                                       
                                       
                                       CGRect screenRect = [[UIScreen mainScreen] bounds];
                                       CGFloat screenWidth = screenRect.size.width;
                                       if (xCoordinate<= screenWidth) {
                                           cell.signatoryScrollView.scrollEnabled=NO;
                                           
                                           if ([signatoryDetail isEqualToString:@"Signed"]) {
                                               label.backgroundColor = ([UIColor colorWithRed:102.0/255.0 green:153.0/255.0 blue:0.0/255.0 alpha:1.0]);
                                               
                                           }
                                           else if ([signatoryDetail isEqualToString:@"Pending"])
                                           {
                                               label.backgroundColor = ([UIColor colorWithRed:243.0/255.0 green:111.0/255.0 blue:33.0/255.0 alpha:1.0]);
                                           }
                                           else if ([signatoryDetail isEqualToString:@"InActive"])
                                           {
                                               label.backgroundColor = ([UIColor colorWithRed:255.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0]);
                                           }
                                           else if ([signatoryDetail isEqualToString:@"Completed"])
                                           {
                                               label.backgroundColor = ([UIColor colorWithRed:102.0/255.0 green:153.0/255.0 blue:0.0/255.0 alpha:1.0]);
                                           }
                                           else if ([signatoryDetail isEqualToString:@"Initiate"])
                                           {
                                               label.backgroundColor = ([UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0]);
                                           }
                                           
                                           else if ([signatoryDetail isEqualToString:@"Declined"])
                                           {
                                               label.backgroundColor = ([UIColor colorWithRed:204.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0]);
                                           }
                                           else if ([signatoryDetail isEqualToString:@"Recalled"])
                                           {
                                               label.backgroundColor = ([UIColor colorWithRed:0.0/255.0 green:102.0/255.0 blue:204.0/255.0 alpha:1.0]);
                                           }
                                           else if ([signatoryDetail isEqualToString:@"Not yet started"])
                                           {
                                               label.backgroundColor = ([UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0]);
                                           }

                                           
                                       }
                                       else{
                                           cell.signatoryScrollView.scrollEnabled=YES;
                                           if ([signatoryDetail isEqualToString:@"Signed"]) {
                                               label.backgroundColor = ([UIColor colorWithRed:102.0/255.0 green:153.0/255.0 blue:0.0/255.0 alpha:1.0]);
                                               
                                               
                                           }
                                           else if ([signatoryDetail isEqualToString:@"Pending"])
                                           {
                                               label.backgroundColor = ([UIColor colorWithRed:243.0/255.0 green:111.0/255.0 blue:33.0/255.0 alpha:1.0]);
                                           }
                                           else if ([signatoryDetail isEqualToString:@"InActive"])
                                           {
                                               label.backgroundColor = ([UIColor colorWithRed:255.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0]);
                                           }
                                           else if ([signatoryDetail isEqualToString:@"Completed"])
                                           {
                                               label.backgroundColor = ([UIColor colorWithRed:102.0/255.0 green:153.0/255.0 blue:0.0/255.0 alpha:1.0]);
                                           }
                                           else if ([signatoryDetail isEqualToString:@"Initiate"])
                                           {
                                               label.backgroundColor = ([UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0]);
                                           }
                                           
                                           else if ([signatoryDetail isEqualToString:@"Declined"])
                                           {
                                               label.backgroundColor = ([UIColor colorWithRed:204.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0]);
                                           }
                                           else if ([signatoryDetail isEqualToString:@"Recalled"])
                                           {
                                               label.backgroundColor = ([UIColor colorWithRed:0.0/255.0 green:102.0/255.0 blue:204.0/255.0 alpha:1.0]);
                                           }
                                           else if ([signatoryDetail isEqualToString:@"Not yet started"])
                                           {
                                               label.backgroundColor = ([UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0]);
                                           }

                                       }
                                       
                                      }
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
            [self stopActivity];
        }
        
    }];
    
    [self stopActivity]; */
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 50.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *documentId = GlobalVariables.sharedInstance.documentId;
   // NSInteger documentId = [documentId1 integerValue];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *loggedInUserEmail = [defaults stringForKey:@"Email"];
    
    
    self.selectedRow = indexPath.row;
    /*************************Web Service*******************************/
        
        [self startActivity:@"Loading..."];
        
       // NSString *requestURL = [NSString stringWithFormat:@"%@DownloadDocumentById?documentId=%@",kOpenPDFImage,[[_listArray objectAtIndex:indexPath.row] valueForKey:@"DocumentID"]];
       NSString *requestURL = [NSString stringWithFormat:@"%@GetDocumentDetailsById?DocumentId=%@&workflowType=%@",kOpenPDFImage,[[_listArray objectAtIndex:indexPath.row] valueForKey:@"DocumentId"],_workFlowType];
    
        [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
            
           // if(status)
                if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    self->coordinatesArray = [[NSMutableArray alloc]init];

                    self->_checkNullArray = [responseValue valueForKey:@"Response"];

                    //Check Null String Address
                    self->lstOriginatory = [[NSMutableArray alloc]init];
                    self->lstSignatory = [[NSMutableArray alloc]init];
                    
                   // self->lstOriginatory = [[responseValue valueForKey:@"Response"] valueForKey:@"lstOriginatory"];
                    self->lstOriginatory = [[responseValue valueForKey:@"Response"] valueForKey:@"Originatory"];
                   // self->lstSignatory = [[responseValue valueForKey:@"Response"] valueForKey:@"lstSignatory"];
                    self->lstSignatory = [[responseValue valueForKey:@"Response"] valueForKey:@"Signatory"];
                    
                    
                    self->descriptionStr=[[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[[responseValue valueForKey:@"Response"] valueForKey:@"Document"]]];
                  
                   // descriptionStr=[[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[[responseValue valueForKey:@"Response"] valueForKey:@"Description"]]];
                    
                   // NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
                   // NSData *tempData = [[NSUserDefaults standardUserDefaults] valueForKey:@"Signatory"];
                    //NSDictionary *myDicProfile = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSDictionary class] fromData:tempData error:nil];
                    
                   // SignatoryArray = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSArray class] fromData:tempData error:nil];

                                               //   self->SignatoryArray =  [prefs objectForKey:@"Signatory"];
                            
                     
                    if (self->lstSignatory.count > 0){
                        
                        
                        for (int i = 0; i <self->lstSignatory.count; i++) {
                            
                           NSDictionary * dict = self->lstSignatory[i];
                           NSString *email = [dict valueForKey:@"EmailID"];
                           NSString *documentID = [NSString stringWithFormat:@"%@",[dict valueForKey:@"DocumentId"]];
                           NSString *statusId = [NSString stringWithFormat:@"%@",[dict valueForKey:@"StatusID"]];
                            
                            NSLog(@"Email id: %@",email);
                            NSLog(@"Document id: %@",documentID);
                            NSLog(@"Status id: %@",statusId);
                            
                            NSLog(@"Origional Email: %@",loggedInUserEmail);
                            NSLog(@"Original Document ID: %@",documentId);
                            
                           //if (email == loggedInUserEmail && documentID == documentId) {
                            if([email isEqualToString:loggedInUserEmail] && [documentID isEqualToString:documentId]) {
                               
                               NSLog(@"Both Email and DOcument id are same");
                               
                               if([statusId isEqualToString:@"7"]) {
                                   
                                   [self->coordinatesArray addObject:dict];
                                   NSLog(@"Object Added");
                               }else{
                                   NSLog(@"Object Not Added - Status Id is not same");
                               }
                           }
                
                        } //Loop end
                    }
                   
                   /* //Checking for signatorys and multiple PDF
                    //for (int i = 0; i<self->_signatoryHolderArray.count; i++) {
                    for (int i = 0; i<self->_signatoryHolderArray.count; i++) {
                       
                        NSString * lowercaseEmail = [[self->_signatoryHolderArray [i]valueForKey:@"EmailID"]lowercaseString];
                       // NSString * loginMail = [[[NSUserDefaults standardUserDefaults]valueForKey:@"Email"]lowercaseString];
                        
                        if([lowercaseEmail isEqualToString:loggedInUserEmail] && (documentId == [[[self->_listArray objectAtIndex:indexPath.row] valueForKey:@"DocumentId"]integerValue])) {
                            
                            if (([[self->_signatoryHolderArray[i]valueForKey:@"StatusID"]intValue] == 7) || ([[self->_signatoryHolderArray[i]valueForKey:@"StatusID"]integerValue] == 53)|| ([[self->_signatoryHolderArray[i]valueForKey:@"StatusID"]integerValue] == 8)) {
                                
                                [self->coordinatesArray addObject:self->_signatoryHolderArray[i]];
                            }
                        }
                    
                    } */
                    
                    self.mstrXMLString = [[NSMutableString alloc]init];
                    //NSArray *arr =  [[responseValue valueForKey:@"Response"]valueForKey:@"lstSignatory"];
                    NSArray *arr =  [[responseValue valueForKey:@"Response"]valueForKey:@"Signatory"];
                    
                    if (arr.count > 0) {
                        NSString * ischeck = @"ischeck";
                        [self->_mstrXMLString appendString:@"Signed By:"];
                        
                        for (int i = 0; i < arr.count; i++) {
                            NSDictionary * dict = arr[i];
                           // if ([dict[@"StatusID"]intValue] == 13) {
                            if ([dict[@"StatusID"]intValue] == 7) {
                                NSString* emailid = dict[@"EmailID"];
                                NSString* name = dict[@"Name"];
                                NSString * totalstring = [NSString stringWithFormat:@"%@[%@]",name,emailid];
                                
                                if ([self->_mstrXMLString containsString:[NSString stringWithFormat:@"%@",totalstring]]) {
                                    
                                }
                                else
                                {
                                    [self->_mstrXMLString appendString:[NSString stringWithFormat:@" %@",totalstring]];
                                }
                                
                                //[mstrXMLString appendString:[NSString stringWithFormat:@"Signed By: %@",totalstring]];
                                ischeck = @"Signatory";
                                NSLog(@"%@",self->_mstrXMLString);
                            }
                        }
                        if ([ischeck  isEqual: @"ischeck"])
                        {
                           // NSArray *arr1 =  [[responseValue valueForKey:@"Response"] valueForKey:@"lstOriginatory"];
                            NSArray *arr1 =  [[responseValue valueForKey:@"Response"] valueForKey:@"Originatory"];
        
                            
                            if (arr1 != (id)[NSNull null] && arr1 != nil && [arr1 count] != 0 ){
                              // NSLog(@"Array is: %@", arr1);
                               NSLog(@"Array Count is: %lu", (unsigned long)arr1.count);
                                if(arr1.count > 0){
                                    self->_mstrXMLString = [NSMutableString string];
                                    
                                    [self->_mstrXMLString appendString:@"Originated By:"];
                                    for (int i = 0; i< arr1.count; i++) {
                                        NSDictionary * dict = arr1[i];
                                        
                                        NSString* emailid = dict[@"EmailID"];
                                        NSString* name = dict[@"Name"];
                                        NSString * totalstring = [NSString stringWithFormat:@"%@[%@]",name,emailid];
                                        [self->_mstrXMLString appendString:[NSString stringWithFormat:@" %@",totalstring]];
                                        NSLog(@"%@",self->_mstrXMLString);
                                    }
                                }
                            }
                            else{
                                NSLog(@"Array is Null");
                            }
                        }
                        //}
                    }
                    
                    else
                    {
                        NSArray *arr1 =  [[responseValue valueForKey:@"Response"] valueForKey:@"Originatory"];
                        if(arr1.count > 0){
                            [self->_mstrXMLString appendString:@"Originated By:"];
                            
                            for (int i = 0; i< arr1.count; i++) {
                                NSDictionary * dict = arr1[i];
                                
                                NSString* emailid = dict[@"EmailID"];
                                NSString* name = dict[@"Name"];
                                NSString * totalstring = [NSString stringWithFormat:@"%@[%@]",name,emailid];
                                [self->_mstrXMLString appendString:[NSString stringWithFormat:@"%@",totalstring]];
                                NSLog(@"%@",self->_mstrXMLString);
                            }
                        }
                    }
                    
                    if ([[[responseValue valueForKey:@"Response"] valueForKey:@"IsPasswordProtected"] boolValue]==YES) {
                        
                        NSLog(@"%@",[[responseValue valueForKey:@"Response"] valueForKey:@"DocumentName"]);
                        
                       // descriptionStr=[[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[[responseValue valueForKey:@"Response"] valueForKey:@"Filebyte"]]];
                        self->descriptionStr=[[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[[responseValue valueForKey:@"Response"] valueForKey:@"Document"]]];
                        
                        self->data = [[NSData alloc]initWithBase64EncodedString:self->descriptionStr options:0];
                        // from your converted Base64 string
                        NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
                        NSString *path = [documentsDirectory stringByAppendingPathComponent:[[self->_listArray objectAtIndex:indexPath.row] objectForKey:@"DocumentName"]];
                        [self->data writeToFile:path atomically:YES];
                        
                        NSString *displayName = [[self->_listArray objectAtIndex:indexPath.row] objectForKey:@"DocumentName"];
                        [[NSUserDefaults standardUserDefaults] setObject:displayName forKey:@"displayName"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        self.pdfDocument = [[PDFDocument alloc] initWithData:self->data];

                        
                        if ([self.pdfDocument isLocked]) {
                            UIAlertView *passwordAlertView = [[UIAlertView alloc]initWithTitle: @"Password Protected"
                                                                                       message: [NSString stringWithFormat: @"%@",@"This file is password protected"]
                                                                                      delegate: self
                                                                             cancelButtonTitle: @"Cancel"
                                                                             otherButtonTitles: @"Done", nil];
                            passwordAlertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
                            [passwordAlertView show];
                            [self stopActivity];
                            return;
                        }
                       
                    }
                    
                    self->data = [[NSData alloc]initWithBase64EncodedString:self->descriptionStr options:0];
                    // from your converted Base64 string
                    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
                    NSString *path = [documentsDirectory stringByAppendingPathComponent:[[self->_listArray objectAtIndex:indexPath.row] objectForKey:@"DocumentName"]];
                    [self->data writeToFile:path atomically:YES];
                    
                    NSString*  SubscriberId = [[NSUserDefaults standardUserDefaults]valueForKey:@"signOrReviewerText"];

                    BOOL  isSignatory = false,isReviewer = false;
                    if ([SubscriberId isEqualToString:@"Sign & Review"]) {
                        isSignatory = true;
                        isReviewer = true;
                    }
                    else if([SubscriberId isEqualToString:@"Sign"]){
                        isSignatory = true;
                        isReviewer = false;

                    }
                     else if([SubscriberId isEqualToString:@"Reviewer"]){
                         isReviewer = true;
                         isSignatory = false;

                     }
                    
                    
                    
//                    if (self.isSignatory == true && self.isReviewer == true) {
//                        self.signlabel.text = @"Sign & Review";
//                    }
//                    else if (self.isSignatory == true)
//                    {
//                        self.signlabel.text = @"Sign";
//                    }
//                    else if (self.isReviewer == true)
//                    {
//                        self.signlabel.text = @"Reviewer";
//                    }
                    
                    if (![self->_parallel isEqualToString:@"1"]) {
                    PendingListVC *temp = [[PendingListVC alloc] init];//WithFilename:path path:path document: doc];

                    temp.pdfImagedetail = self->descriptionStr;
                    temp.strExcutedFrom = self->_strExcutedFrom;
                    temp.myTitle = [[self->_listArray objectAtIndex:indexPath.row] objectForKey:@"DocumentName"];
                    temp.workFlowID = self->_workFlowId;
                    temp.workFlowType = self->_workFlowType;
                    temp.signatoryString = self.mstrXMLString;
                    temp.signatoryHolderArray =  self->_signatoryHolderArray;
                    temp.isSignatory = isSignatory;
                    temp.isReviewer = isReviewer;
                    temp.placeholderArray = self->coordinatesArray;
                    temp.signatureImage = self.signatureImage;
                    [self.navigationController pushViewController:temp animated:YES];
                    [self stopActivity];
                    }
                    else
                    {
                        ParallelSigning *temp = [[ParallelSigning alloc] init];//WithFilename:path path:path document: doc];
                        
                        temp._pathForDoc = path;
                        temp.pdfImagedetail = self->descriptionStr;
                        temp.myTitle = [[self->_listArray objectAtIndex:indexPath.row] objectForKey:@"DocumentName"];
                        temp.strExcutedFrom=@"Completed";
                        temp.workflowID = self->_workFlowId;
                        temp.documentCount = [[self->_checkNullArray valueForKey:@"NoOfDocuments"] stringValue];
                        temp.signatoryString = self->_mstrXMLString;
                        // temp.matchSignersList = arr;
                        temp.placeholderArray = self->coordinatesArray;
                        temp.matchSignersList =    self->_signatoryHolderArray;

                        // temp.attachmentCount = [[_checkNullArray valueForKey:@"NoOfAttachments"] stringValue];
                        [self.navigationController pushViewController:temp animated:YES];
                        [self stopActivity];
                    }
                   
                });
                
            }
            else{
                //Alert at the time of no server connection
                
                UIAlertController * alert = [UIAlertController
                                             alertControllerWithTitle:@"Alert"
                                             message:@"Try again"
                                             preferredStyle:UIAlertControllerStyleAlert];
                
                //Add Buttons
                
                UIAlertAction* yesButton = [UIAlertAction
                                            actionWithTitle:@"Ok"
                                            style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                //Handle your yes please button action here
                                                
                                            }];

                //Add your buttons to alert controller
                
                [alert addAction:yesButton];
                [self presentViewController:alert animated:YES completion:nil];
                [self stopActivity];
                
            }
            
        }];

}

-(void)docInfoBtnClicked1:(UIButton*)sender
{
    
}

-(void)dissmissCellPopup:(NSInteger)row
{
    
}

-(NSString*) addSignature:(UIImage *) imgSignature onPDFData:(NSData *)pdfData withCoordinates:(NSMutableArray*)arr Count:(NSArray*)array {
    
    NSMutableData* outputPDFData = [[NSMutableData alloc] init];
    CGDataConsumerRef dataConsumer = CGDataConsumerCreateWithCFData((CFMutableDataRef)outputPDFData);
    
    long pnum = 0;
    CFMutableDictionaryRef attrDictionary = NULL;
    attrDictionary = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionarySetValue(attrDictionary, kCGPDFContextTitle, CFSTR("My Doc"));
    NSString *pass = [[NSUserDefaults standardUserDefaults] valueForKey:@"Password"];
    
    CGContextRef pdfContext = CGPDFContextCreate(dataConsumer, NULL, attrDictionary);
    CFRelease(dataConsumer);
    CFRelease(attrDictionary);
    CGRect pageRect;
    CGRect coordinatesRect;
    NSMutableArray * coordinatesArray;
    // Draw the old "pdfData" on pdfContext
    CFDataRef myPDFData = (__bridge CFDataRef) pdfData;
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(myPDFData);
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithProvider(provider);
    CGPDFDocumentUnlockWithPassword(pdf, [pass UTF8String]);
    CGDataProviderRelease(provider);
    long pageCount = CGPDFDocumentGetNumberOfPages(pdf);
    coordinatesArray = [[NSMutableArray alloc]init];
    
    for (int k=1; k<=pageCount; k++) {
        
        for (int i = 0; i<arr.count; i++) {
            
            if ([[arr[i] valueForKey:@"SinaturePage"] isEqualToString:@"FIRST"]) {
                pnum = 1;
                // coordinatesRect = CGRectMake([[dict valueForKey:@"Left"]doubleValue], [[dict valueForKey:@"Top"]doubleValue] - 58, 112 , 58);
                [coordinatesArray  addObject:[NSValue valueWithCGRect:CGRectMake([[arr[i] valueForKey:@"Left"]doubleValue], [[arr[i]  valueForKey:@"Top"]doubleValue] - 58,112 , 58)]];
            }
            else if ([[arr[i] valueForKey:@"SinaturePage"] isEqualToString:@"LAST"]) {
                pnum = pageCount;
                // coordinatesRect = CGRectMake([[arr[k] valueForKey:@"Left"]doubleValue], [[arr[k] valueForKey:@"Top"]doubleValue] - 58, 112 , 58);
                [coordinatesArray  addObject:[NSValue valueWithCGRect:CGRectMake([[arr[i] valueForKey:@"Left"]doubleValue], [[arr[i]  valueForKey:@"Top"]doubleValue] - 58,112 , 58)]];
            }
            else if ([[arr[i] valueForKey:@"SinaturePage"] isEqualToString:@"EVEN PAGES"]) {
                if (k%2 == 0) {
                    pnum = k;
                    //                coordinatesRect = CGRectMake([[arr[k] valueForKey:@"Left"]doubleValue], [[arr[k] valueForKey:@"Top"]doubleValue] - 58, 112 , 58);
                    [coordinatesArray  addObject:[NSValue valueWithCGRect:CGRectMake([[array[k] valueForKey:@"Left"]doubleValue], [[array[k]  valueForKey:@"Top"]doubleValue] - 58,112 , 58)]];
                }
            }
            else if ([[arr[i] valueForKey:@"SinaturePage"] isEqualToString:@"ODD PAGES"]) {
                if (k%2 != 0) {
                    pnum = k;
                    //                coordinatesRect = CGRectMake([[arr[k] valueForKey:@"Left"]doubleValue], [[arr[k] valueForKey:@"Top"]doubleValue] - 58, 112 , 58);
                    [coordinatesArray  addObject:[NSValue valueWithCGRect:CGRectMake([[array[k] valueForKey:@"Left"]doubleValue], [[array[k]  valueForKey:@"Top"]doubleValue] - 58,112 , 58)]];
                }
            }
            else if ([[arr[i] valueForKey:@"SinaturePage"] isEqualToString:@"ALL"]) {
                pnum = k;
                //            coordinatesRect = CGRectMake([[arr[k] valueForKey:@"Left"]doubleValue], [[arr[k] valueForKey:@"Top"]doubleValue] - 58, 112 , 58);
                [coordinatesArray  addObject:[NSValue valueWithCGRect:CGRectMake([[arr[i] valueForKey:@"Left"]doubleValue], [[arr[i]  valueForKey:@"Top"]doubleValue] - 58,112 , 58)]];
            }
            else if ([[arr[i] valueForKey:@"SinaturePage"] isEqualToString:@"SPECIFY"]) {
                NSArray* str = [[arr[i] valueForKey:@"PageNo"]componentsSeparatedByString:@","];
                for (int j=0; j<str.count; j++) {
                    
                    if (k == [str[j]intValue])
                    {
                        pnum = k;
                        //                    coordinatesRect = CGRectMake([[arr[k] valueForKey:@"Left"]doubleValue], [[arr[k] valueForKey:@"Top"]doubleValue] - 58, 112 , 58);
                        [coordinatesArray  addObject:[NSValue valueWithCGRect:CGRectMake([[arr[i] valueForKey:@"Left"]doubleValue], [[arr[i]  valueForKey:@"Top"]doubleValue] - 58,112 , 58)]];
                    }
                }
            }
            else if ([[arr[i] valueForKey:@"SinaturePage"] isEqualToString:@"PAGE LEVEL"]) {
                coordinatesArray = [NSMutableArray array];
                for (int i = 0; i< array.count; i++) {
                    
                    if ([[array[i]valueForKey:@"PageNo"]intValue] == k) {
                        pnum = k;//[[array[i]valueForKey:@"PageNo"]intValue];
                        // coordinatesRect = CGRectMake([[array[i] valueForKey:@"Left"]doubleValue], [[array[i]  valueForKey:@"Top"]doubleValue] - 58, 112 , 58);
                        [coordinatesArray  addObject:[NSValue valueWithCGRect:CGRectMake([[array[i] valueForKey:@"Left"]doubleValue], [[array[i]  valueForKey:@"Top"]doubleValue] - 58,112 , 58)]];
                        //[self pageLevel:pdfContext :pdf :k :pnum :coordinatesRect :imgSignature :outputPDFData];
                        // return;
                    }
                    
                }
            }
            
            //for (int i = 0; i<coordinatesArray.count; i++) {
            
            
            CGPDFPageRef page3 = CGPDFDocumentGetPage(pdf, k);
            pageRect = CGPDFPageGetBoxRect(page3, kCGPDFMediaBox);
            CGContextBeginPage(pdfContext, &pageRect);
            CGContextDrawPDFPage(pdfContext, page3);
            
            if (k == pnum) {
                for (int i = 0; i<coordinatesArray.count; i++) {
                    pageRect = [coordinatesArray[i]CGRectValue];
                    // pageRect = coordinatesRect;
                    
                    CGImageRef pageImage = [imgSignature CGImage];
                    CGContextDrawImage(pdfContext, pageRect, pageImage);
                }
            }
            CGPDFContextEndPage(pdfContext);
        }
    }
    //}
    // release the allocated memory
    CGPDFContextEndPage(pdfContext);
    CGPDFContextClose(pdfContext);
    CGContextRelease(pdfContext);
    
    // write new PDFData in "outPutPDF.pdf" file in document directory
    NSString *docsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *pdfFilePath =[NSString stringWithFormat:@"%@/outPutPDF.pdf",docsDirectory];
    [outputPDFData writeToFile:pdfFilePath atomically:YES];
    return pdfFilePath;
    
}

#pragma mark == UIPopoverPresentationControllerDelegate ==
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

#pragma mark - PDF Handlers

#pragma mark ask for password


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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    password = [alertView textFieldAtIndex: 0].text.UTF8String;
    UITextField *emailInput = [alertView textFieldAtIndex:0].text;

    
    [[NSUserDefaults standardUserDefaults] setObject:emailInput forKey:@"Password"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [alertView dismissWithClickedButtonIndex: buttonIndex animated: TRUE];
    if (buttonIndex == 1) {
        if ([self.pdfDocument isLocked]) {
            [self onPasswordOK];
        }
        else
            [self askForPassword: @"Wrong password. Try again:"];
    } else {
        [self stopActivity];
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

- (void) onPasswordOK
{

    NSString *displayName = [[NSUserDefaults standardUserDefaults] valueForKey:@"displayName"];
    
    NSString*  SubscriberId = [[NSUserDefaults standardUserDefaults]valueForKey:@"signOrReviewerText"];
    
    BOOL  isSignatory,isReviewer;
    if ([SubscriberId isEqualToString:@"Sign & Review"]) {
        isSignatory = true;
        isReviewer = true;
    }
    else if([SubscriberId isEqualToString:@"Sign"]){
        isSignatory = true;
    }
    else if([SubscriberId isEqualToString:@"Reviewer"]){
        isReviewer = true;
    }
    
    if (![self.pdfDocument unlockWithPassword:[[NSUserDefaults standardUserDefaults] valueForKey:@"Password"]]) {
        [self askForPassword: @"Wrong password. Try again:"];
        [self stopActivity];
        return;
    }
    
    if (![_parallel isEqualToString:@"1"]) {
        PendingListVC *temp = [[PendingListVC alloc] init];
        
        temp.pdfImagedetail = descriptionStr;
        temp.strExcutedFrom = _strExcutedFrom;
        temp.myTitle = displayName;
        temp.workFlowID = _workFlowId;
        temp.workFlowType = _workFlowType;
        temp.signatoryString = self.mstrXMLString;
        //temp.placeholderArray = _placeholderArray;
        temp.placeholderArray = coordinatesArray;
        temp.signatoryHolderArray =  _signatoryHolderArray;
        temp.statusId = [[[NSUserDefaults standardUserDefaults]valueForKey:@"statusIdForMultiplePdf"]integerValue];
        temp.passwordForPDF = password;
        temp.isSignatory = isSignatory;
        temp.isReviewer = isReviewer;
        [self.navigationController pushViewController:temp animated:YES];
        [self stopActivity];
    }
    else
    {
        ParallelSigning *temp = [[ParallelSigning alloc] init];//WithFilename:path path:path document: doc];
        
        temp._pathForDoc = path;
        temp.pdfImagedetail = descriptionStr;
        temp.myTitle = displayName;
        temp.strExcutedFrom=@"Completed";
        temp.workflowID = _workFlowId;
        temp.documentCount = [[_checkNullArray valueForKey:@"NoOfDocuments"] stringValue];
        temp.signatoryString = _mstrXMLString;
        temp.placeholderArray = coordinatesArray;
        temp.matchSignersList = _signatoryHolderArray;
        temp.passwordForPDF = password;
       // temp.attachmentCount = [[_checkNullArray valueForKey:@"NoOfAttachments"] stringValue];
        [self.navigationController pushViewController:temp animated:YES];
        [self stopActivity];
    }
    
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
