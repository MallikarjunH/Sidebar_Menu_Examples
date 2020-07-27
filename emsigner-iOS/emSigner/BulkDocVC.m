//
//  BulkDocVC.m
//  emSigner
//
//  Created by Emudhra on 17/06/20.
//  Copyright © 2020 Emudhra. All rights reserved.
//

#import "BulkDocVC.h"
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
#import "ParallelSigning.h"

//#import "CheckDocInfoController.h"

#import "NSString+DateAsAppleTime.h"
@interface BulkDocVC () {
      BOOL hasPresentedAlert;
      int currentPage;
      // MuDocRef *doc;
      NSMutableString * mstrXMLString;
      UILabel *noDataLabel;
      NSString *dateCategoryString;
      BOOL isPageRefreshing;
      
      NSString* searchSting;
      NSInteger* statusId;
      NSString* pdfFilePathForSignatures;
      NSData *data;
      NSMutableArray * coordinatesArray;
      NSArray *arr;
      NSString* path;
      NSString* createPdfString;
      NSIndexPath *selectedIndex;
      const char *password;
      NSUserDefaults *save;
      NSString* statusForPlaceholders;
      BOOL isdelegate;
      BOOL isopened;
}

@end

@implementation BulkDocVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Bulk Documents";
    _addFile = [[NSMutableArray alloc]init];
    _checkNullArray = [[NSMutableArray alloc]init];
  
    [self getBulkDocuments];
    _workflowTable.tableFooterView = [UIView new];
    self.navigationController.navigationBar.topItem.title = @" ";
}


