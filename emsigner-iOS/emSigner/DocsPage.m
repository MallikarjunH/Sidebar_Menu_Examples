//
//  DocsPage.m
//  emSigner
//
//  Created by Emudhra on 27/07/18.
//  Copyright © 2018 Emudhra. All rights reserved.
//

#import "DocsPage.h"
#import "DocsCell.h"
#import "WebserviceManager.h"
#import "HoursConstants.h"
#import "SingletonAPI.h"
#import "AppDelegate.h"
#import "BaseViewController.h"
#import "HomeNewDashBoardVC.h"
#import "CoSignPendingVC.h"
#import "PendingVC.h"
#import "DeclineStatusVC.h"
#import "CompleteStatusVC.h"
#import "RecallStatusVC.h"
#import "RateUsVC.h"
#import "ViewController.h"
#import "MBProgressHUD.h"
#import "NSObject+Activity.h"
#import "Reachability.h"
#import "DocStoreVC.h"
#import "WorkflowTableViewController.h"
#import "UploadDocuments.h"
#import "GlobalVariables.h"

@interface DocsPage ()
{
    UIRefreshControl * refreshControl;
    GlobalVariables *globalVariables;
}
@property (weak, nonatomic) IBOutlet UITabBar *tabbar;
@property (nonatomic) UIViewController *selectedController;


@end

@implementation DocsPage

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self startActivity:@"Loading"];

    self.title = _titleName;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
   // [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.0 green:96.0 blue:192.0 alpha:1.0]];
    
    self.categoriesArray = [NSMutableArray arrayWithObjects: @"My Signatures", @"Waiting For Others", @"Declined", @"Recalled", @"Completed", nil];

    //self.docsArray = [NSMutableArray arrayWithObjects:@"View Docstore",@"Workflows",@"Upload Documents", nil];
    
    globalVariables=[GlobalVariables sharedInstance];
      
    
    //Pull to refresh
    refreshControl = [[UIRefreshControl alloc]init];
    
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];

    if (@available(iOS 10.0, *)) {
        self.docsTableView.refreshControl = refreshControl;
    } else {
        [self.docsTableView addSubview:refreshControl];
    }
    
    self.docsArray = [NSMutableArray arrayWithObjects:@"View Docstore",@"Workflows", nil];

    self.DocumentTypeImageview = @[@"pending-1x",@"ico-waiting-32",@"decline-1x",@"recalled-1x",@"completed-1x"];

    _docsTableView.delegate = self;
    _docsTableView.dataSource =self;
    self.tabbar.delegate = self;
    
    [self startActivity:@"Loading"];
    [self dashBoardCount];
    [self profileDetails];
    [self.tabbar setSelectedItem:[self.tabbar.items objectAtIndex:0]];
}

-(void)viewWillAppear:(BOOL)animated
{
   /* if (![self connected]){
        NSLog(@"Not Internet Conection");
    }else{
        NSLog(@" Internet Conection");
    }*/
    
  /*  [self startActivity:@"Loading"];
    [self dashBoardCount];
    [self profileDetails];
    [self.tabbar setSelectedItem:[self.tabbar.items objectAtIndex:0]]; */

}

- (void)refreshTable {
    //TODO: refresh your data
    [self dashBoardCount];
    [self.docsTableView reloadData];
    [refreshControl endRefreshing];
}

-(void)dashBoardCount
{
    [self startActivity:@"Loading"];

    NSString *requestURL = [NSString stringWithFormat:@"%@GetDashboardSummary",kGetDashboardSummary];
    
    [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
        //if(status)
        if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])
        {
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               [self startActivity:@"Loading"];

                               _responseArray=[responseValue valueForKey:@"Response"];
                               
                               if (_responseArray != (id)[NSNull null])
                               {
                                   _searchResults = [[NSMutableArray alloc]initWithArray:(NSMutableArray*)_responseArray];
                                   
                                  /* for (int i=0; i<self->_searchResults.count; i++) {
                                      
                                       NSDictionary * dict = _searchResults[i];
                                       //NSString *
                                   } */
                                   
                                   [_docsTableView reloadData];
                                   
                                   [self stopActivity];
                                   
                               }
                               else
                               {
                                   [_docsTableView reloadData];
                                   
                                   [self stopActivity];
                               }
                               
                           });
            [self stopActivity];

        }
        else{
            dispatch_async(dispatch_get_main_queue(),
                           ^{
            
            
            [self stopActivity];
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:nil
                                         message:@"Login failed please try Again!"
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
        });
        }
    }];
}


