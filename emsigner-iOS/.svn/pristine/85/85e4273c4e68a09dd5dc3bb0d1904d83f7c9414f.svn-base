//
//  CoSignPendingVC.m
//  emSigner
//
//  Created by Administrator on 7/15/16.
//  Copyright © 2016 Emudhra. All rights reserved.
//

#import "CoSignPendingVC.h"
#import "WebserviceManager.h"
#import "HoursConstants.h"
#import "MBProgressHUD.h"
#import "NSObject+Activity.h"
#import "Reachability.h"
#import "AppDelegate.h"
#import "ShareVC.h"
#import "ViewController.h"

#import "NSString+DateAsAppleTime.h"


@interface CoSignPendingVC ()
{
    BOOL hasPresentedAlert;
    NSString *dateCategoryString;

}

@end

@implementation CoSignPendingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _draftToolbar.hidden = YES;
    
    // Do any additional setup after loading the view from its nib.
    [self.tableView setContentOffset:CGPointMake(0.0, self.tableView.tableHeaderView.frame.size.height) animated:YES];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerNib:[UINib nibWithNibName:@"NotStartedTableViewCell" bundle:nil] forCellReuseIdentifier:@"NotStartedTableViewCell"];
    _filterItem = [[NSMutableArray alloc]init];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:241.0/255.0 alpha:1.0];
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    [self makeServieCallWithPageNumaber:0];
    
    
}

- (void)makeServieCallWithPageNumaber:(NSUInteger)pageNumber
{
    /*************************Web Service*******************************/
    
    [self startActivity:@"Refreshing"];
    NSString *requestURL = [NSString stringWithFormat:@"%@GetDocumentsByStatus?statusId=%@&PageSize=%lu",kAllDocumetStatusUrl,@"drafts",(unsigned long)pageNumber];
    
    [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
        
       // if(status)
            if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

        {
            
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                              
                               _draftArray = [responseValue valueForKey:@"Response"];
                               
                               if (_draftArray != (id)[NSNull null])
                               {
                                   _filterItem = [[NSMutableArray alloc]initWithArray:(NSMutableArray*)_draftArray];
                                   
                                   [_filterArray addObjectsFromArray:_filterItem];
                                   [_tableView reloadData];
                                   
                                   [self stopActivity];
                               }
                               else{
//                                   UIAlertController * alert = [UIAlertController
//                                                                alertControllerWithTitle:@""
//                                                                message:[[responseValue valueForKey:@"Messages"] objectAtIndex:0]
//                                                                preferredStyle:UIAlertControllerStyleAlert];
//                                   
//                                   //Add Buttons
//                                   
//                                   UIAlertAction* yesButton = [UIAlertAction
//                                                               actionWithTitle:@"Ok"
//                                                               style:UIAlertActionStyleDefault
//                                                               handler:^(UIAlertAction * action) {
//                                                                   
//                                                                   //
//                                                               }];
//                                   
//                                   //Add your buttons to alert controller
//                                   
//                                   [alert addAction:yesButton];
//                                   //[alert addAction:noButton];
//                                   
//                                   [self presentViewController:alert animated:YES completion:nil];
                                   [self stopActivity];
                               }
                              
                           });
            
        }
        else{
           
                    
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
               // }
                
            //}
            
        }
        
    }];
    /*******************************************************************/
}

- (void)refresh:(UIRefreshControl *)refreshControl
{
    
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
            [refreshControl endRefreshing];
        }
    }
    else
    {

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor grayColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        refreshControl.attributedTitle = attributedTitle;
        //
        //
        [self makeServieCallWithPageNumaber:0];
        //
        [self stopActivity];
        [refreshControl endRefreshing];
        /*******************************************************************/
    }
    
}

