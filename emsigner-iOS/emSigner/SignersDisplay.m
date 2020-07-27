//
//  SignersDisplay.m
//  emSigner
//
//  Created by EMUDHRA on 29/10/18.
//  Copyright © 2018 Emudhra. All rights reserved.
//

#import "SignersDisplay.h"
#import "SignerListCell.h"
#import "WebserviceManager.h"
#import "MPBSignatureViewController.h"
#import "HoursConstants.h"
#import "MBProgressHUD.h"
#import "ReviewerController.h"
#import "NSObject+Activity.h"

CGFloat currentKeyboardHeight = 0.0f;
CGFloat popupDimensionWidth = 300.0f;
CGFloat popupDimensionHeight = 300.0f;

static int const kHeaderSectionTag = 6900;

@interface SignersDisplay ()
{
    NSMutableArray*arr;
    NSMutableArray*arr1;
    NSString * SubscriberId;
    NSMutableDictionary * Subscriberdictionary;
    NSMutableArray * sectionArray;
    int foundInIndex;
    BOOL reviewerForME;
    BOOL isPickedME;
    NSMutableArray *savedIndex;

    NSString * WorkflowType;
    NSMutableArray * SignType;
    UIScreen *mainScreen;

    UIAlertController *alertController;
    UISearchBar * searchForSignatories;

}
@property (assign) NSInteger expandedSectionHeaderNumber;
@property (assign) NSInteger SectionNumber;
@property (assign) UITableViewHeaderFooterView *expandedSectionHeader;

@end

@implementation SignersDisplay

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //[[IQKeyboardManager sharedManager] setEnable:YES];
    
    searchForSignatories = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.signersList.frame.size.width - 20, 44)];
    searchForSignatories.placeholder = @"Search for Signatories";
    searchForSignatories.delegate = self;
    /*the search bar widht must be > 1, the height must be at least 44
    (the real size of the search bar)*/

    self.signersList.tableHeaderView = searchForSignatories;
    
    _docName =[[NSMutableArray alloc]init];
    
    _subscriberIdarray=[[NSMutableArray alloc]init];
    SignType = [[NSMutableArray alloc]init];

    self.signersList.delegate = self;
    self.signersList.dataSource = self;
    
    isPickedME = NO;
    
    self.searchResults = [[NSArray alloc]init];
    _holdSignersList = [[NSMutableArray alloc] init];
    _passsignerArray = [[NSMutableArray alloc] init];
    self.expandedSectionHeaderNumber = -1;
    self.SectionNumber = 0;
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0 green:96.0/255.0 blue:192.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    
    UIBarButtonItem* customBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismissViewController)];
    
    self.navigationItem.leftBarButtonItem = customBarButtonItem;
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(savebtnAction:)];
    
    UIBarButtonItem *adhocButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"addAdhocUserForSignatories.png"] style:UIBarButtonItemStylePlain target:self action:@selector(addAdhocSignatories:)];
  
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:saveButton, adhocButton, nil];

    self.signersList.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
  
    [self.signersList registerNib:[UINib nibWithNibName:@"SignerListCell" bundle:nil] forCellReuseIdentifier:@"SignerListCell"];
    // self.signersList.rowHeight = UITableViewAutomaticDimension;
    self.signersList.estimatedRowHeight = 100;
    
    
    [self getSignersListToDisplay];
    
    savedIndex = [[NSMutableArray alloc]init];
    for (int i = 0; i<self.SignerssectionArray.count; i++) {
        [savedIndex addObject:@""];
    }
    
    //hold name and email data
    self.arrayForCollectionViewForTap = [[NSMutableArray alloc]init];
    
    WorkflowType = [[NSUserDefaults standardUserDefaults]valueForKey:@"WorkflowType"];
    
    _refillName.delegate = self;
    _refillMobile.delegate = self;
    _refillEmailId.delegate = self;
    _refillOrganization.delegate = self;
    

}

-(void)dismissViewController{
    
    [self dismissViewControllerAnimated:true completion:^{
        
    }];
}

-(void)viewWillAppear:(BOOL)animated
{

    sectionArray =[[NSMutableArray alloc]init];

    NSMutableDictionary *empty = [[NSMutableDictionary alloc]init];
    for (int i = 0; i< self.signersCount; i++) {
        [_subscriberIdarray addObject:empty];
        [self.arrayForCollectionViewForTap addObject:empty];

    }

    sectionArray = [NSMutableArray arrayWithArray:self.SignerssectionArray];
    
    reviewerForME = NO;
    
    //for custom pop up adhoc sign user
    self.customPopUp.hidden = YES;
    self.customPopUp.alpha = 0.0;

}

