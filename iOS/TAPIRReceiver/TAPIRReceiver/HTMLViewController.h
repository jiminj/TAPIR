//
//  HTMLViewController.h
//  TAPIRReceiver
//
//  Created by dilu on 2/9/14.
//  Copyright (c) 2014 dilu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HTMLViewController : UIViewController{
    NSURL* htmlPageName;
    IBOutlet UIWebView* webView;
}
@property NSURL* htmlPageName;
@end
