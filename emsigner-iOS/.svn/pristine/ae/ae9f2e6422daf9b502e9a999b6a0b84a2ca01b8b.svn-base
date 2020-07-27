//
//  DeclineStatusVC.m
//  emSigner
//
//  Created by Administrator on 11/15/16.
//  Copyright © 2016 Emudhra. All rights reserved.
//

#import "DeclineStatusVC.h"
#import "WebserviceManager.h"
#import "HoursConstants.h"
#import "MBProgressHUD.h"
#import "NSObject+Activity.h"
#import "DocumentInfoNames.h"
#import "Reachability.h"
#import "ViewController.h"
#import "DeclineTableViewCell.h"

#import "DocumentInfoVC.h"

#import "NSString+DateAsAppleTime.h"

@interface DeclineStatusVC ()
{
    BOOL hasPresentedAlert;
    NSString *dateCategoryString;
    BOOL isPageRefreshing;
    BOOL issearchRefreshing;

    NSString* searchSting;

}

@end

@implementation DeclineStatusVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //[self.tableView setContentOffset:CGPointMake(0.0, self.tableView.tableHeaderView.frame.size.height) animated:YES];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.topItem.title = @" ";
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerNib:[UINib nibWithNibName:@"DeclineTableViewCell" bundle:nil] forCellReuseIdentifier:@"DeclineTableViewCell"];
    
//    self.navigationItem.title = @"Declined";
//    [self.navigationController.navigationBar setTitleTextAttributes:
//     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:241.0/255.0 alpha:1.0];
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [self startActivity:@""];
    _filterArray = [[NSMutableArray alloc]init];
     searchSting = @"";
    _currentPage = 1;
    [self makeServieCallWithPageNumaber:_currentPage :searchSting];
   // [self.tableView reloadData];
    
}
- (void)makeServieCallWithPageNumaber:(NSUInteger)pageNumber:(NSString*)search
{
    /*************************Web Service*******************************/
    [self startActivity:@""];
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
        }
    }
    else
    {
       // [self startActivity:@"Refreshing"];
        NSString *requestURL = [NSString stringWithFormat:@"%@GetDocumentsByStatus?statusId=%@&PageSize=%lu&searchFilter=%@",kAllDocumetStatusUrl,@"declined",(unsigned long)pageNumber,search];
        
        
        [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
            
           // if(status)
                if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

            {
                
                dispatch_async(dispatch_get_main_queue(),
                               ^{
                                  
                                   _declineArray = [responseValue valueForKey:@"Response"];
                                   
                                   if (_declineArray != (id)[NSNull null])
                                   {
                                       isPageRefreshing=NO;

                                       _filterSecArrayDeclined  = [[NSMutableArray alloc]initWithArray:(NSMutableArray*)_declineArray];
                                       
                                       [_filterArray addObjectsFromArray:_filterSecArrayDeclined];
                                       
                                       [_tableView reloadData];
                                       
                                       [self stopActivity];
                                   }
                                   else{
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

                                       self.navigationItem.rightBarButtonItem = nil;

                                       [self stopActivity];

                                   }
                                   
                               });
                
            }
            else
            {
                [self stopActivity];
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
                    
               // }
                
           // }
            
        }];
        
    }
    
    /*******************************************************************/
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

        //[self makeServieCallWithPageNumaber:0];
        [_tableView reloadData];
        [refreshControl endRefreshing];
        //
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
//
        [self stopActivity];
