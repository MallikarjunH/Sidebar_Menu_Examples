//
//  RecallDeclineVC.h
//  emSigner
//
//  Created by Administrator on 12/15/16.
//  Copyright © 2016 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DocumentLogVC.h"

@interface RecallDeclineVC : UIViewController
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *documentLogBtn;
@property (nonatomic, strong) NSString *myTitle;
@property (strong, nonatomic) NSString *pdfImagedetail;
@property (strong, nonatomic) NSString *workflowID;

- (IBAction)documentLogBtn:(id)sender;
@end
