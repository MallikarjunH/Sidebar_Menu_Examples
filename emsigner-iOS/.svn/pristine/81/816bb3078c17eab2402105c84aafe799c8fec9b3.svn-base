//
//  RecallStatusVC.m
//  emSigner
//
//  Created by Administrator on 11/15/16.
//  Copyright © 2016 Emudhra. All rights reserved.
//

#import "RecallStatusVC.h"
#import "WebserviceManager.h"
#import "HoursConstants.h"
#import "MBProgressHUD.h"
#import "NSObject+Activity.h"
#import "DocumentInfoNames.h"
#import "Reachability.h"
#import "ViewController.h"
#import "RecallTableViewCell.h"

#import "DocumentInfoVC.h"
#import "NSString+DateAsAppleTime.h"


@interface RecallStatusVC ()
{
    BOOL hasPresentedAlert;
    NSString *dateCategoryString;
    BOOL isPageRefreshing;
    NSString* searchSting;

}
@end

@implementation RecallStatusVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
   // [self.tableView setContentOffset:CGPointMake(0.0, self.tableView.tableHeaderView.frame.size.height) animated:YES];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.topItem.title = @" ";
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"RecallTableViewCell" bundle:nil] forCellReuseIdentifier:@"RecallTableViewCell"];
    
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:241.0/255.0 alpha:1.0];
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
}

-(void)viewWillAppear:(BOOL)animated
{
   // [self.tableView reloadData];
    _recalledArray = [[NSMutableArray alloc]init];
    _filterArray = [[NSMutableArray alloc]init];
    _currentPage = 1;
    searchSting = @"";
    //EMIOS110
    self.navigationItem.title = @"Recalled";
    [self makeServieCallWithPageNumaber:_currentPage :searchSting];
}

