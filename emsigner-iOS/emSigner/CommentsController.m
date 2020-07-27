//
//  CommentsController.m
//  emSigner
//
//  Created by EMUDHRA on 14/08/19.
//  Copyright © 2019 Emudhra. All rights reserved.
//

#import "CommentsController.h"
#import "DropDownCell.h"
#import "HoursConstants.h"
#import "NSObject+Activity.h"
#import "MBProgressHUD.h"
#import "WebserviceManager.h"


@interface CommentsController ()
{
    NSMutableArray * commentsCountArray ;
    NSArray * countArr;
    NSString * commentId;
}
@end

@implementation CommentsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    /*self.navigationController.navigationBar.topItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                                                         initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];*/
    // self.navigationController.navigationBar.topItem.title = @"Document Details";
    
    self.title = @"Comments";;
    self.navigationController.navigationBar.topItem.title = @" ";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    UITapGestureRecognizer *tapToCall = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToCall:)];
    [self.commetsView addGestureRecognizer:tapToCall];
    commentsCountArray = [[NSMutableArray alloc]init];
    
    [self getCommentsByWorkflowID];
    self.commentsTableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    self.commentsTextField.delegate = self;

    
    _docTableView.delegate = self;
    _docTableView.dataSource = self;
    self.docTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    _bgView.hidden = true;
    _docTableView.hidden = true;
    
    //GetUserComments?workflowId=
    [self.post_Btn setTitle:@"POST" forState:UIControlStateNormal];

}


-(void)viewWillAppear:(BOOL)animated {
    
    
    
}

//Adarsha Not working
-(void) getDocumentsById{
    _documentNamesArray = [[NSMutableArray alloc]init];
    [self startActivity:@"Refreshing"];
    NSString *requestURL = [NSString stringWithFormat:@"%@DownloadWorkflowDocuments?WorkflowID=%@",kMultipleDoc,self.workflowID];
    
    [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
         
        //  if(status)
        if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])
            
        {
            
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               _documentNamesArray=[responseValue valueForKey:@"Response"];
                                [_docTableView reloadData];
                               [self stopActivity];
                               
                           });
            
        }
        else{
            
        }
        
    }];
    [self stopActivity];
}

-(void)getCommentsByWorkflowID{
    _getDcommentsArray = [[NSMutableArray alloc]init];
    [self startActivity:@"Refreshing"];
   
    NSString *requestURL = [NSString stringWithFormat:@"%@GetWorkflowComments?workflowId=%@",kMultipleDoc,self.workflowID];
    
    [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
        
        //  if(status)
        if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])
            
        {
            
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               _getDcommentsArray=[responseValue valueForKey:@"Response"];
                               if (![[[responseValue valueForKey:@"Response"]valueForKey:@"DocumentId"] isKindOfClass:[NSNull class]]) {
                                   [self.commentsTableview reloadData];
                               } else {
                                   
                                   [self.commentsTableview reloadData];
                               }
                               [self stopActivity];
                               
                           });
            
        }
        else{
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                 [self.commentsTableview reloadData];
            }
                           );
              
        }
        
    }];
    [self stopActivity];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.commentsTextField resignFirstResponder];
    return true;
}

- (void)tapToCall:(UITapGestureRecognizer *)sender
{    
   /* UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Select Document" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (int j= 0; j<_documentNamesArray.count; j++) {
        NSString *str = [_documentNamesArray[j]valueForKey:@"DocumentName"];
        [actionSheet addAction:[UIAlertAction actionWithTitle:str style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            self.commentLabel.text = [self.documentNamesArray[j]valueForKey:@"DocumentName"];
            self.documentID = [self.documentNamesArray[j]valueForKey:@"DocumentId"];
            //[self dismissViewControllerAnimated:YES completion:^{
                
            //}];

        }]];

    }
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
       // [self dismissViewControllerAnimated:YES completion:^{
       // }];
    }]];

    
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];*/
    _bgView.hidden = false;
    _docTableView.hidden  = false;
    //_commentsTableview.hidden = true;
    [self getDocumentsById];
}

