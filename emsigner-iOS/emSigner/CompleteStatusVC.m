//
//  CompleteStatusVC.m
//  emSigner
//
//  Created by Administrator on 11/15/16.
//  Copyright © 2016 Emudhra. All rights reserved.
//

#import "CompleteStatusVC.h"
#import "WebserviceManager.h"
#import "HoursConstants.h"
#import "MBProgressHUD.h"
#import "NSObject+Activity.h"
#import "DocumentInfoNames.h"
#import "Reachability.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "PendingVCTableViewCell.h"
#import "CommentsController.h"
#import "ShareVC.h"
#import "NSString+DateAsAppleTime.h"
#import "DocumentInfoVC.h"
#import "BulkDocVC.h"

@interface CompleteStatusVC ()
{
    BOOL hasPresentedAlert;
    int currentPreviewIndex;
    NSMutableString * mstrXMLString;
    NSString* documentId;
    NSString *dateCategoryString;
    BOOL isPageRefreshing;
    NSString* searchSting;
    const char *password;

}
@property (nonatomic, strong) UITextView *shareTextView;
@end

@implementation CompleteStatusVC


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
   
    //Empty cell keep blank
   // [self.tableView setContentOffset:CGPointMake(0.0, self.tableView.tableHeaderView.frame.size.height) animated:YES];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.topItem.title = @" ";
    _addFile = [[NSMutableArray alloc] init];

    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    _completedArray = [[NSMutableArray alloc] init];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PendingVCTableViewCell" bundle:nil] forCellReuseIdentifier:@"PendingVCTableViewCell"];
    self.navigationItem.title = @"Completed";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:241.0/255.0 alpha:1.0];
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    //[self makeServieCallWithPageNumaber:0];

    //[self startActivity:@"Refreshing"];
}

- (void)makeServieCallWithPageNumaber:(NSUInteger)pageNumber:(NSString*)search
{
    /*************************Web Service*******************************/
    [self startActivity:@"Refreshing"];

    //Network Check
    if (![self connected])
    {
        if(hasPresentedAlert == false){
            
            // not connected
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"No internet connection!"
                                         message:@"Check internet connection!"
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            //Add Buttons
            
            UIAlertAction* yesButton = [UIAlertAction
                                        actionWithTitle:@"Okay"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            //Handle your yes please button action here
                                            
                                        }];
            
            //Add your buttons to alert controller
            
            [alert addAction:yesButton];
            
            [self presentViewController:alert animated:YES completion:nil];
            hasPresentedAlert = true;
        }
    }
    else
    {
        if (self.filterArray == nil) {
            self.filterArray = [[NSMutableArray alloc] init];
        }
        

        NSString *requestURL = [NSString stringWithFormat:@"%@GetDocumentsByStatus?statusId=%@&PageSize=%lu&searchFilter=%@",kAllDocumetStatusUrl,@"completed",(unsigned long)pageNumber,search];
        
        [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
            
         //   if(status)
                if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

            {
                
                dispatch_async(dispatch_get_main_queue(),
                               ^{
                                  // [self startActivity:@"Refreshing"];
                                   _completedArray = [responseValue valueForKey:@"Response"];
                                   
                                   if (_completedArray != (id)[NSNull null])
                                   {
                                       isPageRefreshing=NO;

                                      _filterSecondArray  = [[NSMutableArray alloc]initWithArray:(NSMutableArray*)_completedArray];
                                       [_filterArray addObjectsFromArray:_filterSecondArray];
                                       [_tableView reloadData];
                                       
                                       [self stopActivity];
                                   }
                                   else
                                   {
                                       
                                     
                                       if (_filterArray.count == 0) {
                                           
                                           UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
                                           noDataLabel.text             = @"You do not have any files";
                                           noDataLabel.textColor        = [UIColor grayColor];
                                           noDataLabel.textAlignment    = NSTextAlignmentCenter;
                                           self.tableView.backgroundView = noDataLabel;
                                           self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                                           
                                           //hide right bar button item if there is no data
                                           self.navigationItem.rightBarButtonItem = nil;
                                           [_filterArray removeAllObjects];
                                            [_tableView reloadData];
                                           [self stopActivity];
                                       }
//                                       UIAlertController * alert = [UIAlertController
//                                                                    alertControllerWithTitle:@""
//                                                                    message:[[responseValue valueForKey:@"Messages"] objectAtIndex:0]
//                                                                    preferredStyle:UIAlertControllerStyleAlert];
//
//                                       //Add Buttons
//
//                                       UIAlertAction* yesButton = [UIAlertAction
//                                                                   actionWithTitle:@"Ok"
//                                                                   style:UIAlertActionStyleDefault
//                                                                   handler:^(UIAlertAction * action) {
//
//                                                                       //
//                                                                   }];
//
                                       //Add your buttons to alert controller
                                       
                                       //[alert addAction:yesButton];
                                       //[alert addAction:noButton];
                                       
                                      // [self presentViewController:alert animated:YES completion:nil];
                                      [self stopActivity];
                                   }
                                   
                               });
                
            }
            else{
                
                dispatch_async(dispatch_get_main_queue(),
                               ^{
                                   if (_filterArray.count == 0) {
                                       
                                       UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
                                       noDataLabel.text             = @"You do not have any files";
                                       noDataLabel.textColor        = [UIColor grayColor];
                                       noDataLabel.textAlignment    = NSTextAlignmentCenter;
                                       self.tableView.backgroundView = noDataLabel;
                                       self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                                       
                                       //hide right bar button item if there is no data
                                       self.navigationItem.rightBarButtonItem = nil;
                                       
                                       [_filterArray removeAllObjects];
                                       [self.tableView reloadData];
                                   }
                                   [self stopActivity];
                               });
            }
        
    }
    
    /*******************************************************************/
];
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    self.title = @"Completed";
    self.navigationItem.title = @"Completed";
    [self startActivity:@"Refreshing"];
    _filterArray = [[NSMutableArray alloc]init];

    _currentPage = 1;
    searchSting = @"";

    [self makeServieCallWithPageNumaber:_currentPage :searchSting];
   // [self stopActivity];
}

