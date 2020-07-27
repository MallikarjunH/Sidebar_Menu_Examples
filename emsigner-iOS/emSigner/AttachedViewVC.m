//
//  AttachedViewVC.m
//  emSigner
//
//  Created by Administrator on 7/20/17.
//  Copyright © 2017 Emudhra. All rights reserved.
//

#import "AttachedViewVC.h"
#import "WebserviceManager.h"
#import "HoursConstants.h"
#import "NSObject+Activity.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
@interface AttachedViewVC ()
{
     int currentPreviewIndex;
}

@end

@implementation AttachedViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (_isDelete == YES) {
        _deleteView.hidden = NO;
    }
    else{
        _deleteView.hidden = YES;
    }
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem* customBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"tab-download-1x.png"] style:UIBarButtonItemStylePlain target:self action:@selector(downloadBtn:)];;
       
      // self.navigationItem.leftBarButtonItem = customBarButtonItem;
       
       UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ico-delete-18-1.png"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteBtn:)];;
            
       self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:saveButton, customBarButtonItem, nil];


    NSData *data = [[NSData alloc]initWithBase64EncodedString:_pdfImagedetail options:0];
    
    _attchedWebview.scalesPageToFit = YES;
    _attchedWebview.opaque = NO;
    _attchedWebview.backgroundColor = [UIColor clearColor];
    [_attchedWebview loadData:data MIMEType:@"application/pdf" textEncodingName:@"utf-8" baseURL:[NSURL URLWithString:@"http://"]];
    
   // self.attachedToolbar.hidden = YES;
    self.title = _myTitle;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) downloadBtn:(UIButton*)sender{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Download"
                                 message:@"Do you want to download document?"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    //Add Buttons
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Yes"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                    //[self clearAllData];
                                    
                                    [self startActivity:@"Loading..."];
                                    
                                    NSString *requestURL = [NSString stringWithFormat:@"%@DownloadDocumentById?documentId=%@",kDownloadPdf,_documentID];
                                    [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
                                        
                                      //  if(status)
                                            if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

                                        {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                
                                                _pdfImageArray=[[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",[[responseValue valueForKey:@"Response"] valueForKey:@"Filebyte"]]];
                                                if (_pdfImageArray != (id)[NSNull null])
                                                {
                                                    int Count;
                                                    NSData *data = [[NSData alloc]initWithBase64EncodedString:_pdfImageArray options:0];
                                                    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
                                                    NSString *path = [documentsDirectory stringByAppendingPathComponent:_myTitle];
                                                    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
                                                    for (Count = 0; Count < (int)[directoryContent count]; Count++)
                                                    {
                                                        NSLog(@"File %d: %@", (Count + 1), [directoryContent objectAtIndex:Count]);
                                                    }
                                                    [data writeToFile:path atomically:YES];
                                                    [self stopActivity];
                                                    QLPreviewController *previewController=[[QLPreviewController alloc]init];
                                                    previewController.delegate=self;
                                                    previewController.dataSource=self;
                                                    [self presentViewController:previewController animated:YES completion:nil];
                                                    
                                                    [previewController.navigationItem setRightBarButtonItem:nil];
                                                    _attachedToolbar.hidden = NO;
                                                    
                                                }
                                                else{
                                                    return;
                                                }
                                                
                                            });
                                            
                                        }
                                        else{
                                            
                                        }
                                    }];
                                    
                                }];
    UIAlertAction* noButton = [UIAlertAction
                                actionWithTitle:@"No"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                               {
                                   
                               }];
    
    //Add your buttons to alert controller
    
    [alert addAction:yesButton];
    [alert addAction:noButton];
    [self presentViewController:alert animated:YES completion:nil];
}



#pragma mark - data source(Preview)
//Data source methods
//– numberOfPreviewItemsInPreviewController:
//– previewController:previewItemAtIndex:
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return 1;
    
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    NSString *path = [[[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject] path];
    //You'll need an additional '/'
    NSString *fullPath = [path stringByAppendingFormat:@"/%@", _myTitle];
    return [NSURL fileURLWithPath:fullPath];
}

#pragma mark - delegate methods


- (BOOL)previewController:(QLPreviewController *)controller shouldOpenURL:(NSURL *)url forPreviewItem:(id <QLPreviewItem>)item
{
    return YES;
}

- (CGRect)previewController:(QLPreviewController *)controller frameForPreviewItem:(id <QLPreviewItem>)item inSourceView:(UIView **)view
{
    
    //Rectangle of the button which has been pressed by the user
    //Zoom in and out effect appears to happen from the button which is pressed.
    UIView *view1 = [self.view viewWithTag:currentPreviewIndex+1];
    return view1.frame;
}

- (void)deleteBtn:(UIButton*)sender {
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Delete"
                                 message:@"Do you want to delete document?"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    //Add Buttons
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Yes"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                    
                                    [self startActivity:@"Processing..."];
                                    NSString *requestURL = [NSString stringWithFormat:@"%@MarkAsInactive?documentId=%@&status=%@",kInactive,_documentID,@"Attachment"];
                                    
                                    [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
                                        
                                     //   if(status)
                                            if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

                                        {
                                            dispatch_async(dispatch_get_main_queue(),
                                                           ^{
                                                               
                                                               _inactiveArray =responseValue;
                                                               
                                                               if (_inactiveArray != (id)[NSNull null])
                                                               {
                                                                   
                                                                   if (self.selectedIndexPath) {
                                                                       [_listArray removeObjectAtIndex:self.selectedIndexPath.row];
                                                                   }

                                                               [self.navigationController popToRootViewControllerAnimated:YES];
                                                               
                                                               }
                                                           });
                                            
                                        }
                                       
                                        
                                    }];
                                    
                                    
                                    
                                }];
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"No"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   
                               }];
    
    //Add your buttons to alert controller
    
    [alert addAction:yesButton];
    [alert addAction:noButton];
    [self presentViewController:alert animated:YES completion:nil];
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