- (void)viewWillLayoutSubviews {
    
        self.refillName.layer.cornerRadius = 5;
        self.refillEmailId.layer.cornerRadius = 5;
        self.refillMobile.layer.cornerRadius = 5;
        self.refillOrganization.layer.cornerRadius = 5;

        CALayer *border = [CALayer layer];
        CGFloat borderWidth = 1;
        border.borderColor = ([UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0].CGColor);
        border.frame = CGRectMake(0, _refillName.frame.size.height - borderWidth, _refillName.frame.size.width, _refillName.frame.size.height);
        border.borderWidth = borderWidth;
        [_refillName.layer addSublayer:border];
        _refillName.layer.masksToBounds = YES;
        
        CALayer *border1 = [CALayer layer];
        CGFloat borderWidth1 = 1;
        border1.borderColor =  ([UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0].CGColor);
        border1.frame = CGRectMake(0, _refillEmailId.frame.size.height - borderWidth1, _refillEmailId.frame.size.width, _refillEmailId.frame.size.height);
        border1.borderWidth = borderWidth1;
        [_refillEmailId.layer addSublayer:border1];
        _refillEmailId.layer.masksToBounds = YES;
    
        CALayer *border2 = [CALayer layer];
        CGFloat borderWidth2 = 1;
        border2.borderColor =  ([UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0].CGColor);
        border2.frame = CGRectMake(0, _refillMobile.frame.size.height - borderWidth2, _refillMobile.frame.size.width, _refillMobile.frame.size.height);
        border2.borderWidth = borderWidth2;
        [_refillMobile.layer addSublayer:border2];
        _refillMobile.layer.masksToBounds = YES;
    
        CALayer *border3 = [CALayer layer];
        CGFloat borderWidth3 = 1;
        border3.borderColor =  ([UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0].CGColor);
        border3.frame = CGRectMake(0, _refillOrganization.frame.size.height - borderWidth3, _refillOrganization.frame.size.width, _refillOrganization.frame.size.height);
        border3.borderWidth = borderWidth3;
        [_refillOrganization.layer addSublayer:border3];
        _refillOrganization.layer.masksToBounds = YES;
}



-(void)savebtnAction:(UIButton *)sender
{

    int signStatus = 0;
    if (![savedIndex containsObject:@""]) {
        
        NSString *foruploadApiDocumentId = [NSString stringWithFormat:@"%ld",(long)self.DocumentIDFromUploadApi];
        NSMutableDictionary* sendingvalues = [[NSMutableDictionary alloc]init];
    
           // NSInteger cid =[self.CategoryId integerValue];
            [sendingvalues setObject:self.CategoryId forKey:@"TemplateId"];
            [sendingvalues setObject:_CategoryName forKey:@"CategoryName"];
            [sendingvalues setObject:self.Documentname forKey:@"DocumentName"];
            [sendingvalues setObject:_subscriberIdarray  forKey:@"Signatories"];
            [sendingvalues setValue:[NSNumber numberWithInteger:self.DocumentID] forKey:@"DocumentId"];
            [sendingvalues setObject:WorkflowType forKey:@"WorkflowType"];

    for (int i = 0; i<self.signersCount; i++) {
        
        [_docName addObject:[self.signersList headerViewForSection:i].textLabel.text];
        if ([_docName[i]isEqualToString:@"ME"]&& [savedIndex[i]isEqualToString:@"Signer"]) {
            signStatus = 1;
            [SignType addObject:@"Signer"];
        }
        else if ([_docName[i]isEqualToString:@"ME"]&& [savedIndex[i]isEqualToString:@"Reviewer"])
        {
            signStatus = 2;
            [SignType addObject:@"Reviewer"];

        }
        else{
             [SignType addObject:@"Internal"];
        }
    }
  
        [self.navigationController dismissViewControllerAnimated:true completion:^ {
          [_delegate sendDataTosigners:self.docName SubscriberDict:sendingvalues SignType:SignType DataForNameAndEmailID:self.arrayForCollectionViewForTap];
          
        }];
        
    }
    else{
        UIAlertView *passwordAlertView = [[UIAlertView alloc]initWithTitle: @"Please pick Signatories"
                                                                   message: @"" //[NSString stringWithFormat: @"%@ %@",@"hello", @"is password protected"]
                                                                  delegate: nil
                                                         cancelButtonTitle: @"OK"
                                                         otherButtonTitles: nil];
        passwordAlertView.alertViewStyle = UIAlertViewStyleDefault;
        [passwordAlertView show];
        return;
        
    }
}

