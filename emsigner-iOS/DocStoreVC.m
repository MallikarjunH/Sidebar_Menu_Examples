//
//  DocStoreVC.m
//  emSigner
//
//  Created by Nawin Kumar on 7/17/16.
//  Copyright © 2016 Emudhra. All rights reserved.
//

#import "DocStoreVC.h"
#import "WebserviceManager.h"
#import "HoursConstants.h"
#import "MBProgressHUD.h"
#import "NSObject+Activity.h"
#import "PendingListVC.h"
#import "CompletedNextVC.h"
#import "DraftInactiveVC.h"
#import "RecallDeclineVC.h"
#import "DeclineNextVC.h"
#import "DocumentInfoNames.h"
#import "Reachability.h"
#import "RecallVC.h"
#import "LMNavigationController.h"
#import "WorkflowTableViewController.h"
#import "DocumentInfoVC.h"
#import "NSString+DateAsAppleTime.h"
#import "ParallelSigning.h"
#import "DocsPage.h"



@interface DocStoreVC ()<UITableViewDelegate>
{
    BOOL hasPresentedAlert;
    UIAlertController * alert;
    UIAlertAction* Info;
    UIAlertAction* Inactive;
    UIAlertAction* Recall;
    UIAlertAction* DocLog;
    UIAlertAction* Download ;
    UIAlertAction* Share;
    UIAlertAction* cancel;
    UIAlertAction* Decline;
    NSMutableString * mstrXMLString;
    NSString *dateCategoryString;
    BOOL isPageRefreshing;
    NSString* searchSting;
    NSString* pdfFilePathForSignatures;
    NSInteger * statusId;
    NSData *data;
    NSMutableArray * coordinatesArray;
    NSArray *arr;
    NSString* path;
    NSString* createPdfString;
    const char *password ;
    NSIndexPath *selectedIndex;
    BOOL isdelegate;
    BOOL isopened;
    
}
@property (nonatomic) UIViewController *selectedController;

@end


@implementation DocStoreVC


- (void)viewDidLoad {
    [super viewDidLoad];

    
    _pdfImageArray = [[NSMutableArray alloc] init];
    _addFile = [[NSMutableArray alloc] init];
    _signPadDict = [[NSMutableDictionary alloc]init];

    createPdfString = [NSString string];
    _searchResults = [NSMutableArray array];
       
   
    _docsStoretoolbar.hidden = YES;
    tabBar.delegate = self;
    
    //self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 65, 0);
    self.title = @"Doc Store";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //nib cell
    [self.tableView registerNib:[UINib nibWithNibName:@"RecallTableViewCell" bundle:nil] forCellReuseIdentifier:@"RecallTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"DeclineTableViewCell" bundle:nil] forCellReuseIdentifier:@"DeclineTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"PendingVCTableViewCell" bundle:nil] forCellReuseIdentifier:@"PendingVCTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"NotStartedTableViewCell" bundle:nil] forCellReuseIdentifier:@"NotStartedTableViewCell"];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:241.0/255.0 alpha:1.0];
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    statusId = 0;

}

