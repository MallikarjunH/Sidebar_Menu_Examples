//
//  ShowPdfForImages.h
//  emSigner
//
//  Created by Emudhra on 03/01/19.
//  Copyright © 2019 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PDFKit/PDFKit.h>

@interface ShowPdfForImages : UIViewController<UIDocumentInteractionControllerDelegate>

@property (weak, nonatomic) IBOutlet PDFView *showImagesView;
@property (strong, nonatomic) PDFDocument *pdfDocument;

@property(strong,nonatomic) NSString *imgPdfString;
@property(strong,nonatomic) NSString *documentName;
@property(strong,nonatomic) NSString *categoryname;

@end