- (IBAction)PostBtn_Action:(UIButton*)sender {
    // [self.commentsTableview reloadData];
    
    
    if ([self.commentLabel.text  isEqual: @"Select Document"]) {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:nil
                                     message:@"Select the document!"
                                     preferredStyle:UIAlertControllerStyleAlert];
        //Add Buttons
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Ok"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        //Handle your yes please button action here
                                    }];
        [alert addAction:yesButton];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    if (self.commentsTextField.text.length > 0) {
        NSString *isValid = self.commentsTextField.text;
        
        BOOL valid = [self validateSpecialCharactor:isValid];
        
        if (valid) {
            
            if ([self.post_Btn.titleLabel.text  isEqual: @"POST"]) {
                [self PostCall];
                
            }
            else{
                [self EditCall:commentId];
            }
        }
        else{
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            // Configure for text only and offset down
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"Special Characters are not allowed.";//[NSString stringWithFormat:@"Page %@ of %lu", self.view.currentPage.label, (unsigned long)self.pdfDocument.pageCount];
            hud.margin = 10.f;
            hud.yOffset = 170;
            hud.removeFromSuperViewOnHide = YES;
            
            [hud hide:YES afterDelay:2];
            
        }
    }
    else{
        [[[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please enter comments." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
  
    
}

- (BOOL) validateSpecialCharactor: (NSString *) text {
    
    NSString *specialCharacterString = @"!~`@#$%^&*-+();:={}[],<>?\\/\"\'";
    NSCharacterSet *specialCharacterSet = [NSCharacterSet
                                           characterSetWithCharactersInString:specialCharacterString];
    
    if ([text.lowercaseString rangeOfCharacterFromSet:specialCharacterSet].length) {
        NSLog(@"contains special characters");
        return  false;
    }
    else{
        return true;
    }
    
    
//    NSString *Regex = @"[A-Za-z0-9^]*";
//    NSPredicate *TestResult = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", Regex];
//    return [TestResult evaluateWithObject:text];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == _commentsTableview) {
           
        DropDownCell *cell =[tableView dequeueReusableCellWithIdentifier:@"DropDownCell"];
            countArr = [[_getDcommentsArray objectAtIndex:indexPath.section]valueForKey:@"Comments"];
            cell.user_name.text = [countArr[indexPath.row] valueForKey:@"UserName"];
            cell.comment_label.text = [countArr[indexPath.row] valueForKey:@"Comment"];
            cell.date_label.text = [countArr[indexPath.row] valueForKey:@"CommentTime"];
            NSLog(@"%@",[countArr[indexPath.row] valueForKey:@"Comment"]);
            return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DocCell" forIndexPath:indexPath];
        cell.textLabel.text = [_documentNamesArray[indexPath.row] valueForKey:@"DocumentName"];
        return cell;
    }

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  NSArray* commentsArr = [[_getDcommentsArray objectAtIndex:section]valueForKey:@"Comments"];
    if (tableView == self.commentsTableview){
        return commentsArr.count;}
    else  {return
        _documentNamesArray.count;}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 110;
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    if (tableView ==_commentsTableview) {
        return  _getDcommentsArray.count;
    } else {
        return  0;
    }
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _docTableView) {
        self.commentLabel.text = [self.documentNamesArray[indexPath.row]valueForKey:@"DocumentName"];
        self.documentID = [self.documentNamesArray[indexPath.row]valueForKey:@"DocumentId"];
    } else {
        
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 5, tableView.frame.size.width, 18)];
    [label setFont:[UIFont boldSystemFontOfSize:12]];
    UIImageView *DocImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 20, 20)];
    [DocImage setImage:[UIImage imageNamed:@"documentpotline.png"]];
    NSString *string = [[_getDcommentsArray objectAtIndex:section]valueForKey:@"DocumentName"];
    NSArray *commentsCount = [[_getDcommentsArray objectAtIndex:section]valueForKey:@"Comments"];
    if (commentsCount.count == 0) {
        _commentsTableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        return _commentsTableview.tableFooterView;
    }
    /* Section header is in 0th index... */
    if ([string isKindOfClass:[NSNull class]]) {
        [label setText: @""];

    }
    else {
        [label setText:string];
    }
    //[label setText:string ? string : @""];
    [view addSubview:DocImage];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor colorWithRed:166/255.0 green:177/255.0 blue:186/255.0 alpha:1.0]];
    //your background color...
    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    
    //Checking for SubscriberId for edit & delete
    NSString*  SubscriberId = [[NSUserDefaults standardUserDefaults]valueForKey:@"SubscriberId"];
    BOOL isReviewer = [[[_getDcommentsArray[indexPath.section]valueForKey:@"Comments"][indexPath.row]valueForKey:@"IsReviewerComment"]boolValue];
  //  ![value boolValue]
    if ([SubscriberId isEqualToString:[[_getDcommentsArray[indexPath.section]valueForKey:@"Comments"][indexPath.row]valueForKey:@"SubscriberId"]] && !isReviewer) {
        return YES;
        
    }
    else
        return false;
}


