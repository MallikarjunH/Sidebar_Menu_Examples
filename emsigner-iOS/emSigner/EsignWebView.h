//
//  EsignWebView.h
//  emSigner
//
//  Created by Emudhra on 26/06/19.
//  Copyright © 2019 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EsignWebView : UIViewController<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webViewEsign;
@property (nonatomic,strong) NSString *urlForWebViewEsign;

@end

NS_ASSUME_NONNULL_END
