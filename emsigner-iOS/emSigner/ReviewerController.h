//
//  ReviewerController.h
//  emSigner
//
//  Created by EMUDHRA on 13/09/19.
//  Copyright © 2019 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReviewerController : UIViewController<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *reviewerTextView;
@property (weak, nonatomic) IBOutlet UIButton *doneBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIView *customView;
@property(weak,nonatomic) NSMutableArray* requestArray;
@property(weak,nonatomic) NSMutableArray* subscriberIdarray;
@property(weak,nonatomic) NSMutableArray* d;
@property (strong,nonatomic) NSMutableArray* signersArray;
@property (strong,nonatomic) NSString* workflowID;
@property (strong,nonatomic) NSString* workFlowType;
@property (strong,nonatomic) NSString* pendingvc;
@property (nonatomic, assign) BOOL isReviewer;
@property (nonatomic, assign) BOOL isSignatory;

@property (nonatomic, assign) const char *passwordForPDF;




@end

NS_ASSUME_NONNULL_END
