//
//  PreviewerController.h
//  emSigner
//
//  Created by EMUDHRA on 05/12/18.
//  Copyright © 2018 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageFileCrop.h"

@protocol ImageUpdate<NSObject>
- (void) imageupdater:(NSMutableArray *)ImageArray;
-(void)sendDataToShowEdit:(NSMutableArray *)addImages; //I am thinking my data is NSArray, you can use another object for store your information.

@end
@interface PreviewerController : UIViewController<ImageCropViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *previewimage;
@property (strong,nonatomic) UIImage * Previewimg;
@property (strong,nonatomic) NSMutableArray * imageArray;
@property (strong,nonatomic) NSMutableArray * sourceImageArray;
@property (weak,nonatomic) id imageupdateDelegate;
@property(nonatomic,strong)NSString *categoryname;
@property(nonatomic,strong)NSString *documentName;
@property(assign)BOOL uploadAttachment;
@property(assign)BOOL isDocStore;
@property(nonatomic,strong)NSString *workflowId;
@property(nonatomic,strong)NSString *documentId;
@property(strong,nonatomic) NSMutableArray * post;
@end
