//
//  DelegateDocument.h
//  emSigner
//
//  Created by Emudhra on 12/02/19.
//  Copyright © 2019 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "RPFloatingPlaceholderTextField.h"
#import "MPGTextField.h"

@interface DelegateDocument : UIViewController<UITextFieldDelegate,UITextViewDelegate,MPGTextFieldDelegate>
//@property (weak, nonatomic) IBOutlet RPFloatingPlaceholderTextField *emailText;
//@property (weak, nonatomic) IBOutlet RPFloatingPlaceholderTextField *nameText;
@property (weak, nonatomic) IBOutlet MPGTextField *emailText;
@property (weak, nonatomic) IBOutlet MPGTextField *nameText;

@property (weak, nonatomic) IBOutlet UITextView *commentsText;

@property(strong,nonatomic) NSMutableArray* holdSignersList;
@property(strong,nonatomic) NSMutableArray* matchSignersList;


@property(strong,nonatomic)NSArray* workflowID;




@end
