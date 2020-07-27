//
//  CompleteMultipleDocumentVC.m
//  emSigner
//
//  Created by Administrator on 6/1/17.
//  Copyright © 2017 Emudhra. All rights reserved.
//

#import "CompleteMultipleDocumentVC.h"
#import "MBProgressHUD.h"
#import "NSObject+Activity.h"
#import "WebserviceManager.h"
#import "HoursConstants.h"
#import "PendingListVC.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import "CompletedNextVC.h"

@interface CompleteMultipleDocumentVC ()
{
    NSMutableString* mstrXMLString;
    const char *password;

}

@end

@implementation CompleteMultipleDocumentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup

    //Empty cell keep blank
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 65, 0);
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    //[self.tableView setContentOffset:CGPointMake(0.0, self.tableView.tableHeaderView.frame.size.height) animated:YES];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    self.title = _document;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MultiplePdfTableViewCell" bundle:nil] forCellReuseIdentifier:@"MultiplePdfTableViewCell"];
    
    _listArray = [[NSMutableArray alloc]init];
    //    /*************************Web Service*******************************/
    
    [self startActivity:@"Refreshing"];
    NSString *requestURL = [NSString stringWithFormat:@"%@GetDocumentidsByWorkflowid?WorkflowID=%@",kMultipleDoc,_workFlowId];
    
    [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
        
       // if(status)
            if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

        {
            
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               _listArray=[responseValue valueForKey:@"Response"];
                                if (_listArray != (id)[NSNull null])
                                {
                                    [_tableView reloadData];
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
    [self stopActivity];
    /*******************************************************************************/
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    //    if (section == 0)
    //    {
    //        int cellCount = 2; // Default count - if not a single cell is expanded
    //
    //        if (isSection0Cell0Expanded)
    //        {
    //            cellCount += [cell0SubMenuItemsArray count];
    //        }
    //
    //        return cellCount;
    //    }
    
    return [_listArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MultiplePdfTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MultiplePdfTableViewCell" forIndexPath:indexPath];
    cell.documentNameLable.text = [[_listArray objectAtIndex:indexPath.row] objectForKey:@"DocumentName"];
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:250.0/255.0 alpha:1.0];
    [cell setSelectedBackgroundView:bgColorView];
    
    if(indexPath.row == _currentSelectedRow)
    {
        [tableView
         selectRowAtIndexPath:indexPath
         animated:TRUE
         scrollPosition:UITableViewScrollPositionNone
         ];
    }
    
    //    /*************************Web Service*******************************/
    
    
    [self startActivity:@"Loading.."];
    //    NSString *PendingWorkflowID = [[NSUserDefaults standardUserDefaults]
    //                                   valueForKey:@"PendingWorkflowID"];
    NSString *requestURL = [NSString stringWithFormat:@"%@GetSignerDetails?DocumentId=%@",kMultipleSignatory,[[_listArray objectAtIndex:indexPath.row] valueForKey:@"DocumentID"]];
    
    [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
        
      //  if(status)
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
                                       label.font=[label.font fontWithSize:20];
                                       label.baselineAdjustment = YES;
                                       label.adjustsFontSizeToFitWidth = YES;
                                       //label.layer.borderColor = [UIColor colorWithRed:0.0/255.0 green:96.0/255.0 blue:192.0/255.0 alpha:1.0].CGColor;
                                       //label.layer.borderWidth = 1.0;
                                       label.textAlignment = NSTextAlignmentCenter;
                                       label.textColor = [UIColor whiteColor];
                                       //label.backgroundColor = [UIColor whiteColor];
                                       [label sizeToFit];
                                       label.layer.masksToBounds = YES;
                                       label.layer.cornerRadius = 10.0;
                                       xCoordinate=xCoordinate+label.frame.size.width+ver_space;
                                       [cell.signatoryScrollView addSubview:label];
                                       
                                       
                                       
                                       CGRect screenRect = [[UIScreen mainScreen] bounds];
                                       CGFloat screenWidth = screenRect.size.width;
                                       if (xCoordinate<= screenWidth)
                                       {
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
                                   //[alert addAction:noButton];
                                   
                                   [self presentViewController:alert animated:YES completion:nil];                                   [self stopActivity];
                               }
                               
                               
                               
                           });
            
        }
        else{
            
            
        }
        
    }];
    /****************************************************************/
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 50.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedRow = indexPath.row;
    
    [self startActivity:@"Loading..."];
    
    NSString *requestURL = [NSString stringWithFormat:@"%@DownloadDocumentById?documentId=%@",kOpenPDFImage,[[_listArray objectAtIndex:indexPath.row] valueForKey:@"DocumentID"]];
    [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
        
        if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //Check Null String Address
                NSString *descriptionStr;
                descriptionStr=[[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[[responseValue valueForKey:@"Response"] valueForKey:@"Filebyte"]]];
                
                mstrXMLString = [[NSMutableString alloc]init];
                NSArray *arr =  [[responseValue valueForKey:@"Response"] valueForKey:@"lstSignatory"];
                
                
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
                        NSArray *arr1 =  [[responseValue valueForKey:@"Response"] valueForKey:@"lstOriginatory"];
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
                    NSArray *arr1 =  [[responseValue valueForKey:@"Response"] valueForKey:@"lstOriginatory"];
                    
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
                
                if ([[[responseValue valueForKey:@"Response"] valueForKey:@"IsPasswordProtected"] boolValue]==YES) {
                    NSData *data = [[NSData alloc]initWithBase64EncodedString:descriptionStr options:0];
                    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
                    NSString *path = [documentsDirectory stringByAppendingPathComponent:[[_listArray objectAtIndex:indexPath.row] objectForKey:@"DocumentName"]];
                    [data writeToFile:path atomically:YES];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:path forKey:@"pathForDoc"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    NSString *displayName = [[_listArray objectAtIndex:indexPath.row] objectForKey:@"DocumentName"];
                    [[NSUserDefaults standardUserDefaults] setObject:displayName forKey:@"displayName"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    NSString *workflowId = _workFlowId;
                    [[NSUserDefaults standardUserDefaults] setObject:workflowId forKey:@"workflowId"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    NSString *description = descriptionStr;
                    [[NSUserDefaults standardUserDefaults] setObject:description forKey:@"description"];
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
                
                NSData *data = [[NSData alloc]initWithBase64EncodedString:descriptionStr options:0];
                // from your converted Base64 string
                NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
                NSString *path = [documentsDirectory stringByAppendingPathComponent:[[_listArray objectAtIndex:indexPath.row] objectForKey:@"DocumentName"]];
                [data writeToFile:path atomically:YES];
            
                CompletedNextVC *temp = [[CompletedNextVC alloc] init];
                
                temp.pdfImagedetail = descriptionStr;
                temp.myTitle = [[_listArray objectAtIndex:indexPath.row] objectForKey:@"DocumentName"];
                temp.strExcutedFrom = _strExcutedFrom;
                temp.workflowID = _workFlowId;
                temp.signatoryString = mstrXMLString;
//                temp.documentCount = [[[responseValue valueForKey:@"Response"] valueForKey:@"NoOfDocuments"] integerValue];
//                temp.attachmentCount = [[[responseValue valueForKey:@"Response"] valueForKey:@"NoOfAttachments"] integerValue];
                [self.navigationController pushViewController:temp animated:YES];
                [self stopActivity];
                
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

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
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
    NSString *description = [[NSUserDefaults standardUserDefaults] valueForKey:@"description"];

    if (![self.pdfDocument unlockWithPassword:[[NSUserDefaults standardUserDefaults] valueForKey:@"Password"]]) {
        [self askForPassword: @"Wrong password. Try again:"];
        [self stopActivity];
        return;
    }
    
    CompletedNextVC *temp = [[CompletedNextVC alloc] init];
    temp.pdfImagedetail = description;
    temp.myTitle = displayName;
    temp.strExcutedFrom = _strExcutedFrom;
    temp.workflowID = _workFlowId;
    temp.signatoryString = mstrXMLString;
    temp.passwordForPDF = password;
    [self.navigationController pushViewController:temp animated:YES];

    [self stopActivity];
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
