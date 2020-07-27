//
//  BaseViewController.m
//  11thHour
//
//  Created by Nawin Kumar on 7/19/15.
//  Copyright (c) 2015 alchemy. All rights reserved.
//

#import "BaseViewController.h"
#import "LeftMenuViewController.h"
#import "MyProfileVC.h"
#import "ChangePasswordVC.h"
#import "iRate.h"
#import "AboutUsVC.h"
#import "ViewController.h"
#import "CoSignPendingVC.h"
#import "AppDelegate.h"
#import "PendingVC.h"
#import "DeclineStatusVC.h"
#import "CompleteStatusVC.h"
#import "RecallStatusVC.h"
#import "LMMenuCell.h"
#import "DocStoreVC.h"
#import "RateUsVC.h"
#import "LMNavigationController.h"
#import "HomeNewDashBoardVC.h"
#import "DocsPage.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "emSigner-Swift.h"

@interface BaseViewController ()

{
   // UIViewController *selectedController;
    bool clicked;

}
@property(nonatomic,strong)LeftMenuViewController *leftCntrlr;
@property(strong,nonatomic) swiftController *cntroller;

- (IBAction)SlidetheView:(id)sender;

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(clicked ? @"Yes" : @"No");
    
    [_allDocumentBtn setTitle:@"Dashboard" forState:UIControlStateNormal];
    self.DocumentType = @[@"View DocStore",@"My Signatures", @"Waiting For Others", @"Declined",@"Recalled",@"Completed",];
    self.DocumentTypeImageview = @[@"ico_doc_24",@"pending-1x",@"ico-waiting-32", @"decline-1x",@"recalled-1x",@"completed-1x"];
    self.currentDocumentTypeIndex = 0;
    _sideMenuArray = [[NSMutableArray alloc]initWithObjects:@"Doc Store",@"Pending",@"Doc Store",@"My Profile",@"Rate the App",@"Scan Document",@"About",@"Logout",nil];
    self.title = @"Dashboard";
    _mStoryIdArray = [[NSArray alloc]initWithObjects:@"DocsPage",@"HomeNewDashBoardVC",@"DocStoreVC",@"MyProfileVC",@"RateUsVC",@"AboutUsVC",@"ViewController",nil];
    [self loadViewonSelection:@"DocsPage"];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self setTitle:@"Dashboard"];
    self.tabBarController.navigationItem.title = @"Dashboard";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self SlidetheView:nil];
}

- (IBAction)SlidetheView:(id)sender
{
    [self MenuAction];
    [self.dropdownView hide];
}


-(void)MenuAction
{
    
    if (self.leftCntrlr==nil)
    {
        self.leftCntrlr = [[LeftMenuViewController alloc] init];
        self.leftCntrlr.mdelegate=self;
        _leftCntrlr.view.frame = CGRectMake(-self.view.frame.size.width , 0, self.view.frame.size.width, self.view.frame.size.height);
        [self.view addSubview:self.leftCntrlr.view];
        [self addChildViewController:_leftCntrlr];
    }
    
    self.leftCntrlr.mdelegate = self;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        if (!(_leftCntrlr.view.frame.origin.x<0)) {
            NSLog(@"open");
            _leftCntrlr.view.frame = CGRectMake(-self.view.frame.size.width , 0, self.view.frame.size.width, self.view.frame.size.height);
        }
        else{
            NSLog(@"close");
            _leftCntrlr.view.frame = CGRectMake(0 , 0, self.view.frame.size.width, self.view.frame.size.height);
            
        }
        
        [self.view addSubview:self.leftCntrlr.view];
    }
                     completion:^(BOOL finished) {
                         if (finished) {
                             
                             [self addChildViewController:_leftCntrlr];
                         }
                     }];
    
}

-(void)tableCellClickedWithIndex:(int)aIndex
{
    if (aIndex == 4) {
    [self LogoutAction];
        
    }
    else if (aIndex == 0) {
        
        UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        AboutUsVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"AboutUsVC"];
        objTrackOrderVC.titleName = @"About";
        [self.navigationController pushViewController:objTrackOrderVC animated:YES];
        [self MenuAction];
        
    }

    else if (aIndex == 1)
    {

        
        DocsPage *controller1 = [self.storyboard instantiateViewControllerWithIdentifier:@"DocsPage"];
        [_allDocumentBtn setTitle:@"Dashboard" forState:UIControlStateNormal];
        
        controller1.view.frame = self.view.bounds;
        [self.view addSubview:controller1.view];
        /*Calling the addChildViewController: method also calls
         the child’s willMoveToParentViewController: method automatically */
        
        [self addSelectedControllerViewOnBaseView:controller1];
        [self MenuAction];

    }
    else if (aIndex==2)
    {
        UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MyProfileVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"MyProfileVC"];
        objTrackOrderVC.titleName = @"My Profile";
        [self.navigationController pushViewController:objTrackOrderVC animated:YES];
        [self MenuAction];
    }
  
    else if (aIndex == 3)
    {
        
        NSString *iTunesLink = @"https://itunes.apple.com/us/app/apple-store/id1246670687?mt=8";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
        [self MenuAction];
      
        
    }
    else{
        [self MenuAction];
    }
    
}