-(void)GetDocumentsByStatus:(NSString*)status {
    /*************************Web Service*******************************/
       //  [self startActivity:@"Refreshing"];
        //Network Check

        if (![self connected])
        {
            if(hasPresentedAlert == false){
                [self stopActivity];
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
                [self stopActivity];
                [self presentViewController:alert animated:YES completion:nil];
                hasPresentedAlert = true;
            }
        }
        else
        {
         //   [self startActivity:@"Refreshing"];
            
            /*
             
             1.Pending(my signatures)
             2.cosign(waiting for others)
             3.completed
             4.declined
             5.recalled
             6.deleted
             7.drafts
             
             */
            
            if ([status  isEqual: @"Pending"]) {
                status = @"pending";
            }
            if ([status isEqual: @"Completed"]) {
                status = @"Completed";
            }
            if ([status isEqual: @"Cosign"]) {
                           status = @"Cosign";
                       }
            if ([status isEqual: @"Declined"]) {
                           status = @"declined";
                       }
            if ([status isEqual: @"Recalled"]) {
                           status = @"recalled";
                       }
            if ([status isEqual: @"Deleted"]) {
                                      status = @"deleted";
                                  }
            if ([status isEqual: @"Drafts"]) {
                                      status = @"drafts";
                                  }
            NSString *requestURL = [NSString stringWithFormat:@"%@GetDocumentsByStatus?StatusId=%@&PageSize=%d",kDocsStoreUrl,status,10];
            [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
                
                if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

                {
                    NSLog(@"%@", responseValue);
                    dispatch_async(dispatch_get_main_queue(),
                                   ^{
                                       _documentArray = [responseValue valueForKey:@"Response"];
                                       
                                       if (_documentArray != (id)[NSNull null])
                                       {
                                           isPageRefreshing=NO;

                                           _filterSecondDocstoreArray = [[NSMutableArray alloc]initWithArray:(NSMutableArray*)_documentArray];
                                           
                                           [_filterArray addObjectsFromArray:_filterSecondDocstoreArray];
                                           [_tableView reloadData];
                                           
                                           [self stopActivity];
                                       }
                                       else{
                                           
                                           if (_filterArray.count == 0) {
                                               
                                           dispatch_async(dispatch_get_main_queue(), ^(void){
                                               
                                               UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
                                               noDataLabel.text             = @"You do not have any files";
                                               noDataLabel.textColor        = [UIColor grayColor];
                                               noDataLabel.textAlignment    = NSTextAlignmentCenter;
                                               self.tableView.backgroundView = noDataLabel;
                                               self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                                               
                                               //hide right bar button item if there is no data
                                               self.navigationItem.rightBarButtonItem = nil;
                                               [self stopActivity];
                                           });
                                       }
                                           [self stopActivity];

                                       }
                                   });
                }
                else
                {
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
    }

    -(void)viewWillAppear:(BOOL)animated
    {
        [self startActivity:@"Refreshing"];
        _filterArray = [[NSMutableArray alloc]init];

        _currentPage = 1;
        searchSting = @"";

        [self setTitle:@"DocStore"];
        self.tabBarController.navigationItem.title = @"DocStore";
        
        [self makeServieCallWithPageNumaber:_currentPage :searchSting];
        _docsStoretoolbar.hidden = YES;
        [tabBar setSelectedItem:[tabBar.items objectAtIndex:1]];

    }

    - (void)refresh:(UIRefreshControl *)refreshControl
    {
        
        //Network Check
        if (![self connected])
        {
            if(hasPresentedAlert == false){
                
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
                //[alert addAction:noButton];
                
                [self presentViewController:alert animated:YES completion:nil];
                hasPresentedAlert = true;
                [refreshControl endRefreshing];
            }
        }
        else
        {
            
    //        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //        [formatter setDateFormat:@"MMM d, h:mm a"];
    //        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
    //        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor grayColor]
    //                                                                    forKey:NSForegroundColorAttributeName];
    //        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
            refreshControl.attributedTitle = [dateCategoryString refreshForDate];
            [self makeServieCallWithPageNumaber:0 :searchSting];

            [self stopActivity];
            [refreshControl endRefreshing];
        }
        
      


}

- (void)makeServieCallWithPageNumaber:(NSUInteger)pageNumber:(NSString*)search
{
    /*************************Web Service*******************************/
     [self startActivity:@"Refreshing"];
    //Network Check
    if (![self connected])
    {
        if(hasPresentedAlert == false){
            [self stopActivity];
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
            [self stopActivity];
            [self presentViewController:alert animated:YES completion:nil];
            hasPresentedAlert = true;
        }
    }
    else
    {
        [self startActivity:@"Refreshing"];
        
        NSMutableDictionary *post = [[NSMutableDictionary alloc]init];
        [post setObject:[NSString stringWithFormat:@"%lu",(unsigned long)pageNumber]  forKey:@"pagenumber"];
            [post setObject:[NSString stringWithFormat:@"%d",10] forKey:@"PageSize"];
           

        NSMutableArray * postArray = [[NSMutableArray alloc]init];
        [postArray addObject:post];

        NSString *requestURL = [NSString stringWithFormat:@"%@GetAllDocuments",kDocsStoreUrl];
        [WebserviceManager sendSyncRequestWithURLDocument:requestURL method:SAServiceReqestHTTPMethodPOST body:post completionBlock:^(BOOL status, id responseValue) {
            
            if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

            {
                
                dispatch_async(dispatch_get_main_queue(),
                               ^{
                                   _documentArray = [responseValue valueForKey:@"Response"];
                                   
                                   if (_documentArray != (id)[NSNull null])
                                   {
                                       isPageRefreshing=NO;

                                       _filterSecondDocstoreArray = [[NSMutableArray alloc]initWithArray:(NSMutableArray*)_documentArray];
                                       
                                       [_filterArray addObjectsFromArray:_filterSecondDocstoreArray];
                                       [_tableView reloadData];
                                       
                                       [self stopActivity];
                                   }
                                   else{
                                       
                                       if (_filterArray.count == 0) {
                                           
                                       dispatch_async(dispatch_get_main_queue(), ^(void){
                                           
                                           UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
                                           noDataLabel.text             = @"You do not have any files";
                                           noDataLabel.textColor        = [UIColor grayColor];
                                           noDataLabel.textAlignment    = NSTextAlignmentCenter;
                                           self.tableView.backgroundView = noDataLabel;
                                           self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                                           
                                           //hide right bar button item if there is no data
                                           self.navigationItem.rightBarButtonItem = nil;
                                           [self stopActivity];
                                       });
                                   }
                                       [self stopActivity];

                                   }
                               });
            }
            else
            {
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

//Network Connection Checks
- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numOfSections = 0;
    if ([self.filterArray count]>0)
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        numOfSections                = 1;
        self.tableView.backgroundView = nil;
    }
    else
    {
    }
    
    return numOfSections;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if(_searchResults == nil || _searchResults.count == 0){
            return _filterArray.count;
           }else{
               return _searchResults.count;}
   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
   //_filterArray =  [_filterArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    //Decline
    NSArray* date= [[[_filterArray objectAtIndex:indexPath.row] objectForKey:@"UploadTime"] componentsSeparatedByString: @" "];
   // NSDate* firstBit = [date objectAtIndex: 0];
   // NSDate *secondBit = [date objectAtIndex:1];
    
    NSString *dateFromArray = [[_filterArray objectAtIndex:indexPath.row] objectForKey:@"UploadTime"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSDate *dates = [formatter dateFromString:dateFromArray];
    
    if(_searchResults == nil || _searchResults.count == 0){
    
    
    if ([[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"Status"] isEqualToString:@"Declined"])
    {
        
        static NSString *CellIdentifier1 = @"DeclineTableViewCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier1];
        }
        
        DeclineTableViewCell* cell5 = (DeclineTableViewCell *)cell;
        
        _totalRow = [[[_filterArray objectAtIndex:indexPath.row] objectForKey:@"totalRecords"]integerValue];
        cell5.documentName.text = [[_filterArray objectAtIndex:indexPath.row] objectForKey:@"DisplayName"];
        cell5.profileName.text = [[_filterArray objectAtIndex:indexPath.row] objectForKey:@"Name"];
        
        NSArray* date= [[[_filterArray objectAtIndex:indexPath.row] objectForKey:@"UploadTime"] componentsSeparatedByString: @"T"];
        
        dateCategoryString = [NSString string];
        cell5.dateLable.text = [dateCategoryString transformedValue:dates];
        cell5.timeLabel.text = [date objectAtIndex:1];
        long numberOfAttachmentString = [[[_filterArray objectAtIndex:indexPath.row] objectForKey:@"NoofAttachment"]intValue];
        
        cell5.attachmentsImage.hidden = YES;

        cell5.docInfoBtn.imageView.image = [UIImage imageNamed:@"doc-info-1x.png"];
        //InfoButton
        cell5.docInfoBtn.tag = indexPath.row;
        [cell5.docInfoBtn addTarget:self action:@selector(docInfoBtnClickedDeclined:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell5;
    }
    
    //pending
    
    else if ([[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"Status"] isEqualToString:@"Pending"])
    {
        static NSString *CellIdentifier2 = @"PendingVCTableViewCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2];
        }
        
        PendingVCTableViewCell* cell2 = (PendingVCTableViewCell *)cell;
        
        _totalRow = [[[_filterArray objectAtIndex:indexPath.row] objectForKey:@"totalRecords"]integerValue];
        cell2.documentName.text = [[_filterArray objectAtIndex:indexPath.row] objectForKey:@"DisplayName"];
        
        cell2.ownerName.text = [[_filterArray objectAtIndex:indexPath.row] objectForKey:@"Name"];
        cell2.pdfImage.image = [UIImage imageNamed: @"pending-1x.png"];
        NSArray* date= [[[_filterArray objectAtIndex:indexPath.row] objectForKey:@"UploadTime"] componentsSeparatedByString: @"T"];
        
        //[[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"SignatureType"]integerValue] == 2 ||
        
        if ([[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue] == 2 || [[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue] == 4 || [[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue] == 5 )
        {
            cell2.docInfoBtn.hidden = YES;
            
        }
        else{
            cell2.docInfoBtn.hidden = NO;
            
        }
        dateCategoryString = [NSString string];
        cell2.dateLable.text = [dateCategoryString transformedValue:dates];
        cell2.timeLabel.text = [date objectAtIndex:1];

        long numberOfAttachmentString = [[[_filterArray objectAtIndex:indexPath.row] objectForKey:@"IsAttachment"]intValue];
        
        if (numberOfAttachmentString == 0) {
            cell2.attachmentsImage.image = [UIImage imageNamed:@""];
        }
        else {
            cell2.attachmentsImage.image = [UIImage imageNamed:@"attachment-1x"];
        };
        
        //InfoButton
        cell2.docInfoBtn.tag = indexPath.row;
        [cell2.docInfoBtn addTarget:self action:@selector(docInfoBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell2;
    }
    
    //Inprogress
    
    else if ([[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"Status"] isEqualToString:@"Cosine-Pending"])
    {
        //PendingVCTableViewCell
        static NSString *REUSEIDENTIFIER = @"PendingVCTableViewCell";
        cell = [tableView dequeueReusableCellWithIdentifier:REUSEIDENTIFIER];

        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:REUSEIDENTIFIER];
        }

        PendingVCTableViewCell* cell9 = (PendingVCTableViewCell *)cell;
        
        _totalRow = [[[_filterArray objectAtIndex:indexPath.row] objectForKey:@"totalRecords"]integerValue];
        cell9.documentName.text = [[_filterArray objectAtIndex:indexPath.row] objectForKey:@"DocumentName"];
        cell9.pdfImage.image = [UIImage imageNamed: @"ico-waiting-32.png"];
        cell9.ownerName.text = [[_filterArray objectAtIndex:indexPath.row] objectForKey:@"Name"];
        NSArray* date= [[[_filterArray objectAtIndex:indexPath.row] objectForKey:@"UploadTime"] componentsSeparatedByString: @"T"];
        dateCategoryString = [NSString string];
        cell9.dateLable.text = [dateCategoryString transformedValue:dates];
        cell9.timeLabel.text = [date objectAtIndex:1];

        if ([[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue] == 2 || [[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue] == 4 || [[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue] == 5 )
        {
            cell9.docInfoBtn.hidden = YES;
            
        }
        else{
            cell9.docInfoBtn.hidden = NO;
            
        }
        
        long numberOfAttachmentString = [[[_filterArray objectAtIndex:indexPath.row] objectForKey:@"NoofAttachment"]intValue];
        
        if (numberOfAttachmentString == 0) {
            cell9.attachmentsImage.image = [UIImage imageNamed:@""];
        }
        else {
            cell9.attachmentsImage.image = [UIImage imageNamed:@"attachment-1x"];
        };
        
        //InfoButton
        cell9.docInfoBtn.tag = indexPath.row;
        [cell9.docInfoBtn addTarget:self action:@selector(docInfoBtnClickedWaiting:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell9;
    }

    //Compelted
    
    else if ([[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"Status"] isEqualToString:@"Completed"])
    {
        static NSString *CellIdentifier4 = @"PendingVCTableViewCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier4];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier4];
        }
        
        PendingVCTableViewCell* cell3 = (PendingVCTableViewCell *)cell;
        
        _totalRow = [[[_filterArray objectAtIndex:indexPath.row] objectForKey:@"totalRecords"]integerValue];
        cell3.documentName.text = [[_filterArray objectAtIndex:indexPath.row] objectForKey:@"DisplayName"];
        cell3.pdfImage.image = [UIImage imageNamed:@"completed-1x.png"];

        cell3.ownerName.text = [[_filterArray objectAtIndex:indexPath.row] objectForKey:@"Name"];
        NSArray* date= [[[_filterArray objectAtIndex:indexPath.row] objectForKey:@"UploadTime"] componentsSeparatedByString: @"T"];
       // NSString* firstBit = [date objectAtIndex: 0];
        
        dateCategoryString = [NSString string];
        cell3.dateLable.text = [dateCategoryString transformedValue:dates];
        cell3.timeLabel.text = [date objectAtIndex:1];

        
        if ([[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue] == 2 || [[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue] == 4 || [[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue] == 5 )
        {
            cell3.docInfoBtn.hidden = YES;
            
        }
        else{
            cell3.docInfoBtn.hidden = NO;
            
        }
        
        long numberOfAttachmentString = [[[_filterArray objectAtIndex:indexPath.row] objectForKey:@"NoofAttachment"]intValue];
        
        if (numberOfAttachmentString == 0) {
            cell3.attachmentsImage.image = [UIImage imageNamed:@""];
        }
        else {
            cell3.attachmentsImage.image = [UIImage imageNamed:@"attachment-1x"];
        }
        
        //InfoButton
        cell3.docInfoBtn.tag = indexPath.row;
        [cell3.docInfoBtn addTarget:self action:@selector(docInfoBtnClickedComplted:) forControlEvents:UIControlEventTouchUpInside];

        return cell3;
    }
    
    //Recalled
    
    else if ([[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"Status"] isEqualToString:@"Recalled"])
    {
        static NSString *CellIdentifier5 = @"RecallTableViewCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier5];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier5];
        }
        
        RecallTableViewCell* cell4 = (RecallTableViewCell *)cell;
        
            _totalRow = [[[_filterArray objectAtIndex:indexPath.row] objectForKey:@"totalRecords"]integerValue];
        cell4.mName.text = [[_filterArray objectAtIndex:indexPath.row] objectForKey:@"Name"];
        
        cell4.Lable1.text = [[_filterArray objectAtIndex:indexPath.row] objectForKey:@"DisplayName"];
        NSArray* date= [[[_filterArray objectAtIndex:indexPath.row] objectForKey:@"UploadedDatetime"] componentsSeparatedByString: @"T"];
        NSString* firstBit = [date objectAtIndex: 0];
        
        dateCategoryString = [NSString string];
        cell4.dateLable.text = [dateCategoryString transformedValue:dates];
        cell4.timeLabel.text = [date objectAtIndex:1];

        cell4.pdfImage.image = [UIImage imageNamed:@"recalled-1x.png"];
        cell4.docInfoBtn.imageView.image = [UIImage imageNamed:@"doc-info-1x.png"];
        //if (numberOfAttachmentString == 0) {
            //cell4.numberOfAttachmentsLabel.hidden = YES;
            cell4.attachmentsImage.hidden = YES;
       // }
     //   else cell4.numberOfAttachmentsLabel.text = [[[_filterArray objectAtIndex:indexPath.row] objectForKey:@"NoofAttachment"]stringValue];
        
        
        //InfoButton
        cell4.docInfoBtn.tag = indexPath.row;
        [cell4.docInfoBtn addTarget:self action:@selector(docInfoBtnClickedRecall:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell4;
    }
    //(Initiate)
    else if ([[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"Status"] isEqualToString:@"Inactive"])
    {
        static NSString *CellIdentifier6 = @"NotStartedTableViewCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier6];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier6];
        }
        NotStartedTableViewCell* cell1 = (NotStartedTableViewCell *)cell;
        _totalRow = [[[_filterArray objectAtIndex:indexPath.row] objectForKey:@"totalRecords"]integerValue];
        cell1.mLable1.text = [[_filterArray objectAtIndex:indexPath.row] objectForKey:@"DisplayName"];
        cell1.pdfImage.image = [UIImage imageNamed: @"draft-1x.png"];
        cell1.mName.text = [[_filterArray objectAtIndex:indexPath.row] objectForKey:@"Name"];
        NSArray* date= [[[_filterArray objectAtIndex:indexPath.row] objectForKey:@"UploadTime"] componentsSeparatedByString: @"T"];
        NSString* firstBit = [date objectAtIndex: 0];
        
        dateCategoryString = [NSString string];
        cell1.mdate.text = [dateCategoryString transformedValue:dates];
        cell1.timeLabel.text = [date objectAtIndex:1];
        cell1.pdfImage.image = [UIImage imageNamed: @"ico_inacive.png"];
        
        return cell1;

    }
    //Document Uploaded
    else if ([[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"Status"] isEqualToString:@"Document Uploaded"])
    {
        static NSString *CellIdentifier7 = @"NotStartedTableViewCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier7];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier7];
        }
        NotStartedTableViewCell* cell1 = (NotStartedTableViewCell *)cell;
        
        _totalRow = [[[_filterArray objectAtIndex:indexPath.row] objectForKey:@"totalRecords"]integerValue];
        cell1.mLable1.text = [[_filterArray objectAtIndex:indexPath.row] objectForKey:@"DisplayName"];
        cell1.pdfImage.image = [UIImage imageNamed: @"draft-1x.png"];
        cell1.mName.text = [[_filterArray objectAtIndex:indexPath.row] objectForKey:@"Name"];
        NSArray* date= [[[_filterArray objectAtIndex:indexPath.row] objectForKey:@"UploadTime"] componentsSeparatedByString: @"'T'"];
        NSString* firstBit = [date objectAtIndex: 0];
        
        dateCategoryString = [NSString string];
        cell1.mdate.text = [dateCategoryString transformedValue:dates];
        cell1.timeLabel.text = [date objectAtIndex:1];

        cell1.pdfImage.image = [UIImage imageNamed: @"ico-doc.png"];
        
        return cell1;

    }
    
    //Drafts
    
    else([[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"Status"] isEqualToString:@"Initiate"]);
    {
        static NSString *CellIdentifier8 = @"NotStartedTableViewCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier8];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier8];
        }
        NotStartedTableViewCell* cell1 = (NotStartedTableViewCell *)cell;
        
        _totalRow = [[[_filterArray objectAtIndex:indexPath.row] objectForKey:@"totalRecords"]integerValue];
        cell1.mLable1.text = [[_filterArray objectAtIndex:indexPath.row] objectForKey:@"DisplayName"];
        cell1.pdfImage.image = [UIImage imageNamed: @"draft-1x.png"];
        cell1.mName.text = [[_filterArray objectAtIndex:indexPath.row] objectForKey:@"Name"];
        NSArray* date= [[[_filterArray objectAtIndex:indexPath.row] objectForKey:@"UploadedTime"] componentsSeparatedByString: @"T"];
      //  NSString* firstBit = [date objectAtIndex: 0];
        
        dateCategoryString = [NSString string];
        cell1.mdate.text = [dateCategoryString transformedValue:dates];
        cell1.timeLabel.text = [date objectAtIndex:1];
        return cell1;
    }
    } else {
        if ([[[_searchResults objectAtIndex:indexPath.row] valueForKey:@"Status"] isEqualToString:@"Declined"])
           {
               
               static NSString *CellIdentifier1 = @"DeclineTableViewCell";
               cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
               if (cell == nil) {
                   cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier1];
               }
               
               DeclineTableViewCell* cell5 = (PendingVCTableViewCell *)cell;
               
               _totalRow = [[[_searchResults objectAtIndex:indexPath.row] objectForKey:@"totalRecords"]integerValue];
               cell5.documentName.text = [[_searchResults objectAtIndex:indexPath.row] objectForKey:@"DocumentName"];
               cell5.profileName.text = [[_searchResults objectAtIndex:indexPath.row] objectForKey:@"Name"];
               
               NSArray* date= [[[_searchResults objectAtIndex:indexPath.row] objectForKey:@"UploadTime"] componentsSeparatedByString: @"'T'"];
               
               dateCategoryString = [NSString string];
               cell5.dateLable.text = [dateCategoryString transformedValue:dates];
               cell5.timeLabel.text = [date objectAtIndex:1];
               long numberOfAttachmentString = [[[_searchResults objectAtIndex:indexPath.row] objectForKey:@"NoofAttachment"]intValue];
               
               cell5.attachmentsImage.hidden = YES;

               cell5.docInfoBtn.imageView.image = [UIImage imageNamed:@"doc-info-1x.png"];
               //InfoButton
               cell5.docInfoBtn.tag = indexPath.row;
               [cell5.docInfoBtn addTarget:self action:@selector(docInfoBtnClickedDeclined:) forControlEvents:UIControlEventTouchUpInside];
               
               return cell5;
           }
           
           //pending
           
           else if ([[[_searchResults objectAtIndex:indexPath.row] valueForKey:@"Status"] isEqualToString:@"Pending"])
           {
               static NSString *CellIdentifier2 = @"PendingVCTableViewCell";
               cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
               if (cell == nil) {
                   cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2];
               }
               
               PendingVCTableViewCell* cell2 = (PendingVCTableViewCell *)cell;
               
               _totalRow = [[[_searchResults objectAtIndex:indexPath.row] objectForKey:@"totalRecords"]integerValue];
               cell2.documentName.text = [[_searchResults objectAtIndex:indexPath.row] objectForKey:@"DisplayName"];
               
               cell2.ownerName.text = [[_searchResults objectAtIndex:indexPath.row] objectForKey:@"Name"];
               cell2.pdfImage.image = [UIImage imageNamed: @"pending-1x.png"];
               NSArray* date= [[[_searchResults objectAtIndex:indexPath.row] objectForKey:@"UploadTime"] componentsSeparatedByString: @"T"];
               
               //[[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"SignatureType"]integerValue] == 2 ||
               
               if ([[[_searchResults objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue] == 2 || [[[_searchResults objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue] == 4 || [[[_searchResults objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue] == 5 )
               {
                   cell2.docInfoBtn.hidden = YES;
                   
               }
               else{
                   cell2.docInfoBtn.hidden = NO;
                   
               }
               dateCategoryString = [NSString string];
               cell2.dateLable.text = [dateCategoryString transformedValue:dates];
               cell2.timeLabel.text = [date objectAtIndex:1];

               long numberOfAttachmentString = [[[_searchResults objectAtIndex:indexPath.row] objectForKey:@"NoofAttachment"]intValue];
               
               if (numberOfAttachmentString == 0) {
                   cell2.attachmentsImage.image = [UIImage imageNamed:@""];
               }
               else {
                   cell2.attachmentsImage.image = [UIImage imageNamed:@"attachment-1x"];
               };
               
               //InfoButton
               cell2.docInfoBtn.tag = indexPath.row;
               [cell2.docInfoBtn addTarget:self action:@selector(docInfoBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
               
               return cell2;
           }
           
           //Inprogress
           
           else if ([[[_searchResults objectAtIndex:indexPath.row] valueForKey:@"Status"] isEqualToString:@"Cosine-Pending"])
           {
               //PendingVCTableViewCell
               static NSString *REUSEIDENTIFIER = @"PendingVCTableViewCell";
               cell = [tableView dequeueReusableCellWithIdentifier:REUSEIDENTIFIER];

               if (cell == nil) {
                   cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:REUSEIDENTIFIER];
               }

               PendingVCTableViewCell* cell9 = (PendingVCTableViewCell *)cell;
               
               _totalRow = [[[_searchResults objectAtIndex:indexPath.row] objectForKey:@"totalRecords"]integerValue];
               cell9.documentName.text = [[_searchResults objectAtIndex:indexPath.row] objectForKey:@"DocumentName"];
               cell9.pdfImage.image = [UIImage imageNamed: @"ico-waiting-32.png"];
               cell9.ownerName.text = [[_searchResults objectAtIndex:indexPath.row] objectForKey:@"Name"];
               NSArray* date= [[[_searchResults objectAtIndex:indexPath.row] objectForKey:@"UploadTime"] componentsSeparatedByString: @"T"];
               dateCategoryString = [NSString string];
               cell9.dateLable.text = [dateCategoryString transformedValue:dates];
               cell9.timeLabel.text = [date objectAtIndex:1];

               if ([[[_searchResults objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue] == 2 || [[[_searchResults objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue] == 4 || [[[_searchResults objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue] == 5 )
               {
                   cell9.docInfoBtn.hidden = YES;
                   
               }
               else{
                   cell9.docInfoBtn.hidden = NO;
                   
               }
               
               long numberOfAttachmentString = [[[_searchResults objectAtIndex:indexPath.row] objectForKey:@"NoofAttachment"]intValue];
               
               if (numberOfAttachmentString == 0) {
                   cell9.attachmentsImage.image = [UIImage imageNamed:@""];
               }
               else {
                   cell9.attachmentsImage.image = [UIImage imageNamed:@"attachment-1x"];
               };
               
               //InfoButton
               cell9.docInfoBtn.tag = indexPath.row;
               [cell9.docInfoBtn addTarget:self action:@selector(docInfoBtnClickedWaiting:) forControlEvents:UIControlEventTouchUpInside];
               
               return cell9;
           }

           //Compelted
           
           else if ([[[_searchResults objectAtIndex:indexPath.row] valueForKey:@"Status"] isEqualToString:@"Completed"])
           {
               static NSString *CellIdentifier4 = @"PendingVCTableViewCell";
               cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier4];
               if (cell == nil) {
                   cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier4];
               }
               
               PendingVCTableViewCell* cell3 = (PendingVCTableViewCell *)cell;
               
               _totalRow = [[[_searchResults objectAtIndex:indexPath.row] objectForKey:@"totalRecords"]integerValue];
               cell3.documentName.text = [[_searchResults objectAtIndex:indexPath.row] objectForKey:@"DisplayName"];
               cell3.pdfImage.image = [UIImage imageNamed:@"completed-1x.png"];

               cell3.ownerName.text = [[_searchResults objectAtIndex:indexPath.row] objectForKey:@"Name"];
               NSArray* date= [[[_searchResults objectAtIndex:indexPath.row] objectForKey:@"UploadTime"] componentsSeparatedByString: @"T"];
              // NSString* firstBit = [date objectAtIndex: 0];
               
               dateCategoryString = [NSString string];
               cell3.dateLable.text = [dateCategoryString transformedValue:dates];
               cell3.timeLabel.text = [date objectAtIndex:1];

               
               if ([[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue] == 2 || [[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue] == 4 || [[[_searchResults objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue] == 5 )
               {
                   cell3.docInfoBtn.hidden = YES;
                   
               }
               else{
                   cell3.docInfoBtn.hidden = NO;
                   
               }
               
               long numberOfAttachmentString = [[[_searchResults objectAtIndex:indexPath.row] objectForKey:@"NoofAttachment"]intValue];
               
               if (numberOfAttachmentString == 0) {
                   cell3.attachmentsImage.image = [UIImage imageNamed:@""];
               }
               else {
                   cell3.attachmentsImage.image = [UIImage imageNamed:@"attachment-1x"];
               }
               
               //InfoButton
               cell3.docInfoBtn.tag = indexPath.row;
               [cell3.docInfoBtn addTarget:self action:@selector(docInfoBtnClickedComplted:) forControlEvents:UIControlEventTouchUpInside];

               return cell3;
           }
           
           //Recalled
           
           else if ([[[_searchResults objectAtIndex:indexPath.row] valueForKey:@"Status"] isEqualToString:@"Recalled"])
           {
               static NSString *CellIdentifier5 = @"RecallTableViewCell";
               cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier5];
               if (cell == nil) {
                   cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier5];
               }
               
               RecallTableViewCell* cell4 = (RecallTableViewCell *)cell;
               
                   _totalRow = [[[_searchResults objectAtIndex:indexPath.row] objectForKey:@"totalRecords"]integerValue];
               cell4.mName.text = [[_searchResults objectAtIndex:indexPath.row] objectForKey:@"Name"];
               
               cell4.Lable1.text = [[_searchResults objectAtIndex:indexPath.row] objectForKey:@"DisplayName"];
               NSArray* date= [[[_searchResults objectAtIndex:indexPath.row] objectForKey:@"UploadedDatetime"] componentsSeparatedByString: @"T"];
               NSString* firstBit = [date objectAtIndex: 0];
               
               dateCategoryString = [NSString string];
               cell4.dateLable.text = [dateCategoryString transformedValue:dates];
               cell4.timeLabel.text = [date objectAtIndex:1];

               cell4.pdfImage.image = [UIImage imageNamed:@"recalled-1x.png"];
               cell4.docInfoBtn.imageView.image = [UIImage imageNamed:@"doc-info-1x.png"];
               //if (numberOfAttachmentString == 0) {
                   //cell4.numberOfAttachmentsLabel.hidden = YES;
                   cell4.attachmentsImage.hidden = YES;
              // }
            //   else cell4.numberOfAttachmentsLabel.text = [[[_filterArray objectAtIndex:indexPath.row] objectForKey:@"NoofAttachment"]stringValue];
               
               
               //InfoButton
               cell4.docInfoBtn.tag = indexPath.row;
               [cell4.docInfoBtn addTarget:self action:@selector(docInfoBtnClickedRecall:) forControlEvents:UIControlEventTouchUpInside];
               
               return cell4;
           }
           //(Initiate)
           else if ([[[_searchResults objectAtIndex:indexPath.row] valueForKey:@"Status"] isEqualToString:@"Inactive"])
           {
               static NSString *CellIdentifier6 = @"NotStartedTableViewCell";
               cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier6];
               if (cell == nil) {
                   cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier6];
               }
               NotStartedTableViewCell* cell1 = (NotStartedTableViewCell *)cell;
               _totalRow = [[[_searchResults objectAtIndex:indexPath.row] objectForKey:@"totalRecords"]integerValue];
               cell1.mLable1.text = [[_searchResults objectAtIndex:indexPath.row] objectForKey:@"DisplayName"];
               cell1.pdfImage.image = [UIImage imageNamed: @"draft-1x.png"];
               cell1.mName.text = [[_searchResults objectAtIndex:indexPath.row] objectForKey:@"Name"];
               NSArray* date= [[[_searchResults objectAtIndex:indexPath.row] objectForKey:@"UploadTime"] componentsSeparatedByString: @"T"];
               NSString* firstBit = [date objectAtIndex: 0];
               
               dateCategoryString = [NSString string];
               cell1.mdate.text = [dateCategoryString transformedValue:dates];
               cell1.timeLabel.text = [date objectAtIndex:1];
               cell1.pdfImage.image = [UIImage imageNamed: @"ico_inacive.png"];
               
               return cell1;

           }
           //Document Uploaded
           else if ([[[_searchResults objectAtIndex:indexPath.row] valueForKey:@"Status"] isEqualToString:@"Document Uploaded"])
           {
               static NSString *CellIdentifier7 = @"NotStartedTableViewCell";
               cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier7];
               if (cell == nil) {
                   cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier7];
               }
               NotStartedTableViewCell* cell1 = (NotStartedTableViewCell *)cell;
               
               _totalRow = [[[_searchResults objectAtIndex:indexPath.row] objectForKey:@"totalRecords"]integerValue];
               cell1.mLable1.text = [[_searchResults objectAtIndex:indexPath.row] objectForKey:@"DisplayName"];
               cell1.pdfImage.image = [UIImage imageNamed: @"draft-1x.png"];
               cell1.mName.text = [[_searchResults objectAtIndex:indexPath.row] objectForKey:@"Name"];
               NSArray* date= [[[_searchResults objectAtIndex:indexPath.row] objectForKey:@"UploadTime"] componentsSeparatedByString: @"'T'"];
               NSString* firstBit = [date objectAtIndex: 0];
               
               dateCategoryString = [NSString string];
               cell1.mdate.text = [dateCategoryString transformedValue:dates];
               cell1.timeLabel.text = [date objectAtIndex:1];

               cell1.pdfImage.image = [UIImage imageNamed: @"ico-doc.png"];
               
               return cell1;

           }
           
           //Drafts
           
           else([[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"Status"] isEqualToString:@"Initiate"]);
           {
               static NSString *CellIdentifier8 = @"NotStartedTableViewCell";
               cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier8];
               if (cell == nil) {
                   cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier8];
               }
               NotStartedTableViewCell* cell1 = (NotStartedTableViewCell *)cell;
               
               _totalRow = [[[_searchResults objectAtIndex:indexPath.row] objectForKey:@"totalRecords"]integerValue];
               cell1.mLable1.text = [[_searchResults objectAtIndex:indexPath.row] objectForKey:@"DisplayName"];
               cell1.pdfImage.image = [UIImage imageNamed: @"draft-1x.png"];
               cell1.mName.text = [[_searchResults objectAtIndex:indexPath.row] objectForKey:@"Name"];
               NSArray* date= [[[_searchResults objectAtIndex:indexPath.row] objectForKey:@"UploadedTime"] componentsSeparatedByString: @"T"];
             //  NSString* firstBit = [date objectAtIndex: 0];
               
               dateCategoryString = [NSString string];
               cell1.mdate.text = [dateCategoryString transformedValue:dates];
               cell1.timeLabel.text = [date objectAtIndex:1];
               return cell1;
           }
        
        
        
        
        
        
        
    }
    
    return cell;
//    }
//    else{
//
//        [self.tableView registerNib:[UINib nibWithNibName:@"LoadingCell" bundle:nil] forCellReuseIdentifier:@"LoadingCell"];
//        LoadingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LoadingCell" forIndexPath:indexPath];
//        [cell.animator startAnimating];
//
//        _currentPage+=1;
//        //[self callPageNumbers:_currentPage];
//
//        return cell;
//    }
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
//            [formatter setDateStyle:NSDateFormatterNoStyle];
//            [formatter setTimeStyle:NSDateFormatterShortStyle];
//            return [formatter stringFromDate:date];
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
    
    selectedIndex =  indexPath;

    /*************************Web Service*******************************/
    
    _workflowID = [[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkFlowId"];
    [[NSUserDefaults standardUserDefaults] setObject:_workflowID forKey:@"workflowId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _openFileName = [[_filterArray objectAtIndex:indexPath.row] valueForKey:@"DisplayName"];
        /*****************************Pending******************************/
    NSString* stateComplete = [[_filterArray objectAtIndex:indexPath.row] valueForKey:@"Status"] ;
    [[NSUserDefaults standardUserDefaults] setObject:stateComplete forKey:@"stateComplete"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    int statusCheckForPar =[[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]intValue];
    [[NSUserDefaults standardUserDefaults] setInteger:statusCheckForPar forKey:@"statusCheckForPar"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    mstrXMLString = [[NSMutableString alloc] init];
   // [self GetDocumentsByStatus:[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"Status"]];

       if ([[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"Status"] isEqualToString:@"Pending"])
        {
            NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults removeObjectForKey:@"pdfpath"];
            
            NSUserDefaults * userDefaultssaveSignature = [NSUserDefaults standardUserDefaults];
            [userDefaultssaveSignature removeObjectForKey:@"saveSignature"];
            
            [self startActivity:@"Loading..."];
            
          
            NSString *requestURL = [NSString stringWithFormat:@"%@GetDocumentDetailsById?workFlowId=%@&workflowType=%@",kOpenPDFImage,[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkFlowId"],[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]];
            [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
                
               // if(status)
                if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        _checkNullArray = [responseValue valueForKey:@"Response"];
                        
                        arr =  [_checkNullArray valueForKey:@"Signatory"];
                        
           ////////////////////
                        //workflow type 2
                        if ([[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue] == 2)
                        {
                            [self alertForFlexiforms];
                            return ;
                        }
                        
                        //workflow type 4
                        
                        if ([[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue] == 4)
                        {
                            [self alertForBulkDocuments];
                            return;
                        }
                        
                        //workflow type 5
                        if ([[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue] == 5)
                        {
                            [self alertForCollaborative];
                            return;
                        }
                        
//                        if ([[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"SignatureType"]integerValue] == 2)
//                        {
//                            [self alertForReview];
//                            return;
//                        }

             //////////////////////
                        if (arr.count > 0) {
                            NSString * ischeck = @"ischeck";
                            [mstrXMLString appendString:@"Signed By:"];
                            
                            for (int i = 0; arr.count>i; i++) {
                                NSDictionary * dict = arr[i];
                                
                                
                                //status id for parallel signing
                                if ([dict[@"StatusID"]intValue] == 7) {
                                    //statusId = 1;
                                }
                                
                                //displaying signatories on top .
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
                        
                        
                        coordinatesArray = [[NSMutableArray alloc]init];
                        
                        
                        //Checking for signatorys and multiple PDF
                        for (int i = 0; i<arr.count; i++) {
                            
                            if ([[arr[i]valueForKey:@"EmailID"] caseInsensitiveCompare:[[NSUserDefaults standardUserDefaults]valueForKey:@"Email"]] == NSOrderedSame)
                            {
                                if (([[arr[i]valueForKey:@"StatusID"]integerValue] == 53)) {
                                    isdelegate = false;
                                    statusId = 0;
                                }
                                else if ([[arr[i]valueForKey:@"StatusID"]integerValue] == 7){
                                    isdelegate = true;
                                    statusId = 1;
                                }
                                if ((([[arr[i]valueForKey:@"StatusID"]integerValue] == 7)|| ([[arr[i]valueForKey:@"StatusID"]integerValue] == 53)|| ([[arr[i]valueForKey:@"StatusID"]integerValue] == 8))) {
                                    
                                    if ([[arr[i]valueForKey:@"DocumentId"]integerValue]== [[[_checkNullArray valueForKey:@"DocumentId"]objectAtIndex:0]integerValue]) {
                                        [coordinatesArray addObject:arr[i]];
                                    }
                                }
                            }
                        }
                        if (_checkNullArray == (id)[NSNull null])
                        {
                            UIAlertController * alert = [UIAlertController
                                                         alertControllerWithTitle:@""
                                                         message:@"This file is corrupted."
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
                            //[alert addAction:noButton];
                            
                            [self presentViewController:alert animated:YES completion:nil];
                            [self stopActivity];
                            
                            return;
                        }
                        
                        _pdfImageArray=[_checkNullArray valueForKey:@"Document"];
                        
                        [[NSUserDefaults standardUserDefaults] setObject:path forKey:@"pathForDoc"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        
//                        NSString *IsSignatory = [[_filterArray objectAtIndex:indexPath.row] objectForKey:@"DisplayName"];
//                        [[NSUserDefaults standardUserDefaults] setBool:[[_checkNullArray valueForKey:@"IsSignatory"]boolValue] forKey:@"IsSignatory"];
//                        [[NSUserDefaults standardUserDefaults] synchronize];
//
//
//                        NSString *IsReviewer = [[_filterArray objectAtIndex:indexPath.row] objectForKey:@"DisplayName"];
//                        [[NSUserDefaults standardUserDefaults] setBool:[[_checkNullArray valueForKey:@"IsReviewer"]boolValue] forKey:@"IsReviewer"];
//                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                       
                        
                        if ([[_checkNullArray valueForKey:@"IsPasswordProtected"] boolValue]==YES) {

                            //workflow type  == 3
                            
                            if ([[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue] == 3)
                            {
                                [self parallelSigning:indexPath.row];
                            }
                            
                            NSData *data = [[NSData alloc]initWithBase64EncodedString:_pdfImageArray options:0];
                            // from your converted Base64 string
                            NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
                            path = [documentsDirectory stringByAppendingPathComponent:@"test.pdf"];
                            [data writeToFile:path atomically:YES];

                            [[NSUserDefaults standardUserDefaults] setObject:path forKey:@"pathForDoc"];
                            [[NSUserDefaults standardUserDefaults] synchronize];

                            NSString *displayName = [[_filterArray objectAtIndex:indexPath.row] objectForKey:@"DisplayName"];
                            [[NSUserDefaults standardUserDefaults] setObject:displayName forKey:@"displayName"];
                            [[NSUserDefaults standardUserDefaults] synchronize];

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
                                [self stopActivity];
                                return;
                            }

                           
                        }
                        
                        if (_pdfImageArray != (id)[NSNull null] && _pdfImageArray != nil)
                        {
                            
                            //workflow type  == 3
                            
                            if ([[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue] == 3)
                            {
                                [self parallelSigningNoPassword:indexPath.row];
                            }
                            
                            NSData *data = [[NSData alloc]initWithBase64EncodedString:_pdfImageArray options:0];
                            // from your converted Base64 string
                            NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
                            NSString *path = [documentsDirectory stringByAppendingPathComponent:@"test.pdf"];
                            [data writeToFile:path atomically:YES];
                            
                            CompletedNextVC *temp = [[CompletedNextVC alloc] init];//WithFilename:path path:path document: doc];
                            if ([[[responseValue valueForKey:@"Response"] valueForKey:@"IsSignatory"] boolValue] == NO && [[[responseValue valueForKey:@"Response"] valueForKey:@"IsReviewer"] boolValue] == NO)
                            {

                                temp.pdfImagedetail = _pdfImageArray;
                                temp.workflowID = [[            _filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkFlowId"];
                                temp.documentCount = [[[responseValue valueForKey:@"Response"] valueForKey:@"NoOfDocuments"] stringValue];
                                temp.attachmentCount = [[[responseValue valueForKey:@"Response"] valueForKey:@"NoOfAttachments"] stringValue];
                                temp.documentID = [[[responseValue valueForKey:@"Response"] valueForKey:@"DocumentId"]objectAtIndex:0];
                                temp.isDocStore = true;
                                temp.signatoryString = mstrXMLString;
                                //temp.isSignatory = [[_checkNullArray valueForKey:@"IsSignatory"] boolValue];
                                temp.strExcutedFrom=@"DocsStore";
                                temp.myTitle = [[_filterArray objectAtIndex:indexPath.row] objectForKey:@"DisplayName"];
                                temp.signatorylbl.text = self.mstrXMLString;
                                [self.navigationController pushViewController:temp animated:YES];
                                [self stopActivity];
                                return;
                                
                            }
                            else //if( [[[responseValue valueForKey:@"Response"] valueForKey:@"IsSignatory"] boolValue] == true )
                            {
                                PendingListVC *temp = [[PendingListVC alloc] init];//WithFilename:path path:path document: doc];
                                temp.pdfImagedetail = _pdfImageArray;
                                temp.workFlowID = [[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkFlowId"];
                                temp.documentCount = [[[responseValue valueForKey:@"Response"] valueForKey:@"NoOfDocuments"] stringValue];
                                temp.attachmentCount = [[[responseValue valueForKey:@"Response"] valueForKey:@"NoOfAttachments"] stringValue];
                                //temp.isSignatory = [[_checkNullArray valueForKey:@"IsSignatory"] boolValue];
                                temp.documentID = [[[responseValue valueForKey:@"Response"] valueForKey:@"DocumentId"]objectAtIndex:0];
                                temp.isDocStore = true;
                                temp.strExcutedFrom=@"DocsStore";
                                temp.myTitle = [[_filterArray objectAtIndex:indexPath.row] objectForKey:@"DisplayName"];
                                temp.signatoryString = mstrXMLString;
                                temp.statusId = statusId;
                                temp.signatoryHolderArray = arr;
                                temp.placeholderArray = coordinatesArray;
                                
                                temp.workFlowType = [[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"];
                                temp.isSignatory = [[_checkNullArray valueForKey:@"IsSignatory"]boolValue];
                                temp.isReviewer = [[_checkNullArray valueForKey:@"IsReviewer"]boolValue];
                                [self stopActivity];
                                [self.navigationController pushViewController:temp animated:YES];
                                
                                return;
                            }
                        }
                        else{
                            
                            UIAlertController * alert = [UIAlertController
                                                         alertControllerWithTitle:@""
                                                         message:@"This file is corrupted."
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
                                                 alertControllerWithTitle:@""
                                                 message:@"This file is corrupted."
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
    
    
    
    /*****************************In-Progess******************************/
    else if ([[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"Status"] isEqualToString:@"Cosign-Pending"])
    {
        [self startActivity:@"Loading..."];
        
        NSString *requestURL = [NSString stringWithFormat:@"%@GetDocumentDetailsById?workFlowId=%@&workflowType=%@",kOpenPDFImage,[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkFlowId"],[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]];
        [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
            
            if(status && [responseValue valueForKey:@"Response"]!= [NSNull null])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    _checkNullArray = [responseValue valueForKey:@"Response"];
                    
                    _pdfImageArray=[[responseValue valueForKey:@"Response"] valueForKey:@"Document"];
                
                    
                    NSArray *arr =  [_checkNullArray valueForKey:@"Signatory"];
                    
                    //workflow type 2
                    if ([[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue] == 2)
                    {
                        [self alertForFlexiforms];
                        return ;
                    }
                    
                    //workflow type 4
                    
                    if ([[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue] == 4)
                    {
                        [self alertForBulkDocuments];
                        return;
                    }
                    
                    //workflow type 5
                    if ([[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue] == 5)
                    {
                        [self alertForCollaborative];
                        return;
                    }
                    if ([[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"SignatureType"]integerValue] == 2)
                    {
                        [self alertForReview];
                        return;
                    }
                    
                    
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
                    
                    //hghghghgh
                    
                    if (_pdfImageArray != (id)[NSNull null] && _pdfImageArray != nil)
                    {
                    
                    if ([[[responseValue valueForKey:@"Response"] valueForKey:@"IsPasswordProtected"] boolValue]==YES) {
                        
                        NSString *checkPassword = [[responseValue valueForKey:@"Response"] valueForKey:@"IsPasswordProtected"];
                        [[NSUserDefaults standardUserDefaults] setObject:checkPassword forKey:@"checkPassword"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        NSLog(@"%@",[[responseValue valueForKey:@"Response"] valueForKey:@"DisplayName"]);
                        
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
                            [self stopActivity];
                            return;
                        }
                        
                       
                    }
                    
                        NSData *data = [[NSData alloc]initWithBase64EncodedString:_pdfImageArray options:0];
                        // from your converted Base64 string
                        NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
                        NSString *path = [documentsDirectory stringByAppendingPathComponent:@"test.pdf"];
                        [data writeToFile:path atomically:YES];
                        
                        CoSignPendingListVC *temp = [[CoSignPendingListVC alloc] init];//WithFilename:path path:path document: doc];
                        
                        temp.pdfImagedetail = _pdfImageArray;
                        temp.workflowID = [[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkFlowId"];
                        temp.documentCount = [[[responseValue valueForKey:@"Response"] valueForKey:@"NoOfDocuments"] stringValue];
                        temp.documentID = [[[responseValue valueForKey:@"Response"] valueForKey:@"DocumentId"]objectAtIndex:0];

                        temp.strExcutedFrom=@"DocsStore";
                        temp.attachmentCount = [[[responseValue valueForKey:@"Response"] valueForKey:@"NoOfAttachments"] stringValue];
                        temp.myTitle = [[_filterArray objectAtIndex:indexPath.row] objectForKey:@"DisplayName"];
                        temp.signatoryString = mstrXMLString;

                        [self.navigationController pushViewController:temp animated:YES];
                        [self stopActivity];
                    }
                    else{

                        UIAlertController * alert = [UIAlertController
                                                     alertControllerWithTitle:@""
                                                     message:@"This file is corrupted. "
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
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message: @"This file is corrupted." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
                [self stopActivity];
            }
            
        }];
    }
    
    
        /***************************Inactive*******************************************/
    
        else if ([[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"Status"] isEqualToString:@"InActive"])
        {
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"Document is Inactive"
                                         message:@""
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
            
        }
    
        /*****************************Declined*****************************************/
        else if ([[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"Status"] isEqualToString:@"Declined"])
        {
            //************************Web Service******************************
            
            [self startActivity:@"Loading..."];
            
            NSString *requestURL = [NSString stringWithFormat:@"%@GetDeclinedRemarks?WorkFlowId=%@",kDeclineRemarks,[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkFlowId"]];
            [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
                
                //if(status)
                if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _pdfImageArray=[responseValue valueForKey:@"Response"];
                        UIAlertController * alert = [UIAlertController
                                                     alertControllerWithTitle:@"Declined Document Remarks"
                                                     message:[responseValue valueForKey:@"Response"]
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
                       
                    });
                }
                else{
                    UIAlertController * alert = [UIAlertController
                                                 alertControllerWithTitle:@""
                                                 message:@"This file is corrupted."
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
        /*****************************Completed***********************************/
        else if ([[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"Status"] isEqualToString:@"Completed"])
        {
            [self startActivity:@"Loading..."];
            
              NSString* stateComplete = [[_filterArray objectAtIndex:indexPath.row] valueForKey:@"Status"] ;
              [[NSUserDefaults standardUserDefaults] setObject:stateComplete forKey:@"stateComplete"];
              [[NSUserDefaults standardUserDefaults] synchronize];
            NSString *requestURL = [NSString stringWithFormat:@"%@GetDocumentDetailsById?workFlowId=%@&workflowType=%@",kOpenPDFImage,[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkFlowId"],[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]];
            [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
                
               // if(status)
                if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        _pdfImageArray=[[responseValue valueForKey:@"Response"] valueForKey:@"Document"];
                        
                        //hjhdjdhjhd
                        NSArray *arr =  [[responseValue valueForKey:@"Response"] valueForKey:@"Signatory"];
                        
                        //workflow type 2
                        if ([[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue] == 2)
                        {
                            [self alertForFlexiforms];
                            return ;
                        }
                        
                        //workflow type 4
                        
                        if ([[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue] == 4)
                        {
                            [self alertForBulkDocuments];
                            return;
                        }
                        
                        //workflow type 5
                        if ([[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue] == 5)
                        {
                            [self alertForCollaborative];
                            return;
                        }
                        
                    //    mstrXMLString = [[NSMutableString alloc] init];
                        
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
                        
                        
                        
                        if (_pdfImageArray != (id)[NSNull null] && _pdfImageArray != nil)
                        {
                            if ([[[responseValue valueForKey:@"Response"] valueForKey:@"IsPasswordProtected"] boolValue]==YES) {
                                
                                NSLog(@"%@",[[responseValue valueForKey:@"Response"] valueForKey:@"DisplayName"]);
                                
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
                                
                                NSString *docCount = [[[responseValue valueForKey:@"Response"] valueForKey:@"NoOfDocuments"] stringValue];
                                [[NSUserDefaults standardUserDefaults] setObject:docCount forKey:@"docCount"];
                                [[NSUserDefaults standardUserDefaults] synchronize];
                                
                                NSString *attachmentCount = [[[responseValue valueForKey:@"Response"] valueForKey:@"NoOfAttachments"] stringValue];
                                [[NSUserDefaults standardUserDefaults] setObject:attachmentCount forKey:@"attachmentCount"];
                                [[NSUserDefaults standardUserDefaults] synchronize];
                                
                                NSString *workflowId = [[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkFlowId"];;
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
                                    [self stopActivity];
                                    return;
                                    
                                }
                                
                               
                            }

                            NSData *data = [[NSData alloc]initWithBase64EncodedString:_pdfImageArray options:0];
                            // from your converted Base64 string
                            NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
                            NSString *path = [documentsDirectory stringByAppendingPathComponent:@"test.pdf"];
                            [data writeToFile:path atomically:YES];
                            
                            CompletedNextVC *temp = [[CompletedNextVC alloc] init];//WithFilename:path path:path document: doc];
                            temp.pdfImagedetail = _pdfImageArray;
                            temp.workflowID = [[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkFlowId"];
                            temp.documentCount = [[[responseValue valueForKey:@"Response"] valueForKey:@"NoOfDocuments"] stringValue];
                            temp.attachmentCount = [[[responseValue valueForKey:@"Response"] valueForKey:@"NoOfAttachments"] stringValue];
                            temp.documentID = [[[responseValue valueForKey:@"Response"] valueForKey:@"DocumentId"]objectAtIndex:0];

                            temp.strExcutedFrom=@"DocsStore";
                            temp.myTitle = [[_filterArray objectAtIndex:indexPath.row] objectForKey:@"DisplayName"];
                            temp.signatoryString = mstrXMLString;
                            [self.navigationController pushViewController:temp animated:YES];
                            [self stopActivity];
                        
                        }
                        else{

                            UIAlertController * alert = [UIAlertController
                                                         alertControllerWithTitle:@""
                                                         message:@"This file is corrupted. "
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
                                                 alertControllerWithTitle:@""
                                                 message:@"This file is corrupted."
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
        
        /***************************Recalled************************************/
        else if ([[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"Status"] isEqualToString:@"Recalled"])
        {
            /*************************Web Service*******************************/
            
            [self startActivity:@"Loading..."];
            
            NSString *requestURL = [NSString stringWithFormat:@"%@GetRecalledRemarks?WorkFlowId=%@",kRecallRemarks,[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkFlowId"]];
            [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
                
               // if(status)
                if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

                {
                    //Adarsha Recall
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _pdfImageArray=[responseValue valueForKey:@"Response"];
                        //
                        UIAlertController * alert = [UIAlertController
                                                     alertControllerWithTitle:@"Recalled Document Remarks"
                                                     message:[responseValue valueForKey:@"Response"]
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
                    });
                }
                else{
                    UIAlertController * alert = [UIAlertController
                                                 alertControllerWithTitle:@""
                                                 message:@"This file is corrupted. "
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
    
    /***************************(Document Uploaded )************************************/
        else if ([[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"Status"] isEqualToString:@"Document Uploaded"])
        {
            /*************************Web Service*******************************/
            
            
            _docsStoretoolbar.hidden = NO;
            [self startActivity:@"Loading..."];
            
            NSString *requestURL = [NSString stringWithFormat:@"%@GetDrFileData?workFlowId=%@",kDraftPDFImage,[[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkFlowId"]];
            [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
                
              //  if(status)
                if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _pdfImageArray=[responseValue valueForKey:@"Response"];
                        [self stopActivity];
                        
                    });
                }
                else{
                    UIAlertController * alert = [UIAlertController
                                                 alertControllerWithTitle:@""
                                                 message:@"This file is corrupted."
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
    
    //Draft
        else{
            [self startActivity:@"Loading..."];
            
            NSString *requestURL = [NSString stringWithFormat:@"%@GetFileData?docuentid=%@",kDraftPDFImage,_workflowID];
            [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
                
                //if(status)
                if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

                {
                    [self stopActivity];
                    UIAlertController * alert = [UIAlertController
                                                                    alertControllerWithTitle:@"emSigner"
                                                                    message:@"Summary found successfully!"
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
                                           [self presentViewController:alert animated:YES completion:nil];});
                                       
                                   }
                    
                 /*   dispatch_async(dispatch_get_main_queue(), ^{
                        _pdfImageArray=[responseValue valueForKey:@"Response"];

                        
                       if ([[[responseValue valueForKey:@"Response"] valueForKey:@"IsPasswordProtected"] boolValue]==YES) {
                            
                               // NSLog(@"%@",[[responseValue valueForKey:@"Response"] valueForKey:@"FileData"]);
                                
                                NSData *data = [[NSData alloc]initWithBase64EncodedString:[[responseValue valueForKey:@"Response"] valueForKey:@"FileData"] options:0];
                                // from your converted Base64 string
                                NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
                                NSString *path = [documentsDirectory stringByAppendingPathComponent:@"test.pdf"];
                                [data writeToFile:path atomically:YES];
                                
                                [[NSUserDefaults standardUserDefaults] setObject:path forKey:@"pathForDoc"];
                                [[NSUserDefaults standardUserDefaults] synchronize];
                                
                                NSString *displayName = [[_filterArray objectAtIndex:indexPath.row] objectForKey:@"DisplayName"];
                                [[NSUserDefaults standardUserDefaults] setObject:displayName forKey:@"displayName"];
                                [[NSUserDefaults standardUserDefaults] synchronize];
                                
                                NSString *docCount = [[[responseValue valueForKey:@"Response"] valueForKey:@"NoOfDocuments"] stringValue];
                                [[NSUserDefaults standardUserDefaults] setObject:docCount forKey:@"docCount"];
                                [[NSUserDefaults standardUserDefaults] synchronize];
                                
                                NSString *attachmentCount = [[[responseValue valueForKey:@"Response"] valueForKey:@"NoOfAttachments"] stringValue];
                                [[NSUserDefaults standardUserDefaults] setObject:attachmentCount forKey:@"attachmentCount"];
                                [[NSUserDefaults standardUserDefaults] synchronize];
                                
                                NSString *workflowId = [[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkFlowId"];;
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
                                    [self stopActivity];
                                    return;
                                }
                                
                        }
                        
                        //Check Null String
                        NSString *descriptionStr2;
                        descriptionStr2=[[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[[responseValue valueForKey:@"Response"] valueForKey:@"FileData"]]];
                        
                        NSData *data = [[NSData alloc]initWithBase64EncodedString:descriptionStr2 options:0];
                        // from your converted Base64 string
                        NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
                        NSString *path = [documentsDirectory stringByAppendingPathComponent:@"test.pdf"];
                        [data writeToFile:path atomically:YES];
                        
                        DraftInactiveVC *temp = [[DraftInactiveVC alloc] init];//WithFilename:path path:path document: doc];
                        temp.pdfImagedetail = descriptionStr2;
                        temp.myTitle = [[_filterArray objectAtIndex:indexPath.row] objectForKey:@"DisplayName"];
                        temp.workflowID = [[_filterArray objectAtIndex:indexPath.row] valueForKey:@"WorkFlowId"];
                        [self.navigationController pushViewController:temp animated:YES];
                        [self stopActivity];
                        
                    });*/
                
                else{
                    
                    UIAlertController * alert = [UIAlertController
                                                 alertControllerWithTitle:@"emSigner"
                                                 message:@"Contact eMudhra for more details"
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
                        [self presentViewController:alert animated:YES completion:nil];});
                    
                }
                
            }];
        }

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

-(void)docInfoBtnClicked:(UIButton*)sender
{
    alert =   [[UIAlertController
                alloc]init];
     Info = [UIAlertAction
                           actionWithTitle:@"View Document Information"
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
                           {
                               //Do some thing here

                               
                                 [self getDocumentInfo:[[_filterArray objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"]];

                               
                           }];
   

   
     DocLog = [UIAlertAction
                             actionWithTitle:@"Document Log"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                 DocumentLogVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"DocumentLogVC"];
                                 
                                 objTrackOrderVC.workflowID = [[_filterArray objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"];
                                 [self.navigationController pushViewController:objTrackOrderVC animated:YES];
                             }];
    
    Download = [UIAlertAction
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
                                                                   
                                                                   [self startActivity:@"Loading..."];
                                                                   NSString *requestURL = [NSString stringWithFormat:@"%@DownloadWorkflowDocuments?WorkFlowId=%@",kDownloadPdf,[[_filterArray objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"]];
                                                                   [self download:requestURL];
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
    Share = [UIAlertAction
                            actionWithTitle:@"Share Document"
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action)
                            {
                                
                                NSString *pendingdocumentName =[[_filterArray objectAtIndex:sender.tag] valueForKey:@"DisplayName"];
                                NSString* documentId = [[_filterArray objectAtIndex:sender.tag] valueForKey:@"DocumentId"];

                                NSString *pendingWorkflowID =[[_filterArray objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"];
                                UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                ShareVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"ShareVC"];
                                objTrackOrderVC.documentName = pendingdocumentName;
                                objTrackOrderVC.documentID = documentId;

                                objTrackOrderVC.workflowID = pendingWorkflowID;
                                [self.navigationController pushViewController:objTrackOrderVC animated:YES];
                                
                            }];
    
     cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [Info setValue:[[UIImage imageNamed:@"information-outline-2.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [Decline setValue:[[UIImage imageNamed:@"cancel.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [DocLog setValue:[[UIImage imageNamed:@"stack-exchange.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [Download setValue:[[UIImage imageNamed:@"download.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [Share setValue:[[UIImage imageNamed:@"share-variant.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    
    [Info setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    [Decline setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    [DocLog setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    [Download setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    [Share setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    
    alert.view.tintColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
    [alert addAction:Info];
    //[alert addAction:Decline];
    [alert addAction:DocLog];
    [alert addAction:Download];
    [alert addAction:Share];
    
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
    
}


-(void)docInfoBtnClickedWaiting:(UIButton*)sender
{
    
    alert = [[UIAlertController alloc]init];
    Info = [UIAlertAction
                           actionWithTitle:@"View Document Information"
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
                           {
                               //Do some thing here
                               
                               [self getDocumentInfo:[[_filterArray objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"]];
                               
                           }];
     Inactive = [UIAlertAction
                              actionWithTitle:@"Mark as Inactive"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  
                                  UIAlertController * alert = [UIAlertController
                                                               alertControllerWithTitle:@"Mark Inactive"
                                                               message:@"Do you  want to mark as inactive?"
                                                               preferredStyle:UIAlertControllerStyleAlert];
                                  
                                  //Add Buttons
                                  
                                  UIAlertAction* yesButton = [UIAlertAction
                                                              actionWithTitle:@"Yes"
                                                              style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  //Handle your yes please button action here
                                                                  [self startActivity:@"Processing..."];
                                                                  NSString *requestURL = [NSString stringWithFormat:@"%@MarkAsInactive?documentId=%@&status=%@",kInactive,[[_filterArray objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"],@"Pending"];
                                                                  [self inactive:requestURL];

                                                              }];
                                  [alert addAction:yesButton];
                                  
                                  UIAlertAction* noButton = [UIAlertAction
                                                             actionWithTitle:@"No"
                                                             style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 //Handle your yes please button action here
                                                                 
                                                             }];
                                  [alert addAction:noButton];
                                  [self presentViewController:alert animated:YES completion:nil];

                              }];
    
    Recall = [UIAlertAction
              actionWithTitle:@"Recall Document"
              style:UIAlertActionStyleDefault
              handler:^(UIAlertAction * action)
              {
                  UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                  RecallVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"RecallVC"];
                  self.definesPresentationContext = YES; //self is presenting view controller
                  objTrackOrderVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
                  objTrackOrderVC.workflowID = [[_filterArray objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"];
                  objTrackOrderVC.strExcutedFrom=@"WaitingForOther";
                  [self.navigationController presentViewController:objTrackOrderVC animated:YES completion:nil];
                  
              }];
    
    DocLog = [UIAlertAction
                             actionWithTitle:@"Document log"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                 DocumentLogVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"DocumentLogVC"];
                                 
                                 objTrackOrderVC.workflowID = [[_filterArray objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"];
                                 [self.navigationController pushViewController:objTrackOrderVC animated:YES];
                             }];
    Download = [UIAlertAction
                               actionWithTitle:@"Download"
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
                                                                   
                                                                   [self startActivity:@"Loading..."];
                                                                   NSString *requestURL = [NSString stringWithFormat:@"%@DownloadWorkflowDocuments?WorkFlowId=%@",kDownloadPdf,[[_filterArray objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"]];
                                                                   [self download:requestURL];
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

   Share = [UIAlertAction
                            actionWithTitle:@"Share"
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action)
                            {
                                
                                NSString *pendingdocumentName =[[_filterArray objectAtIndex:sender.tag] valueForKey:@"DisplayName"];
                                NSString* documentId = [[_filterArray objectAtIndex:sender.tag] valueForKey:@"DocumentId"];

                                NSString *pendingWorkflowID =[[_filterArray objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"];
                                UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                ShareVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"ShareVC"];
                                objTrackOrderVC.documentName = pendingdocumentName;
                                objTrackOrderVC.documentID = documentId;

                                objTrackOrderVC.workflowID = pendingWorkflowID;
                                [self.navigationController pushViewController:objTrackOrderVC animated:YES];
                                
                            }];
     cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction * action)
                             {
                             }];
    
    [Info setValue:[[UIImage imageNamed:@"information-outline-2.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [Inactive setValue:[[UIImage imageNamed:@"minus-circle.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [Recall setValue:[[UIImage imageNamed:@"tumblr-reblog.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [DocLog setValue:[[UIImage imageNamed:@"stack-exchange.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [Download setValue:[[UIImage imageNamed:@"download.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [Share setValue:[[UIImage imageNamed:@"share-variant.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    
    [Info setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    [Inactive setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    [Recall setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    [DocLog setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    [Download setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    [Share setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    
    alert.view.tintColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
    [alert addAction:Info];
    [alert addAction:Inactive];
    [alert addAction:Recall];
    [alert addAction:DocLog];
    [alert addAction:Download];
    [alert addAction:Share];
    
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(void)docInfoBtnClickedComplted:(UIButton*)sender
{
   
    alert =   [[UIAlertController
                alloc]init];
              Info = [UIAlertAction
                           actionWithTitle:@"View Document Information"
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
                           {
                               //Do some thing here
                               
                               [self getDocumentInfo:[[_filterArray objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"]];
                               
                           }];
   DocLog = [UIAlertAction
                             actionWithTitle:@"Document Log"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                 DocumentLogVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"DocumentLogVC"];
                                 objTrackOrderVC.workflowID = [[_filterArray objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"] ;
                                 [self.navigationController pushViewController:objTrackOrderVC animated:YES];                              }];
     Download = [UIAlertAction
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
                                                                   [self download:requestURL];
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
    Share = [UIAlertAction
                            actionWithTitle:@"Share Document"
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action)
                            {
                                
                                NSString *pendingdocumentName =[[_filterArray objectAtIndex:sender.tag] valueForKey:@"DisplayName"];
                                NSString* documentId = [[_filterArray objectAtIndex:sender.tag] valueForKey:@"DocumentId"];

                                NSString *pendingWorkflowID =[[_filterArray objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"];
                                UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                ShareVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"ShareVC"];
                                objTrackOrderVC.documentName = pendingdocumentName;
                                objTrackOrderVC.documentID = documentId;

                                objTrackOrderVC.workflowID = pendingWorkflowID;
                                [self.navigationController pushViewController:objTrackOrderVC animated:YES];
                                
                            }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [Info setValue:[[UIImage imageNamed:@"information-outline-2.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [DocLog setValue:[[UIImage imageNamed:@"stack-exchange.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [Download setValue:[[UIImage imageNamed:@"download.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [Share setValue:[[UIImage imageNamed:@"share-variant.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    
    alert.view.tintColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];

    [Info setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    [DocLog setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    [Download setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    [Share setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];

    [alert addAction:Info];
    [alert addAction:DocLog];
    [alert addAction:Download];
    [alert addAction:Share];
    
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];

}
-(void)docInfoBtnClickedDeclined:(UIButton*)sender
{

    [self getDocumentInfo:[[_filterArray objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"]];

    
}

-(void)docInfoBtnClickedRecall:(UIButton*)sender
{
    [self getDocumentInfoForRecalled:[[_filterArray objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"]];

}

-(void)getDocumentInfo:(NSString*)workflowId
{
    
    [self startActivity:@"Loading.."];
    NSString *requestURL = [NSString stringWithFormat:@"%@GetDocumentInfo?WorkFlowId=%@",kDocumentInfo,workflowId];
    
    [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
        
       // if(status)
        if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

        {
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               _docInfoArray = [responseValue valueForKey:@"Response"];
                               
                               if (_docInfoArray != (id)[NSNull null])
                               {
                                   
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
        }
    }];
    
    
}

-(void)getDocumentInfoForRecalled:(NSString*)workflowId

{
    
    [self startActivity:@"Loading.."];
    NSString *requestURL = [NSString stringWithFormat:@"%@GetDocumentInfo?WorkFlowId=%@",kDocumentInfo,workflowId];
    
    [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
        
        // if(status)
        if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])
            
        {
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               _docInfoArray = [responseValue valueForKey:@"Response"];
                               
                               if (_docInfoArray != (id)[NSNull null])
                               {
                                   if(_docInfoArray.count == 1)
                                   {
                                       UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                       DocumentInfoVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"DocumentInfoVC"];
                                       objTrackOrderVC.documentInfoArray = _docInfoArray[0];
                                       objTrackOrderVC.docInfoWorkflowId = workflowId;

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
           
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:nil
                                         message:[[responseValue valueForKey:@"Messages"]objectAtIndex:0]
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            //Add Buttons
            
            UIAlertAction* yesButton = [UIAlertAction
                                        actionWithTitle:@"Ok"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
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
    return;
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
    return;
}
-(void) alertForReview
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@""
                                 message:@"Review documents can't be opened as of now."
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
    return;
}


#pragma mark  - parallel signing

-(void)parallelSigningNoPassword:(long)indexpath
{
    int checkIsOpen = [[[_checkNullArray valueForKey:@"CurrentStatus"]valueForKey:@"IsOpened"]intValue];
    
    if (checkIsOpen == 1)
    {
        
        // [@"Email Id : " stringByAppendingFormat:@"%@", [[signatoriescount objectAtIndex:indexPath.row]valueForKey:@"EmailID"]]
        
        NSString *namneAndString = [NSString stringWithFormat:@"%@,%@.", [[_checkNullArray valueForKey:@"CurrentStatus"]valueForKey:@"Name"],[[_checkNullArray valueForKey:@"CurrentStatus"]valueForKey:@"EmailId"]];
        
        NSString *message = [[@"Document is currently opened by " stringByAppendingString:namneAndString] stringByAppendingString:@" So document can be opened in read only mode ."];
        
        
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@""
                                     message:message
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        //Add Buttons
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Ok"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        //Handle your yes please button action here
                                        
                                        _pdfImageArray=[_checkNullArray valueForKey:@"Document"];
                                        
                                        NSData *data = [[NSData alloc]initWithBase64EncodedString:_pdfImageArray options:0];
                                        NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
                                        NSString *path = [documentsDirectory stringByAppendingPathComponent:[[_checkNullArray valueForKey:@"DocumentName"] objectAtIndex:0]];
                                        [data writeToFile:path atomically:YES];
                                        
                                        CFUUIDRef uuid = CFUUIDCreate(NULL);
                                        CFStringRef uuidString = CFUUIDCreateString(NULL, uuid);
                                        CFRelease(uuid);
                                        
                                        //Add signBox
                                        UIImage *image = [UIImage imageNamed:@"signer.png"];
                                        
                                        
                                        if (coordinatesArray.count != 0) {
                                            // path = [self addSignature:image onPDFData:data withCoordinates:coordinatesArray Count:arr];
                                            //   path = [createPdfString addSignature:image onPDFData:data withCoordinates:coordinatesArray Count:arr];
                                            
                                            
                                        }
                                        
                                        if (isdelegate == false) {
                                            CompletedNextVC *temp = [[CompletedNextVC alloc] init];//WithFilename:path path:path document: doc];
                                            temp._pathForDoc = path;
                                            temp.pdfImagedetail = _pdfImageArray;
                                            temp.myTitle = [[_checkNullArray valueForKey:@"DocumentName"]objectAtIndex:0];
                                            temp.strExcutedFrom=@"Completed";
                                            temp.workflowID = [[_filterArray objectAtIndex:indexpath] valueForKey:@"WorkFlowId"];
                                            temp.documentCount = [[_checkNullArray valueForKey:@"NoOfDocuments"] stringValue];
                                            temp.signatoryString = mstrXMLString;
                                            temp.attachmentCount = [[_checkNullArray valueForKey:@"NoOfAttachments"] stringValue];
                                            [self.navigationController pushViewController:temp animated:YES];
                                            [self stopActivity];
                                            return;
                                        }
                                        else{
                                            ParallelSigning *temp = [[ParallelSigning alloc] init];//WithFilename:path path:path document: doc];
                                            
                                            temp._pathForDoc = path;
                                            temp.pdfImagedetail = _pdfImageArray;
                                            temp.myTitle = [[_checkNullArray valueForKey:@"DocumentName"]objectAtIndex:0];
                                            temp.strExcutedFrom=@"Completed";
                                            temp.workflowID = [[_filterArray objectAtIndex:indexpath] valueForKey:@"WorkFlowId"];
                                            temp.documentCount = [[_checkNullArray valueForKey:@"NoOfDocuments"] stringValue];
                                            temp.signatoryString = mstrXMLString;
                                            // temp.parallel = 1;
                                            temp.placeholderArray = coordinatesArray;
                                            temp.matchSignersList = arr;
                                            
                                            temp.attachmentCount = [[_checkNullArray valueForKey:@"NoOfAttachments"] stringValue];
                                            [self.navigationController pushViewController:temp animated:YES];
                                            [self stopActivity];
                                        }
                                    }];
        
        //Add your buttons to alert controller
        
        [alert addAction:yesButton];
        
        [self presentViewController:alert animated:YES completion:nil];
        [self stopActivity];
        return;
        
    }
    
}


-(void)parallelSigning:(long )indexPath
{
    int checkIsOpen = [[[_checkNullArray valueForKey:@"CurrentStatus"]valueForKey:@"IsOpened"]intValue];
    
    if (checkIsOpen == 1)
    {
        isopened = true;
        NSString *namneAndString = [NSString stringWithFormat:@"%@,%@.", [[_checkNullArray valueForKey:@"CurrentStatus"]valueForKey:@"Name"],[[_checkNullArray valueForKey:@"CurrentStatus"]valueForKey:@"EmailId"]];
        
        NSString *message = [[@"Document is currently opened by " stringByAppendingString:namneAndString] stringByAppendingString:@" So document can be opened in read only mode ."];
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@""
                                     message:message
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
        // return;
    }
    else
    {
        isopened = false;
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
    _searchResults = [[NSArray alloc]init];
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
   // _currentPage = 1;
    _filterArray = [_filterSecondDocstoreArray mutableCopy];
       
          [_tableView reloadData];
 //   [self makeServieCallWithPageNumaber:_currentPage :searchSting];
    
    //remaining Code'll go here
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    

    if ([searchText length] == 0) {
           self.searchResults = nil;
           _filterArray = [_filterSecondDocstoreArray mutableCopy];
           [_tableView reloadData];
           [searchBar resignFirstResponder];
       }
     
       else{
       
       NSPredicate *filter = [NSPredicate predicateWithFormat:@"DisplayName contains[c] %@ ",searchText];
        
           _searchResults = [_filterArray  filteredArrayUsingPredicate:filter];

           if (_searchResults.count == 0) {
               self.searchResults = nil;
               _filterArray = [_searchResults mutableCopy];
               [_tableView reloadData];
               [searchBar resignFirstResponder];
              

           }
           else{
               _filterArray = [_searchResults mutableCopy];
               [_tableView reloadData];
           }

       }
}
/*
  (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
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
   //  _searchResults = [NSMutableArray array];
     searchBar.text = @"";
     [searchBar resignFirstResponder];
     [searchBar setShowsCancelButton:NO animated:YES];
     _ShowSignersList = [_holdSignersList mutableCopy];
    
       [self.signersList reloadData];

     //remaining Code'll go here
 }

 -(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
 {    if ([searchText length] == 0) {
         self.searchResults = nil;
         _ShowSignersList = [_holdSignersList mutableCopy];
         [self.signersList reloadData];
         [searchBar resignFirstResponder];
     }
   
     else{
     
     NSPredicate *filter = [NSPredicate predicateWithFormat:@"FullName contains[c] %@ ",searchText];
      
         _searchResults = [self.ShowSignersList  filteredArrayUsingPredicate:filter];

         if (_searchResults.count == 0) {
             _ShowSignersList = [[NSMutableArray alloc]init];
             [self.signersList reloadData];

         }
         else{
             _ShowSignersList = [_searchResults mutableCopy];
             [self.signersList reloadData];
         }

     }
 }
 
 */

- (IBAction)cancelBtn:(id)sender {
    _docsStoretoolbar.hidden = YES;
    [_tableView reloadData];
}

- (IBAction)inactiveBtn:(id)sender {
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Inactive"
                                 message:@"Do you want to mark the document as inactive?"
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
                                        
                                      //  if(status)
                                        if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

                                        {
                                            dispatch_async(dispatch_get_main_queue(),
                                                           ^{
                                                               
                                                               _inactiveArray =responseValue;
                                                               _docsStoretoolbar.hidden = YES;
                                                               [self.navigationController popViewControllerAnimated:YES];
                                                               [self stopActivity];
                                                               
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
                                    //Handle your yes please button action here
                                    
                                }];
    
    //Add your buttons to alert controller
    
    [alert addAction:yesButton];
    [alert addAction:noButton];
    
    [self presentViewController:alert animated:YES completion:nil];
 
}

- (IBAction)downloadBtn:(id)sender {

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
                                        
                                       // if(status)
                                        if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

                                        {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                
                                                int Count;
                                                
                                                //Check Null String Address
                                                NSString *descriptionStr;
                                                descriptionStr=[[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[responseValue valueForKey:@"Response"]]];
                                                
                                                NSData *data = [[NSData alloc]initWithBase64EncodedString:descriptionStr options:0];
                                                NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
                                                NSString *path = [documentsDirectory stringByAppendingPathComponent:_openFileName];
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
                                    
                                }];
    
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"No"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   //Handle your yes please button action here
                                   
                               }];
    
    //Add your buttons to alert controller
    
    [alert addAction:yesButton];
    [alert addAction:noButton];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (IBAction)shareBtn:(id)sender {
    UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ShareVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"ShareVC"];
    self.definesPresentationContext = YES;
    objTrackOrderVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    objTrackOrderVC.strExcutedFrom=@"Completed";
    objTrackOrderVC.strExcutedFrom=@"Initiate";
    objTrackOrderVC.strExcutedFrom=@"WaitingForOther";
    objTrackOrderVC.strExcutedFrom=@"darfts";
    objTrackOrderVC.workflowID = _workflowID;
    [self.navigationController presentViewController:objTrackOrderVC animated:YES completion:nil];
    _docsStoretoolbar.hidden = YES;
}


-(void)inactive:(NSString*)requestUrl
{
    [self stopActivity];

    [WebserviceManager sendSyncRequestWithURLGet:requestUrl method:SAServiceReqestHTTPMethodGET body:requestUrl completionBlock:^(BOOL status, id responseValue) {
        
       // if(status)
        if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

        {
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               
                               
                               NSArray* _inactiveArray =responseValue;
                               /*******************/
                               [self.navigationController popViewControllerAnimated:YES];
                               
                           });
            
        }
        else{
            
        }
        
    }];
    
}


-(void)download:(NSString*)requestUrl
{
    
    [WebserviceManager sendSyncRequestWithURLGet:requestUrl method:SAServiceReqestHTTPMethodGET body:requestUrl completionBlock:^(BOOL status, id responseValue) {
        
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

#pragma mark ask for password


- (void)openDocument:(NSString *)file
{
    if ([self.pdfDocument isLocked]){
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
        if ([self.pdfDocument isLocked]){
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
    
  //  NSString *path  = [[NSUserDefaults standardUserDefaults] valueForKey:@"pathForDoc"];
    NSString *displayName = [[NSUserDefaults standardUserDefaults] valueForKey:@"displayName"];
    NSString *docCount = [[NSUserDefaults standardUserDefaults] valueForKey:@"docCount"];
    NSString *attachmentCount = [[NSUserDefaults standardUserDefaults] valueForKey:@"attachmentCount"];
    NSString *workflowId = [[NSUserDefaults standardUserDefaults] valueForKey:@"workflowId"];
    NSString *stateComplete = [[NSUserDefaults standardUserDefaults] valueForKey:@"stateComplete"];
    BOOL isSignatory = [[_checkNullArray valueForKey:@"IsSignatory"]boolValue];
    int parallelCheck = [[[NSUserDefaults standardUserDefaults]valueForKey:@"statusCheckForPar"]intValue];
    
    [[NSUserDefaults standardUserDefaults] setObject:path forKey:@"pathForDoc"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (![self.pdfDocument unlockWithPassword:[[NSUserDefaults standardUserDefaults] valueForKey:@"Password"]]) {
        [self askForPassword: @"Wrong password. Try again:"];
        [self stopActivity];
        return;
    }
    
    if ( !isSignatory && [stateComplete isEqualToString:@"Pending"] ){
        stateComplete = @"Completed";
    }
    
    BOOL statuscheck = false;
    BOOL parallelStatusCheckCompleted = false;
    for (int i = 0; i<coordinatesArray.count; i++) {
        if ([[coordinatesArray[i]valueForKey:@"StatusID"]isEqualToString:@"7"]) {
            statuscheck = true;
        }
        if ([[coordinatesArray[i]valueForKey:@"StatusID"]isEqualToString:@"53"]) {
            parallelStatusCheckCompleted = true;
        }
    }
   
    if ([stateComplete isEqualToString:@"Completed"])
    {
        
        CompletedNextVC *temp = [[CompletedNextVC alloc] init];//WithFilename:path path:path document: doc];
        temp._pathForDoc = path;
        temp.pdfImagedetail = _pdfImageArray;
        temp.myTitle = displayName;
        temp.documentID = [[[_checkNullArray valueForKey:@"Response"] valueForKey:@"DocumentId"]objectAtIndex:0];
        temp.strExcutedFrom=@"Completed";
        temp.workflowID = workflowId;
        temp.documentCount = docCount;
        temp.passwordForPDF = password;

        temp.signatoryString = mstrXMLString;
        temp.attachmentCount = attachmentCount;
        [self.navigationController pushViewController:temp animated:YES];
        [self stopActivity];
        return;
        
    }
    else if ([stateComplete isEqualToString:@"Pending"])
    {
        
        if (isopened) {
            if (isdelegate == true) {
                ParallelSigning *temp = [[ParallelSigning alloc] init];
                
                temp._pathForDoc = path;
                temp.pdfImagedetail = _pdfImageArray;
                temp.myTitle = [[_checkNullArray valueForKey:@"DocumentName"]objectAtIndex:0];
                temp.strExcutedFrom=@"Completed";
                temp.workflowID = workflowId;
                temp.documentCount = [[_checkNullArray  valueForKey:@"NoOfDocuments"] stringValue];
                temp.signatoryString = mstrXMLString;
                temp.placeholderArray = coordinatesArray;
                temp.passwordForPDF = password;
                temp.documentID = [[[_checkNullArray valueForKey:@"Response"] valueForKey:@"DocumentId"]objectAtIndex:0];

                temp.matchSignersList = arr;
                temp.attachmentCount = [[_checkNullArray  valueForKey:@"NoOfAttachments"] stringValue];
                [self.navigationController pushViewController:temp animated:YES];
                [self stopActivity];
                return;
            }
            else
            {
                CompletedNextVC *temp = [[CompletedNextVC alloc] init];
                temp._pathForDoc = path;
                temp.pdfImagedetail = _pdfImageArray;
                // temp.myTitle = [[_checkNullArray valueForKey:@"CurrentStatus"]valueForKey:@"Name"];
                temp.myTitle = displayName;
                temp.strExcutedFrom=@"Completed";
                temp.workflowID = workflowId;
                temp.documentCount = [[_checkNullArray valueForKey:@"NoOfDocuments"] stringValue];
                temp.signatoryString = mstrXMLString;
                temp.passwordForPDF = password;
                temp.documentID = [[[_checkNullArray valueForKey:@"Response"] valueForKey:@"DocumentId"]objectAtIndex:0];

                temp.attachmentCount = [[_checkNullArray valueForKey:@"NoOfAttachments"] stringValue];
                [self.navigationController pushViewController:temp animated:YES];
                [self stopActivity];
                
            }
        }
        else{
            //            if (isdelegate == true) {
            PendingListVC *temp = [[PendingListVC alloc] init];
            temp.pdfImagedetail = _pdfImageArray;
            temp.workFlowID = workflowId;
            temp.documentCount = docCount;
            temp.attachmentCount = attachmentCount;
           // temp.isSignatory = [[_checkNullArray valueForKey:@"IsSignatory"] boolValue];
            temp.documentID = [[[_checkNullArray valueForKey:@"Response"] valueForKey:@"DocumentId"]objectAtIndex:0];

            temp.strExcutedFrom=@"DocsStore";
            temp.myTitle = displayName;
            temp.signatoryString = mstrXMLString;
            temp.passwordForPDF = password;
            temp.statusId = statusId;
            temp.signatoryHolderArray = arr;
            temp.isSignatory = [[_checkNullArray valueForKey:@"IsSignatory"]boolValue];
            temp.isReviewer = [[_checkNullArray valueForKey:@"IsReviewer"]boolValue];
            temp.placeholderArray = coordinatesArray;
            temp.workFlowType = [[_filterArray objectAtIndex:selectedIndex.row] valueForKey:@"WorkflowType"];
            [self.navigationController pushViewController:temp animated:YES];
            [self stopActivity];
        }
        
    }
    
    else if ([stateComplete isEqualToString:@"Cosign-Pending"])
    {
        CoSignPendingListVC *temp = [[CoSignPendingListVC alloc] init];
        temp.passwordForPDF = password;
        temp.pdfImagedetail = _pdfImageArray;
        temp.workflowID = workflowId;
        temp.documentCount = docCount;
        temp.strExcutedFrom=@"DocsStore";
        temp.passwordForPDF = password;

        temp.attachmentCount = attachmentCount;
        temp.myTitle = displayName;
        temp.signatoryString = mstrXMLString;
        [self.navigationController pushViewController:temp animated:YES];
        [self stopActivity];
        return;
        
    }
    
    else if ([stateComplete isEqualToString:@"Initiate"])
    {
        
        DraftInactiveVC *temp = [[DraftInactiveVC alloc] init];
        temp.pdfImagedetail = _pdfImageArray;
        temp.myTitle = displayName;
        temp.workflowID = workflowId;
        temp.passwordForPDF = password;

        [self.navigationController pushViewController:temp animated:YES];
        [self stopActivity];
        return;
        
    }
}
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    // Do Stuff!
    //UIWindow* window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if([item.title  isEqual: @"DashBoard"]) {
        DocsPage *controller1 = [self.storyboard instantiateViewControllerWithIdentifier:@"DocsPage"];
        controller1.view.frame = self.view.bounds;
        // [self.view removeFromSuperview];
        [self.view addSubview:controller1.view];
        [self addSelectedControllerViewOnBaseView:controller1];
    }
    else if ([item.title  isEqual: @"Docstore"]){
       
        
    }
    else if ([item.title  isEqual: @"WorkFlows"]){
        //         WorkflowTableViewController *objTrackOrderVC= [[WorkflowTableViewController alloc] initWithNibName:@"WorkflowTableViewController" bundle:nil];
        //         //objTrackOrderVC.categoryId = [NSString stringWithFormat:@"%d",CategoryId];
        //         [self.navigationController pushViewController:objTrackOrderVC animated:YES];
        
        WorkflowTableViewController *controller1 = [self.storyboard instantiateViewControllerWithIdentifier:@"WorkflowTableViewController"];
        controller1.view.frame = self.view.bounds;
        //  [self.view removeFromSuperview];
        [self.view addSubview:controller1.view];
        //[self loadViewonSelection:@"WorkflowTableViewController"];
        [self addSelectedControllerViewOnBaseView:controller1];
    }
    
}
- (void) addSelectedControllerViewOnBaseView:(UIViewController *)controller
{
    if (_selectedController)
    {
        [_selectedController.view removeFromSuperview];
        [_selectedController removeFromParentViewController];
        _selectedController.view=nil;
        _selectedController = nil;
    }
    [self addChildViewController:controller];
    [controller didMoveToParentViewController:self];
    [self.view addSubview:controller.view];
    _selectedController = controller;
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