- (void)showModal:(UIModalPresentationStyle) style style:(MPBCustomStyleSignatureViewController*) controller
{
    
    MPBCustomStyleSignatureViewController* signatureViewController = [controller initWithConfiguration:[MPBSignatureViewControllerConfiguration configurationWithFormattedAmount:@""]];
    signatureViewController.modalPresentationStyle = style;
    signatureViewController.strExcutedFrom=@"Waiting for Others";
    signatureViewController.gotParametersForInitiateWorkFlow =[NSMutableArray arrayWithObject:@"ME"];
    
    signatureViewController.CategoryId = _CategoryId;
    signatureViewController.Documentname =  _Documentname;
    signatureViewController.CategoryName = _CategoryName;
    signatureViewController.ConfigId = _ConfigId;
    signatureViewController.DocumentID = *(&(_DocumentID));
    signatureViewController.subscriberIdarray =_subscriberIdarray;
    signatureViewController.d = _docName;
    
    signatureViewController.preferredContentSize = CGSizeMake(800, 500);
    signatureViewController.configuration.scheme = MPBSignatureViewControllerConfigurationSchemeAmex;
    // signatureViewController.signatureWorkFlowID = _workFlowID;
    signatureViewController.continueBlock = ^(UIImage *signature) {
        //[self showImage: signature];
    };
    signatureViewController.cancelBlock = ^ {
        
    };
    signatureViewController.delegate = self;
    [self presentViewController:signatureViewController animated:YES completion:nil];
    //[self.navigationController pushViewController:signatureViewController animated:true];
    
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
                            _holdSignersList = [NSMutableArray new];
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
                                            [self.signersList reloadData];
                                           //NSLog(@"%@"_holdSignersListt);
            
                                       });
                [self getAdhocUser];
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
                dispatch_async(dispatch_get_main_queue(),
                ^{
    
                [self presentViewController:alert animated:YES completion:nil];
                });
                return;
            }
    
        }];
    
}

-(void) getAdhocUser {
     NSString *post = [NSString stringWithFormat:@"SubsciberId=%d&pagenumber=%d&PageSize=%d",0,1,200];
                   
                   
                   [WebserviceManager sendSyncRequestWithURL:kGetAdhocUser method:SAServiceReqestHTTPMethodPOST body:post completionBlock:^(BOOL status, id responseValue){
               //if(status)
               if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])
               {
                           dispatch_async(dispatch_get_main_queue(),
                                          ^{
                                              NSMutableArray * responseArray = [[NSMutableArray alloc]init];
                               
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
                                               [self.signersList reloadData];
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

-(void)sendsign:(NSMutableDictionary *)signdict
{
    [self dismissViewControllerAnimated:true completion:^{
       [_delegate sendDataTosigners:self.docName SubscriberDict:signdict SignType:SignType DataForNameAndEmailID:self.arrayForCollectionViewForTap];

    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (self.signersCount > 0) {
        self.signersList.backgroundView = nil;
        return self.signersCount;
    } else {
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = @"Retrieving data.\nPlease wait.";
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:20];
        [messageLabel sizeToFit];
        self.signersList.backgroundView = messageLabel;
        
        return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (self.signersCount) {
        
        return [sectionArray objectAtIndex:section];
        
    }else return @"";
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section; {
    return 44.0;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {

    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.contentView.backgroundColor = [UIColor lightGrayColor];
    header.textLabel.textColor = [UIColor whiteColor];
 
    header.textLabel.preferredMaxLayoutWidth =  header.textLabel.frame.size.width + 30;
    header.textLabel.numberOfLines = 0;

    UIImageView *viewWithTag = [self.view viewWithTag:kHeaderSectionTag + section];
    if (viewWithTag) {
        [viewWithTag removeFromSuperview];
    }

    if (_signersCount >0)
    {
        CGSize headerFrame = self.view.frame.size;
        UIImageView *theImageView = [[UIImageView alloc] initWithFrame:CGRectMake(headerFrame.width - 32, 13, 18, 18)];
        theImageView.image = [UIImage imageNamed:@"Expand Arrow-25"];
        theImageView.tag = kHeaderSectionTag + section;
        [header addSubview:theImageView];

        header.tag = section;
        UITapGestureRecognizer *headerTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionHeaderWasTouched:)];
        [header addGestureRecognizer:headerTapGesture];
        
    }
}

- (void) addAdhocSignatories:(UIButton*)sender
{
    
    [self callalertPopUp];
    
}

-(void) callalertPopUp{
    
    alertController = [UIAlertController
                                          alertControllerWithTitle:@"Refill For Adhoc User"
                                          message:@""
                                   preferredStyle:UIAlertControllerStyleAlert];

    __block typeof(self) weakSelf = self;

    //name
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.tag = 1001;
         textField.delegate = weakSelf;
         textField.placeholder = @"Name";
         textField.keyboardType = UIKeyboardTypeDefault;
       
         textField.clearButtonMode = UITextFieldViewModeWhileEditing;
         [textField addTarget:weakSelf action:@selector(alertTextFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
     }];

    //email id
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.tag = 1002;
         textField.delegate = weakSelf;
         textField.placeholder = @"Email ID";
         textField.clearButtonMode = UITextFieldViewModeWhileEditing;
         textField.keyboardType = UIKeyboardTypeDefault;

        [textField addTarget:weakSelf action:@selector(alertTextFieldDidChange:)
                    forControlEvents:UIControlEventEditingChanged];
         }];

    //Mobile
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.tag = 1003;
         textField.delegate = weakSelf;
         textField.placeholder = @"Mobile";
         [textField setKeyboardType:UIKeyboardTypeNumberPad];
         textField.clearButtonMode = UITextFieldViewModeWhileEditing;

     }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
        {
            textField.tag = 1004;
            textField.delegate = weakSelf;
            textField.placeholder = @"Organization";
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            [textField.layer setBorderColor:[UIColor clearColor].CGColor];
           
        }];
    
    [alertController.actions firstObject].enabled = NO;

    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Current password %@", [[alertController textFields][1] text]);
        //compare the current password and do action here
       alertController.message = @"Warning message";
        
        BOOL validEmail = [self IsValidEmail:[[alertController textFields][1] text]];
        if (!validEmail) {
            [self alertForinvalidEmailID];
           
        }else{
            [self callForAdhocCreate:[[alertController textFields][0] text] :[[alertController textFields][1] text] :[[alertController textFields][2] text] :[[alertController textFields][3] text]];
        }

    }];
    
    confirmAction.enabled = NO;
    [alertController addAction:confirmAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Canelled");
    }];
    [alertController addAction:cancelAction];

    [self presentViewController:alertController animated:YES completion:nil];

  
}

