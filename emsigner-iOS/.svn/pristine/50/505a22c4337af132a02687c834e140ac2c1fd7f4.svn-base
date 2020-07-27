//
//  ViewController.h
//  imagecroper
//
//  Created by Administrator on 10/12/18.
//  Copyright © 2018 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ImageFileCrop.h"
#import "ShowEditImagesFromImageList.h"
#import "PreviewerController.h"
//#import "VCFloatingActionButton.h"

@protocol uploadDocumentsDelegate <NSObject>
-(void)sendData:(NSDictionary *)senddict; //I am thinking my data is NSArray, you can use another object for store your information.
@end
@interface UploadDocuments : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,ImageCropViewControllerDelegate,ImageUpdate,UIDocumentPickerDelegate, UIDocumentMenuDelegate>//floatMenuDelegate
{
    ImageCropView* imageCropView;
    UIImage* image;
    IBOutlet UIImageView *imageView;
    
    UIDocumentPickerViewController *docPicker;
    UIImagePickerController *imagePicker;
    NSMutableArray *arrimg;
    
    
    NSString * UploadType;
    NSURL * PDFUrl;
    
}
//@property (strong, nonatomic) VCFloatingActionButton *addButton;
@property (assign) BOOL uploadAttachment;
@property(assign) BOOL isDocStore;
@property (nonatomic,strong)NSString *documentId;
@property(nonatomic,strong)NSString *workflowId;
@property (weak, nonatomic) IBOutlet UITableView *listTable;
@property(strong,nonatomic) NSMutableArray *catureImagesForListView;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property(strong,nonatomic)  NSMutableArray * SelectedArray;
@property(nonatomic,strong)NSMutableArray *pickImagesandDate;
@property(nonatomic,strong)NSMutableArray *fileSize;

@property(nonatomic,strong)NSMutableArray *arrayForDelegate;
@property(nonatomic,strong)NSMutableArray *sendarray;
@property(nonatomic,strong)NSString *categoryname;
@property(nonatomic,strong)NSString *documentName;
@property(nonatomic,strong)NSString *navigationTitle;
@property(nonatomic,weak) id delegate;
@property(assign)BOOL isSelctd;
-(void)imageFromScanner:(UIImage *)image;
@property(strong,nonatomic) NSMutableArray * post;


@end

