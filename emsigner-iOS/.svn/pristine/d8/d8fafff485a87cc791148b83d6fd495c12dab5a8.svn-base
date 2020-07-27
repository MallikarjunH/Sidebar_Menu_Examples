//
//  WorkflowTableViewController.m
//  emSigner
//
//  Created by eMudhra on 08/10/18.
//  Copyright © 2018 Emudhra. All rights reserved.
//

#import "WorkflowTableViewController.h"
#import "workflow.h"
#import "UploadDocuments.h"
#import "HoursConstants.h"
#import "WebserviceManager.h"
#import "Connection.h"
#import "ShowActivities.h"
#import "SignersInformation.h"
#import "MBProgressHUD.h"
#import "NSObject+Activity.h"
#import "DocsPage.h"
#import "DocStoreVC.h"
#import "BaseViewController.h"
#import "FlexiformsPage.h"
#import "CustomHeader.h"

static int const kHeaderSectionTag = 6900;

@interface WorkflowTableViewController ()
{
    UILabel *noDataLabel;
    NSString* CategoryName;
    NSDictionary *d;
}
@property (assign) NSInteger expandedSectionHeaderNumber;
@property (assign) UITableViewHeaderFooterView *expandedSectionHeader;
@property (strong) NSArray *sectionItems;
@property (strong) NSArray *sectionNames;
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;
@property (nonatomic) UIViewController *selectedController;

@end

@implementation WorkflowTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title=@"WorkFlows";
    self.tabBar.delegate = self;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
        
    [self.tabBar setSelectedItem:[self.tabBar.items objectAtIndex:2]];
    
    UINib *nib  = [UINib nibWithNibName:@"CustomHeader" bundle:nil];
    
    [_workflowsTable registerNib:nib forHeaderFooterViewReuseIdentifier:@"CustomHeader"];
    UIView *view;
    _workflowsTable.delegate = self;
    _workflowsTable.dataSource = self;
    _workflowsTable.tableFooterView = view;

}

-(void) viewWillAppear:(BOOL)animated{
    
    self.arForTable = [[NSMutableArray alloc] init];
    [self.arForTable addObjectsFromArray:self.arrayOriginal];
    self.workflowsTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _subarray = [[NSMutableArray alloc]init];
    [self setTitle:@"Select WorkFlows"];
    self.tabBarController.navigationItem.title = @"WorkFlows";
    _mainarray = [[NSMutableArray alloc]init];
    _childArray = [[NSMutableArray alloc]init];
    [self getWorkFlows];

}

-(void)getWorkFlows
{
    [self startActivity:@"Refreshing..."];
    //https://sandboxapi.emsigner.com/api/GetWorkflows
    NSString *requestURL = [NSString stringWithFormat:@"%@ListTemplates",kGetWorkFlows];
    
    [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
        
       if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])
        {
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               
                               _responseArray=[responseValue valueForKey:@"Response"];
                            
                               if (_responseArray != (id)[NSNull null] || _responseArray.count != 0)
                               {
                                   
                               for (int i = 0; i<_responseArray.count; i++) {
                                   NSDictionary *dict = _responseArray[i];
                                   NSString *codeR = [[dict objectForKey:@"ParentId"] stringValue];
                                   
                                   if ([codeR isEqualToString:@"0"]) {
                                       [_mainarray addObject:dict];
                                   }
                               }
                               
                               [self.workflowsTable reloadData];
                               [self stopActivity];
                               }
                               else
                               {
                                   
                                   if (_responseArray.count == 0) {
                                       
                                       noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.workflowsTable.bounds.size.width - 30, self.workflowsTable.bounds.size.height)];
                                       noDataLabel.text = [[responseValue valueForKey:@"Messages"]objectAtIndex:0];
                                       noDataLabel.textColor = [UIColor grayColor];
                                       noDataLabel.textAlignment = NSTextAlignmentCenter;
                                       noDataLabel.numberOfLines = 0;

                                       self.workflowsTable.backgroundView = noDataLabel;
                                       self.workflowsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
                                      
                                       [_workflowsTable reloadData];
                                   }
                                   [self stopActivity];
                                   return;
                               }
                               
                           });
        }
        else{
       
            dispatch_async(dispatch_get_main_queue(),
            ^{
            noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.workflowsTable.bounds.size.width - 30, self.workflowsTable.bounds.size.height)];
            noDataLabel.text = [[responseValue valueForKey:@"Messages"]objectAtIndex:0];
            noDataLabel.textColor = [UIColor grayColor];
            noDataLabel.textAlignment = NSTextAlignmentCenter;
            noDataLabel.numberOfLines = 0;
            self.workflowsTable.backgroundView = noDataLabel;
            self.workflowsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
            [_workflowsTable reloadData];

            [self stopActivity];

            });
            
            return;
        }
        
    }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - alerts for documents

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

    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Ok"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                    
                                    [self stopActivity];
                                    
                                    
                                }];

    [alert addAction:yesButton];
    
    [self presentViewController:alert animated:YES completion:nil];
    [self stopActivity];
    
    
}