-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Edit" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        //insert your editAction here
        
     self.commentsTextField.text = [[_getDcommentsArray[indexPath.section]valueForKey:@"Comments"][indexPath.row]valueForKey:@"Comment"];
     commentId = [[_getDcommentsArray[indexPath.section]valueForKey:@"Comments"][indexPath.row]valueForKey:@"CommentId"];
     dispatch_async(dispatch_get_main_queue(),
        ^{
            [self.commentsTextField becomeFirstResponder];
         });
     self.commentLabel.text = [_getDcommentsArray[indexPath.section]valueForKey:@"DocumentName"];
     [self.post_Btn setTitle:@"UPDATE" forState:UIControlStateNormal];


        
    }];
    
    editAction.backgroundColor = [UIColor darkGrayColor];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        //insert your deleteAction here
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:nil
                                     message:@"Are you sure you want delete the comment?"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        //Add Buttons
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Ok"
                                    style:UIAlertActionStyleDestructive
                                    handler:^(UIAlertAction * action) {
                                        //Handle your yes please button action here
                                        [self DeleteCall:[[_getDcommentsArray[indexPath.section]valueForKey:@"Comments"][indexPath.row]valueForKey:@"CommentId"] WorkflowId:[[_getDcommentsArray[indexPath.section]valueForKey:@"Comments"][indexPath.row]valueForKey:@"WorkflowId"]];
                                    }];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     // [self.view dis]
                                 }];
        
        [alert addAction:yesButton];
        [alert addAction:cancel];
        //[self stopActivity];
        [self presentViewController:alert animated:YES completion:nil];
        
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    return @[deleteAction,editAction];
}

-(void)DeleteCall:(NSString*)commentId WorkflowId:(NSString *)workflowId
{
    //DeleteComment?id=commentid
 //Adarsha H
    //EMIOS117
    NSMutableDictionary * senddict = [[NSMutableDictionary alloc]init];
          
           
           //[senddict setValue:CategoryId forKey:@"CategoryID"];
           [senddict setValue:commentId forKey:@"CommentID"];
           [senddict setValue:@"" forKey:@"WorkflowID"];
           [senddict setValue:@"" forKey:@"RefrenceNo"];
    [self startActivity:@"Refreshing"];
   NSString *requestURL = [NSString stringWithFormat:@"%@DeleteComment",kMultipleDoc];
    
    [WebserviceManager sendSyncRequestWithURLDocument:requestURL method:SAServiceReqestHTTPMethodPOST body:senddict completionBlock:^(BOOL status, id responseValue) {
        
        //  if(status)
        if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])
            
        {
            
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               [self stopActivity];
                               if ([[responseValue valueForKey:@"IsSuccess"]integerValue] == 1) {
                                   UIAlertController * alert = [UIAlertController
                                                                alertControllerWithTitle:nil
                                                                message:@"Comments deleted successfully."
                                                                preferredStyle:UIAlertControllerStyleAlert];
                                   
                                   //Add Buttons
                                   
                                   UIAlertAction* yesButton = [UIAlertAction
                                                               actionWithTitle:@"Ok"
                                                               style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action) {
                                                                   [self getCommentsByWorkflowID];
                                                                   [self.post_Btn setTitle:@"POST" forState:UIControlStateNormal];

                                                               }];
                                   
                                   
                                   [alert addAction:yesButton];
                                   
                                   [self presentViewController:alert animated:YES completion:nil];

                               }
                               
                           });
            
        }
        else{
            
        }
        
    }];
    [self stopActivity];
    

}

-(void)EditCall:(NSString *)commentID
{
    
        [self startActivity:@""];
        
        // Login
        NSString *post = [NSString stringWithFormat:@"CommentId=%@&Comment=%@",commentID,self.commentsTextField.text];
        
        
        [WebserviceManager sendSyncRequestWithURL:kUpdateComment method:SAServiceReqestHTTPMethodPOST body:post completionBlock:^(BOOL status, id responseValue){
            
            if (status) {
                NSNumber * isSuccessNumber = (NSNumber *)[responseValue valueForKey:@"IsSuccess"];
                if([isSuccessNumber boolValue] == YES)
                {
                    dispatch_async(dispatch_get_main_queue(),
                    ^{
                        [[[UIAlertView alloc] initWithTitle:@"" message:@"User Comments Edited Successfully!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                        self.commentsTextField.text = @"";
                        [self.post_Btn setTitle:@"POST" forState:UIControlStateNormal];

                        [self getCommentsByWorkflowID];
                    });
                }
            }
        }];

}

-(void)PostCall
{
    
    [self startActivity:@""];
    
    // Login
    NSString *post = [NSString stringWithFormat:@"DocumentId=%@&Comment=%@",_documentID,self.commentsTextField.text];
    [WebserviceManager sendSyncRequestWithURL:kSaveComment method:SAServiceReqestHTTPMethodPOST body:post completionBlock:^(BOOL status, id responseValue){
        
        if (status) {
            NSNumber * isSuccessNumber = (NSNumber *)[responseValue valueForKey:@"IsSuccess"];
            if([isSuccessNumber boolValue] == YES)
            {
                dispatch_async(dispatch_get_main_queue(),
                ^{
                [[[UIAlertView alloc] initWithTitle:@"" message:@"User Comments Saved Successfully!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                self.commentsTextField.text = @"";
                [self.post_Btn setTitle:@"POST" forState:UIControlStateNormal];

                [self getCommentsByWorkflowID];
                });
            }
        }
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
