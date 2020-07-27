//
//  SignatoriesListForFlexiforms.m
//  emSigner
//
//  Created by Emudhra on 27/02/20.
//  Copyright © 2020 Emudhra. All rights reserved.
//

#import "SignatoriesListForFlexiforms.h"
#import "WebserviceManager.h"
#import "MPBSignatureViewController.h"
#import "HoursConstants.h"
#import "MBProgressHUD.h"
#import "NSObject+Activity.h"
#import "SignerListCell.h"


static int const kHeaderSectionTag = 6900;

@interface SignatoriesListForFlexiforms ()

@end

@implementation SignatoriesListForFlexiforms

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.signatoriesList.delegate = self;
    self.signatoriesList.dataSource = self;
    
    self.expandedSectionHeaderNumber = -1;
    self.SectionNumber = 0;
    
    self.subscriberIdArray = [[NSMutableArray alloc]init];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0 green:96.0/255.0 blue:192.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem* customBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismissViewController)];
      
      self.navigationItem.leftBarButtonItem = customBarButtonItem;
      
      UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(savebtnAction:)];
    
    self.navigationItem.rightBarButtonItem = saveButton;

    self.signatoriesList.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
     
       [self.signatoriesList registerNib:[UINib nibWithNibName:@"SignerListCell" bundle:nil] forCellReuseIdentifier:@"SignerListCell"];
       // self.signersList.rowHeight = UITableViewAutomaticDimension;
       self.signatoriesList.estimatedRowHeight = 100;
       [self getSignersListToDisplay];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSMutableDictionary *empty = [[NSMutableDictionary alloc]init];
    for (int i = 0; i< self.signersCount; i++) {
        [_subscriberIdArray addObject:empty];
       // [ sectionArray addObject:[@"Signatory " stringByAppendingFormat:@"%d ",i+1]];
    }
}

-(void)dismissViewController{
    
    [self dismissViewControllerAnimated:true completion:nil];
}

-(void) getSignersListToDisplay
{
    
        [WebserviceManager sendSyncRequestWithURLGet:kGetAllSigners method:SAServiceReqestHTTPMethodGET body:kGetAllSigners completionBlock:^(BOOL status, id responseValue) {
            //if(status)
            if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])
            {
                        dispatch_async(dispatch_get_main_queue(),
                                       ^{
                                           NSMutableArray * responseArray = [[NSMutableArray alloc]init];
                                          _ShowSignersList = [[NSMutableArray alloc]init];
                                           _holdSignersList = [[NSMutableArray alloc]init];
                                           responseArray = [responseValue valueForKey:@"Response"];
                                           for (int i = 0; i<responseArray.count; i++) {
                                               if ([[responseArray[i]valueForKey:@"Name"]isEqualToString:@"ME"]) {
                                                   
                                                   [self.holdSignersList insertObject:responseArray[i] atIndex:0];
                                               }
                                               else{
                                                   [self.holdSignersList addObject:responseArray[i]];
                                               }
                                                   
                                           }
                                            _ShowSignersList = [self.holdSignersList mutableCopy];
                                            [self.signatoriesList reloadData];
                                           //NSLog(@"%@"_holdSignersListt);
            
                                       });
                    }
            else{
    
                UIAlertController * alert = [UIAlertController
                                             alertControllerWithTitle:nil
                                             message:[[responseValue valueForKey:@"Messages"]objectAtIndex:0]
                                             preferredStyle:UIAlertControllerStyleAlert];
    
                //Add Buttons
    
                UIAlertAction* yesButton = [UIAlertAction
                                            actionWithTitle:@"Ok"
                                            style:UIAlertActionStyleDefault
                                            handler:nil];
    
                [alert addAction:yesButton];
    
                [self presentViewController:alert animated:YES completion:nil];
    
                return;
            }
    
    
        }];
    
    
    
}




#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //if(_searchResults == nil || _searchResults.count == 0){
    if (self.expandedSectionHeaderNumber == section) {
     
        return self.ShowSignersList.count;
    } else {
        return 0;
        
    }
