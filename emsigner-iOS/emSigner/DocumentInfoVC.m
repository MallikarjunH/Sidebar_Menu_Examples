//
//  DocumentInfoVC.m
//  emSigner
//
//  Created by Administrator on 1/19/17.
//  Copyright © 2017 Emudhra. All rights reserved.
//

#import "DocumentInfoVC.h"
#import "MBProgressHUD.h"
#import "SubClassView.h"
#import "NSObject+Activity.h"
#import "WebserviceManager.h"
#import "HoursConstants.h"
#import <QuartzCore/QuartzCore.h>
#import "HomeNewDashBoardVC.h"
#import "LMNavigationController.h"
#import "ViewController.h"
//#import "DocInfoTableViewCell.h"
#import "DocumentInfoCollectionCell.h"
#import "NSString+DateAsAppleTime.h"
#import "DocinfoSignatoryCell.h"


@interface DocumentInfoVC ()
{
    UILabel *label;
    UIButton *button;
    NSMutableArray* countArray;
    NSArray *signatoriescount;
    NSString *dateCategoryString;
    
}
@end

@implementation DocumentInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    signatoriescount = [_documentInfoArray valueForKey:@"Signatories"];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.topItem.title = @" ";

    [self.documentTable registerNib:[UINib nibWithNibName:@"DocinfoSignatoryCell" bundle:nil] forCellReuseIdentifier:@"DocinfoSignatoryCell"];
    //    self.tableTitleArray = [NSMutableArray arrayWithObjects:@"",@"Document Category", @"Document Number", @"Uploaded", @"Modified", @"Document Size",@"Number Of Attachments", nil];
    self.tableTitleArray = [NSMutableArray arrayWithObjects:@"Document Category", @"Document Number", @"Uploaded", @"Modified", @"Document Size",@"Number Of Attachments", nil];
    self.documentTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
 /*self.navigationController.navigationBar.topItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                                                         initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];*/
    
    //    self.navigationController.navigationBar.topItem.backBarButtonItem = [[UIBarButtonItem alloc]
    //                                                                         initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    
    
    self.title = _titleString;
    NSInteger c = 0;
    NSArray* signersCount = [_documentInfoArray valueForKey:@"Signatories"];
    countArray = [[NSMutableArray alloc]init];
    countArray = signersCount[0];
    
    
    NSLog(@"%li",(long)c);
    
    //    if ([_status  isEqualToString: @"Recalled"])
    //    {
    //        _signcollectionView.translatesAutoresizingMaskIntoConstraints = YES;
    //        self.authorisedSignatureLabel.frame = CGRectMake(0, 0, 0, 0);
    //        self.authorisedSignatureLabel.hidden = YES;
    //       _signcollectionView.frame = CGRectMake(0, 0, 0, 5);
    //    }
    
    _recalledArray = [[NSMutableArray alloc]init];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return _tableTitleArray.count;
    }
    else
    {
        if (![_status  isEqualToString: @"Recalled"])
        {
            
            return signatoriescount.count;
            
        }
        else{
            return 0;
        }
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0;
    if (indexPath.section == 1 && [_status  isEqualToString: @"Recalled"]) {
        height = 0.0;
    } else {
        height = 45.0;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell * cell;
    
    
    //            if (indexPath.row == 0) {
    //
    //                UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    //                [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    //                self.signcollectionView =[[UICollectionView alloc] initWithFrame:CGRectMake(8, 3, self.documentTable.frame.size.width, 40) collectionViewLayout:layout];
    //                [self.signcollectionView  setDataSource:self];
    //                [self.signcollectionView  setDelegate:self];
    //
    //                self.signcollectionView.collectionViewLayout = layout;
    //                [self.signcollectionView  setBackgroundColor:[UIColor whiteColor]];
    //                [self.signcollectionView  registerClass:[DocumentInfoCollectionCell class] forCellWithReuseIdentifier:@"DocumentInfoCollectionCell"];
    //
    //                if ([_status  isEqualToString: @"Recalled"])
    //                {
    //                    _signcollectionView.translatesAutoresizingMaskIntoConstraints = YES;
    //                    self.authorisedSignatureLabel.frame = CGRectMake(0, 0, 0, 0);
    //                    self.authorisedSignatureLabel.hidden = YES;
    //                    _signcollectionView.frame = CGRectMake(0, 0, 0, 5);
    //                }
    //
    //                else [cell addSubview:self.signcollectionView];
    //                [self.signcollectionView reloadData];
    //            }
    if (indexPath.section == 0) {
        static NSString *CellIdentifier = @"cell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.textLabel.text = [_tableTitleArray objectAtIndex:indexPath.row];
        
        if (indexPath.row == 0)
        {
            [cell.detailTextLabel setText:[_documentInfoArray  valueForKey:@"WorkflowName"]];
        }
        
        if (indexPath.row == 1) {
            [cell.detailTextLabel setText: [NSString stringWithFormat:@"%@%@",@"  ",[_documentInfoArray valueForKey:@"DocumentNumber"]]];
        }
        if (indexPath.row == 2) {
            
            NSString *dateFromArray =[_documentInfoArray  valueForKey:@"UploadDateTime"];
            
            if (![dateFromArray isEqualToString:@"N/A"])
            {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"d/M/yyyy HH:mm:ss"];
                NSDate *dates = [formatter dateFromString:dateFromArray];
                dateCategoryString = [NSString string];
                
                NSArray* date= [[_documentInfoArray valueForKey:@"UploadDateTime"] componentsSeparatedByString:@" "];
                NSString *transformedDate = [dateCategoryString transformedValue:dates];
                
                if ([transformedDate isEqualToString:@"Today"]) {
                    cell.detailTextLabel.text = [date objectAtIndex:1];
                    
                }
                else{
                    cell.detailTextLabel.text = [dateCategoryString transformedValue:dates];
                }
                
                
                //cell.detailTextLabel.text = [dateCategoryString transformedValue:dates];
            }
            else cell.detailTextLabel.text = dateFromArray;
            
        }
        if (indexPath.row == 3) {
            
            NSString *dateFromArray = [_documentInfoArray  valueForKey:@"Modifieddate"];
            if (![dateFromArray isEqualToString:@"N/A"])
            {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
                NSDate *dates = [formatter dateFromString:dateFromArray];
                //NSString *stringFromCategory = [[NSString alloc]init];
                NSArray* date= [[_documentInfoArray valueForKey:@"Modifieddate"] componentsSeparatedByString:@" "];
                NSString *transformedDate = [dateCategoryString transformedValue:dates];
                
                //  cell.detailTextLabel.text = [stringFromCategory transformedValue:dates];
                
                
                if ([transformedDate isEqualToString:@"Today"]) {
                    cell.detailTextLabel.text = [date objectAtIndex:1];
                    
                }
                else{
                    cell.detailTextLabel.text = [dateCategoryString transformedValue:dates];
                }
                
            }
            else cell.detailTextLabel.text = dateFromArray;
            
        }
        if (indexPath.row == 4)
        {
            NSString *kb = [_documentInfoArray valueForKey:@"DocumentSize"] ;
            cell.detailTextLabel.text = [kb stringByAppendingString:@" Kb "];
        }
        
        if (indexPath.row == 5)
        {
            [cell.detailTextLabel setText: [NSString stringWithFormat:@"%@%@",@"  ",[_documentInfoArray  valueForKey:@"NoOfAttachment"]]];
        }
        
    }
    else
    {
        
        static NSString *CellIdentifier1 = @"DocinfoSignatoryCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier1];
        }
        DocinfoSignatoryCell* cell2 = (DocinfoSignatoryCell *)cell;
        
        
        NSArray *signatoriescount = [_documentInfoArray valueForKey:@"Signatories"];
        
        for (int i=0; i<signatoriescount.count; i++) {
            
            NSLog(@"%@",[[signatoriescount objectAtIndex:indexPath.item]valueForKey:@"StatusID"]);
            if ([[[signatoriescount objectAtIndex:indexPath.item]valueForKey:@"StatusID"]intValue]==13)
            {
                //rgb(254,100,46)
                cell2.Signertype.backgroundColor = ([UIColor colorWithRed:102.0/255.0 green:153.0/255.0 blue:0.0/255.0 alpha:1.0]);
                
            }
            else if ([[[signatoriescount objectAtIndex:indexPath.item]valueForKey:@"StatusID"]intValue]==7)
            {
                //rgb(102,153,0)
                cell2.Signertype.backgroundColor = ([UIColor colorWithRed:243.0/255.0 green:111.0/255.0 blue:33.0/255.0 alpha:1.0]);
            }
            else if ([[[signatoriescount objectAtIndex:indexPath.item]valueForKey:@"StatusID"]intValue]==53)
            {
                cell2.Signertype.backgroundColor = ([UIColor colorWithRed:243.0/255.0 green:111.0/255.0 blue:33.0/255.0 alpha:1.0]);
            }
            
            else
            {
                cell2.Signertype.backgroundColor = ([UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0]);
            }
            //cell2.name.text =
        }
        cell2.Signertype.text = [@"S" stringByAppendingFormat:@"%ld ",(long)indexPath.row+1];
        cell2.name.text = [[signatoriescount objectAtIndex:indexPath.row] valueForKey:@"Name"];
        cell2.email.text = [[signatoriescount objectAtIndex:indexPath.row] valueForKey:@"EmailID"];
    }
    return cell;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (![_status  isEqualToString: @"Recalled"]) {
        if (section == 1) {
            return @"Authorised Signatories";
        }
        else
        {
            return @"Document Details";
        }
    }
    else
    {
        if (section == 1) {
            return @"";
        }
        else
        {
            return @"Document Details";
        }
    }
    
}
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
//{
//    return signatoriescount.count;
//}
//
//- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    DocumentInfoCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DocumentInfoCollectionCell" forIndexPath:indexPath];
//    UILabel * lbl = [[UILabel alloc]initWithFrame:CGRectMake(8, 8, 30, 20)];
//    lbl.text = [@"S" stringByAppendingFormat:@"%ld ",(long)indexPath.row+1];
//    [cell addSubview:lbl];
//
//    [self.signcollectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
//
//    //NSArray *signatoriescount = [[_documentInfoArray objectAtIndex:indexPath.row]valueForKey:@"Signatories"];
//   // NSArray *signatoriescount = [_documentInfoArray valueForKey:@"Signatories"];
//    //for (int i=0; i<signatoriescount.count; i++) {
//
//
//        NSLog(@"%@",[[signatoriescount objectAtIndex:indexPath.item]valueForKey:@"StatusID"]);
//        if ([[[signatoriescount objectAtIndex:indexPath.item]valueForKey:@"StatusID"]intValue]==13)
//        {
//            //rgb(254,100,46)
//            cell.backgroundColor = ([UIColor colorWithRed:102.0/255.0 green:153.0/255.0 blue:0.0/255.0 alpha:1.0]);
//
//        }
//        else if ([[[signatoriescount objectAtIndex:indexPath.item]valueForKey:@"StatusID"]intValue]==7)
//        {
//            //rgb(102,153,0)
//            cell.backgroundColor = ([UIColor colorWithRed:243.0/255.0 green:111.0/255.0 blue:33.0/255.0 alpha:1.0]);
//        }
//        else if ([[[signatoriescount objectAtIndex:indexPath.item]valueForKey:@"StatusID"]intValue]==53)
//        {
//            cell.backgroundColor = ([UIColor colorWithRed:243.0/255.0 green:111.0/255.0 blue:33.0/255.0 alpha:1.0]);
//        }
//
//        else
//        {
//            cell.backgroundColor = ([UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0]);
//        }
//  //  }
//
//
//
//    return cell;
//}
//
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//
//    NSArray *signatoriescount = [_documentInfoArray valueForKey:@"Signatories"];
//
//
//    NSString *signatory = [@"Name : " stringByAppendingFormat:@"%@", [[signatoriescount objectAtIndex:indexPath.row] valueForKey:@"Name"]];
//    NSString *Email_Id =  [@"Email Id : " stringByAppendingFormat:@"%@", [[signatoriescount objectAtIndex:indexPath.row]valueForKey:@"EmailID"]];
//
//
//    NSString *signatoryInfo = [@"Signatory "stringByAppendingFormat:@"S%ld",indexPath.row+1];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:signatoryInfo
//                                                    message:[NSString stringWithFormat: @"%@ \n %@ ",signatory,Email_Id]
//                                                   delegate:nil
//                                          cancelButtonTitle:@"OK"
//                                          otherButtonTitles:nil,
//                          nil];
//    [alert show];
//
//}
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
//    return YES;
//}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)cancelBtnClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:Nil];
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
