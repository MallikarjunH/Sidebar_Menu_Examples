//
//  DocsStoreNextVC.m
//  emSigner
//
//  Created by Administrator on 2/9/17.
//  Copyright © 2017 Emudhra. All rights reserved.
//

#import "DocsStoreNextVC.h"
#import "DocsStoreMultiplePdf.h"
@interface DocsStoreNextVC ()

@end

@implementation DocsStoreNextVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //
    UIButton* customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    customButton.backgroundColor = [UIColor colorWithRed:20.0/255.0 green:80.0/255.0 blue:170.0/255.0 alpha:1.0];
    customButton.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    [customButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    customButton.layer.cornerRadius = 5;
    [customButton setTitle:@"Documents" forState:UIControlStateNormal];
    [customButton sizeToFit];
    UIBarButtonItem* customBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:customButton];
    [customButton addTarget:self
                     action:@selector(flipView:)
           forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = customBarButtonItem;
    //
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

-(void)flipView:(UIButton*)sender
{
    
    UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DocsStoreMultiplePdf *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"DocsStoreMultiplePdf"];
    objTrackOrderVC.delegate = self;
    objTrackOrderVC.workFlowId = _workflowID;
    objTrackOrderVC.currentSelectedRow = _selectedIndex;
    objTrackOrderVC.document =@"Documents";
    self.definesPresentationContext = YES;
    //self is presenting view controller
    objTrackOrderVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self.navigationController pushViewController:objTrackOrderVC animated:YES];
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