-(void)loadViewonSelection:(NSString*)StoryIdentifier
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    UIViewController *cntrlr = [self.storyboard instantiateViewControllerWithIdentifier:StoryIdentifier];
    [self addSelectedControllerViewOnBaseView:cntrlr];
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

-(void)LogoutAction
{
    //Logout
    AppDelegate *theDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    //for office 365
    _cntroller = [[swiftController alloc]init];
    _cntroller.signOut;
    

    theDelegate.isLoggedIn = NO;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:theDelegate.isLoggedIn] forKey:@"isLogin"];
    [NSUserDefaults resetStandardUserDefaults];
    [NSUserDefaults standardUserDefaults];
    UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"ViewController"];
    [self presentViewController:objTrackOrderVC animated:YES completion:nil];
    
}


- (IBAction)allDocumentsBtn:(id)sender
{
    //[self showDropDownViewFromDirection:LMDropdownViewDirectionTop];
}

- (IBAction)rightMenu:(id)sender {
    
    
    }

#pragma mark == UIPopoverPresentationControllerDelegate ==
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.documentTableView.frame = CGRectMake(CGRectGetMinX(self.documentTableView.frame),
                                      CGRectGetMinY(self.documentTableView.frame),
                                      CGRectGetWidth(self.view.bounds),
                                      MIN(CGRectGetHeight(self.view.bounds) - 50, self.DocumentType.count * 50));
}

#pragma mark - DROPDOWN VIEW

- (void)showDropDownViewFromDirection:(LMDropdownViewDirection)direction
{
    // Init dropdown view
    if (!self.dropdownView) {
        self.dropdownView = [LMDropdownView dropdownView];
        self.dropdownView.delegate = self;
        }
    self.dropdownView.direction = direction;
    
    // Show/hide dropdown view
    if ([self.dropdownView isOpen]) {
        [self.dropdownView hide];
    }
    else {
        switch (direction) {
            case LMDropdownViewDirectionTop: {
                
                [self.dropdownView showFromNavigationController:self.navigationController
                                                withContentView:self.documentTableView];
                break;
            }
            default:
                break;
        }
    }
}

- (void)dropdownViewWillShow:(LMDropdownView *)dropdownView
{
    NSLog(@"Dropdown view will show");
}

- (void)dropdownViewDidShow:(LMDropdownView *)dropdownView
{
    NSLog(@"Dropdown view did show");
}

- (void)dropdownViewWillHide:(LMDropdownView *)dropdownView
{
    NSLog(@"Dropdown view will hide");
}