-(void)profileDetails
{
    //[self startActivity:@"Loading..."];
    NSString *requestURL = [NSString stringWithFormat:@"%@AccountProfile",kMyProfile];
    
    [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
        //if(status)
        if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])
        {
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               
                            NSMutableArray* _profileArray = [responseValue valueForKey:@"Response"];
                
                            NSData * profileArraydata = [NSKeyedArchiver archivedDataWithRootObject:_profileArray requiringSecureCoding:NO error:nil];

                            [[NSUserDefaults standardUserDefaults] setObject:profileArraydata forKey:@"UserProfile"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                               
                               NSString *name = [NSString stringWithFormat:@"%@",[_profileArray valueForKey:@"FullName"]];
                               [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"Name"];
                               [[NSUserDefaults standardUserDefaults] synchronize];
                               
                               //Getting subscriber id for commentsController
                               NSString *SubscriberId = [NSString stringWithFormat:@"%@",[_profileArray valueForKey:@"SubscriberId"]];
                               [[NSUserDefaults standardUserDefaults] setObject:SubscriberId forKey:@"SubscriberId"];
                               
                               //Saving Email
                               NSString *emailName = [NSString stringWithFormat:@"%@",[_profileArray valueForKey:@"PlanName"]];
                               [[NSUserDefaults standardUserDefaults] setObject:emailName forKey:@"PlanName"];
                               [[NSUserDefaults standardUserDefaults] synchronize];
                               
                           });
        }
        else{
            
          
            
            //Add Buttons
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               UIAlertController * alert = [UIAlertController
                                                            alertControllerWithTitle:nil
                                                            message:@"Login failed please try Again!"
                                                            preferredStyle:UIAlertControllerStyleAlert];
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
                           });
            return;
        }
    }];
    //[self stopActivity];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
       return  _categoriesArray.count;
    }
    else  return _docsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.section == 0)
    {
        static NSString *cellIdentifier = @"cell";
        DocsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.docsLabel.text = (self.categoriesArray)[indexPath.row];
        [cell.docsImageView setImage:[UIImage imageNamed:[_DocumentTypeImageview objectAtIndex:indexPath.row]]];
  
            if (indexPath.row == 0) {
                
                NSArray* pending = [self filteredArray:@"Status" :@"Pending"];
                NSArray* inprogress = [self filteredArray:@"Status" :@"CosignPending"];
                long pendingNumber = 0;
                long inprogressNumber = 0;
                
                if (pending.count !=0) {
                    
                     pendingNumber = [[[pending objectAtIndex:0] valueForKey:@"Count"]integerValue];
                    if (inprogress.count == 0) {
                        inprogressNumber = 0;
                    } else {
                        inprogressNumber = [[[inprogress objectAtIndex:0] valueForKey:@"Count"]integerValue];
                    }
                     
                    
                }
                else
                {
                    
                }
                long subtract = pendingNumber - inprogressNumber;
                    if (pending.count == 0) {
                    [cell.docsCount setTitle:@"0" forState:UIControlStateNormal];
                }
                else
                {
                    [cell.docsCount setTitle:[NSString stringWithFormat:@"%ld",subtract] forState:UIControlStateNormal];
                    globalVariables.mySignatureCount = [NSString stringWithFormat:@"%ld",subtract];
                }

            }
            else if (indexPath.row == 1)
            {
                 NSArray* inprogress = [self filteredArray:@"Status" :@"CosignPending"];
                if (inprogress.count == 0) {
                    [cell.docsCount setTitle:@"0" forState:UIControlStateNormal];
                }
                else
                {
                    [cell.docsCount setTitle:[NSString stringWithFormat:@"%@", [[inprogress objectAtIndex:0] valueForKey:@"Count"]] forState:UIControlStateNormal];
                    globalVariables.waitingOthersCount = [NSString stringWithFormat:@"%@", [[inprogress objectAtIndex:0] valueForKey:@"Count"]];
                }
                
            }

            else if (indexPath.row == 2)
            {
                NSArray* declined = [self filteredArray:@"Status" :@"Declined"];
                if (declined.count==0) {
                    [cell.docsCount setTitle:@"0" forState:UIControlStateNormal];
                }
                else
                {
                    [cell.docsCount setTitle:[NSString stringWithFormat:@"%@", [[declined objectAtIndex:0] valueForKey:@"Count"]] forState:UIControlStateNormal];
                    globalVariables.declinedCount = [NSString stringWithFormat:@"%@", [[declined objectAtIndex:0] valueForKey:@"Count"]];
                }
            }
            else if (indexPath.row == 3)
            {
                NSArray* recalled = [self filteredArray:@"Status" :@"Recalled"];
                if (recalled .count==0) {
                    [cell.docsCount setTitle:@"0" forState:UIControlStateNormal];
                }
                else
                {
                    [cell.docsCount setTitle:[NSString stringWithFormat:@"%@", [[recalled objectAtIndex:0] valueForKey:@"Count"]] forState:UIControlStateNormal];
                    globalVariables.recalledCount = [NSString stringWithFormat:@"%@", [[recalled objectAtIndex:0] valueForKey:@"Count"]];
                }
            }
            else if (indexPath.row == 4)
            {
                NSArray* completed = [self filteredArray:@"Status" :@"Completed"];
                if (completed .count == 0) {
                    [cell.docsCount setTitle:@"0" forState:UIControlStateNormal];
                }
                else
                {
                    [cell.docsCount setTitle:[NSString stringWithFormat:@"%@", [[completed objectAtIndex:0] valueForKey:@"Count"]] forState:UIControlStateNormal];
                    globalVariables.completedCount = [NSString stringWithFormat:@"%@", [[completed objectAtIndex:0] valueForKey:@"Count"]];
                }
            }
        return cell;

        }
    else //if(indexPath.section == 1)
    {
        NSString *CellIdentifier = @"docscell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.textLabel.text = (self.docsArray)[indexPath.row];
        return cell;

    }
