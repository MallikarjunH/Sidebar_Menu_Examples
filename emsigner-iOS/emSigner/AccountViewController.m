//
//  AccountViewController.m
//  emSigner
//
//  Created by Emudhra on 05/09/19.
//  Copyright © 2019 Emudhra. All rights reserved.
//

#import "AccountViewController.h"
#import "AboutUsVC.h"
#import "MyProfileVC.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "ChangePasswordVC.h"

@interface AccountViewController (){
    NSString *email;
    NSString *PlanName;
    NSMutableArray *_mMenuImageArray;
    
}
@end

@implementation AccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.profileArray = [NSMutableArray arrayWithObjects:@"About",@"My Profile",@"Change Password",@"Feedback", nil];
    email = [[NSUserDefaults standardUserDefaults]
                       valueForKey:@"Name"];
    PlanName = [[NSUserDefaults standardUserDefaults]
                          valueForKey:@"PlanName"];
    _mMenuImageArray = [[NSMutableArray alloc] initWithObjects:@"aboutAccount",@"user.png",@"changePassword",@"star-outline.png",nil];

}

- (void) viewWillAppear:(BOOL)animated{
    [self setTitle:@"Account"];
    self.tabBarController.navigationItem.title = @"Account";
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return  1;
    }
    else if (section == 1) {
        return self.profileArray.count;
    }
    else return 1;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    if (section == 0) {
//        return 100;
//
//    }
//    else return 0;
//}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.section == 0)
    {
        static NSString *cellIdentifier = @"AccountNameWithImage";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        NSString *strName= [NSString stringWithFormat: @"Name: %@ ", email];
        cell.textLabel.text = strName;
        
        NSString *strPlanName= [NSString stringWithFormat: @"Subscribed To: %@ ", PlanName];
        cell.detailTextLabel.text = strPlanName;
        //[cell.imageView setImage:[UIImage imageNamed:@"icon_emsigner"]];

        return cell;
        
    }
    else if (indexPath.section == 1)
    {
        static NSString *cellIdentifier = @"AccountNameWithArray";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        cell.textLabel.text = [self.profileArray objectAtIndex:indexPath.row];
        [cell.imageView setImage:[UIImage imageNamed:[_mMenuImageArray objectAtIndex:indexPath.row]]];

        return cell;

    }
    else{
        
        static NSString *cellIdentifier = @"AccountLogOut";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        cell.textLabel.text = @"Log Out";
        cell.textLabel.textAlignment= NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor redColor];
        return cell;
        
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 1) {
        
        switch (indexPath.row) {
            case 0:
            {
                UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                AboutUsVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"AboutUsVC"];
                objTrackOrderVC.titleName = @"About";
                [self.navigationController pushViewController:objTrackOrderVC animated:YES];
            }
                break;
                
            case 1:
            {
                UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                MyProfileVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"MyProfileVC"];
                objTrackOrderVC.titleName = @"My Profile";
                [self.navigationController pushViewController:objTrackOrderVC animated:YES];
            }
                break;
                
            case 2:
                {
                    UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    ChangePasswordVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"ChangePasswordVC"];
                   objTrackOrderVC.title = @"Change Password";
                    [self.navigationController pushViewController:objTrackOrderVC animated:YES];
                }
                    break;
            case 3:
            {
                NSString *iTunesLink = @"https://itunes.apple.com/us/app/apple-store/id1246670687?mt=8";
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
            }
                break;
            default:
                break;
        }
    }
    else if (indexPath.section == 2) {
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
//        [self presentViewController:objTrackOrderVC animated:YES completion:nil];
        
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//        UITabBarController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"tabBarcontroller"];
        [[UIApplication sharedApplication].keyWindow setRootViewController:objTrackOrderVC];
        
        
        
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if (section == 0) {
        
    
    // Background color
    view.tintColor = [UIColor clearColor];
    
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    
    UIImageView *dot =[[UIImageView alloc] initWithFrame:CGRectMake(10,30,70,70)];
    dot.image=[UIImage imageNamed:@"icon_emsigner"];
    [header addSubview:dot];
    
    NSString *email = [[NSUserDefaults standardUserDefaults]
                       valueForKey:@"Name"];
    NSString *PlanName = [[NSUserDefaults standardUserDefaults]
                          valueForKey:@"PlanName"];
    
    UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(15, dot.frame.size.height +30 ,200, 40)];
    label.text= email;
    [label setTextColor:[UIColor blackColor]];
    [label setFont:[UIFont fontWithName:@"Arial-BoldMT" size:20]];
    
    [header addSubview:label];
    
    UILabel *label1 = [[UILabel alloc] initWithFrame: CGRectMake(15,dot.frame.size.height+ label.frame.size.height + 20,200,30)];
    [header addSubview:label1];
    //label1.numberOfLines = 0;
    
    //draw attrString here...
    label1.text= @"You are subscribed to ";
    [label1 setFont:[UIFont fontWithName:@"TimesNewRomanPS-ItalicMT" size:14]];
    [label1 setTextColor:[UIColor blackColor]];   // PlanName
    
    UIFont * font = [UIFont  fontWithName:@"TimesNewRomanPS-BoldItalicMT" size:14];
    CGSize size = [PlanName sizeWithAttributes:@{NSFontAttributeName: font}];
    UILabel *label2 = [[UILabel alloc] initWithFrame: CGRectMake(15,dot.frame.size.height+ label.frame.size.height +label1.frame.size.height+8,size.width,30)];
    [header addSubview:label2];
    // label2.numberOfLines = 0;
    label2.text = PlanName;
    [label2 setTextColor:[UIColor blackColor]];
    [label2 setFont:[UIFont fontWithName:@"TimesNewRomanPS-BoldItalicMT" size:14]];
    
    UILabel *label3 = [[UILabel alloc] initWithFrame: CGRectMake(label2.frame.size.width +20,dot.frame.size.height+ label.frame.size.height +label1.frame.size.height+8,50,30)];
    [header addSubview:label3];
    // label2.numberOfLines = 0;
    
    [label3 setTextColor:[UIColor blackColor]];
    [label3 setFont:[UIFont fontWithName:@"TimesNewRomanPS-ItalicMT" size:14]];
    label3.text = @"Plan.";
    }
    
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