//- (void)dropdownViewDidHide:(LMDropdownView *)dropdownView
//{
//    NSLog(@"Dropdown view did hide");
//
//    switch (self.currentDocumentTypeIndex) {
//        case 0:
//            //self.mapView.mapType = MKMapTypeStandard;
//            break;
//        case 1:
//            //self.mapView.mapType = MKMapTypeSatellite;
//            break;
//        case 2:
//            //self.mapView.mapType = MKMapTypeHybrid;
//            break;
//        default:
//            break;
//    }
//}
#pragma mark - MENU TABLE VIEW

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.DocumentType count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    LMMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuCell"];
    if (!cell) {
        cell = [[LMMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"menuCell"];
    }
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor blackColor];
    [cell setSelectedBackgroundView:bgColorView];
    
    cell.menuItemLabel.text = [self.DocumentType objectAtIndex:indexPath.row];
    [cell.selectedMarkView setImage:[UIImage imageNamed:[_DocumentTypeImageview objectAtIndex:indexPath.row]]];
    
    //
    if(indexPath.row == _currentSelectedRow)
    {
        
        [tableView
         selectRowAtIndexPath:indexPath
         animated:TRUE
         scrollPosition:UITableViewScrollPositionNone
         ];
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (!(_leftCntrlr.view.frame.origin.x<0)) {
        NSLog(@"open");
        _leftCntrlr.view.frame = CGRectMake(-self.view.frame.size.width , 0, self.view.frame.size.width, self.view.frame.size.height);
    }
    
    switch (indexPath.row) {

 
            
        case 0:
        {
           

            DocsPage *controller1 = [self.storyboard instantiateViewControllerWithIdentifier:@"DocStoreVC"];

            [_allDocumentBtn setTitle:[_DocumentType objectAtIndex:0] forState:UIControlStateNormal];
            
            controller1.view.frame = self.view.bounds;
            [self.view addSubview:controller1.view];
            /*Calling the addChildViewController: method also calls
             the child’s willMoveToParentViewController: method automatically */
            [self addSelectedControllerViewOnBaseView:controller1];
            
        }
            break;
        case 1:
        {
            HomeNewDashBoardVC *controller1 = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeNewDashBoardVC"];
            [_allDocumentBtn setTitle:[_DocumentType objectAtIndex:1] forState:UIControlStateNormal];
            
            controller1.view.frame = self.view.bounds;
            [self.view addSubview:controller1.view];
            /*Calling the addChildViewController: method also calls
             the child’s willMoveToParentViewController: method automatically */
            
            [self addSelectedControllerViewOnBaseView:controller1];

            
            
//            [self addChildViewController:controller7];
//            [controller7 didMoveToParentViewController:self];
            
        }
            
            break;
            
        case 2:
        {
            PendingVC *controller2 = [[PendingVC alloc] initWithNibName:@"PendingVC" bundle:nil];
            [_allDocumentBtn setTitle:[_DocumentType objectAtIndex:2] forState:UIControlStateNormal];
            
            controller2.view.frame = self.view.bounds;
            [self.view addSubview:controller2.view];
            /*Calling the addChildViewController: method also calls
             the child’s willMoveToParentViewController: method automatically */
            
            [self addSelectedControllerViewOnBaseView:controller2];

            
//            [self addChildViewController:controller2];
//            [controller2 didMoveToParentViewController:self];
        }
            break;
            
       // case 3:
       // {
//            CoSignPendingVC *controller5 = [[CoSignPendingVC alloc]initWithNibName:@"CoSignPendingVC" bundle:nil];
//            [_allDocumentBtn setTitle:[_DocumentType objectAtIndex:3] forState:UIControlStateNormal];
//
//            controller5.view.frame = self.view.bounds;
//            [self.view addSubview:controller5.view];
//            /*Calling the addChildViewController: method also calls
//             the child’s willMoveToParentViewController: method automatically */
//
//            [self addSelectedControllerViewOnBaseView:controller5];

            
//            [self addChildViewController:controller5];
//            [controller5 didMoveToParentViewController:self];
       // }

          //  break;
            
        case 3:
        {
            DeclineStatusVC *controller4 = [[DeclineStatusVC alloc] initWithNibName:@"DeclineStatusVC" bundle:nil];
            [_allDocumentBtn setTitle:[_DocumentType objectAtIndex:3] forState:UIControlStateNormal];
            controller4.view.frame = self.view.bounds;
            [self.view addSubview:controller4.view];
            /*Calling the addChildViewController: method also calls
             the child’s willMoveToParentViewController: method automatically */
            
            [self addSelectedControllerViewOnBaseView:controller4];

            
//            [self addChildViewController:controller4];
//            [controller4 didMoveToParentViewController:self];
        }
            
            break;
        
        case 4:
        {
            RecallStatusVC *controller3 = [[RecallStatusVC alloc]initWithNibName:@"RecallStatusVC" bundle:nil];
            [_allDocumentBtn setTitle:[_DocumentType objectAtIndex:4] forState:UIControlStateNormal];
            controller3.view.frame = self.view.bounds;
            [self.view addSubview:controller3.view];
            /*Calling the addChildViewController: method also calls
             the child’s willMoveToParentViewController: method automatically */
            
            [self addSelectedControllerViewOnBaseView:controller3];

            
//            [self addChildViewController:controller3];
//            [controller3 didMoveToParentViewController:self];
        }
            
            break;
            
        case 5:
        {
            
            CompleteStatusVC *controller3 = [[CompleteStatusVC alloc]initWithNibName:@"CompleteStatusVC" bundle:nil];
            [_allDocumentBtn setTitle:[_DocumentType objectAtIndex:5] forState:UIControlStateNormal];
            controller3.view.frame = self.view.bounds;
            [self.view addSubview:controller3.view];
            /*Calling the addChildViewController: method also calls
             the child’s willMoveToParentViewController: method automatically */
            [self addSelectedControllerViewOnBaseView:controller3];
            
        }
            
        default:
        break;
    }
    
    self.currentDocumentTypeIndex = indexPath.row;
    [self.dropdownView hide];
    
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