#pragma mark - Table view data source



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_responseArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    UIButton *docInfoBtn = [cell viewWithTag:1];
    
    // NSString *flowText = [cell viewWithTag:1];
    
    cell.textLabel.text = [[self.responseArray objectAtIndex:indexPath.row] valueForKey:@"DocumentName"];
    // cell.imageView.image = [UIImage imageNamed:@"folder"];
    
    
    docInfoBtn.tag = indexPath.row;
    [docInfoBtn addTarget:self action:@selector(verticalDotsBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
          mstrXMLString = [[NSMutableString alloc] init];
          //Start EMIOS-1098
          NSString *requestURL = [NSString stringWithFormat:@"%@GetDocumentDetailsById?workFlowId=%@&workflowType=%@",kOpenPDFImage,[[_responseArray objectAtIndex:indexPath.row] valueForKey:@"WorkFlowId"],_workflowType];
          [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
              
              if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])
              {
                  int issucess = [[responseValue valueForKey:@"IsSuccess"]intValue];
                  
                  if (issucess != 0) {
                      
                      dispatch_async(dispatch_get_main_queue(), ^{
                          
                          _checkNullArray = [responseValue valueForKey:@"Response"];
                          
                          if (_checkNullArray == (id)[NSNull null])
                          {
                              UIAlertController * alert = [UIAlertController
                                                           alertControllerWithTitle:@""
                                                           message:@"This file has been corrupted."
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
                              
                              return;
                          }
                          
                          arr =  [_checkNullArray valueForKey:@"Signatory"];
                          
                          NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
                          NSData * data = [NSKeyedArchiver archivedDataWithRootObject:arr requiringSecureCoding:NO error:nil];
                          [prefs setObject:data forKey:@"Signatory"];
                          
                          if (arr.count > 0) {
                              NSString * ischeck = @"ischeck";
                              [mstrXMLString appendString:@"Signed By:"];
                              
                              for (int i = 0; arr.count>i; i++) {
                                  NSDictionary * dict = arr[i];

                                  if ([dict[@"StatusID"]intValue] == 7) {
                                      // statusId = 1;
                                  }

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
                                  // ([[[_checkNullArray valueForKey:@"CurrentStatus"]valueForKey:@"IsOpened"]intValue]== 1)
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
                          
                          statusForPlaceholders = [coordinatesArray valueForKey:@"StatusID"];

                          _pdfImageArray=[[responseValue valueForKey:@"Response"] valueForKey:@"Document"];
                          
                          if (_pdfImageArray != (id)[NSNull null])
                          {
                              NSUserDefaults *statusIdForMultiplePdf = [NSUserDefaults standardUserDefaults];
                              [statusIdForMultiplePdf setInteger:(long)statusId forKey:@"statusIdForMultiplePdf"];
                              [statusIdForMultiplePdf synchronize];
                              
                              if ([[[responseValue valueForKey:@"Response"] valueForKey:@"IsPasswordProtected"] boolValue]==YES) {
                                  
                                  NSData *data = [[NSData alloc]initWithBase64EncodedString:_pdfImageArray options:0];
                                  
                                  self.pdfDocument = [[PDFDocument alloc] initWithData:data];

                                  if ([[[self.responseArray objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue] == 3)
                                  {
                                      [self parallelSigning:indexPath.row];
                                      
                                  }
                                  
                                  NSString *checkPassword = [[responseValue valueForKey:@"Response"] valueForKey:@"IsPasswordProtected"];
                                  [[NSUserDefaults standardUserDefaults] setObject:checkPassword forKey:@"checkPassword"];
                                  [[NSUserDefaults standardUserDefaults] synchronize];
                                  
                                  data = [[NSData alloc]initWithBase64EncodedString:_pdfImageArray options:0];
                                  NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
                                  NSString *path = [documentsDirectory stringByAppendingPathComponent:[[self.responseArray objectAtIndex:indexPath.row] objectForKey:@"DisplayName"]];
                                  [data writeToFile:path atomically:YES];
                                  
                                  
                                  [[NSUserDefaults standardUserDefaults] setObject:path forKey:@"pathForDoc"];
                                  [[NSUserDefaults standardUserDefaults] synchronize];
                                  
                                  NSString *displayName = [[self.responseArray objectAtIndex:indexPath.row] objectForKey:@"DisplayName"];
                                  [[NSUserDefaults standardUserDefaults] setObject:displayName forKey:@"displayName"];
                                  [[NSUserDefaults standardUserDefaults] synchronize];
                                  
                                  NSString *docCount = [[[responseValue valueForKey:@"Response"] valueForKey:@"NoOfDocuments"] stringValue];
                                  [[NSUserDefaults standardUserDefaults] setObject:docCount forKey:@"docCount"];
                                  [[NSUserDefaults standardUserDefaults] synchronize];
                                  
                                  NSString *attachmentCount = [[[responseValue valueForKey:@"Response"] valueForKey:@"NoOfAttachments"] stringValue];
                                  [[NSUserDefaults standardUserDefaults] setObject:attachmentCount forKey:@"attachmentCount"];
                                  [[NSUserDefaults standardUserDefaults] synchronize];
                                  
                                  NSString *workflowId = [[self.responseArray objectAtIndex:indexPath.row] valueForKey:@"WorkFlowId"];
                                  [[NSUserDefaults standardUserDefaults] setObject:workflowId forKey:@"workflowId"];
                                  [[NSUserDefaults standardUserDefaults] synchronize];
                                  
                                  
                                  
                                  if ([self.pdfDocument isLocked]) {
                                      UIAlertView *passwordAlertView = [[UIAlertView alloc]initWithTitle: @"Password Protected"
                                                                                                 message:  [NSString stringWithFormat: @"%@ %@", path.lastPathComponent, @"is password protected"]
                                                                                                delegate: self
                                                                                       cancelButtonTitle: @"Cancel"
                                                                                       otherButtonTitles: @"Done", nil];
                                      passwordAlertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
                                      [passwordAlertView show];
                                      return;
                                      
                                  }
                                  
                                  [self stopActivity];
                                  
                              }
                              else
                              {
                                  
                                  NSData *data = [[NSData alloc]initWithBase64EncodedString:_pdfImageArray options:0];
                                  // from your converted Base64 string
                                  NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
                                  NSString *path = [documentsDirectory stringByAppendingPathComponent:[[_responseArray objectAtIndex:indexPath.row] objectForKey:@"DocumentName"]];
                                  [data writeToFile:path atomically:YES];
                                  
                                  CFUUIDRef uuid = CFUUIDCreate(NULL);
                                  CFStringRef uuidString = CFUUIDCreateString(NULL, uuid);
                                  CFRelease(uuid);
                                  
                                  UIImage *image = [UIImage imageNamed:@"signer.png"];
                                  
                              }

                              if ([[[self.responseArray objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"]integerValue] == 3)
                              {
                                  [self parallelSigningNoPassword:indexPath.row];
                                  
                              }
                              
                              [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"data"];
                              [[NSUserDefaults standardUserDefaults] synchronize];
                              
                              NSData * data = [NSKeyedArchiver archivedDataWithRootObject:coordinatesArray requiringSecureCoding:NO error:nil];
                              [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"coordinatesArray"];
                              [[NSUserDefaults standardUserDefaults] synchronize];

                              if (isdelegate == true)
                              {
                                  PendingListVC *temp = [[PendingListVC alloc]init];
                                  // Start EMIOS-1098
                                  temp.pdfImagedetail = _pdfImageArray;
                                  temp.workFlowID = [[self.responseArray objectAtIndex:indexPath.row] valueForKey:@"WorkFlowId"];
                                  temp.documentCount = [[[responseValue valueForKey:@"Response"] valueForKey:@"NoOfDocuments"] stringValue];
                                  temp.attachmentCount = [[[responseValue valueForKey:@"Response"] valueForKey:@"NoOfAttachments"] stringValue];
                                  temp.documentID = [[[responseValue valueForKey:@"Response"] valueForKey:@"DocumentId"]objectAtIndex:0];
                                  temp.isPasswordProtected = [[[responseValue valueForKey:@"Response"] valueForKey:@"IsPasswordProtected"] boolValue];
                                  temp.myTitle = [[self.responseArray objectAtIndex:indexPath.row] objectForKey:@"DocumentName"];
                                  temp.signatoryString = mstrXMLString;
                                  temp.statusId = statusId;
                                  temp.signatoryHolderArray = arr;
                                  temp.placeholderArray = coordinatesArray;
                                  temp.workFlowType = [[self.responseArray objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"];
                                  temp.isSignatory = [[_checkNullArray valueForKey:@"IsSignatory"]boolValue];
                                  temp.isReviewer = [[_checkNullArray valueForKey:@"IsReviewer"]boolValue];
                                  // End EMIOS-1098
                                  [self.navigationController pushViewController:temp animated:YES];
                                  [self stopActivity];
                              }
                              else if(isdelegate == false){
                                  PendingListVC *temp = [[PendingListVC alloc]init];
                                  // Start EMIOS-1098
                                  temp.pdfImagedetail = _pdfImageArray;
                                  temp.workFlowID = [[self.responseArray objectAtIndex:indexPath.row] valueForKey:@"WorkFlowId"];
                                  temp.documentCount = [[[responseValue valueForKey:@"Response"] valueForKey:@"NoOfDocuments"] stringValue];
                                  temp.attachmentCount = [[[responseValue valueForKey:@"Response"] valueForKey:@"NoOfAttachments"] stringValue];
                                  temp.isPasswordProtected = [[[responseValue valueForKey:@"Response"] valueForKey:@"IsPasswordProtected"] boolValue];
                                  temp.documentID = [[[responseValue valueForKey:@"Response"] valueForKey:@"DocumentId"]objectAtIndex:0];
                                  
                                  temp.myTitle = [[self.responseArray objectAtIndex:indexPath.row] objectForKey:@"DocumentName"];
                                  temp.signatoryString = mstrXMLString;
                                  temp.statusId = statusId;
                                  temp.signatoryHolderArray = arr;
                                  temp.placeholderArray = coordinatesArray;
                                  temp.workFlowType = [[self.responseArray objectAtIndex:indexPath.row] valueForKey:@"WorkflowType"];
                                  temp.isSignatory = [[_checkNullArray valueForKey:@"IsSignatory"]boolValue];
                                  temp.isReviewer = [[_checkNullArray valueForKey:@"IsReviewer"]boolValue];
                                  // End EMIOS-1098
                                  [self.navigationController pushViewController:temp animated:YES];
                                  [self stopActivity];
                              }
                              
                          }
                          else{
                              
                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message: @"This file was corrupted. Please contact eMudhra for more details." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                              [alert show];
                              [self stopActivity];
                          }
                      });
                      
                  }
                  else{
                      //Alert at the time of no server connection
                      
                      dispatch_async(dispatch_get_main_queue(), ^{
                          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message: @"Try again" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                          [alert show];
                          [self stopActivity];
                          
                      });
                      
                  }
              }
              else{
                  dispatch_async(dispatch_get_main_queue(), ^{
                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message: @"The API request is invalid or improperly formed." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                      [alert show];
                      [self stopActivity];
                  });
              }
          }];
          //End EMIOS-1098
      }


-(void)parallelSigning:(long )indexPath
{
    //start EMIOS-1098
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
        return;
    }
    else
    {
        isopened = false;
    }
    // End EMIOS-1098
}

#pragma mark  - parallel signing

-(void)parallelSigningNoPassword:(long)indexpath
{
    //Start EMIOS-1098
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
            NSString *path = [documentsDirectory stringByAppendingPathComponent:[[_searchResults objectAtIndex:indexpath] objectForKey:@"DisplayName"]];
            [data writeToFile:path atomically:YES];
            
            CFUUIDRef uuid = CFUUIDCreate(NULL);
            CFStringRef uuidString = CFUUIDCreateString(NULL, uuid);
            CFRelease(uuid);
            
            //Add signBox
            UIImage *image = [UIImage imageNamed:@"signer.png"];
            
            if (coordinatesArray.count != 0) {
                // path = [createPdfString addSignature:image onPDFData:data withCoordinates:coordinatesArray Count:arr];
                
                
            }

            if (isdelegate == false) {
                CompletedNextVC *temp = [[CompletedNextVC alloc] init];//WithFilename:path path:path document: doc];
                temp._pathForDoc = path;
                temp.pdfImagedetail = _pdfImageArray;
                temp.myTitle = [[_checkNullArray valueForKey:@"DocumentName"]objectAtIndex:0];
                temp.strExcutedFrom=@"Completed";
                temp.workflowID = [[_searchResults objectAtIndex:indexpath] valueForKey:@"WorkFlowId"];
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
                temp.workflowID = [[_searchResults objectAtIndex:indexpath] valueForKey:@"WorkFlowId"];
                temp.documentCount = [[_checkNullArray valueForKey:@"NoOfDocuments"] stringValue];
                temp.placeholderArray = coordinatesArray;
                
                temp.signatoryString = mstrXMLString;
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
        
    }
    //End EMIOS-1098
}



#pragma mark - API Call
-(void)getBulkDocuments
{
    [self startActivity:@"Refreshing..."];
    
    NSString *requestURL = [NSString stringWithFormat:@"%@ListBulkDocuments?lotId=%@",kGetBulkDocuments,_lotId];
    
    [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
        
        if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])
        {
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                
                _responseArray=[responseValue valueForKey:@"Response"];
                
                [self.workflowTable reloadData];
                [self stopActivity];
                
            });
        }
    }];
}




-(void)verticalDotsBtnClicked:(UIButton*)sender
{
    UIAlertController * view=   [[UIAlertController
                                  alloc]init];
    UIAlertAction* Info = [UIAlertAction
                           actionWithTitle:@"View Document Information"
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
                           {
        //Do some thing here
        
        [self getDocumentInfo:[[_responseArray objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"]];
        
    }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction * action)
                             {
        
    }];
    UIAlertAction* Decline = [UIAlertAction
                              actionWithTitle:@"Decline Document"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
        UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        DeclineVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"DeclineVC"];
        self.definesPresentationContext = YES; //self is presenting view controller
        objTrackOrderVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        objTrackOrderVC.workflowID = [[_responseArray
                                       objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"];;
        [self.navigationController presentViewController:objTrackOrderVC animated:YES completion:nil];
    }];
    
    UIAlertAction* Doclog = [UIAlertAction
                             actionWithTitle:@"Document log"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
        UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        DocumentLogVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"DocumentLogVC"];
        
        objTrackOrderVC.workflowID = [[_responseArray objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"];;
        [self.navigationController pushViewController:objTrackOrderVC animated:YES];
    }];
    UIAlertAction* Comments = [UIAlertAction
                               actionWithTitle:@"Comments"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
        UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CommentsController *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"CommentsController"];
        objTrackOrderVC.documentID = [[_responseArray objectAtIndex:sender.tag] valueForKey:@"DocumentId"];
        objTrackOrderVC.workflowID = [[_responseArray objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"];
        
        [self.navigationController pushViewController:objTrackOrderVC animated:YES];
    }];
    UIAlertAction* Download = [UIAlertAction
                               actionWithTitle:@"Download Document"
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
            NSString *requestURL = [NSString stringWithFormat:@"%@DownloadWorkflowDocuments?WorkFlowId=%@",kDownloadPdf,[[_responseArray objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"]];
            [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
                
                //  if(status)
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
                                NSString *uniqueFileName = [NSString stringWithFormat:@"%@%@",(__bridge NSString *)uuidString, _pdfFileName];
                                
                                
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
    UIAlertAction* Share = [UIAlertAction
                            actionWithTitle:@"Share Document"
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action)
                            {
        NSString *pendingdocumentName =[[_responseArray objectAtIndex:sender.tag] valueForKey:@"DisplayName"];
        NSString* documentId = [[_responseArray objectAtIndex:sender.tag] valueForKey:@"DocumentId"];
        
        NSString *pendingWorkflowID =[[_responseArray objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"];
        UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ShareVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"ShareVC"];
        objTrackOrderVC.documentName = pendingdocumentName;
        objTrackOrderVC.documentID = documentId;
        objTrackOrderVC.workflowID = pendingWorkflowID;
        [self.navigationController pushViewController:objTrackOrderVC animated:YES];
        
        
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
            NSString *requestURL = [NSString stringWithFormat:@"%@MarkAsInactive?WorkflowId=%@&status=%@",kInactive,[[_responseArray objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"],@"pending"];
            
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
    
    [Info setValue:[[UIImage imageNamed:@"information-outline-2.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [Decline setValue:[[UIImage imageNamed:@"cancel.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [Doclog setValue:[[UIImage imageNamed:@"stack-exchange.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [Comments setValue:[[UIImage imageNamed:@"comments"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [Download setValue:[[UIImage imageNamed:@"download.png"]
                        imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [Share setValue:[[UIImage imageNamed:@"share-variant.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    //Start EMIOS-1098
    [Inactive setValue:[[UIImage imageNamed:@"minus-circle.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [Recall setValue:[[UIImage imageNamed:@"tumblr-reblog.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    //End EMIOS-1098
    [Info setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    [Decline setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    //Start EMIOS-1098
    [Inactive setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    [Recall setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    //End EMIOS-1098
    [Doclog setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    [Comments setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    [Download setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    [Share setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    view.view.tintColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
    
    [view addAction:Info];
    //Start EMIOS-1098
    if ([_type  isEqual: @"Me"]) {
        [view addAction:Decline];
    }
    if ([_type  isEqual: @"Other"]) {
        [view addAction:Inactive];
        [view addAction:Recall];
    }
    //End EMIOS-1098
    [view addAction:Doclog];
    [view addAction:Comments];
    [view addAction:Download];
    [view addAction:Share];
    [view addAction:cancel];
    
    [self presentViewController:view animated:YES completion:nil];
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
            
            dispatch_async(dispatch_get_main_queue(),
                           ^{
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
                    //                                            AppDelegate *theDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                    //                                            theDelegate.isLoggedIn = NO;
                    //                                            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:theDelegate.isLoggedIn] forKey:@"isLogin"];
                    //                                            [NSUserDefaults resetStandardUserDefaults];
                    //                                            [NSUserDefaults standardUserDefaults];
                    //                                            UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    //                                            ViewController *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"ViewController"];
                    //                                            [self presentViewController:objTrackOrderVC animated:YES completion:nil];
                }];
                
                [alert addAction:yesButton];
                
                [self presentViewController:alert animated:YES completion:nil];
                
                return;
                //}
            });
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



@end
