//
//  MyProfileVC.m
//  emSigner
//
//  Created by Administrator on 7/26/16.
//  Copyright © 2016 Emudhra. All rights reserved.
//

#import "MyProfileVC.h"
#import "WebserviceManager.h"
#import "HoursConstants.h"
#import "MBProgressHUD.h"
#import "NSObject+Activity.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import "ViewController.h"
@interface MyProfileVC ()
{
    BOOL hasPresentedAlert;
    NSString *descriptionStr7;
}
@end

@implementation MyProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.topItem.title = @" ";

    self.section1tableTitleArray = [NSMutableArray arrayWithObjects: @"Name", @"Email", @"Designation", @"Department", @"Organization", @"Mobile Number",@"Address",@"City",@"State",@"Country",@"Zip Code", nil];

    self.section2tableTitleArray = [NSMutableArray arrayWithObjects: @"Plan Name", @"Signature Type", @"Email Notification", @"Adhoc Signature Type",@"Users", nil];
    
    self.profileTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.title = _titleName;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    _profileArray = [[NSMutableArray alloc] init];
    
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
            
            [self presentViewController:alert animated:YES completion:nil];
            
            hasPresentedAlert = true;
        }
    }
    else
    {
        [self startActivity:@"Loading..."];
        NSString *requestURL = [NSString stringWithFormat:@"%@AccountProfile",kMyProfile];
        
        [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
            
            //if(status)
                if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

            {
                dispatch_async(dispatch_get_main_queue(),
                               ^{
                                   
                                   //[_profileArray removeAllObjects];
                                   _profileArray = [responseValue valueForKey:@"Response"];
                              
                                   [self.profileTableView reloadData];
                                   [self stopActivity];
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
                                                //[self.navigationController pushViewController:objTrackOrderVC animated:YES];
                                                [self presentViewController:objTrackOrderVC animated:YES completion:nil];
                                            }];
                
                [alert addAction:yesButton];
                
                [self presentViewController:alert animated:YES completion:nil];
                
                return;
                
            }
            
        }];
       // [self stopActivity];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
       return  _section1tableTitleArray.count;
    }
    else return _section2tableTitleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ProfilecellIdentifier = @"Profilecell";
    static NSString *SubscribercellIdentifier = @"Subscribercell";
    
    if (indexPath.section == 0) {
        UITableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:ProfilecellIdentifier];
        
        cell1.textLabel.text = [_section1tableTitleArray objectAtIndex:indexPath.row];
            //cell1.textLabel.text = [[[_profileArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] valueForKey:@"key"];
        
        if (indexPath.row == 0) {
            
             NSString *singType = [[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[_profileArray valueForKey:@"FullName"]]];
            if ([singType isEqualToString:@""]) {
                cell1.detailTextLabel.text = @"N/A";
            }
           else cell1.detailTextLabel.text = [[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[_profileArray valueForKey:@"FullName"]]];
            
        }
        if (indexPath.row == 1) {
            
            NSString *singType = [[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[_profileArray valueForKey:@"Email_Id"]]];
            if ([singType isEqualToString:@""]) {
                cell1.detailTextLabel.text = @"N/A";
            }
           else cell1.detailTextLabel.text = [[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[_profileArray valueForKey:@"Email_Id"]]];
            
            
        }
        if (indexPath.row == 2) {
            
            NSString *singType = [[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[_profileArray valueForKey:@"Designation"]]];
            if ([singType isEqualToString:@""]) {
                cell1.detailTextLabel.text = @"N/A";
            }
            else cell1.detailTextLabel.text = cell1.detailTextLabel.text = [[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[_profileArray valueForKey:@"Designation"]]];
            
        }
        if (indexPath.row == 3) {
            NSString *singType = [[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[_profileArray valueForKey:@"Department"]]];
            if ([singType isEqualToString:@""]) {
                cell1.detailTextLabel.text = @"N/A";
            }
            else cell1.detailTextLabel.text = [[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[_profileArray valueForKey:@"Department"]]];
            
        }
        if (indexPath.row == 4) {
            NSString *singType = [[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[_profileArray valueForKey:@"Organization"]]];
            if ([singType isEqualToString:@""]) {
                cell1.detailTextLabel.text = @"N/A";
            }
            else cell1.detailTextLabel.text = [[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[_profileArray valueForKey:@"Organization"]]];
            
        }
        if (indexPath.row == 5) {
            NSString *singType = [[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[_profileArray valueForKey:@"Contact_Number"]]];
            if ([singType isEqualToString:@""]) {
                cell1.detailTextLabel.text = @"N/A";
            }
            else cell1.detailTextLabel.text = [[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[_profileArray valueForKey:@"Contact_Number"]]];
            
        }
        if (indexPath.row == 6) {
            NSString *singType = [[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[_profileArray valueForKey:@"Address"]]];
            if ([singType isEqualToString:@""]) {
                cell1.detailTextLabel.text = @"N/A";
            }
            else cell1.detailTextLabel.text = [[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[_profileArray valueForKey:@"Address"]]];
            
        }
        if (indexPath.row == 7) {
            NSString *singType = [[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[_profileArray valueForKey:@"City"]]];
            if ([singType isEqualToString:@""]) {
                cell1.detailTextLabel.text = @"N/A";
            }
            else  cell1.detailTextLabel.text = [[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[_profileArray valueForKey:@"City"]]];
            
        }
        if (indexPath.row == 8) {
            NSString *singType = [[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[_profileArray valueForKey:@"State"]]];
            if ([singType isEqualToString:@""]) {
                cell1.detailTextLabel.text = @"N/A";
            }
            else cell1.detailTextLabel.text = [[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[_profileArray valueForKey:@"State"]]];
            
        }
        if (indexPath.row == 9) {
            NSString *singType = [[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[_profileArray valueForKey:@"Country_Code"]]];
            if ([singType isEqualToString:@""]) {
                cell1.detailTextLabel.text = @"N/A";
            }
            else cell1.detailTextLabel.text = [[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[_profileArray valueForKey:@"Country_Code"]]];
            
        }
        if (indexPath.row == 10) {
            NSString *singType = [[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[_profileArray valueForKey:@"Zip_Code"]]];
            if ([singType isEqualToString:@""]) {
                cell1.detailTextLabel.text = @"N/A";
            }
            else cell1.detailTextLabel.text = [[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[_profileArray valueForKey:@"Zip_Code"]]];
            
        }
        
