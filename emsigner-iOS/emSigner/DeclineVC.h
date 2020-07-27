//
//  DeclineVC.h
//  emSigner
//
//  Created by Administrator on 8/1/16.
//  Copyright © 2016 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeclineVC : UIViewController<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *customView;
@property (weak, nonatomic) IBOutlet UIButton *noBtn;
@property (weak, nonatomic) IBOutlet UITextView *remarkText;
@property (weak, nonatomic) IBOutlet UIButton *yesBtn;

@property (weak, nonatomic) NSMutableArray *declineArray;
@property (nonatomic, strong) NSString *workflowID;
@property (strong, nonatomic) NSString *strExcutedFrom;

- (IBAction)yesBtn:(id)sender;
- (IBAction)noBtn:(id)sender;

@end
