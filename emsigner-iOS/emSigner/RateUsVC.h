//
//  RateUsVC.h
//  emSigner
//
//  Created by Administrator on 5/15/17.
//  Copyright © 2017 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RateUsVC : UIViewController

@property (weak, nonatomic) IBOutlet UIView *customView;
@property (weak, nonatomic) IBOutlet UIView *customView1;
@property (weak, nonatomic) IBOutlet UIView *customView2;
@property (weak, nonatomic) IBOutlet UIImageView *staticImage;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;


- (IBAction)yesbtnClicked:(id)sender;
- (IBAction)noBtnClicked:(id)sender;
- (IBAction)laterBtnClicked:(id)sender;
@end