//    else if(indexPath.section == 2)
//    {
//        NSString *CellIdentifier = @"workFlows";
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//        return cell;
//
//    }
//    else
//    {
//        NSString *CellIdentifier = @"UploadDocuments";
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//        return cell;
//
//    }
    
}

-(NSArray*)filteredArray:(NSString*)Status:(NSString*)Value
{
    return [_searchResults filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id elem, NSDictionary *bindings) {
        return ([[elem objectForKey:Status]  isEqual: Value]);
        
    }]];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Browse By Categories";
    }
    else return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 70;
    }
    if (section == 1) {
        return 30;
    }
    else return 0.0;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        
    switch (indexPath.row) {
        case 0:
        {
            UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            HomeNewDashBoardVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"HomeNewDashBoardVC"];
            objTrackOrderVC.title = @"My Signatures";
            [self.navigationController pushViewController:objTrackOrderVC animated:YES];

        }
            
            break;
        case 1:
        {
            PendingVC *objTrackOrderVC = [[PendingVC alloc] initWithNibName:@"PendingVC" bundle:nil];
            objTrackOrderVC.title = @"Waiting For Others";
            [self.navigationController pushViewController:objTrackOrderVC animated:YES];
        }
            
            break;
            
        case 2:
        {
            
            DeclineStatusVC *objTrackOrderVC= [[DeclineStatusVC alloc]initWithNibName:@"DeclineStatusVC" bundle:nil];
            objTrackOrderVC.title = @"Declined";
            [self.navigationController pushViewController:objTrackOrderVC animated:YES];
            
        }
            
            break;
            
        case 3:
        {
           
            RecallStatusVC *objTrackOrderVC= [[RecallStatusVC alloc] initWithNibName:@"RecallStatusVC" bundle:nil];
            objTrackOrderVC.title = @"Recalled";
            [self.navigationController pushViewController:objTrackOrderVC animated:YES];
            
        }
            
            break;
            
        case 4:
        {
            CompleteStatusVC *objTrackOrderVC= [[CompleteStatusVC alloc]initWithNibName:@"CompleteStatusVC" bundle:nil];
            objTrackOrderVC.title = @"Completed";
            [self.navigationController pushViewController:objTrackOrderVC animated:YES];
    
        }
            break;
        default:
            break;
    }
    }
    else if (indexPath.section == 1)
    {
        switch (indexPath.row) {
            case 0:
            {
                    UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    DocStoreVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"DocStoreVC"];
                    // objTrackOrderVC.title = @"Doc Store";
                    [self.navigationController pushViewController:objTrackOrderVC animated:YES];
                
                break;
            }
                case 1:
            {
                    WorkflowTableViewController *objTrackOrderVC= [[WorkflowTableViewController alloc] initWithNibName:@"WorkflowTableViewController" bundle:nil];
                            //objTrackOrderVC.categoryId = [NSString stringWithFormat:@"%d",CategoryId];
                    [self.navigationController pushViewController:objTrackOrderVC animated:YES];
                break;
            }
            
//            case 2:
//            {
//
//                UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//                UploadDocuments *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"UploadDocuments"];
//                // objTrackOrderVC.title = @"Doc Store";
//              //  [self.navigationController pushViewController:objTrackOrderVC animated:YES];
//                UINavigationController *objNavigationController = [[UINavigationController alloc]initWithRootViewController:objTrackOrderVC];
//                [self presentViewController:objNavigationController animated:true completion:nil];
//                break;
//            }

            default:
                break;
        }
        
    }
    
}
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    // Do Stuff!
    //UIWindow* window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    if([item.title  isEqual: @"DashBoard"]) {
         
     }
     else if ([item.title  isEqual: @"Docstore"]){
//         UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//         DocStoreVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"DocStoreVC"];
//         // objTrackOrderVC.title = @"Doc Store";
//         [self.navigationController pushViewController:objTrackOrderVC animated:YES];
         DocStoreVC *controller1 = [self.storyboard instantiateViewControllerWithIdentifier:@"DocStoreVC"];
         controller1.view.frame = self.view.bounds;
        // [self.view removeFromSuperview];
         [self.view addSubview:controller1.view];
         /*Calling the addChildViewController: method also calls
          the child’s willMoveToParentViewController: method automatically */
        // [self loadViewonSelection:@"DocStoreVC"];
           [self addSelectedControllerViewOnBaseView:controller1];
         
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
-(void)loadViewonSelection:(NSString*)StoryIdentifier
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    UIViewController *cntrlr = [self.storyboard instantiateViewControllerWithIdentifier:StoryIdentifier];
    [self addSelectedControllerViewOnBaseView:cntrlr];
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

//Network Connection Checks
- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

@end