-(void) alertForReview
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@""
                                 message:@"Review documents can't be opened as of now."
                                 preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Ok"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                    
                                    [self stopActivity];
                                    
                                    
                                }];

    [alert addAction:yesButton];
    
    [self presentViewController:alert animated:YES completion:nil];
    [self stopActivity];
    
    
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

    [alert addAction:yesButton];
    
    [self presentViewController:alert animated:YES completion:nil];
    [self stopActivity];
    
    
}
#pragma mark - Table view data source
#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_mainarray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    cell.textLabel.text = [[self.mainarray objectAtIndex:indexPath.row] valueForKey:@"TemplateName"];

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{


    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _subarray = [NSMutableArray array];
    d = [[NSDictionary alloc]init];
    d =[self.mainarray objectAtIndex:indexPath.row];
    
    int CategoryId = [[d valueForKey:@"TemplateId"]intValue];

    //workflow type 2
    if ([[d valueForKey:@"TemplateType"]integerValue] == 2)
    {
        //[self getFlexiformsFileData:CategoryId];
        [self alertForFlexiforms];
        return;
    }
    
    //workflow type 4
    
    if ([[d valueForKey:@"TemplateType"]integerValue] == 4)
    {
        [self alertForBulkDocuments];
        return;
    }
    
    //workflow type 5
    if ([[d valueForKey:@"TemplateType"]integerValue] == 5)
    {
        [self alertForCollaborative];
        return;
    }
    
    [[NSUserDefaults standardUserDefaults]setObject:[d valueForKey:@"TemplateType"] forKey:@"TemplateType"] ;

    //Start EMIOS-1098
    for(int i=0;i<_responseArray.count;i++) {
        NSDictionary * dict1 = _responseArray[i];
                                                             NSLog(@"%i",i);
                                                             if (CategoryId == [[dict1 valueForKey:@"ParentId"]intValue])
                                                             {
                                                                  NSLog(@"parentId %i",[[dict1 valueForKey:@"ParentId"]intValue]);
                                                                  [_subarray addObject:dict1];
                                                             }
    }
     if (_subarray.count > 0) {
         NSUInteger length = [[d valueForKey:@"TemplateName"] length];
                 
                 if (length >2) {
                   CategoryName  = [[d valueForKey:@"TemplateName"]substringToIndex:2];
                 }
                 else
                 {
                   CategoryName = [d valueForKey:@"TemplateName"];
                 }

                                              ShowActivities *objTrackOrderVC= [[ShowActivities alloc] initWithNibName:@"ShowActivities" bundle:nil];
                                              objTrackOrderVC.showArrayForActivity = _subarray;
                                              objTrackOrderVC.TotalArrayForActivity = _responseArray;
                                              objTrackOrderVC.categoryname = CategoryName;
                                              [self.navigationController pushViewController:objTrackOrderVC animated:YES];
        
     } else {
         NSUInteger length = [[d valueForKey:@"TemplateName"] length];
         
         if (length >2) {
           CategoryName  = [[d valueForKey:@"TemplateName"]substringToIndex:2];
         }
         else
         {
           CategoryName = [d valueForKey:@"TemplateName"];
         }
         [self checkMenuAccessForWorkflow:CategoryId];
     }
    //End EMIOS-1098
}

