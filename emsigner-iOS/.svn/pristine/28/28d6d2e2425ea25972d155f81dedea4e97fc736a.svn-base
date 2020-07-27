//
//  ShowActivities.m
//  emSigner
//
//  Created by EMUDHRA on 26/10/18.
//  Copyright © 2018 Emudhra. All rights reserved.
//

#import "ShowActivities.h"
#import "ShowActivitiesCellTableViewCell.h"
#import "UploadDocuments.h"
#import "SignersInformation.h"
#import "HoursConstants.h"
#import "WebserviceManager.h"
#import "Connection.h"
#import "FlexiformsPage.h"
#import "MBProgressHUD.h"
#import "NSObject+Activity.h"


@interface ShowActivities ()
{
    NSMutableString * MutableCategoryName;
    NSDictionary *d;
    int CategoryId;
    NSString* CategoryName;
}
@end

@implementation ShowActivities

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _showActivities.delegate = self;
    _showActivities.dataSource = self;
    MutableCategoryName = [[NSMutableString alloc]initWithString:_categoryname];
    self.showActivities.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    d = [[NSDictionary alloc]init];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    [self.showActivities registerNib:[UINib nibWithNibName:@"ShowActivitiesCellTableViewCell" bundle:nil] forCellReuseIdentifier:@"ShowActivitiesCellTableViewCell"];
    self.title = @"Activities";
    self.navigationController.navigationBar.topItem.title = @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _showArrayForActivity.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    ShowActivitiesCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ShowActivitiesCellTableViewCell" forIndexPath:indexPath];
    cell.imageForActivity.image = [UIImage imageNamed:@"folder"];
    
    cell.showActivityLabel.text = [[_showArrayForActivity objectAtIndex:indexPath.row]valueForKey:@"TemplateName"];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    d =[self.showArrayForActivity objectAtIndex:indexPath.row];
    CategoryId = [[d valueForKey:@"TemplateId"]intValue];
    NSUInteger length = [[d valueForKey:@"TemplateName"] length];
    
    if (length >2) {
        CategoryName  = [[d valueForKey:@"TemplateName"]substringToIndex:2];
        
    }
    else
    {
        CategoryName = [d valueForKey:@"TemplateName"];
    }
    
    if ([[d valueForKey:@"TemplateType"]integerValue] == 2)
    {
        _responseArray = [[NSArray alloc]init];
        [self alertForFlexiforms];
        //[self getFlexiformsFileData:CategoryId];
        return;
    }
    
    // NSString* CategoryName = [[d valueForKey:@"CategoryName"]substringToIndex:2];
    [self checkMenuAccessForWorkflow:CategoryId];
    
}


