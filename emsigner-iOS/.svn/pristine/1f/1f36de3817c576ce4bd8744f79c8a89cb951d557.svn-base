//
//  DocumentInfoNames.m
//  emSigner
//
//  Created by EMUDHRA on 31/10/18.
//  Copyright © 2018 Emudhra. All rights reserved.
//

#import "DocumentInfoNames.h"

#import "MBProgressHUD.h"
#import "NSObject+Activity.h"
#import "WebserviceManager.h"
#import "HoursConstants.h"
#import "ViewController.h"
#import "DocumentNamesCell.h"
#import "DocumentInfoVC.h"

@interface DocumentInfoNames ()

@end

@implementation DocumentInfoNames

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _documentInfoTable.delegate = self;
    _documentInfoTable.dataSource= self;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.topItem.title = @" ";
   // self.navigationItem.backBarButtonItem.title = @"";
    [self.documentInfoTable registerNib:[UINib nibWithNibName:@"DocumentNamesCell" bundle:nil] forCellReuseIdentifier:@"DocumentNamesCell"];
  
    _documentInfoArray = [[NSMutableArray alloc]init];
    self.documentInfoTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

  /*  self.navigationController.navigationBar.topItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                                                         initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];*/
    [self getDocumentInfo:_docInfoWorkflowId];
    
    
    
}

-(void)getDocumentInfo:(NSString*)workflowId

{
    
    [self startActivity:@"Loading.."];
    NSString *requestURL = [NSString stringWithFormat:@"%@GetWorkflowInfo?WorkFlowId=%@",kDocumentInfo,_docInfoWorkflowId];
    
    [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
        
       // if(status)
            if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

        {
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               _documentInfoArray = [responseValue valueForKey:@"Response"];
                               
                               if (_documentInfoArray != (id)[NSNull null])
                               {
                                    [self.documentInfoTable reloadData];

                                   
//                                   if(_documentInfoArray.count == 1)
//                                   {
//                                       UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//                                       DocumentInfoVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"DocumentInfoVC"];
//                                       objTrackOrderVC.documentInfoArray = _documentInfoArray[0];
//
//                                       NSString *names = [[_documentInfoArray objectAtIndex:0]valueForKey:@"DocumentName"];
//
//                                       objTrackOrderVC.titleString = names;
//
//                                       objTrackOrderVC.status = self.status;
//                                       [self.navigationController pushViewController:objTrackOrderVC animated:YES];
//
//                                   }
//                                   else{
//                                       [self.documentInfoTable reloadData];
//                                   }
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _documentInfoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
     DocumentNamesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DocumentNamesCell" forIndexPath:indexPath];
    cell.textLabel.text  =[[_documentInfoArray objectAtIndex:indexPath.row]valueForKey:@"DocumentName"];
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
                                   UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                   DocumentInfoVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"DocumentInfoVC"];
                                    objTrackOrderVC.documentInfoArray = _documentInfoArray[indexPath.row];
    
                                   NSString *names = [[_documentInfoArray objectAtIndex:indexPath.row]valueForKey:@"DocumentName"];
    
                                    objTrackOrderVC.titleString = names;

                                   objTrackOrderVC.status = self.status;
                                   [self.navigationController pushViewController:objTrackOrderVC animated:YES];
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
