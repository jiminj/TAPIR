//
//  HTMLViewController.h
//  TAPIRReceiver
//
//  Created by dilu on 2/9/14.
//  Copyright (c) 2014 dilu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HTMLViewController : UIViewController{
    NSString* htmlPageName;
    IBOutlet UIWebView* webView;
}
@property NSString* htmlPageName;
@end