-(void)checkMenuAccessForWorkflow:(int)categoryId{
    [self startActivity:@""];
    NSString *requestURL = [NSString stringWithFormat:@"%@=%d",kCheckMenuAccess,categoryId];
    
    [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
        
        if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])
        {
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               
                               if (_responseArray != (id)[NSNull null])
                               {
                                   NSMutableArray *arCells=[[NSMutableArray alloc]init];
                                   
                                   if ([[d valueForKey:@"IsWorkflowCreated"]boolValue] == false) {
                                       
                                       for (int j= 0; j<_TotalArrayForActivity.count; j++) {
                                           NSDictionary * dict1 = _TotalArrayForActivity[j];
                                           NSLog(@"%i",j);
                                           
                                           if (CategoryId == [[dict1 valueForKey:@"ParentId"]intValue]) {
                                               
                                               NSLog(@"parentId %i",[[dict1 valueForKey:@"ParentId"]intValue]);
                                               [arCells addObject:dict1];
                                               
                                               [MutableCategoryName appendString:[NSMutableString stringWithFormat:@"/%@",CategoryName]];
                                               
                                           }
                                       }
                                       if (arCells.count > 0) {
                                           _showArrayForActivity = [[NSMutableArray alloc]init];
                                           NSArray*arr;
                                           for ( arr in arCells) {
                                               [_showArrayForActivity addObject:arr];
                                           }
                                           [self.showActivities reloadData];
                                           [self stopActivity];
                                       }
                                       else
                                       {
                                           [self stopActivity];
                                           UIAlertController * alert = [UIAlertController
                                                                        alertControllerWithTitle:nil
                                                                        message:@"Workflow Templates is not created for this activity "
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                                           
                                           //Add Buttons
                                           
                                           UIAlertAction* yesButton = [UIAlertAction
                                                                       actionWithTitle:@"Ok"
                                                                       style:UIAlertActionStyleDefault
                                                                       handler:^(UIAlertAction * action) {
                                                                           [self.navigationController popViewControllerAnimated:YES];
                                                                       }];
                                           
                                           
                                           [alert addAction:yesButton];
                                           
                                           [self presentViewController:alert animated:YES completion:nil];
                                           
                                       }
                                   }
                                   else{
                                       NSUserDefaults *savePathForPdf = [NSUserDefaults standardUserDefaults];
                                       [savePathForPdf setInteger:CategoryId forKey:@"workflowCategoryId"];
                                       [savePathForPdf synchronize];
                                       
                                       [MutableCategoryName appendString:[NSMutableString stringWithFormat:@"/%@",CategoryName]];
                                       SignersInformation *objTrackOrderVC= [[SignersInformation alloc] initWithNibName:@"SignersInformation" bundle:nil];
                                       objTrackOrderVC.categoryId = [NSString stringWithFormat:@"%d",CategoryId];
                                       objTrackOrderVC.categoryname = MutableCategoryName;
                                       objTrackOrderVC.navigationTitle = [d valueForKey:@"WorkflowName"];
                                       [self.navigationController pushViewController:objTrackOrderVC animated:YES];
                                       [self stopActivity];
                                   }
                                   
                               }
                           });
        }
        else{
            
            [self stopActivity];
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:@"Workflow Templates is not created for this activity " preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                                           handler:nil];
            [alert addAction:cancel];
            [self presentViewController:alert animated:YES completion:nil];
        }
        
    }];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return @"Select Activities";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 100;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    CGRect frame = cell.frame;
    //    [cell setFrame:CGRectMake(0, self.workflowsTable.frame.size.height, frame.size.width, frame.size.height)];
    //    [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionTransitionCrossDissolve  animations:^{
    //        [cell setFrame:frame];
    //    } completion:^(BOOL finished) {
    //    }];
    
    cell.transform = CGAffineTransformMakeTranslation(0.f, 45);
    cell.layer.shadowColor = [[UIColor blackColor]CGColor];
    cell.layer.shadowOffset = CGSizeMake(10, 10);
    cell.alpha = 0;
    
    //2. Define the final state (After the animation) and commit the animation
    [UIView beginAnimations:@"rotation" context:NULL];
    [UIView setAnimationDuration:0.5];
    cell.transform = CGAffineTransformMakeTranslation(0.f, 0);
    cell.alpha = 1;
    cell.layer.shadowOffset = CGSizeMake(0, 0);
    [UIView commitAnimations];
}

-(void) alertForFlexiforms
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@""
                                 message:@"Flexiform documents can't be opened as of now."
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

-(void)getFlexiformsFileData:(int)categoryId
{
    [self startActivity:@"Refreshing..."];
    NSString *requestURL = [NSString stringWithFormat:@"%@GetFlexiformtemplatedetails?categoryId=%d",kGetFlexiformtemplatedetails,categoryId];
    
    [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
        
        if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])
        {
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               
                               _responseArray=[responseValue valueForKey:@"Response"];
                               
                               if (_responseArray != (id)[NSNull null])
                               {
                                   FlexiformsPage *objtrack = [[FlexiformsPage alloc]init] ;
                                   objtrack.base64String = [[_responseArray objectAtIndex:0] valueForKey:@"Base64FileData"];
                                   objtrack.documentNameFlexiForms = [[_responseArray objectAtIndex:0] valueForKey:@"DocumentName"];
                                   objtrack.documentIdFlexiForms = [NSString stringWithFormat:@"%@", [[_responseArray objectAtIndex:0] valueForKey:@"DocumentID"]];
                                   [self.navigationController pushViewController:objtrack animated:YES];
                                   
                                   
                                   [self stopActivity];
                               }
                           });
        }
        else{
            
        }
        
    }];
}
@end
