//
//  ListPdfViewer.m
//  emSigner
//
//  Created by Administrator on 3/21/17.
//  Copyright © 2017 Emudhra. All rights reserved.
//

#import "ListPdfViewer.h"
#import "DocumentInfoNames.h"
@interface ListPdfViewer ()
{
    NSArray *cell0SubMenuItemsArray;
    
    BOOL isSection0Cell0Expanded;
    int selectedIndex;
    
}

@end

@implementation ListPdfViewer

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Empty cell keep blank
    //
    [self.listTableView setContentOffset:CGPointMake(0.0, self.listTableView.tableHeaderView.frame.size.height) animated:YES];
    //
    
    _listTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //
    
    [self.listTableView registerNib:[UINib nibWithNibName:@"PdfListTableViewCell" bundle:nil] forCellReuseIdentifier:@"PdfListTableViewCell"];
   //
    
    _customView.layer.borderWidth = 1;
    _customView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
//
    cell0SubMenuItemsArray = [[NSMutableArray alloc] initWithObjects:@"S1",@"S2",@"S3",@"S4", nil];;
    _listArray = [[NSMutableArray alloc] initWithObjects:@"Appointment letter1",@"Appointment letter2",@"Appointment letter3",@"Appointment letter4", nil];
    _countArray = [[NSMutableArray alloc]initWithObjects:@"1.",@"2.",@"3.",@"4.", nil];
    //
    //
  
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_listArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PdfListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PdfListTableViewCell" forIndexPath:indexPath];
    cell.documentName.text = [_listArray objectAtIndex:indexPath.row];
    cell.numberCount.text = [_countArray objectAtIndex:indexPath.row];
    cell.signatory.text = [cell0SubMenuItemsArray objectAtIndex:indexPath.row];
    
    if (isSection0Cell0Expanded)
    {
        cell.expandCollapsImageView.image = [UIImage imageNamed:@"Collapse Arrow-25.png"];
        cell.signatory.hidden = NO;
    }
    else
    {
        cell.expandCollapsImageView.image = [UIImage imageNamed:@"Expand Arrow-25.png"];
        cell.signatory.hidden = YES;
    }
    
   
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isSection0Cell0Expanded)
    {
        return 84.0;
    }
    return 44.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (selectedIndex == indexPath.row) {
        isSection0Cell0Expanded = !isSection0Cell0Expanded;
        [_listTableView reloadData];
    }
    
}


-(void)docInfoBtnListClicked:(UIButton*)sender
{
//    UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    DocumentInfoVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"DocumentInfoVC"];
//    objTrackOrderVC.status = @"Pending";
//    [self.navigationController pushViewController:objTrackOrderVC animated:YES];
//
    DocumentInfoNames *objTrackOrderVC= [[DocumentInfoNames alloc] initWithNibName:@"DocumentInfoNames" bundle:nil];
    //objTrackOrderVC.docInfoWorkflowId = [[_filterArray objectAtIndex:sender.tag] valueForKey:@"WorkFlowId"];
    objTrackOrderVC.status = @"Pending";
    [self.navigationController pushViewController:objTrackOrderVC animated:YES];
    
    
}

- (IBAction)cancelBtnPressed:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:nil];
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
