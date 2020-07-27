//
//  FlexiformsPage.h
//  emSigner
//
//  Created by Emudhra on 26/02/20.
//  Copyright © 2020 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PDFKit/PDFKit.h>
#import "SignatoriesListForFlexiforms.h"

NS_ASSUME_NONNULL_BEGIN

@interface FlexiformsPage : UIViewController<senddattaProtocol,UITextFieldDelegate,UITextViewDelegate>

@property (weak, nonatomic) IBOutlet PDFView *pdfView;
@property (strong, nonatomic) PDFDocument *pdfDocument;
@property (strong,nonatomic) NSString* base64String;
@property (strong,nonatomic) NSString* documentNameFlexiForms;
@property (strong,nonatomic) NSString* documentIdFlexiForms;
@property (strong,nonatomic) NSMutableArray *responseArray;
@property (strong,nonatomic) NSMutableArray *signatoryArray;
@property (weak, nonatomic) IBOutlet UIButton *addSignatories;
@property (strong,nonatomic) NSMutableArray *ControlInfoArray;


@end

NS_ASSUME_NONNULL_END