//    }else{
//        return _searchResults.count;
//    }
  }
  

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SignerListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SignerListCell" forIndexPath:indexPath];
    NSArray *section;
   // if(_searchResults == nil || _searchResults.count == 0){

    section = [self.ShowSignersList objectAtIndex:indexPath.row];
//    }else{
//        section = [self.searchResults objectAtIndex:indexPath.row];
//
//    }
    
    cell.textLabel.text = [section valueForKey:@"Name"];
    if ([section valueForKey:@"EmailId"] == (id)[NSNull null]) cell.detailTextLabel.text = @"Server Error";
    else{
        cell.detailTextLabel.text = [section valueForKey:@"EmailId"];
    }
    if ([[section valueForKey:@"UserType"]integerValue] == 4) {
         cell.imageView.image = [UIImage imageNamed:@"adhocUser"];
    }else if ([[section valueForKey:@"UserType"]integerValue] == 9)
    {
         cell.imageView.image = [UIImage imageNamed:@"internalUser"];
    }else{
        cell.imageView.image = [UIImage imageNamed:@""];
    }
   
//    cell.textLabel.text = [@"Signatory " stringByAppendingFormat:@"%ld ",(long)indexPath.row+1];

       return cell;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (self.signersCount > 0) {
        self.signatoriesList.backgroundView = nil;
        return self.signersCount;
    } else {
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = @"Retrieving data.\nPlease wait.";
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:20];
        [messageLabel sizeToFit];
        self.signatoriesList.backgroundView = messageLabel;
        
        return 0;
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (self.signersCount) {
        
        return [_sectionArray objectAtIndex:section];
        
    }else return @"";
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section; {
    return 44.0;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    // recast your view as a UITableViewHeaderFooterView
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.contentView.backgroundColor = [UIColor lightGrayColor];
    header.textLabel.textColor = [UIColor whiteColor];
 
    header.textLabel.preferredMaxLayoutWidth =  header.textLabel.frame.size.width + 30;
    header.textLabel.numberOfLines = 0;
//    header.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    UIImageView *viewWithTag = [self.view viewWithTag:kHeaderSectionTag + section];
    if (viewWithTag) {
        [viewWithTag removeFromSuperview];
    }
    
    // add the arrow image
    
    if (_signersCount >0)
    {
        CGSize headerFrame = self.view.frame.size;
        UIImageView *theImageView = [[UIImageView alloc] initWithFrame:CGRectMake(headerFrame.width - 32, 13, 18, 18)];
        theImageView.image = [UIImage imageNamed:@"Expand Arrow-25"];
        theImageView.tag = kHeaderSectionTag + section;
        [header addSubview:theImageView];
        
        // make headers touchable
        header.tag = section;
        UITapGestureRecognizer *headerTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionHeaderWasTouched:)];
        [header addGestureRecognizer:headerTapGesture];
        
    }
}


- (void)sectionHeaderWasTouched:(UITapGestureRecognizer *)sender {
    UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)sender.view;
    NSInteger section = headerView.tag;
    UIImageView *eImageView = (UIImageView *)[headerView viewWithTag:kHeaderSectionTag + section];
    self.expandedSectionHeader = headerView;
    
    if (self.expandedSectionHeaderNumber == -1) {
        self.expandedSectionHeaderNumber = section;
        [self tableViewExpandSection:section withImage: eImageView];
       
    } else {
        if (self.expandedSectionHeaderNumber == section) {
            [self tableViewCollapeSection:section withImage: eImageView];
            self.expandedSectionHeader = nil;
        } else {
            UIImageView *cImageView  = (UIImageView *)[self.view viewWithTag:kHeaderSectionTag + self.expandedSectionHeaderNumber];
            [self tableViewCollapeSection:self.expandedSectionHeaderNumber withImage: cImageView];
            [self tableViewExpandSection:section withImage: eImageView];
        }
    }
}