-(void)checkMenuAccessForWorkflow:(int)categoryId{
     [self startActivity:@""];
    NSString *requestURL = [NSString stringWithFormat:@"%@=%d",kCheckMenuAccess,categoryId];
        
        [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
           
           if(status && [[responseValue valueForKey:@"IsSuccess"]intValue] == 1)
            {
                dispatch_async(dispatch_get_main_queue(),
                               ^{
                                                                   
                                   if (_responseArray != (id)[NSNull null])
                                   {
//
                                          if ([[d valueForKey:@"IsWorkflowCreated"]boolValue] == 0)
                                       {

                                                     for (int j= 0; j<_responseArray.count; j++) {
                                                      NSDictionary * dict1 = _responseArray[j];
                                                      NSLog(@"%i",j);
                                                      if (categoryId == [[dict1 valueForKey:@"ParentId"]intValue])
                                                      {
                                                           NSLog(@"parentId %i",[[dict1 valueForKey:@"ParentId"]intValue]);
                                                           [_subarray addObject:dict1];
                                                      }
                                                     }
                                       }

                                       if (_subarray.count > 0) {

                                           ShowActivities *objTrackOrderVC= [[ShowActivities alloc] initWithNibName:@"ShowActivities" bundle:nil];
                                           objTrackOrderVC.showArrayForActivity = _subarray;
                                           objTrackOrderVC.TotalArrayForActivity = _responseArray;
                                           objTrackOrderVC.categoryname = CategoryName;
                                           [self.navigationController pushViewController:objTrackOrderVC animated:YES];
                                       }
                                       else
                                       {
                                           NSUserDefaults *savePathForPdf = [NSUserDefaults standardUserDefaults];
                                           [savePathForPdf setInteger:categoryId forKey:@"workf  lowCategoryId"];
                                           [savePathForPdf synchronize];
                                           
                                           SignersInformation *objTrackOrderVC= [[SignersInformation alloc] initWithNibName:@"SignersInformation" bundle:nil];
                                           objTrackOrderVC.categoryId = [NSString stringWithFormat:@"%i", categoryId];
                                           objTrackOrderVC.categoryname = CategoryName;
                                        
                                           objTrackOrderVC.navigationTitle = [d valueForKey:@"TemplateName"];
                                           [self.navigationController pushViewController:objTrackOrderVC animated:YES];
                                       }
                                    [self stopActivity];
                                   }
                                   //}
                               });
            }
            else{
                [self stopActivity];
                
                dispatch_async(dispatch_get_main_queue(),
                                              ^{
                UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:@"Workflow Templates is not created for this activity " preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                                                                    handler:nil];
                [alert addAction:cancel];
                [self presentViewController:alert animated:YES completion:nil];
                 });
           
            }
            
        }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    return 50;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
          CustomHeader *header = [_workflowsTable dequeueReusableHeaderFooterViewWithIdentifier:@"CustomHeader"];
          
          
          return header;
}


- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {

    if([item.title  isEqual: @"DashBoard"]) {
        DocsPage *controller1 = [self.storyboard instantiateViewControllerWithIdentifier:@"DocsPage"];
                controller1.view.frame = self.view.bounds;

        [self.view addSubview:controller1.view];
        [self addSelectedControllerViewOnBaseView:controller1];

    }
    else if ([item.title  isEqual: @"Docstore"]){
      
        DocStoreVC *controller1 = [self.storyboard instantiateViewControllerWithIdentifier:@"DocStoreVC"];
        controller1.view.frame = self.view.bounds;
        [self.view addSubview:controller1.view];
        [self addSelectedControllerViewOnBaseView:controller1];

        
    }
    else if ([item.title  isEqual: @"WorkFlows"]){

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

#pragma mark - Search Bar

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
           
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
    _mainarray = [NSMutableArray array];
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    
    [self getWorkFlows];

}

 
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText length] == 0) {
        self.searchResults = @"";
       
        [self.workflowsTable reloadData];
        [searchBar resignFirstResponder];
    }
  
    else if ([searchText length] >= 1){

    NSPredicate *filter = [NSPredicate predicateWithFormat:@"TemplateName contains[c] %@ ",searchText];
    _searchResults = [self.mainarray filteredArrayUsingPredicate:filter];
        if (_searchResults.count == 0) {
                   self.mainarray = [[NSMutableArray alloc]init];
                   [self.workflowsTable reloadData];

               }
               else{
                   NSMutableArray *sortedArray = [[NSMutableArray alloc]init];
                 
                   sortedArray = [_searchResults mutableCopy];
                   
                   NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"WorkflowName" ascending:YES];
                   self.mainarray = [sortedArray sortedArrayUsingDescriptors:@[sort]];
                   [self.workflowsTable reloadData];
               }
    }
}

@end