- (void)refresh:(UIRefreshControl *)refreshControl
{
    
    //Network Check
    if (![self connected])
    {
        if(hasPresentedAlert == false){
            
            // not connected
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No internet connection!" message:@"Check internet connection!" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
//            [alert show];
            
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"No internet connection!"
                                         message:@"Check internet connection!"
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            //Add Buttons
            
            UIAlertAction* yesButton = [UIAlertAction
                                        actionWithTitle:@"Okay"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            //Handle your yes please button action here
                                            
                                        }];
            
            //Add your buttons to alert controller
            
            [alert addAction:yesButton];
            
            [self presentViewController:alert animated:YES completion:nil];

            hasPresentedAlert = true;
            [refreshControl endRefreshing];
        }
    }
    else
    {
        
        refreshControl.attributedTitle = [dateCategoryString refreshForDate];

        [self makeServieCallWithPageNumaber:0 :searchSting];
        [self stopActivity];
        [refreshControl endRefreshing];
 
    }
    
       /*******************************************************************/
    
}

//Network Connection Checks
- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    NSInteger numOfSections = 0;
    if ([self.filterArray count]>0)
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        numOfSections                = 1;
        self.tableView.backgroundView = nil;
    }
    else
    {
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_filterArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PendingVCTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PendingVCTableViewCell" forIndexPath:indexPath];
    
    _totalRow = [[[_filterArray objectAtIndex:indexPath.row] objectForKey:@"TotalRows"]integerValue];
    cell.documentName.text = [[_filterArray objectAtIndex:indexPath.row] objectForKey:@"DisplayName"];
     cell.ownerName.text  = [[_filterArray objectAtIndex:indexPath.row] objectForKey:@"Name"];
    //cell.numberOfAttachmentsLabel.hidden = YES;
    
    cell.pdfImage.translatesAutoresizingMaskIntoConstraints = YES;
    cell.pdfImage.frame = CGRectMake(0, 0, 0, 0);
    cell.documentName.translatesAutoresizingMaskIntoConstraints = YES;
    CGRect frame = cell.documentName.frame;
    frame.origin.x=  cell.pdfImage.frame.origin.x+8;//pass the X cordinate
    cell.documentName.frame= frame;
    
    long numberOfAttachmentString = [[[_filterArray objectAtIndex:indexPath.row] objectForKey:@"NoofAttachment"]intValue];
    
    if (numberOfAttachmentString == 0) {
       // cell.numberOfAttachments.text = @"";
        cell.attachmentsImage.image = [UIImage imageNamed:@""];
    }
    else {
        //cell.numberOfAttachments.text = [[[_filterArray objectAtIndex:indexPath.row] objectForKey:@"NoofAttachment"]stringValue];
        cell.attachmentsImage.image = [UIImage imageNamed:@"attachment-1x"];
    }
    
    
    //hide images for workflows and reviewer
    
    if ([[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue] == 2 || [[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue] == 5 )
    {
        cell.docInfoBtn.hidden = YES;
        
    }
    else{
        cell.docInfoBtn.hidden = NO;
        
    }


    NSArray* date= [[[_filterArray objectAtIndex:indexPath.row] objectForKey:@"UploadTime"] componentsSeparatedByString: @" "];
    //NSString* firstBit = [date objectAtIndex: 0];
    //cell.dateLable.text = firstBit;
    
   // NSDate* firstBit = [date objectAtIndex: 0];
   // NSDate *secondBit = [date objectAtIndex:1];
    
    NSString *dateFromArray = [[_filterArray objectAtIndex:indexPath.row] objectForKey:@"UploadTime"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    NSDate *dates = [formatter dateFromString:dateFromArray];

    dateCategoryString = [NSString string];
    cell.dateLable.text = [dateCategoryString transformedValue:dates];
    cell.timeLabel.text = [date objectAtIndex:1];
    //[NSString stringWithFormat:@"%@", firstBit];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    //InfoButton
    cell.docInfoBtn.tag = indexPath.row;
    [cell.docInfoBtn addTarget:self action:@selector(docInfoBtnClickedComplted:) forControlEvents:UIControlEventTouchUpInside];
    
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
//            return [NSString stringWithString:@""];
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
//            return [NSString stringWithString:@"Yesterday"];
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
    return 61.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    /*************************Web Service*******************************/
   
    //Saving Document Name
    NSString *compltedDocumentName =[[_filterArray objectAtIndex:indexPath.row] objectForKey:@"DisplayName"];
    [[NSUserDefaults standardUserDefaults] setObject:compltedDocumentName forKey:@"CompltedDisplayName"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self startActivity:@"Loading..."];
    
    if ([[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue] == 2)
    {
        [self alertForFlexiforms];
        return ;
    }
    
    //workflow type 4
    
    if ([[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue] == 4 ) {
                  //Call API
                //EMIOS-1098
                 [self GetBulkDocuments:[NSString stringWithFormat:@"%ld",(long)[[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"LotId"]integerValue]] workflowType:[NSString stringWithFormat:@"%ld",(long)[[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue]]];
              }
    
    //workflow type 5
    if ([[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue] == 5)
    {
        [self alertForCollaborative];
        return;
    }
    _workFlowType = [[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"];
    
    NSString *requestURL = [NSString stringWithFormat:@"%@GetDocumentDetailsById?workFlowId=%@&workflowType=%@",kOpenPDFImage,[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkFlowId"],[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]];
    [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
        
        if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                _pdfImageArray=[[responseValue valueForKey:@"Response"] valueForKey:@"Document"];
                    
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
                            
                            
                            NSData *data = [[NSData alloc]initWithBase64EncodedString:_pdfImageArray options:0];
                            // from your converted Base64 string
                            NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
                            NSString *path = [documentsDirectory stringByAppendingPathComponent:@"test.pdf"];
                            [data writeToFile:path atomically:YES];
                            
                            [[NSUserDefaults standardUserDefaults] setObject:path forKey:@"pathForDoc"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            
                            NSString *displayName = [[_filterArray objectAtIndex:indexPath.row] objectForKey:@"DisplayName"];
                            [[NSUserDefaults standardUserDefaults] setObject:displayName forKey:@"displayName"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            
                            documentId = [[_filterArray objectAtIndex:indexPath.row] objectForKey:@"DocumentId"];
                            
                            NSString *docCount = [[[responseValue valueForKey:@"Response"] valueForKey:@"NoOfDocuments"] stringValue];
                            [[NSUserDefaults standardUserDefaults] setObject:docCount forKey:@"docCount"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            
                            NSString *attachmentCount = [[[responseValue valueForKey:@"Response"] valueForKey:@"NoOfAttachments"] stringValue];
                            [[NSUserDefaults standardUserDefaults] setObject:attachmentCount forKey:@"attachmentCount"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            
                            NSString *workflowId = [[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkFlowId"];
                            [[NSUserDefaults standardUserDefaults] setObject:workflowId forKey:@"workflowId"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            
                            self.pdfDocument = [[PDFDocument alloc] initWithData:data];

                            
                            if ([self.pdfDocument isLocked]) {
                                UIAlertView *passwordAlertView = [[UIAlertView alloc]initWithTitle: @"Password Protected"
                                                                                           message: [NSString stringWithFormat: @"%@ %@", displayName, @"is password protected"]
                                                                                          delegate: self
                                                                                 cancelButtonTitle: @"Cancel"
                                                                                 otherButtonTitles: @"Done", nil];
                                passwordAlertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
                                [passwordAlertView show];
                            
                                
                            }
                            
                            [self stopActivity];
                            return;
                        }
                        
                        NSData *data = [[NSData alloc]initWithBase64EncodedString:_pdfImageArray options:0];
                        // from your converted Base64 string
                        NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
                        NSString *path = [documentsDirectory stringByAppendingPathComponent:@"test.pdf"];
                        [data writeToFile:path atomically:YES];
                        
                       
                        
                        CompletedNextVC *temp = [[CompletedNextVC alloc] init];//WithFilename:path path:path document: doc];
                        
                        temp._pathForDoc = path;
                        temp.pdfImagedetail = _pdfImageArray;
                        temp.myTitle = [[_filterArray objectAtIndex:indexPath.row] objectForKey:@"DisplayName"];
                        temp.strExcutedFrom=@"Completed";
                        temp.workflowID = [[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkFlowId"];
                       temp.documentID = [[[responseValue valueForKey:@"Response"] valueForKey:@"DocumentId"]objectAtIndex:0];
                        temp.documentCount = [[[responseValue valueForKey:@"Response"] valueForKey:@"NoOfAttachments"] stringValue];
                        temp.signatoryString = mstrXMLString;
                        temp.workFlowType = _workFlowType;
                        temp.attachmentCount = [[[responseValue valueForKey:@"Response"] valueForKey:@"NoOfAttachments"] stringValue];
                        [self.navigationController pushViewController:temp animated:YES];
                        [self stopActivity];
                    }
                    else
                    {
//                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message: @"This file was corrupted. Please contact eMudhra for more details." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//                        [alert show];
                        UIAlertController * alert = [UIAlertController
                                                     alertControllerWithTitle:@"Error"
                                                     message:@"This file was corrupted. Please contact eMudhra for more details."
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
                        dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self presentViewController:alert animated:YES completion:nil];
                            [self stopActivity];});
                        
                    }
                });
            }
            else{

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
                
                [alert addAction:yesButton];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:alert animated:YES completion:nil];
                    [self stopActivity];});
                
            }
        
    }];
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    // Check scrolled percentage
//    CGFloat yOffset = tableView.contentOffset.y;
//    CGFloat height = tableView.contentSize.height - tableView.frame.size.height;
//    CGFloat scrolledPercentage = yOffset / height;
//
//    // Check if all the conditions are met to allow loading the next page
//    if (scrolledPercentage > .6f){
//        // This is the bottom of the table view, load more data here.
//        if (_totalRow > self.filterArray.count) {
//            _currentPage+= 10;
//            [self makeServieCallWithPageNumaber:_currentPage];
//            [self stopActivity];
//        }
//        else{
//            // _currentPage = nil;
//        }
//
//    }
    
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
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat yOffset = _tableView.contentOffset.y;
    CGFloat height = _tableView.contentSize.height - _tableView.bounds.size.height;
    if(yOffset >= height)
    {
        if(isPageRefreshing==NO){
            isPageRefreshing=YES;
            _currentPage+=1;
            [self makeServieCallWithPageNumaber:_currentPage :searchSting];
            //[self callPageNumbers:_currentPage];
        }
    }
}

-(void)docInfoBtnClickedComplted:(UIButton*)sender
{
    UIAlertController * view=   [[UIAlertController
                                  alloc]init];
    UIAlertAction* Info = [UIAlertAction
                           actionWithTitle:@"View Document Information"
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
                           {
                               //Do some thing here
                               

                               
                               [self getDocumentInfo:[[_filterArray objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"]];

                               
                           }];
    UIAlertAction* DocLog = [UIAlertAction
                              actionWithTitle:@"Document Log"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                  DocumentLogVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"DocumentLogVC"];
                                  objTrackOrderVC.workflowID = [[_filterArray objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"] ;
                                  [self.navigationController pushViewController:objTrackOrderVC animated:YES];
                                  
                              }];
    UIAlertAction* Comments = [UIAlertAction
                               actionWithTitle:@"Comments"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                   CommentsController *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"CommentsController"];
                                   
                                   objTrackOrderVC.workflowID = [[_filterArray objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"];
                                   [self.navigationController pushViewController:objTrackOrderVC animated:YES];
                               }];
    
    UIAlertAction* Download = [UIAlertAction
                             actionWithTitle:@"Download Document"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
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
                                                                 
                                                                 NSString *requestURL = [NSString stringWithFormat:@"%@DownloadWorkflowDocuments?WorkFlowId=%@",kDownloadPdf, [[_filterArray objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"] ];
                                                                 [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
                                                                     
                                                                   // if(status)
                                                                         if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

                                                                     {
                                                                         
                                                                        
                                                                         
                                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                                             
                                                                         NSArray* _pdfImageArray=[responseValue valueForKey:@"Response"];
                                                                             
                                                                             if (_pdfImageArray != (id)[NSNull null])
                                                                             {
                                                                                [_addFile removeAllObjects];
                                                                                 for(int i=0; i<[_pdfImageArray count];i++)
                                                                                 {
                                                                                     
                                                                              NSString* _pdfFileName = [[_pdfImageArray objectAtIndex:i] objectForKey:@"DocumentName"];
                                                                              //EMIOS-1109
                                                                                     NSString*  _pdfFiledata = [[_pdfImageArray objectAtIndex:i] objectForKey:@"Base64FileData"];
                                                                                     
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
                                                       // [self presentModalViewController:previewController animated:YES];
                                                                                        
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
                                                                     [self stopActivity];
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
                                 
                             }];
    UIAlertAction* Share = [UIAlertAction
                               actionWithTitle:@"Share Document"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                               NSString *pendingdocumentName =[[_filterArray objectAtIndex:sender.tag] valueForKey:@"DisplayName"];
                                                documentId = [[_filterArray objectAtIndex:sender.tag] valueForKey:@"DocumentId"];
                                               NSString *pendingWorkflowID =[[_filterArray objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"];
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
                                    
        [self showModals:UIModalPresentationFullScreen style:[MPBCustomStyleSignatureViewController alloc] Lot:[[_filterArray objectAtIndex:sender.tag] valueForKey:@"LotId"]];
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
              NSString *requestURL = [NSString stringWithFormat:@"%@BulkDownload?lotId=%@",kbulkDownload,[[_filterArray objectAtIndex:sender.tag] valueForKey:@"LotId"]];
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
    [DocLog setValue:[[UIImage imageNamed:@"stack-exchange.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [Download setValue:[[UIImage imageNamed:@"download.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [Share setValue:[[UIImage imageNamed:@"share-variant.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [Comments setValue:[[UIImage imageNamed:@"comments"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];

    //[Info setValue:[UIColor greenColor] forKey:@"titleTextColor"];
    
    [Info setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    [DocLog setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    [Download setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    [Share setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    [Comments setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
//EMIOS1109
    if ([[[_filterArray objectAtIndex:sender.tag] valueForKey:@"LotId"]intValue] != 0){
          //[view addAction:BulkSign];
          [view addAction:BulkDocuments];
    } else {
          [view addAction:Info];
          [view addAction:DocLog];
          [view addAction:Download];
          [view addAction:Share];
          [view addAction:Comments];
    }
     
     [view addAction:cancel];
    view.view.tintColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
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
                                            //[self showImage: signature];
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
    
    [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue)
    {
        
       // if(status)
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
    _filterArray = [NSMutableArray array];
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
            [_filterArray removeAllObjects];
            
            _currentPage = 1;
            searchSting = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            //searchSting = searchText;
            [self makeServieCallWithPageNumaber:_currentPage :searchSting];
            
        }
        [_tableView reloadData];
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


#pragma mark ask for password


- (void)openDocument:(NSString *)file
{
    if ([self.pdfDocument isLocked]) {
        //[self askForPassword:@"'%@' needs a password:"];
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
    else{
        [self stopActivity];
    }
    
}

- (void)onPasswordOK
{
    NSString *path  = [[NSUserDefaults standardUserDefaults] valueForKey:@"pathForDoc"];
    NSString *displayName = [[NSUserDefaults standardUserDefaults] valueForKey:@"displayName"];
    NSString *docCount = [[NSUserDefaults standardUserDefaults] valueForKey:@"docCount"];
    NSString *attachmentCount = [[NSUserDefaults standardUserDefaults] valueForKey:@"attachmentCount"];
    NSString *workflowId = [[NSUserDefaults standardUserDefaults] valueForKey:@"workflowId"];
    
    if (![self.pdfDocument unlockWithPassword:[[NSUserDefaults standardUserDefaults] valueForKey:@"Password"]]) {
        [self askForPassword: @"Wrong password. Try again:"];
        [self stopActivity];
        return;
    }

    CompletedNextVC *temp = [[CompletedNextVC alloc] init];//WithFilename:path path:path document: doc];
    temp.pdfImagedetail = _pdfImageArray;
    temp.myTitle = displayName;
    temp.strExcutedFrom=@"Completed";
    temp.workflowID = workflowId;
    temp.documentCount = docCount;
    temp.attachmentCount = attachmentCount;
    temp.signatoryString = mstrXMLString;
    temp.passwordForPDF = password;
    [self.navigationController pushViewController:temp animated:YES];
    [self stopActivity];
    
}

#pragma mark - data source(Preview)

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return [_addFile count];
    
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
