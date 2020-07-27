//
//  RenameDocument.m
//  emSigner
//
//  Created by EMUDHRA on 12/12/18.
//  Copyright © 2018 Emudhra. All rights reserved.
//

#import "RenameDocument.h"
#import "DocsNameForHeader.h"
#import "DocsSize.h"

@interface RenameDocument ()
{
    NSMutableArray *docsArray;
    long selectedIndex;
}

@end

@implementation RenameDocument

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _tableView.delegate = self;
    _tableView.dataSource  =self;
    [self.tableView registerNib:[UINib nibWithNibName:@"DocsSize" bundle:nil] forCellReuseIdentifier:@"DocsSize"];
    [self.tableView registerNib:[UINib nibWithNibName:@"DocsNameForHeader" bundle:nil] forCellReuseIdentifier:@"DocsNameForHeader"];
    
    docsArray = [NSMutableArray arrayWithObjects:@"A4 (21 * 29.7 cm)",@"A4 Landscape", nil];
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
// called when 'return' key pressed. return NO to ignore.
{
     [self.tableView endEditing:YES];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    DocsNameForHeader *cell = (DocsNameForHeader*) [[textField superview] superview];
    cell.docsText.text = textField.text;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"renameDocument" object:textField.text];

    

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 1;
    }
    else
    {
        return 2;
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   // UITableViewCell *cell ;
    
    if (indexPath.section == 0) {
        DocsNameForHeader * cell = [tableView dequeueReusableCellWithIdentifier:@"DocsNameForHeader"];
        //[cell.docsText becomeFirstResponder];
       // [cell.docsText resignFirstResponder];
        cell.docsText.delegate = self;
         return cell;
        
    }
    else
    {
        DocsSize *cell =[tableView dequeueReusableCellWithIdentifier:@"DocsSize"];
        cell.textLabel.text = docsArray[indexPath.row];
         return cell;
        
    }
    
   
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"";
    }
    else return @"Please select your document size.";
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


//- (void)textFieldDidEndEditing:(UITextField *)textField
//{
//   
//        textfield1.text = [NSString stringWithFormat:@"%@ miles",textField.text];
//    
//}

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