-(void)alertForinvalidEmailID{
    UIAlertController * alert = [UIAlertController
                                        alertControllerWithTitle:nil
                                        message:@"Invalid Email Id"
                                        preferredStyle:UIAlertControllerStyleAlert];
           //Add Buttons
           UIAlertAction* yesButton = [UIAlertAction
                                       actionWithTitle:@"Ok"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
                                           //Handle your yes please button action here
                                        
                                            [self callalertPopUp];
                                       }];
           [alert addAction:yesButton];
           [self presentViewController:alert animated:YES completion:nil];
           return;
}

#pragma mark - UITextField Delegate Methods

- (void)alertTextFieldDidChange:(UITextField *)sender
  {
     alertController = (UIAlertController *)self.presentedViewController;
     UITextField *firstTextField = alertController.textFields[0];
     UITextField *secondTextField = alertController.textFields[1];
    
     UIAlertAction *okAction  = [alertController.actions objectAtIndex: 0];
     UIAlertAction *cancelAction  = [alertController.actions objectAtIndex: 1];
      
     // BOOL validEmail = [self IsValidEmail:secondTextField.text];

      if (firstTextField.text.length >0 && secondTextField.text.length >0 ) {
            BOOL duplicateName = NO;
            okAction.enabled = !duplicateName;
            cancelAction.enabled = !duplicateName;
      }
      else{
          okAction.enabled = NO;

      }
         
  }