//        //hide right bar button item if there is no data
//        self.navigationItem.rightBarButtonItem = nil;
    }
    
    return numOfSections;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (!_filterArray) {
        
        UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
        noDataLabel.text             = @"You do not have any files";
        noDataLabel.textColor        = [UIColor grayColor];
        noDataLabel.textAlignment    = NSTextAlignmentCenter;
        self.tableView.backgroundView = noDataLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return nil;
    }
    else
    {
        return [_filterArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DeclineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeclineTableViewCell" forIndexPath:indexPath];
    
    _totalRow = [[[_filterArray objectAtIndex:indexPath.row] objectForKey:@"TotalRows"]integerValue];
   
    cell.documentName.text = [[_filterArray objectAtIndex:indexPath.row] objectForKey:@"DisplayName"];
    cell.profileName.text = [[_filterArray objectAtIndex:indexPath.row] objectForKey:@"Name"];
   // cell.numberOfAttachmentsLabel.text = [[[_filterArray objectAtIndex:indexPath.row] objectForKey:@"NoofAttachment"]stringValue];
    cell.docInfoBtn.imageView.image = [UIImage imageNamed:@"doc-info-1x"];

    cell.declineImage.translatesAutoresizingMaskIntoConstraints = YES;
    cell.declineImage.frame = CGRectMake(0, 0, 0, 0);
    cell.documentName.translatesAutoresizingMaskIntoConstraints = YES;
    
    CGRect frame = cell.documentName.frame;
    frame.origin.x=  cell.declineImage.frame.origin.x+8;//pass the X cordinate
    cell.documentName.frame= frame;
    
    NSString *numberOfAttachmentString = [[[_filterArray objectAtIndex:indexPath.row] objectForKey:@"NoofAttachment"]stringValue];
    
   // if ([numberOfAttachmentString isEqualToString:@"0"]) {
      //  cell.numberOfAttachmentsLabel.hidden = YES;
        cell.attachmentsImage.hidden = YES;
    //}
  //  else cell.numberOfAttachmentsLabel.text = [[[_filterArray objectAtIndex:indexPath.row] objectForKey:@"NoofAttachment"]stringValue];
    
    NSArray* date= [[[_filterArray objectAtIndex:indexPath.row] objectForKey:@"UploadTime"] componentsSeparatedByString: @" "];
   // NSString* firstBit = [date objectAtIndex: 0];
    
   // cell.dateLable.text = firstBit;
    
    
//    NSDate* firstBit = [date objectAtIndex: 0];
//    NSDate *secondBit = [date objectAtIndex:1];
    
    NSString *dateFromArray = [[_filterArray objectAtIndex:indexPath.row] objectForKey:@"UploadTime"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    NSDate *dates = [formatter dateFromString:dateFromArray];
    
//    NSDate *currentDate = [NSDate date];
//    NSDateFormatter *formatters = [[NSDateFormatter alloc] init];
//    [formatters setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
//
//    NSCalendar *cal = [NSCalendar currentCalendar];
//    NSDateComponents *components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
//    components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:dates];
//
//    BOOL todays = [[NSCalendar currentCalendar] isDateInToday:dates];
//    BOOL isYesterday = [cal isDateInYesterday:dates];
//    BOOL isweekDay = [cal isDateInWeekend:dates];
//
//    if(todays == YES)
//    {
//        cell.dateLable.text =[NSString stringWithFormat:@"%@", secondBit];// secondBit;
//
//    }
//
//    // BOOL isYesterday = [cal isDateInYesterday:dates];
//    else if (isYesterday == YES) {
//        cell.dateLable.text = @"Yesterday";
//
//    }
//
//    else if (isweekDay) {
//        NSInteger weekday = [cal component:NSCalendarUnitWeekday fromDate:dates];
//        NSString *day = [[formatter weekdaySymbols] objectAtIndex:weekday];
//        cell.dateLable.text = day;
//    }
//
//    else
    
    dateCategoryString = [NSString string];
    cell.dateLable.text = [dateCategoryString transformedValue:dates];
    cell.timeLabel.text = [date objectAtIndex:1];
    //[NSString stringWithFormat:@"%@", firstBit];
    
    //
    
    //InfoButton
    cell.docInfoBtn.tag = indexPath.row;
    [cell.docInfoBtn addTarget:self action:@selector(docInfoBtnClickedDeclined:) forControlEvents:UIControlEventTouchUpInside];
    //
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
    
    //************************Web Service******************************
    
    
    [self startActivity:@"Loading..."];
    
    NSString *requestURL = [NSString stringWithFormat:@"%@GetDeclinedRemarks?WorkFlowId=%@",kDeclineRemarks,[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkFlowId"]];
    [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
        
           // if(status)
                if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

            {
                 dispatch_async(dispatch_get_main_queue(), ^{
                _pdfImageArray=[responseValue valueForKey:@"Response"];
                     
                     NSString *resp = [NSString stringWithFormat:@"Declined By %@",[_pdfImageArray valueForKey:@"DeclinedBy"]];
                
                     UIAlertController * alert = [UIAlertController
                                                  alertControllerWithTitle:@"Declined Document Remarks"
                                                  message:resp
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
                //[_pendingTableView reloadData];
                });
            }
            else{
                
            }
        
            //[hud hideAnimated:YES];
       
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
//
//    }
    
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


-(void)docInfoBtnClickedDeclined:(UIButton*)sender
{
    
//    UIAlertController * view=   [UIAlertController
//                                 alertControllerWithTitle:@" "
//                                 message:@"Please select your choice"
//                                 preferredStyle:UIAlertControllerStyleActionSheet];
//    UIAlertAction* Info = [UIAlertAction
//                           actionWithTitle:@"Document Info"
//                           style:UIAlertActionStyleDefault
//                           handler:^(UIAlertAction * action)
//                           {
//                               //Do some thing here
//
//                               UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//                               DocumentInfoVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"DocumentInfoVC"];
//                               objTrackOrderVC.docInfoWorkflowId = [[_filterArray objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"];
//                               objTrackOrderVC.status = @"Declined";
//                               [self.navigationController pushViewController:objTrackOrderVC animated:YES];
    
    
    
//    DocumentInfoNames *objTrackOrderVC= [[DocumentInfoNames alloc] initWithNibName:@"DocumentInfoNames" bundle:nil];
//    objTrackOrderVC.docInfoWorkflowId = [[_filterArray objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"];
//    objTrackOrderVC.status = @"Declined";
//    [self.navigationController pushViewController:objTrackOrderVC animated:YES];
    
    [self getDocumentInfo:[[_filterArray objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"]];

//                           }];
//
//    UIAlertAction* cancel = [UIAlertAction
//                             actionWithTitle:@"cancel"
//                             style:UIAlertActionStyleDestructive
//                             handler:^(UIAlertAction * action)
//                             {
//                                 [view dismissViewControllerAnimated:YES completion:nil];
//                             }];
//
//    [Info setValue:[[UIImage imageNamed:@"information-outline-2.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
//    [Info setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
//    [view addAction:Info];
//    [view addAction:cancel];
//
//    [self presentViewController:view animated:YES completion:nil];
    
}


-(void)getDocumentInfo:(NSString*)workflowId

{
    
    [self startActivity:@"Loading.."];
    NSString *requestURL = [NSString stringWithFormat:@"%@GetDocumentInfo?WorkFlowId=%@",kDocumentInfo,workflowId];
    
    [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
        
      //  if(status)
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
    if ([searchText length] >= 3)
    {
       // isPageRefreshing=NO;

           // if(isPageRefreshing==NO){
          //  isPageRefreshing=YES;
            [_filterArray removeAllObjects];
            
            _currentPage = 1;
            searchSting = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            //searchSting = searchText;
            [self makeServieCallWithPageNumaber:_currentPage :searchSting];
            
       // }
        [_tableView reloadData];
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