- (void)tableViewCollapeSection:(NSInteger)section withImage:(UIImageView *)imageView {
    
    if (self.ShowSignersList.count != 0) {
    NSArray *sectionData = [self.ShowSignersList objectAtIndex:section];
    
    self.expandedSectionHeaderNumber = -1;
    if (self.ShowSignersList.count == 0) {
        return;
    } else {
        [UIView animateWithDuration:0.4 animations:^{
            imageView.transform = CGAffineTransformMakeRotation((0.0 * M_PI) / 180.0);
        }];
        NSMutableArray *arrayOfIndexPaths = [NSMutableArray array];
        for (int i=0; i< self.ShowSignersList.count; i++) {
            NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:section];
            [arrayOfIndexPaths addObject:index];
        }
        
        [self.signatoriesList beginUpdates];
        [self.signatoriesList deleteRowsAtIndexPaths:arrayOfIndexPaths withRowAnimation: UITableViewRowAnimationFade];
        [self.signatoriesList endUpdates];
    }
    }
    else{}
}

- (void)tableViewExpandSection:(NSInteger)section withImage:(UIImageView *)imageView {
   // NSArray *sectionData = [self.holdSignersList objectAtIndex:section];
    if (self.ShowSignersList.count == 0) {
        self.expandedSectionHeaderNumber = -1;
        return;
    } else {
        [UIView animateWithDuration:0.4 animations:^{
            imageView.transform = CGAffineTransformMakeRotation((180.0 * M_PI) / 180.0);
        }];
        NSMutableArray *arrayOfIndexPaths = [NSMutableArray array];
        for (int i=0; i< self.ShowSignersList.count; i++) {
            NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:section];
            [arrayOfIndexPaths addObject:index];
        }
        self.expandedSectionHeaderNumber = section;
        [self.signatoriesList beginUpdates];
        [self.signatoriesList insertRowsAtIndexPaths:arrayOfIndexPaths withRowAnimation: UITableViewRowAnimationFade];
        [self.signatoriesList endUpdates];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
  //  [_subscriberIdarray replaceObjectAtIndex:indexPath.section withObject:Subscriberdictionary];
    NSInteger secti = self.expandedSectionHeaderNumber;
    
    UIImageView *cImageView  = (UIImageView *)[self.view viewWithTag:kHeaderSectionTag + self.expandedSectionHeaderNumber];
    [self tableViewCollapeSection:self.expandedSectionHeaderNumber withImage: cImageView];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:[[self.ShowSignersList objectAtIndex:indexPath.row]valueForKey:@"SubscriberId"] forKey:@"SubscriberId"];
    [dict setObject:[[self.ShowSignersList objectAtIndex:indexPath.row]valueForKey:@"Name"] forKey:@"Name"];


    if (![_sectionArray containsObject:[[self.ShowSignersList objectAtIndex:indexPath.row]valueForKey:@"Name"]]) {
        
        [tableView headerViewForSection:secti].textLabel.text = [[self.ShowSignersList objectAtIndex:indexPath.row]valueForKey:@"Name"];
        [_sectionArray replaceObjectAtIndex:secti withObject:[[self.ShowSignersList objectAtIndex:indexPath.row]valueForKey:@"Name"]];
        [_subscriberIdArray replaceObjectAtIndex:indexPath.section withObject:dict];

    }
    else{
        [self callForAlertMultiplePickingSignatories];
        return;
        // [tableView headerViewForSection:secti].textLabel.text = sectionArray[indexPath.section];
        // [sectionArray replaceObjectAtIndex:secti withObject:sectionArray[indexPath.section]];
    }
   
    
}

-(void)callForAlertMultiplePickingSignatories
{
    UIAlertView *passwordAlertView = [[UIAlertView alloc]initWithTitle: @""
                                                                                                         message: @"You can't select multiple times"
                                                                                                        delegate: nil
                                                                                               cancelButtonTitle: nil
                                                                                               otherButtonTitles: @"OK", nil];
                                              passwordAlertView.alertViewStyle = UIAlertViewStyleDefault;
                                              [passwordAlertView show];
                                              // isPickedME = NO;
                                              return;
}

-(void)savebtnAction:(UIButton *) sender{
    [self.navigationController dismissViewControllerAnimated:YES completion:^ {
        [_delegate sendDataTosigners:self.subscriberIdArray];
      
    }];
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
