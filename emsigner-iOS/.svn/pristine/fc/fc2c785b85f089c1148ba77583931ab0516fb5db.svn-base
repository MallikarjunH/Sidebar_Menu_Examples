//
//  DocsStoreMultiplePdf.m
//  emSigner
//
//  Created by Administrator on 6/26/17.
//  Copyright © 2017 Emudhra. All rights reserved.
//

#import "DocsStoreMultiplePdf.h"
#import "MBProgressHUD.h"
#import "NSObject+Activity.h"
#import "WebserviceManager.h"
#import "HoursConstants.h"
#import "PendingListVC.h"
#import "AppDelegate.h"
#import "Reachability.h"
@interface DocsStoreMultiplePdf ()

@end

@implementation DocsStoreMultiplePdf

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Empty cell keep blank
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 65, 0);
    //
    [self.tableView setContentOffset:CGPointMake(0.0, self.tableView.tableHeaderView.frame.size.height) animated:YES];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //
    self.title = _document;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    
    //
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MultiplePdfTableViewCell" bundle:nil] forCellReuseIdentifier:@"MultiplePdfTableViewCell"];
    
    _listArray = [[NSMutableArray alloc]init];
    //    /*************************Web Service*******************************/
    
    [self startActivity:@"Refreshing"];
    NSString *requestURL = [NSString stringWithFormat:@"%@GetWorkflowDocumentDetails?WorkflowID=%@",kMultipleDoc,_workFlowId];
    
    [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
        
        //if(status)
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
    return [_listArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MultiplePdfTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MultiplePdfTableViewCell" forIndexPath:indexPath];
    cell.documentNameLable.text = [[_listArray objectAtIndex:indexPath.row] objectForKey:@"DocumentName"];
    
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
    //
    
    //    /*************************Web Service*******************************/
    
    
    [self startActivity:@"Loading.."];
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
                                   float ver_space=80.0;
                                   
                                   
                                   for (int i= 0; i<[sign count]-1; i++) {
                                       
                                       NSString *signatory= [sign objectAtIndex:i];
                                       NSArray *signatory1 = [signatory componentsSeparatedByString: @"-"];
                                       NSString *name = [signatory1 objectAtIndex:0];
                                       NSString *signatoryDetail = [signatory1 objectAtIndex:1];
                                       
                                       UILabel *label =  [[UILabel alloc] initWithFrame: CGRectMake(xCoordinate,yCoordinate,width,height)];
                                       label.text = name;
                                       label.baselineAdjustment = YES;
                                       label.adjustsFontSizeToFitWidth = YES;
                                       label.textAlignment = NSTextAlignmentCenter;
                                       label.textColor = [UIColor whiteColor];
                                       label.layer.masksToBounds = YES;
                                       label.layer.cornerRadius = 10.0;
                                       
                                       [cell.signatoryScrollView addSubview:label];
                                       
                                       xCoordinate=xCoordinate+height+ver_space;
                                       if ([signatoryDetail isEqualToString:@"Signed"]) {
                                           label.backgroundColor = ([UIColor colorWithRed:13.0/255.0 green:85.0/255.0 blue:12.0/255.0 alpha:1.0]);
                                           
                                       }
                                       else if ([signatoryDetail isEqualToString:@"Pending"])
                                       {
                                           label.backgroundColor = [UIColor orangeColor];
                                       }
                                       else if ([signatoryDetail isEqualToString:@"Declined"])
                                       {
                                           label.backgroundColor = [UIColor grayColor];
                                       }
                                       else if ([signatoryDetail isEqualToString:@"Recalled"])
                                       {
                                           label.backgroundColor = ([UIColor colorWithRed:0.0/255.0 green:96.0/255.0 blue:192.0/255.0 alpha:1.0]);
                                       }
                                       else if ([signatoryDetail isEqualToString:@"Not yet started"])
                                       {
                                           label.backgroundColor = [UIColor lightGrayColor];
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
    
    return 100.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedRow = indexPath.row;
    
    /*************************Web Service*******************************/
    
    
    
    [self startActivity:@"Loading..."];
    
    NSString *requestURL = [NSString stringWithFormat:@"%@GetFileDataByDocumentId?DocumentId=%@",kOpenPDFImage,[[_listArray objectAtIndex:indexPath.row] valueForKey:@"DocumentId"]];
    [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
        
        
        if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

        //if(status)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //Check Null String Address
                NSString *descriptionStr;
                descriptionStr=[[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[responseValue valueForKey:@"Response"]]];
                //
                
                
                //
                
                if ([_delegate respondsToSelector:@selector(dataFromControllerTwo:)])
                {
                    [_delegate dataFromControllerTwo:descriptionStr];
                    [_delegate documentNameControllerTwo:[[_listArray objectAtIndex:indexPath.row] objectForKey:@"DocumentName"]];
                    [_delegate selectedCellIndexTwo:_selectedRow];
                }
                
                
                [self.navigationController popViewControllerAnimated:YES];
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
            //[alert addAction:noButton];
            
            [self presentViewController:alert animated:YES completion:nil];
            [self stopActivity];
            
        }
        
    }];
    
    //}
    
    
    
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
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
