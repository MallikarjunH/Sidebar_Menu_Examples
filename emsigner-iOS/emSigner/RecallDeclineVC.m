//
//  RecallDeclineVC.m
//  emSigner
//
//  Created by Administrator on 12/15/16.
//  Copyright © 2016 Emudhra. All rights reserved.
//

#import "RecallDeclineVC.h"

@interface RecallDeclineVC ()

@end

@implementation RecallDeclineVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSData *data = [[NSData alloc]initWithBase64EncodedString:_pdfImagedetail options:0];
    
    _webView.scalesPageToFit = YES;
    _webView.opaque = NO;
    _webView.backgroundColor = [UIColor clearColor];
    [_webView loadData:data MIMEType:@"application/pdf" textEncodingName:@"utf-8" baseURL:[NSURL URLWithString:@"http://"]];
    //
    self.title = _myTitle;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)documentLogBtn:(id)sender
{
    UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DocumentLogVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"DocumentLogVC"];
    objTrackOrderVC.workflowID = _workflowID;
    [self.navigationController pushViewController:objTrackOrderVC animated:YES];
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
