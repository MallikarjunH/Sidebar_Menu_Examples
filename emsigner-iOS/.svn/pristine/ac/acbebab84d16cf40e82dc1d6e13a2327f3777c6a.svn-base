//
//  CaptureSignatureView.h
//  emSigner
//
//  Created by Administrator on 12/5/16.
//  Copyright © 2016 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>

// Protocol definition starts here
@protocol CaptureSignatureViewDelegate <NSObject>
@required
- (void)processCompleted:(UIImage*)signImage;
@end

@interface CaptureSignatureView : UIViewController
{
    // Delegate to respond back
    id <CaptureSignatureViewDelegate> _delegate;
    NSString *userName, *signedDate;

}

@property (nonatomic,strong) id delegate;
-(void)startSampleProcess:(NSString*)text;

//@property (weak, nonatomic) IBOutlet UviSignatureView *captureView;
@property (weak, nonatomic) IBOutlet UIButton *captureBtn;

- (IBAction)CaptureBtn:(id)sender;
@end
