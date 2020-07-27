//
//  RateUsVC.m
//  emSigner
//
//  Created by Administrator on 5/15/17.
//  Copyright © 2017 Emudhra. All rights reserved.
//

#import "RateUsVC.h"
#import "HomeNewDashBoardVC.h"
@interface RateUsVC ()

@end

@implementation RateUsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
 
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.customView.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(25.0, 25.0)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.view.bounds;
    maskLayer.path  = maskPath.CGPath;
    self.customView.layer.mask = maskLayer;
  
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self customView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)yesbtnClicked:(id)sender
{
    NSString *iTunesLink = @"https://itunes.apple.com/us/app/apple-store/id1246670687?mt=8";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
    [self dismissViewControllerAnimated:YES completion:Nil]; 
}

- (IBAction)noBtnClicked:(id)sender {
   [self dismissViewControllerAnimated:YES completion:Nil]; 
}

- (IBAction)laterBtnClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
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
