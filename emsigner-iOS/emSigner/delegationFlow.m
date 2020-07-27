//
//  delegationFlow.m
//  emSigner
//
//  Created by EMUDHRA on 09/04/19.
//  Copyright © 2019 Emudhra. All rights reserved.
//

#import "delegationFlow.h"

@interface delegationFlow ()
@property (weak, nonatomic) IBOutlet UITableView *tableview;

@end

@implementation delegationFlow

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableview.layer.cornerRadius = 10;
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
     [self.tableview registerNib:[UINib nibWithNibName:@"delegationtableviewcell" bundle:nil] forCellReuseIdentifier:@"delegationtableviewcell"];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    // Do any additional setup after loading the view from its nib.
}
-(void)dismissKeyboard
{
    [self dismissViewControllerAnimated:true completion:nil];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    else if (section == 1){
        return 2;
    }
    else if (section == 2){
        return 1;
    }
    return 0;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"Originatory";
    }
    else if (section == 1){
        return @"Signatory";
    }
    else if (section == 2){
        return @"Completed";
    }
    return @"";
    
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"delegationtableviewcell" forIndexPath:indexPath];
    if (indexPath.section == 1) {
        cell.textLabel.text = @"Pavan";
        cell.detailTextLabel.text = @"pavan@gmail.com";
        
    }
    else if (indexPath.section == 2)
    {
        cell.textLabel.text = @"Not yet";
        cell.detailTextLabel.text = @"";
        
    }
    if (indexPath.section == 0) {
        cell.textLabel.text = @"santhosh";
        cell.detailTextLabel.text = @"etest3226@gmail.com";
    }
    return cell;
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
