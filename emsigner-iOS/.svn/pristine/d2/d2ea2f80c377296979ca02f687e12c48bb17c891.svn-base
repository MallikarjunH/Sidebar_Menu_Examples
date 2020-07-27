//
//  ShowEditImagesFromImageList.h
//  emSigner
//
//  Created by Emudhra on 23/10/18.
//  Copyright © 2018 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>
#import "AppDelegate.h"
#import "PreviewerController.h"
#import "MWPhotoBrowser.h"
#import <AssetsLibrary/AssetsLibrary.h>

@protocol senddataProtocol <NSObject>
-(void)sendDataToA:(NSDictionary *)dict; //I am thinking my data is NSArray, you can use another object for store your information.
@end

@interface ShowEditImagesFromImageList : UIViewController<UIImagePickerControllerDelegate,UITableViewDataSource,UITableViewDelegate,QLPreviewControllerDelegate,QLPreviewControllerDataSource,UINavigationControllerDelegate,ImageUpdate,MWPhotoBrowserDelegate>


@property (nonatomic, assign) MWPhotoBrowser *browser;

@property (weak, nonatomic) IBOutlet UIImageView *showImageFromListView;
@property (nonatomic, retain) UIImage *theImage;
@property (weak, nonatomic) IBOutlet UITableView *showMultipleImages;
@property(strong,nonatomic) NSMutableArray *showMultImages;
@property(strong,nonatomic) NSMutableArray *sendarray;
@property(strong,nonatomic) NSMutableArray *docresponsearray;
@property(nonatomic,strong)NSString *categoryname;
@property(weak,nonatomic)AppDelegate *appDelegate;
@property (strong, nonatomic) id detailItem;
@property(nonatomic,strong)NSString *documentName;
@property(nonatomic,strong) NSMutableArray *imagesArray;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property(assign)BOOL uploadAttachment;
@property(nonatomic,strong)NSString *documentId;
@property(nonatomic,weak)id delegate;
@property(nonatomic,strong)NSString *workFlowId;
@property(strong,nonatomic) NSMutableArray * post;
@property(assign)BOOL isSelected;
@property(assign)BOOL isDocStore;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addMultipleDocs;
//@property(strong,nonatomic) NSMutableArray *arrayToHoldImages;
@end