//- (IBAction)submitAdhoc:(id)sender {
//
//    if ([self.refillName.text  isEqual: @""] && [self.refillEmailId.text  isEqual: @""]) {
//        //cannot be empty
//
//        ALAlertBanner *banner = [ALAlertBanner alertBannerForView:self.view style:ALAlertBannerStyleFailure position:ALAlertBannerPositionTop title:@"Name or email cannot be empty!" subtitle:@"" tappedBlock:^(ALAlertBanner *alertBanner) {
//            NSLog(@"tapped!");
//            //[alertBanner hide];
//        }];
//
//        [banner show];
//        return;
//    }
//    BOOL validEmail = [self IsValidEmail:self.refillEmailId.text];
//
//    if ([self.refillEmailId text].length > 1 && !validEmail){
//        //email id incorrect
//        ALAlertBanner *banner = [ALAlertBanner alertBannerForView:self.view
//                                                            style:ALAlertBannerStyleNotify
//                                                         position:ALAlertBannerPositionTop
//                                                            title:@"Email id is not valid!"
//                                                         subtitle:@""];
//
//        /*
//         optionally customize banner properties here...
//         */
//
//        [banner show];
//        return;
//    }
//
//    self.customPopUp.hidden = false;
//    [UIView animateWithDuration:0.3 delay:0
//                        options:UIViewAnimationOptionCurveEaseInOut
//                     animations:^ {
//                        self.customPopUp.alpha = 0.0;
//                     }completion:^(BOOL finished) {
//                         self.customPopUp.hidden = true;
//                         [self callForAdhocCreate];
//                     }];
//}

-(BOOL)IsValidEmail:(NSString *)checkString
{
    BOOL isvalidate;
    NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    //Valid email address
    
    if ([emailTest evaluateWithObject:checkString] == YES)
    {
        isvalidate = YES;
        //Do Something
    }
    else
    {
        isvalidate = NO;
        //NSLog(@"email not in proper format");
    }
    return isvalidate;
}

-(void)callForAdhocCreate :(NSString *)Name :(NSString*)EmailId :(NSString*)Mobile :(NSString*)Organization{
    
      [self startActivity:@""];
      
      // Login kCreateAdhocUser
    NSString *post = [NSString stringWithFormat:@"Name=%@&Email=%@&ContactNumber=%@&Organization=%@",Name,EmailId,Mobile,Organization];
      [WebserviceManager sendSyncRequestWithURL:kCreateAdhocUser method:SAServiceReqestHTTPMethodPOST body:post completionBlock:^(BOOL status, id responseValue){
          
          if (status) {
              NSNumber * isSuccessNumber = (NSNumber *)[responseValue valueForKey:@"IsSuccess"];
              if([isSuccessNumber boolValue] == YES)
              {
                  dispatch_async(dispatch_get_main_queue(),
                  ^{
                      [self stopActivity];
                      [[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"%@",[responseValue valueForKey:@"Messages"][0]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                      [self getSignersListToDisplay];
                      
                  });
              }
          }
      }];

}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_searchResults == nil || _searchResults.count == 0){
        
    if (self.expandedSectionHeaderNumber == section) {
     
        return self.ShowSignersList.count;
    } else {
        return 0;
        
    }
    }else{
        if (self.expandedSectionHeaderNumber == section) {
         
           return _searchResults.count;;
        } else {
            return 0;
            
        }
       
    }
  }
  
// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SignerListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SignerListCell" forIndexPath:indexPath];
    NSArray *section;
    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"FullName"
           ascending:YES];
       NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
       NSArray *sortedArray = [self.ShowSignersList sortedArrayUsingDescriptors:sortDescriptors];
    NSString *email = [[NSUserDefaults standardUserDefaults] stringForKey:@"Email"];
    if(_searchResults == nil || _searchResults.count == 0){

    section = [sortedArray objectAtIndex:indexPath.row];
    }else{
        section = [self.searchResults objectAtIndex:indexPath.row];
   }
    if ([section valueForKey:@"FullName"] == (id)[NSNull null]) cell.title.text = @"ME";
    else{
    cell.title.text = [section valueForKey:@"FullName"];
    }
    if ([section valueForKey:@"Email_Id"] == (id)[NSNull null]) cell.subTitle.text = email;
    else{
        cell.subTitle.text = [section valueForKey:@"Email_Id"];
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


#pragma mark - search delegate methods


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    // Do the search...
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
    _searchResults = [NSMutableArray array];
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    _ShowSignersList = [_holdSignersList mutableCopy];
   
      [self.signersList reloadData];

    //remaining Code'll go here
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{    if ([searchText length] == 0) {
        self.searchResults = nil;
        _ShowSignersList = [_holdSignersList mutableCopy];
        [self.signersList reloadData];
        [searchBar resignFirstResponder];
    }
  
    else{
    
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"FullName contains[c] %@ ",searchText];
     
        _searchResults = [self.ShowSignersList  filteredArrayUsingPredicate:filter];

        if (_searchResults.count == 0) {
            _ShowSignersList = [[NSMutableArray alloc]init];
            [self.signersList reloadData];

        }
        else{
            _ShowSignersList = [_searchResults mutableCopy];
            [self.signersList reloadData];
        }

    }
}