//Network Connection Checks
- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   //[self makeServieCallWithPageNumaber:0];
    _draftToolbar.hidden = YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    NSInteger numOfSections = 0;
    if ([self.filterItem count]>0)
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        numOfSections                = 1;
        self.tableView.backgroundView = nil;
    }
    else
    {
        UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
        noDataLabel.text             = @"No documents available";
        noDataLabel.textColor        = [UIColor grayColor];
        noDataLabel.textAlignment    = NSTextAlignmentCenter;
        self.tableView.backgroundView = noDataLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        //hide right bar button item if there is no data
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    return numOfSections;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_filterItem count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotStartedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotStartedTableViewCell" forIndexPath:indexPath];
    
    
//    //Date Formatter
//    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
//    
//    NSDate *date = [dateFormat dateFromString: [[_filterItem objectAtIndex:indexPath.row] objectForKey:@"UploadTime"]];
//    NSDateFormatter *newDateFormatter = [[NSDateFormatter alloc]init];
//    [newDateFormatter setDateFormat:@"dd-MM-yyyy"];
//    NSString *newString = [newDateFormatter stringFromDate:date];
//    NSLog(@"Date: %@, formatted date: %@", date, newString);
//    //
    
    cell.mLable1.text = [[_filterItem objectAtIndex:indexPath.row] objectForKey:@"DisplayName"];
    
    cell.mName.text = [[_filterItem objectAtIndex:indexPath.row] objectForKey:@"Name"];
    
    NSArray* date= [[[_filterItem objectAtIndex:indexPath.row] objectForKey:@"UploadTime"] componentsSeparatedByString: @" "];
   // NSString* firstBit = [date objectAtIndex: 0];
    //cell.mdate.text = firstBit;
    
    NSDate* firstBit = [date objectAtIndex: 0];
    NSDate *secondBit = [date objectAtIndex:1];
    
    NSString *dateFromArray = [[_filterItem objectAtIndex:indexPath.row] objectForKey:@"UploadTime"];
    
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
//        cell.mdate.text =[NSString stringWithFormat:@"%@", secondBit];// secondBit;
//
//    }
//
//    // BOOL isYesterday = [cal isDateInYesterday:dates];
//    else if (isYesterday == YES) {
//         cell.mdate.text = @"Yesterday";
//
//    }
//
////    else if (isweekDay) {
////        NSInteger weekday = [cal component:NSCalendarUnitWeekday fromDate:dates];
////        NSString *day = [[formatter weekdaySymbols] objectAtIndex:weekday];
////        cell.mdate.text = day;
////    }
//
//    else
    
    dateCategoryString = [NSString string];

    cell.mdate.text = [dateCategoryString transformedValue:dates];
    
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
//



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    /*************************Web Service*******************************/

    
    //[self startActivity:@"Loading..."];
    
    NSString *requestURL = [NSString stringWithFormat:@"%@GetDraftFileData?workFlowId=%@",kDraftPDFImage,[[_filterItem objectAtIndex:indexPath.row] valueForKey:@"WorkFlowId"]];
    [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
        
          // if(status)
               if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                     _pdfImageArray=[[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[responseValue valueForKey:@"Response"]]];
                    
                    if (_pdfImageArray != (id)[NSNull null])
                    {
                        
                        if ([[[responseValue valueForKey:@"Response"] valueForKey:@"IsPasswordProtected"] boolValue]==YES) {
                            UIAlertController * alert = [UIAlertController
                                                         alertControllerWithTitle:@""
                                                         message:@"At present password protected documents are not supported"
                                                         preferredStyle:UIAlertControllerStyleAlert];
                            
                            //Add Buttons
                            
                            UIAlertAction* yesButton = [UIAlertAction
                                                        actionWithTitle:@"Ok"
                                                        style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {
                                                            //Handle your yes please button action here
                                                            //[self clearAllData];
                                                        }];
                            
                            //Add your buttons to alert controller
                            
                            [alert addAction:yesButton];
                            //[alert addAction:noButton];
                            
                            [self presentViewController:alert animated:YES completion:nil];
                            [self stopActivity];
                            return;
                        }
                        //Check Null String Address
                        NSString *descriptionStr;
                        descriptionStr=[[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[[responseValue valueForKey:@"Response"] valueForKey:@"FileData"]]];
                        //_pdfImageArray=[responseValue valueForKey:@"Response"];
                        _workflowID =  [[_filterItem objectAtIndex:indexPath.row] valueForKey:@"WorkFlowId"];
                        _myTitle = [[_filterItem objectAtIndex:indexPath.row] objectForKey:@"DisplayName"];
                        _draftToolbar.hidden = NO;
                        _pdfImagedetail = descriptionStr;
                        //                //
                        //                DraftInactiveVC *temp = [[DraftInactiveVC alloc]initWithNibName:@"DraftInactiveVC" bundle:nil];
                        //                temp.myTitle = [[_filterItem objectAtIndex:indexPath.row] objectForKey:@"DisplayName"];
                        //                    temp.workflowID = [[_filterItem objectAtIndex:indexPath.row] valueForKey:@"WorkFlowId"];
                        //                temp.pdfImagedetail = descriptionStr;
                        //                [self.navigationController pushViewController:temp animated:YES];
                        //[self stopActivity];
                       // [_tableView reloadData];
                        
                    }
                    else{
                        
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
                        
                        [self presentViewController:alert animated:YES completion:nil];
                        [self stopActivity];
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
                
                //Add your buttons to alert controller
                
                [alert addAction:yesButton];
                
                [self presentViewController:alert animated:YES completion:nil];
                [self stopActivity];
                }
    }];

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat yOffset = _tableView.contentOffset.y;
    CGFloat height = _tableView.contentSize.height - _tableView.frame.size.height;
    CGFloat scrolledPercentage = yOffset / height;
    
    if(yOffset >= height)
    {
        [self startActivity:@"Loading..."];
        
        
        // if (_totalRow > self.searchResults.count) {
        _currentPage+= 1;
        [self makeServieCallWithPageNumaber:_currentPage];
        [self stopActivity];
    }
    else{
        // _currentPage = nil;
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
    [searchBar resignFirstResponder];
    //remaining Code'll go here
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText length] == 0) {
        [_filterItem removeAllObjects];
        [_filterItem addObjectsFromArray:(NSMutableArray*)_draftArray];
        [searchBar resignFirstResponder];
    }
    else
    {
        [_filterItem removeAllObjects];
        
        NSArray *arrayTemp = [(NSArray *)self.draftArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"DisplayName CONTAINS [cd] %@ OR Name CONTAINS [cd] %@", searchBar.text,searchBar.text]];
        _filterItem = [[NSMutableArray alloc]initWithArray:(NSMutableArray*)arrayTemp];    }
       [_tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)recallButtonClicked:(UIButton*)sender
{
//    UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    CoSignDeleteVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"CoSignDeleteVC"];
//    [self presentViewController:objTrackOrderVC animated:YES completion:nil];
    
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    /********************************Inactive***************************************/
    
    if (alertView.tag == 13)
    {
        if (buttonIndex == 0)
        {
            
            [self startActivity:@"Processing..."];
            NSString *requestURL = [NSString stringWithFormat:@"%@MarkAsInactive?documentId=%@&status=%@",kInactive,_workflowID,@"Draft"];
            
            [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
                
               // if(status)
                    if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

                {
                    dispatch_async(dispatch_get_main_queue(),
                                   ^{
                                       
                                       _inactiveArray =responseValue;
                                       _draftToolbar.hidden = YES;
                                       [_tableView reloadData];
                                       [self makeServieCallWithPageNumaber:0];
                                       [self stopActivity];
                                       
                                   });
                    
                }
                else{
                    
                }
                
            }];
            
        }
        else if (buttonIndex == 0)
        {
            
        }
    }
    
    //Download
    else if (alertView.tag == 14)
    {
        if (buttonIndex == 0)
        {
            
            [self startActivity:@"Loading..."];
            
            NSString *requestURL = [NSString stringWithFormat:@"%@GetDraftFileData?workFlowId=%@",kDraftPDFImage,_workflowID];
            [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
                
                //if(status)
                    if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        _pdfImageArray=[[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[[responseValue valueForKey:@"Response"] valueForKey:@"FileData"]]];
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
                        [self stopActivity];
                        QLPreviewController *previewController=[[QLPreviewController alloc]init];
                        previewController.delegate=self;
                        previewController.dataSource=self;
                        [self presentViewController:previewController animated:YES completion:nil];
                        [previewController.navigationItem setRightBarButtonItem:nil];
                        
                    });
                    
                }
                else{
                    
                }
                
            }];
        }
        else if (buttonIndex == 0)
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
//            [self presentViewController:previewController animated:YES completion:nil];
//            [previewController.navigationItem setRightBarButtonItem:nil];
//        }
//        
//    }
}
#pragma mark - data source(Preview)
//Data source methods
//– numberOfPreviewItemsInPreviewController:
//– previewController:previewItemAtIndex:
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    //return [filenamesArray count];
    
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    NSString *path = [[[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject] path];
    //You'll need an additional '/'
    NSString *fullPath = [path stringByAppendingFormat:@"/%@", [_myTitle stringByAppendingPathExtension:@"pdf"]];
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

- (IBAction)cancelBtn:(id)sender {
    _draftToolbar.hidden = YES;
    [_tableView reloadData];
}

- (IBAction)inactiveBtn:(id)sender {
    UIAlertView *alertView13 = [[UIAlertView alloc] initWithTitle:@"Inactive"
                                                          message:@"Do you want to mark document as inactive?"
                                                         delegate:self
                                
                                                cancelButtonTitle:@"Yes"
                                                otherButtonTitles:@"No", nil];
    alertView13.delegate = self;
    alertView13.tag = 13;
    [alertView13 show];

}

- (IBAction)downloadBtn:(id)sender {
    UIAlertView *alertView14 = [[UIAlertView alloc] initWithTitle:@"Download"
                                                          message:@"Do you want to download document?"
                                                         delegate:self
                                
                                                cancelButtonTitle:@"Yes"
                                                otherButtonTitles:@"No", nil];
    alertView14.tag = 14;
    [alertView14 show];

}

- (IBAction)shareBtn:(id)sender {
    
    UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ShareVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"ShareVC"];
    self.definesPresentationContext = YES;
    objTrackOrderVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    objTrackOrderVC.documentName = _myTitle;
    objTrackOrderVC.strExcutedFrom=@"Completed";
    objTrackOrderVC.documentID = _workflowID;
    [self.navigationController presentViewController:objTrackOrderVC animated:YES completion:nil];
    _draftToolbar.hidden = YES;

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
