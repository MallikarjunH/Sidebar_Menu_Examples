//
//  BaseViewController.h
//  11thHour
//
//  Created by Nawin Kumar on 7/19/15.
//  Copyright (c) 2015 alchemy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LMDropdownView.h"
@interface BaseViewController : UIViewController<UIPopoverPresentationControllerDelegate,UITableViewDataSource,UITableViewDelegate,LMDropdownViewDelegate>
//

@property (nonatomic, assign) int currentSelectedRow;
@property (nonatomic, assign) int selectedRow;
@property (weak, nonatomic) IBOutlet UILabel *navigationLable;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationTitle;
@property (weak, nonatomic) IBOutlet UIButton *sideMenuBtn;
@property (weak, nonatomic) IBOutlet UIButton *rightMenu;

@property (strong, nonatomic) NSArray *DocumentType;
@property (strong, nonatomic) NSArray *DocumentTypeImageview;
@property (strong, nonatomic) NSArray *DashboardMenu;
@property (strong, nonatomic) NSArray *sideMenuArray;
@property (assign, nonatomic) NSInteger currentDocumentTypeIndex;
@property (strong, nonatomic) LMDropdownView *dropdownView;
@property (weak, nonatomic) IBOutlet UILabel *controllerLable;
@property (strong, nonatomic) IBOutlet UITableView *documentTableView;
@property (weak, nonatomic) IBOutlet UIButton *allDocumentBtn;
@property (strong, nonatomic) NSString *strExcutedFrom;
@property (strong,nonatomic)  NSArray *mStoryIdArray;

@property (nonatomic) UIViewController *selectedController;


//@property (strong, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *customPopupMenu;
@property (nonatomic, strong) UIPopoverPresentationController *popover;

- (IBAction)customPopUpMenuBtn:(id)sender;
- (IBAction)allDocumentsBtn:(id)sender;
- (IBAction)rightMenu:(id)sender;
- (void) MenuAction;
- (void) addSelectedControllerViewOnBaseView:(UIViewController *)controller;
-(void) loadViewonSelection:(NSString *)StoryIdentifier;

@end