#pragma mark - Expand / Collapse Methods

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
    if(_searchResults == nil || _searchResults.count == 0){
    
    if (self.ShowSignersList.count != 0) {
   // NSArray *sectionData = [self.ShowSignersList objectAtIndex:section];
    
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
        dispatch_async(dispatch_get_main_queue(),
        ^{
            [self.signersList beginUpdates];
            [self.signersList deleteRowsAtIndexPaths:arrayOfIndexPaths withRowAnimation: UITableViewRowAnimationFade];
            [self.signersList endUpdates];
        });
        }
    }
        else{}} else{
             if (self.searchResults.count != 0) {
            // NSArray *sectionData = [self.ShowSignersList objectAtIndex:section];
             
             self.expandedSectionHeaderNumber = -1;
             if (self.searchResults.count == 0) {
                 return;
             } else {
                 [UIView animateWithDuration:0.4 animations:^{
                     imageView.transform = CGAffineTransformMakeRotation((0.0 * M_PI) / 180.0);
                 }];
                 NSMutableArray *arrayOfIndexPaths = [NSMutableArray array];
                 for (int i=0; i< self.searchResults.count; i++) {
                     NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:section];
                     [arrayOfIndexPaths addObject:index];
                 }
                 dispatch_async(dispatch_get_main_queue(),
                 ^{
                    [self.signersList beginUpdates];
                     [self.signersList deleteRowsAtIndexPaths:arrayOfIndexPaths withRowAnimation: UITableViewRowAnimationFade];
                     [self.signersList endUpdates];
                     
                 });
                 }
             }
            
        }
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
        [self.signersList beginUpdates];
        [self.signersList insertRowsAtIndexPaths:arrayOfIndexPaths withRowAnimation: UITableViewRowAnimationFade];
        [self.signersList endUpdates];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * ReviewerToCompare = @"Reviewer";
    NSString * SignerToCompare = @"Signatory";
    
    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"FullName"
        ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
    if(_searchResults == nil || _searchResults.count == 0){
        
          NSArray *sortArray = [self.ShowSignersList sortedArrayUsingDescriptors:sortDescriptors];
        NSMutableArray *sortedArray = [sortArray mutableCopy];

          Subscriberdictionary = [[NSMutableDictionary alloc]init];
          SubscriberId = [[sortedArray objectAtIndex:indexPath.row]valueForKey:@"SubscriberId"];
          [Subscriberdictionary setObject:SubscriberId forKey:@"SubscriberId"];
          [Subscriberdictionary setObject:@"" forKey:@"SignatureImage"];
          //cuurenlty//[Subscriberdictionary setObject:self.pageIdarray[indexPath.section] forKey:@"pageId"];
          
          
        //  [_subscriberIdarray replaceObjectAtIndex:indexPath.section withObject:Subscriberdictionary];
          NSInteger secti = self.expandedSectionHeaderNumber;
          
          UIImageView *cImageView  = (UIImageView *)[self.view viewWithTag:kHeaderSectionTag + self.expandedSectionHeaderNumber];
          [self tableViewCollapeSection:self.expandedSectionHeaderNumber withImage: cImageView];
             
          self.holdNameandEmailDataForCollectionView = [[NSMutableDictionary alloc]init];

          if (![sectionArray containsObject:[[sortedArray objectAtIndex:indexPath.row]valueForKey:@"FullName"]]) {
               
              //add data
              [self.holdNameandEmailDataForCollectionView setValue:[[sortedArray objectAtIndex:indexPath.row]valueForKey:@"FullName"] forKey:@"Name"];
              [self.holdNameandEmailDataForCollectionView setValue:[[sortedArray objectAtIndex:indexPath.row]valueForKey:@"Email_Id"] forKey:@"Email_Id"];

              if ([[sortedArray objectAtIndex:indexPath.row]valueForKey:@"FullName"] == (id)[NSNull null]) {

                  [sectionArray replaceObjectAtIndex:secti withObject:@"ME"];
                  
                  if (sectionArray.count > 1) {
                  if ([sectionArray.firstObject isEqual: @"ME"] && [sectionArray.lastObject isEqual: @"ME"] ) {
                                       [self callForAlertMultiplePickingSignatories];
                                       return;
                  } else {
                      
                      [tableView headerViewForSection:secti].textLabel.text = @"ME";
                  } } else [tableView headerViewForSection:secti].textLabel.text = @"ME";
              }else{
                  
              
              [tableView headerViewForSection:secti].textLabel.text = [[sortedArray objectAtIndex:indexPath.row]valueForKey:@"FullName"];
                     
                     [sectionArray replaceObjectAtIndex:secti withObject:[[sortedArray objectAtIndex:indexPath.row]valueForKey:@"FullName"]];
              }
              
           
              [_subscriberIdarray replaceObjectAtIndex:indexPath.section withObject:Subscriberdictionary];
              
              //save name and email in array
              [self.arrayForCollectionViewForTap replaceObjectAtIndex:indexPath.section withObject:self.holdNameandEmailDataForCollectionView];
                     
          }
          else{
              [self callForAlertMultiplePickingSignatories];
              return;
              // [tableView headerViewForSection:secti].textLabel.text = sectionArray[indexPath.section];
              // [sectionArray replaceObjectAtIndex:secti withObject:sectionArray[indexPath.section]];
          }
          if (!([[[sortedArray objectAtIndex:indexPath.section] description] rangeOfString:ReviewerToCompare].location == NSNotFound) && [[[sortedArray objectAtIndex:indexPath.row]valueForKey:@"FullName"]isEqualToString:@"ME"]) {
              
              [savedIndex replaceObjectAtIndex:indexPath.section withObject:@"Reviewer"];
              
          }else if(!([[[self.SignerssectionArray objectAtIndex:indexPath.section] description] rangeOfString:SignerToCompare].location == NSNotFound) && [[sortedArray objectAtIndex:indexPath.row]valueForKey:@"FullName"] == (id)[NSNull null]){
              [savedIndex replaceObjectAtIndex:indexPath.section withObject:@"Signer"];
          }
          else{
               [savedIndex replaceObjectAtIndex:indexPath.section withObject:@"Internal"];
          }
        
        
    } else {
        NSArray *sortedArray = [self.searchResults sortedArrayUsingDescriptors:sortDescriptors];


           Subscriberdictionary = [[NSMutableDictionary alloc]init];
           SubscriberId = [[self.searchResults objectAtIndex:indexPath.row]valueForKey:@"SubscriberId"];
           [Subscriberdictionary setObject:SubscriberId forKey:@"SubscriberId"];
           [Subscriberdictionary setObject:@"" forKey:@"SignatureImage"];
           //cuurenlty//[Subscriberdictionary setObject:self.pageIdarray[indexPath.section] forKey:@"pageId"];
           
           
         //  [_subscriberIdarray replaceObjectAtIndex:indexPath.section withObject:Subscriberdictionary];
           NSInteger secti = self.expandedSectionHeaderNumber;
           
           UIImageView *cImageView  = (UIImageView *)[self.view viewWithTag:kHeaderSectionTag + self.expandedSectionHeaderNumber];
           [self tableViewCollapeSection:self.expandedSectionHeaderNumber withImage: cImageView];
              
           self.holdNameandEmailDataForCollectionView = [[NSMutableDictionary alloc]init];
           
           

           if (![sectionArray containsObject:[[self.searchResults objectAtIndex:indexPath.row]valueForKey:@"FullName"]]) {
                
               //add data
               [self.holdNameandEmailDataForCollectionView setValue:[[self.searchResults objectAtIndex:indexPath.row]valueForKey:@"FullName"] forKey:@"Name"];
               [self.holdNameandEmailDataForCollectionView setValue:[[self.searchResults objectAtIndex:indexPath.row]valueForKey:@"Email_Id"] forKey:@"Email_Id"];

               if ([[self.searchResults objectAtIndex:indexPath.row]valueForKey:@"FullName"] == (id)[NSNull null]) {  [tableView headerViewForSection:secti].textLabel.text = @"ME";
                   [sectionArray replaceObjectAtIndex:secti withObject:@"ME"];
               }else{
               [tableView headerViewForSection:secti].textLabel.text = [[self.searchResults objectAtIndex:indexPath.row]valueForKey:@"FullName"];
                      
                      [sectionArray replaceObjectAtIndex:secti withObject:[[self.searchResults objectAtIndex:indexPath.row]valueForKey:@"FullName"]];
               }
               
            
               [_subscriberIdarray replaceObjectAtIndex:indexPath.section withObject:Subscriberdictionary];
               
               //save name and email in array
               [self.arrayForCollectionViewForTap replaceObjectAtIndex:indexPath.section withObject:self.holdNameandEmailDataForCollectionView];
                      
           }
           else{
               [self callForAlertMultiplePickingSignatories];
               return;
               // [tableView headerViewForSection:secti].textLabel.text = sectionArray[indexPath.section];
               // [sectionArray replaceObjectAtIndex:secti withObject:sectionArray[indexPath.section]];
           }
           if (!([[[self.searchResults objectAtIndex:indexPath.section] description] rangeOfString:ReviewerToCompare].location == NSNotFound) && [[[self.searchResults objectAtIndex:indexPath.row]valueForKey:@"FullName"]isEqualToString:@"ME"]) {
               
               [savedIndex replaceObjectAtIndex:indexPath.section withObject:@"Reviewer"];
               
           }else if(!([[[self.SignerssectionArray objectAtIndex:indexPath.section] description] rangeOfString:SignerToCompare].location == NSNotFound) && [[self.searchResults objectAtIndex:indexPath.row]valueForKey:@"FullName"] == (id)[NSNull null]){
               [savedIndex replaceObjectAtIndex:indexPath.section withObject:@"Signer"];
           }
           else{
                [savedIndex replaceObjectAtIndex:indexPath.section withObject:@"Internal"];
           }
        
        
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

- (BOOL) validateSpecialCharactor: (NSString *) text {
    NSString *Regex = @"[A-Za-z0-9^]*";
    NSPredicate *TestResult = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", Regex];
    return [TestResult evaluateWithObject:text];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *emailInput = [alertView textFieldAtIndex:0].text;
  
    BOOL abc = [self validateSpecialCharactor:emailInput];
    if (abc) {
        
   // password = [alertView textFieldAtIndex: 0].text.UTF8String;
    
    
    if (buttonIndex == 1) {
        [alertView dismissWithClickedButtonIndex: buttonIndex animated: TRUE];

        NSMutableDictionary* sendingvalues = [[NSMutableDictionary alloc]init];
        // NSInteger cid =[self.CategoryId integerValue];
        [sendingvalues setObject:self.CategoryId forKey:@"CategoryId"];
        [sendingvalues setObject:_CategoryName forKey:@"CategoryName"];
        [sendingvalues setObject:self.Documentname forKey:@"DocumentName"];
        for (int i = 0; i<_subscriberIdarray.count; i++) {
            NSMutableDictionary * signatoriesDict = [[NSMutableDictionary alloc]init];

            if ([savedIndex[i]  isEqual: @"Reviewer"]) {
                [signatoriesDict setObject:emailInput forKey:@"ReviewerComment"];
                [signatoriesDict setObject:[_subscriberIdarray[i]valueForKey:@"SubscriberId"] forKey:@"SubscriberId"];
                [signatoriesDict setObject:@"" forKey:@"SignatureImage"];
                [signatoriesDict setObject:_pageIdarray[i] forKey:@"pageId"];
                
                [_subscriberIdarray replaceObjectAtIndex:i withObject:signatoriesDict];
            }
            else
            {
                [signatoriesDict setObject:@"" forKey:@"ReviewerComment"];
                [signatoriesDict setObject:[_subscriberIdarray[i]valueForKey:@"SubscriberId"] forKey:@"SubscriberId"];
                [signatoriesDict setObject:@"" forKey:@"SignatureImage"];
                [signatoriesDict setObject:_pageIdarray[i] forKey:@"pageId"];

                
                [_subscriberIdarray replaceObjectAtIndex:i withObject:signatoriesDict];
            }
        }
        [sendingvalues setObject:_subscriberIdarray  forKey:@"Signatories"];
        [sendingvalues setObject:@"false" forKey:@"IsSign"];
        [sendingvalues setObject:@"true" forKey:@"IsReviewer"];

        [sendingvalues setObject:_ConfigId forKey:@"ConfigId"];
        [sendingvalues setValue:[NSNumber numberWithInteger:self.DocumentID] forKey:@"DocumentId"];
        [sendingvalues setObject:WorkflowType forKey:@"WorkflowType"];

        
        for (int i = 0; i<self.signersCount; i++) {
            [_docName addObject:[self.signersList headerViewForSection:i].textLabel.text];
            
        }

            [self.navigationController dismissViewControllerAnimated:true completion:^ {
             //   [_delegate sendDataTosigners:self.d :sendingvalues];
            }];
    
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
        
        [hud hide:YES afterDelay:1];

    }
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    UIAlertViewStyle style = alertView.alertViewStyle;
    
    if ((style == UIAlertViewStyleSecureTextInput) ||
        (style == UIAlertViewStylePlainTextInput) ||
        (style == UIAlertViewStyleLoginAndPasswordInput))
    {
        UITextField *textField = [alertView textFieldAtIndex:0];
        if ([textField.text length] == 0)
        {
            return NO;
        }
    }
    
    return YES;
    
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