//        descriptionStr7 =  [NSString stringWithFormat:@"%@",[[[_profileArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] valueForKey:@"value"]];
//        if ([descriptionStr7 isEqualToString:@"<null>"]) {
//            cell1.detailTextLabel.text = @"N/A";
//        }
//        else{
//             cell1.detailTextLabel.text = [NSString stringWithFormat:@"%@",[[[_profileArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] valueForKey:@"value"]];
//        }
            cell1.selectionStyle = UITableViewCellSelectionStyleNone;

        return cell1;
    }
    else {
        
        UITableViewCell *cell2 = [tableView dequeueReusableCellWithIdentifier:SubscribercellIdentifier];
        cell2.textLabel.text = [_section2tableTitleArray objectAtIndex:indexPath.row];
       // descriptionStr7 =  [NSString stringWithFormat:@"%@",[[[_profileArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] valueForKey:@"value"]];
        
        if (indexPath.row == 0) {
            NSString *singType = [[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[_profileArray valueForKey:@"PlanName"]]];
            if ([singType isEqualToString:@""]) {
                cell2.detailTextLabel.text = @"N/A";
            }
            else cell2.detailTextLabel.text = [[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[_profileArray valueForKey:@"PlanName"]]];
            
        }
//        if (indexPath.row == 1) {
//            NSString *singType = [[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[_profileArray valueForKey:@"SubscribedOn"]]];
//            if (!singType) {
//                cell2.detailTextLabel.text = @"N/A";
//            }
//            else cell2.detailTextLabel.text =  [[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[_profileArray valueForKey:@"SubscribedOn"]]];
//
//        }
        if (indexPath.row == 1) {
            
            NSString *singType = [[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[_profileArray valueForKey:@"SignatureType"]]];
            
//            if ([singType isEqualToString:@"1"]) {
//                cell2.detailTextLabel.text = @"All";
//            }
//            else if ([singType isEqualToString:@"2"]) {
//                cell2.detailTextLabel.text = @"dSign";
//            }
//             else if ([singType isEqualToString:@"3"]) {
//                cell2.detailTextLabel.text = @"eSign";
//            }
//             else if ([singType isEqualToString:@"4"]) {
//                cell2.detailTextLabel.text = @"eSignature";
//            }
//             else if ([singType isEqualToString:@"5"]) {
//                cell2.detailTextLabel.text = @"dSign & eSign";
//            }
//             else if ([singType isEqualToString:@"6"]) {
//                cell2.detailTextLabel.text = @"dSign & eSignature";
//            }
//            else  cell2.detailTextLabel.text = @"N/A";

            //cell2.detailTextLabel.text = [[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[_profileArray valueForKey:@"SignatureType"]]];
            
            
            if ([singType isEqualToString:@"1,2,3"]) {
                cell2.detailTextLabel.text = @"All";
            }
            else  if ([singType isEqualToString:@"1"]) {
                cell2.detailTextLabel.text = @"dSign";
            }
            else  if ([singType isEqualToString:@"2"]) {
                cell2.detailTextLabel.text = @"eSign";
            }
            else  if ([singType isEqualToString:@"3"]) {
                cell2.detailTextLabel.text = @"eSignature";
            }
            else  if ([singType isEqualToString:@"1,2"]) {
                cell2.detailTextLabel.text = @"dSign & eSign";
            }
            else  if ([singType isEqualToString:@"1,3"]) {
                cell2.detailTextLabel.text = @"dSign & eSignature";
            }
            else  if ([singType isEqualToString:@"2,3"]) {
                cell2.detailTextLabel.text = @"eSign & eSignature";
            }
            else  cell2.detailTextLabel.text = @"N/A";
            
        }
        if (indexPath.row == 2) {
            
            NSString *singType = [[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[_profileArray valueForKey:@"Signertype"]]];
            
            if ([singType isEqualToString:@"1"]) {
                cell2.detailTextLabel.text = @"Occasional User";
            }
            else if ([singType isEqualToString:@"2"]) {
                cell2.detailTextLabel.text = @"Regular User";
            }
            else  cell2.detailTextLabel.text = @"N/A";
            
           // cell2.detailTextLabel.text = [[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[_profileArray valueForKey:@"Signertype"]]];
            
        }
        if (indexPath.row == 3) {
            NSString *singType = [[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[_profileArray valueForKey:@"AdhocSignatureType"]]];
            
//            if ([singType isEqualToString:@"1"]) {
//                cell2.detailTextLabel.text = @"All";
//            }
//            else  if ([singType isEqualToString:@"2"]) {
//                cell2.detailTextLabel.text = @"dSign";
//            }
//            else  if ([singType isEqualToString:@"3"]) {
//                cell2.detailTextLabel.text = @"eSign";
//            }
//            else  if ([singType isEqualToString:@"4"]) {
//                cell2.detailTextLabel.text = @"eSignature";
//            }
//            else  if ([singType isEqualToString:@"5"]) {
//                cell2.detailTextLabel.text = @"dSign & eSign";
//            }
//            else  if ([singType isEqualToString:@"6"]) {
//                cell2.detailTextLabel.text = @"dSign & eSignature";
//            }
//            else  cell2.detailTextLabel.text = @"N/A";
            
           // cell2.detailTextLabel.text = [[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[_profileArray valueForKey:@"AdhocSignatureType"]]];
            
            if ([singType isEqualToString:@"1,2,3"]) {
                cell2.detailTextLabel.text = @"All";
            }
            else  if ([singType isEqualToString:@"1"]) {
                cell2.detailTextLabel.text = @"dSign";
            }
            else  if ([singType isEqualToString:@"2"]) {
                cell2.detailTextLabel.text = @"eSign";
            }
            else  if ([singType isEqualToString:@"3"]) {
                cell2.detailTextLabel.text = @"eSignature";
            }
            else  if ([singType isEqualToString:@"1,2"]) {
                cell2.detailTextLabel.text = @"dSign & eSign";
            }
            else  if ([singType isEqualToString:@"1,3"]) {
                cell2.detailTextLabel.text = @"dSign & eSignature";
            }
            else  if ([singType isEqualToString:@"2,3"]) {
                cell2.detailTextLabel.text = @"eSign & eSignature";
            }
            else  cell2.detailTextLabel.text = @"N/A";
            
        }
//        if (indexPath.row == 5) {
//            NSString *singType = [[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[_profileArray valueForKey:@"ExpiresOn"]]];
//            if ([singType isEqualToString:@""]) {
//                cell2.detailTextLabel.text = @"N/A";
//            }
//           else cell2.detailTextLabel.text = [[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[_profileArray valueForKey:@"ExpiresOn"]]];
//
//        }
        if (indexPath.row == 4) {
            NSString *singType = [[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[_profileArray valueForKey:@"NoofUsers"]]];
            if ([singType isEqualToString:@""]) {
                cell2.detailTextLabel.text = @"N/A";
            }
            else cell2.detailTextLabel.text = [[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[_profileArray valueForKey:@"NoofUsers"]]];
            
        }
      
        cell2.selectionStyle = UITableViewCellSelectionStyleNone;

        return cell2;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;//[_profileArray count];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Profile  Details";
    }
    else return @"Subscription  Details";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 50;
    }
    return 30;
}

//Network Connection Checks
- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
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
