//
//  SignatoriesPage.m
//  emSigner
//
//  Created by Emudhra on 06/08/18.
//  Copyright © 2018 Emudhra. All rights reserved.
//

#import "SignatoriesPage.h"
#import "SignatoriesCell.h"
#import "NSObject+Activity.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "WebserviceManager.h"
#import "HoursConstants.h"
#import "SingletonAPI.h"
#import "LMNavigationController.h"
#import "MBProgressHUD.h"

@interface SignatoriesPage ()
{
    long selectedIndex;
    
}

@end

@implementation SignatoriesPage

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _addSignatureTable.delegate = self;
    _addSignatureTable.dataSource = self;
    NSData* imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"FirstImage"];
    //NSString *base64image=[imageData base64EncodedStringWithOptions:0];
   // _imageViewForSign = [UIImage imageWithData:imageData];
    
     _addSignatureTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
     _addSignatureTable.tableFooterView.backgroundColor = _addSignatureTable.separatorColor;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"SignatoriesCell";
    SignatoriesCell *cell = (SignatoriesCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[SignatoriesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
        if (indexPath.row == 0) {
            NSData* imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"FirstImage"];

            UIImage* image = [UIImage imageWithData:imageData];
            cell.addSignImage.image = [UIImage imageWithData:imageData];
            //image;

        }
        else if (indexPath.row == 1)
        {
            NSData* imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"secondImage"];
            UIImage* image = [UIImage imageWithData:imageData];
            cell.addSignImage.image = image;
        }
        else if (indexPath.row == 2)
        {
            NSData* imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"thirdImage"];
            UIImage* image = [UIImage imageWithData:imageData];
            cell.addSignImage.image = image;
        }
    
        return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Please select your signature";
    }
    else return @"";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath   *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    selectedIndex = indexPath.row;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
   
    return 15;
   
}
- (IBAction)signBtn:(id)sender {
    
    if (selectedIndex == 0)
    {
        NSData* signatureData = [[NSUserDefaults standardUserDefaults] objectForKey:@"original1"];
        [self signPdf:signatureData];
    }
    else if (selectedIndex == 1)
    {
       NSData* signatureData = [[NSUserDefaults standardUserDefaults] objectForKey:@"original2"];
       [self signPdf:signatureData];
    }
    else if (selectedIndex == 2)
    {
        
       NSData* signatureData = [[NSUserDefaults standardUserDefaults] objectForKey:@"original3"];
        [self signPdf:signatureData];
    }
    
}

-(void)signPdf:(NSData*)signatureData
{

        [self startActivity:@""];
       // self.continueBlock([self signature]);

       // NSData *dataImage =UIImagePNGRepresentation([self signature]);
        NSString *base64image=[signatureData base64EncodedStringWithOptions:0];
        NSString *password = @"";

        //NSString *passwordPro = [[NSUserDefaults standardUserDefaults]
        //valueForKey:@"passwordPro"];
        NSString *checkPassword  = [[NSUserDefaults standardUserDefaults] valueForKey:@"Password"];

        NSString *post = [NSString stringWithFormat:@"WorkflowId=%@&SignatureImage=%@&Password=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"_signatureWorkFlowIDForMultiple"],base64image,checkPassword];
        post = [[post stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        [WebserviceManager sendSyncRequestWithURL:kSignatureImage method:SAServiceReqestHTTPMethodPOST body:post completionBlock:^(BOOL status, id responseValue){

            if (status) {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Password"];

                //[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:checkPassword];
                NSNumber * isSuccessNumber = (NSNumber *)[responseValue valueForKey:@"IsSuccess"];
                if([isSuccessNumber boolValue] == YES)
                {
                    dispatch_async(dispatch_get_main_queue(),
                                   ^{
                                       _imageArray = [[responseValue valueForKey:@"Messages"] objectAtIndex:0];

                                       UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

                                       if ([_strExcutedFrom isEqualToString:@"Pending"]) {
                                           LMNavigationController *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"HomeNavController"];
                                           [self presentViewController:objTrackOrderVC animated:YES completion:nil];

                                       }

                                       else
                                       {
                                          // [(UINavigationController *)self.presentingViewController  popViewControllerAnimated:NO];
                                           [self dismissViewControllerAnimated:YES completion:nil];
                                       }

                                       [self stopActivity];
                                       UIAlertView * alert15 =[[UIAlertView alloc ] initWithTitle:@"" message:[[responseValue valueForKey:@"Messages"] objectAtIndex:0] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                                       [alert15 show];
                                       //alert15 = nil;

                                   });

                }
            }

        }];

    
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    selectedIndex = indexPath.row;
//    if(indexPath.row == selectedIndex)
//    {
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//    }
//    else
//    {
//        cell.accessoryType = UITableViewCellAccessoryNone;
//    }
//    //[tableView reloadData];
//
//}


- (IBAction)dismissBtn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