- (void)makeServieCallWithPageNumaber:(NSUInteger)pageNumber:(NSString*)search
{
    /*************************Web Service*******************************/
    
    //Network Check
    if (![self connected])
    {
        if(hasPresentedAlert == false){
            
           // [alert showAlertForNoInternet];


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
        [self startActivity:@"Refreshing"];
        NSString *requestURL = [NSString stringWithFormat:@"%@GetDocumentsByStatus?statusId=%@&PageSize=%lu&searchFilter=%@",kAllDocumetStatusUrl,@"recalled",(unsigned long)pageNumber,search];
        
        [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
            
           // if(status)
                if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

            {
                
                dispatch_async(dispatch_get_main_queue(),
                               ^{
                                  
                                   _recalledArray = [responseValue valueForKey:@"Response"];
                                   
                                   if (_recalledArray != (id)[NSNull null])
                                   {
                                       isPageRefreshing=NO;

                                       _filterSecArray  = [[NSMutableArray alloc]initWithArray:(NSMutableArray*)_recalledArray];
                                       [_filterArray addObjectsFromArray:_filterSecArray];
                                       
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
                                           [self.tableView reloadData];
                                       }
                                       
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
            
          
           // [alert showAlertForNoInternet];
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"No internet connection!"
                                         message:@"Check internet connection!"
                                         preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction * yesButton = [UIAlertAction
                                        actionWithTitle:@"Okay"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                        }];

            [alert addAction:yesButton];

            [self presentViewController:alert animated:YES completion:nil];
            hasPresentedAlert = true;
            [refreshControl endRefreshing];
        }
    }
    else
    {

        refreshControl.attributedTitle = [dateCategoryString refreshForDate];
       // [self makeServieCallWithPageNumaber:0];
        [self makeServieCallWithPageNumaber:0 :searchSting];

        [refreshControl endRefreshing];
    }
    
   /***********************************************************/
   
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
//        [self stopActivity];
//
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
    RecallTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecallTableViewCell" forIndexPath:indexPath];
    
    cell.Lable1.text = [[_filterArray objectAtIndex:indexPath.row] objectForKey:@"DisplayName"];
    
    cell.mName.text = [[_filterArray objectAtIndex:indexPath.row] objectForKey:@"Name"];

    cell.attachmentsImage.hidden = YES;
   // doc-info-1x
    
    if ([[[_filterArray objectAtIndex:indexPath.row] objectForKey:@"Status"] isEqualToString:@"Voided"]) {
        cell.docInfoBtn.imageView.image = [UIImage imageNamed:@" "];
        cell.docInfoBtn.hidden = YES;
    }
    else{
        cell.docInfoBtn.imageView.image = [UIImage imageNamed:@"doc-info-1x"];
        cell.docInfoBtn.tag = indexPath.row;
        [cell.docInfoBtn addTarget:self action:@selector(docInfoBtnClickedRecall:) forControlEvents:UIControlEventTouchUpInside];
    }
    cell.pdfImage.translatesAutoresizingMaskIntoConstraints = YES;
    cell.pdfImage.frame = CGRectMake(0, 0, 0, 0);
    cell.Lable1.translatesAutoresizingMaskIntoConstraints = YES;
    CGRect frame = cell.Lable1.frame;
    frame.origin.x=  cell.pdfImage.frame.origin.x+8;//pass the X cordinate
    cell.Lable1.frame= frame;
    
    NSArray* date= [[[_filterArray objectAtIndex:indexPath.row] objectForKey:@"UploadTime"] componentsSeparatedByString: @" "];
    //NSString* firstBit = [date objectAtIndex: 0];
    
    //NSDate *secondBit = [date objectAtIndex:1];
    
    NSString *dateFromArray = [[_filterArray objectAtIndex:indexPath.row] objectForKey:@"UploadTime"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    NSDate *dates = [formatter dateFromString:dateFromArray];
    
    
    dateCategoryString = [NSString string];

    cell.dateLable.text = [dateCategoryString transformedValue:dates];
    cell.timeLabel.text = [date objectAtIndex:1];

    //InfoButton
//    cell.docInfoBtn.tag = indexPath.row;
//    [cell.docInfoBtn addTarget:self action:@selector(docInfoBtnClickedRecall:) forControlEvents:UIControlEventTouchUpInside];
    _totalRow = [[[_filterArray objectAtIndex:indexPath.row] objectForKey:@"TotalRows"]integerValue];
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
    
    [self startActivity:@"Loading..."];
    
    NSString *requestURL = [NSString stringWithFormat:@"%@GetRecalledRemarks?WorkFlowId=%@",kRecallRemarks,[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkFlowId"]];
    [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
        
      //  if(status)
            if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

        {
            dispatch_async(dispatch_get_main_queue(), ^{
               
                if ([[responseValue valueForKey:@"Response"] isEqual:(id)[NSNull null]]) {
                    UIAlertController * alert = [UIAlertController
                                                 alertControllerWithTitle:@"Recalled Document Remarks"
                                                 message:@"Bulk Documents can't be opened as of now. "
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
                else{
                    _pdfImageArray=[responseValue valueForKey:@"Response"];
                //EMIOS-1110
                    NSString *str;

                    str  = [_pdfImageArray valueForKey:@"Remarks"];
                        
                    
               
                    UIAlertController * alert = [UIAlertController
                                             alertControllerWithTitle:@"Remarks"
                                                 message:str
                                             preferredStyle:UIAlertControllerStyleAlert];
                
                    //Add Buttons
                
                    UIAlertAction* yesButton = [UIAlertAction
                                            actionWithTitle:@"Ok"
                                            style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                //Handle your yes please button action here
                                                
                                            }];
                    
                    [alert addAction:yesButton];
                
                    [self presentViewController:alert animated:YES completion:nil];
                
                    [self stopActivity];
            }
                
            });
        }
        else{
            
        }
        //[hud hideAnimated:YES];
        
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
            //[self makeServieCallWithPageNumaber:_currentPage];
            [self makeServieCallWithPageNumaber:_currentPage :searchSting];
        }
    }
    
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

-(void)docInfoBtnClickedRecall:(UIButton*)sender
{
//                               UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//                               DocumentInfoVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"DocumentInfoVC"];
//                               objTrackOrderVC.docInfoWorkflowId = [[_filterArray objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"];
//                               objTrackOrderVC.status = @"Recalled";
//                               [self.navigationController pushViewController:objTrackOrderVC animated:YES];
    [self getDocumentInfo:[[_filterArray objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"]];

    
//    DocumentInfoNames *objTrackOrderVC= [[DocumentInfoNames alloc] initWithNibName:@"DocumentInfoNames" bundle:nil];
//    objTrackOrderVC.docInfoWorkflowId = [[_filterArray objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"];
//    objTrackOrderVC.status = @"Recalled";
//    [self.navigationController pushViewController:objTrackOrderVC animated:YES];
    
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
                                       
                                        objTrackOrderVC.status = @"Recalled";
                                       [self.navigationController pushViewController:objTrackOrderVC animated:YES];
                                       
                                   }
                                   else{
                                       DocumentInfoNames *objTrackOrderVC= [[DocumentInfoNames alloc] initWithNibName:@"DocumentInfoNames" bundle:nil];
                                       objTrackOrderVC.docInfoWorkflowId = workflowId;
                                       objTrackOrderVC.status = @"Recalled";
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
