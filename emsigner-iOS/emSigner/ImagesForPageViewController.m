//
//  ImagesForPageViewController.m
//  emSigner
//
//  Created by Emudhra on 26/08/19.
//  Copyright © 2019 Emudhra. All rights reserved.
//

#import "ImagesForPageViewController.h"
#import "ViewController.h"
#import "GHWalkThroughView.h"


static NSString * const sampleDesc1 = @"Approve all documents using Electronic & Digital Signatures from Anywhere, Anytime. ";

static NSString * const sampleDesc2 = @" Send documents from your Camera, Files, Box for Signing by Multiple Parties.";


@interface ImagesForPageViewController ()<GHWalkThroughViewDataSource>

@property (nonatomic, strong) GHWalkThroughView* ghView;

@property (nonatomic, strong) NSArray* descStrings;

@property (nonatomic, strong) UILabel* welcomeLabel;

@end
@implementation ImagesForPageViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //self.automaticallyAdjustsScrollViewInsets = NO;
    [self.navigationController setNavigationBarHidden:YES];

    _ghView = [[GHWalkThroughView alloc] initWithFrame:self.navigationController.view.bounds];
    [_ghView setDataSource:self];
    self.ghView.isfixedBackground = NO;
    self.ghView.floatingHeaderView = nil;
    [self.ghView setWalkThroughDirection:GHWalkThroughViewDirectionHorizontal];
    [self.ghView showInView:self.navigationController.view animateDuration:0.3];
    self.descStrings = [NSArray arrayWithObjects:sampleDesc1,sampleDesc2,nil];
}

#pragma mark - GHDataSource

-(NSInteger) numberOfPages
{
    return 2;
}

- (void) configurePage:(GHWalkThroughPageCell *)cell atIndex:(NSInteger)index
{
    cell.title = [NSString stringWithFormat:@""];
    cell.titleImage = [UIImage imageNamed:[NSString stringWithFormat:@"", index+1]];
    cell.desc = [self.descStrings objectAtIndex:index];
}

- (UIImage*) bgImageforPage:(NSInteger)index
{
    NSString* imageName =[NSString stringWithFormat:@"intro%ld-img", index+1];
    UIImage* image = [UIImage imageNamed:imageName];
    return image;
}

- (void)didReceiveMemoryWarning
{
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
