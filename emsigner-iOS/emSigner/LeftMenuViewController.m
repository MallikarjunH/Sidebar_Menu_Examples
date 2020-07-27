//
//  LeftMenuViewController.m
//  DrawerMenuApp
//
//  Created by Valtech MacMini on 13/05/15.
//  Copyright (c) 2015 Valtech MacMini. All rights reserved.
//


#import "LeftMenuViewController.h"
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface LeftMenuViewController ()

@property(nonatomic,strong)NSMutableArray *mMenuArray;
@property(nonatomic, strong)NSMutableArray *mMenuImageArray;

@end

@implementation LeftMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[[UIColor lightGrayColor]colorWithAlphaComponent:.8];
    [self setUpMenuArray];
    self.myTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, 250, self.view.frame.size.height)];
    self.myTableView.delegate=self;
    self.myTableView.dataSource=self;
    NSLog(@"frmae is %f",self.myTableView.frame.size.height);
    [self.view addSubview:self.myTableView];
    [self.myTableView reloadData];
    self.myTableView.backgroundColor= [[UIColor whiteColor]colorWithAlphaComponent:1];
    [self.myTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _myTableView.scrollEnabled = NO;
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
        UIColor *altCellColor = [UIColor clearColor];
        cell.backgroundColor = altCellColor;
    }

- (void)setUpMenuArray
{
   
    _mMenuArray = [[NSMutableArray alloc]initWithObjects:@"About",@"View Dashboard",
                   @"My Profile",@"Feedback",@"Logout",nil];
    _mMenuImageArray = [[NSMutableArray alloc] initWithObjects:@"about.png",@"gauge.png",@"user.png",@"star-outline.png",@"logout.png",nil];
    
    [self.myTableView reloadData];
}

#pragma mark -
#pragma mark UITableView Datasource/Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _mMenuArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 46;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellMainNibID = @"my table Cell";
    
    UITableViewCell  *cellMain = [tableView dequeueReusableCellWithIdentifier:cellMainNibID];

    if (cellMain == nil) {
        cellMain =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellMainNibID];

    }
    if ([_mMenuArray count] > 0)
    {
        
    cellMain.textLabel.text = [_mMenuArray objectAtIndex:indexPath.row];
    cellMain.textLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:15.0];
    cellMain.textLabel.textColor =  [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    [cellMain.imageView setImage:[UIImage imageNamed:[_mMenuImageArray objectAtIndex:indexPath.row]]];
        
    }
    [self.myTableView setBackgroundView:nil];
    
    if(indexPath.row == _currentSelectedRow)
    {
        [tableView
         selectRowAtIndexPath:indexPath
         animated:TRUE
         scrollPosition:UITableViewScrollPositionNone
         ];
    }
    cellMain.selectionStyle = UITableViewCellSelectionStyleNone;
    return cellMain;
}

//footer

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 50;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    UIView *footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 250, 50)];
//    footer.backgroundColor = [UIColor clearColor];
//
//    UILabel *lbl = [[UILabel alloc]initWithFrame:footer.frame];
//    lbl.backgroundColor = [UIColor clearColor];
//    lbl.tintColor = [UIColor blackColor];
//    [lbl setFont:[UIFont fontWithName:@"TimesNewRomanPS-ItalicMT" size:20]];
//    lbl.text = @"Version 1.2.0";
//    lbl.textAlignment = NSTextAlignmentCenter;
//    [footer addSubview:lbl];
//
//    return footer;
//}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//     UITableViewCell  *cellMain = [tableView cellForRowAtIndexPath:indexPath];
//       [cellMain setSelectionStyle:UITableViewCellSelectionStyleNone];

    if (_mdelegate!=nil ) {
        [_mdelegate tableCellClickedWithIndex:indexPath.row];
        
    }
   
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{

    NSString *Name = @" "; //= [[NSUserDefaults standardUserDefaults]
                    //  valueForKey:@"Name"];
    return Name;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 200;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
    view.tintColor = [UIColor whiteColor];

    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    //[header.textLabel setTextColor:[UIColor blackColor]];
    
   // UIImageView *dot =[[UIImageView alloc] initWithFrame:CGRectMake(15,5,192,146)];
    UIImageView *dot =[[UIImageView alloc] initWithFrame:CGRectMake(10,30,70,70)];
    dot.image=[UIImage imageNamed:@"icon_emsigner"];
    [header addSubview:dot];
    
    NSString *email = [[NSUserDefaults standardUserDefaults]
      valueForKey:@"Name"];
    NSString *PlanName = [[NSUserDefaults standardUserDefaults]
                          valueForKey:@"PlanName"];
    //NSString *signatory = [email stringByAppendingFormat:@"%@\n", PlanName];
    
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
