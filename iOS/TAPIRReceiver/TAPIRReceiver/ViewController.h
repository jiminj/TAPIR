//
//  ViewController.h
//  TAPIRReceiver
//
//  Created by dilu on 11/15/13.
//  Copyright (c) 2013 dilu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LKAudioInputAccessor.h"

#import <TapirLib/TapirLib.h>

@interface ViewController : UIViewController<UITextFieldDelegate>{
    LKAudioInputAccessor* aia;
    IBOutlet UITextField* windowTF;
    IBOutlet UITextField* bufferTF;
    IBOutlet UITextView* outTF;
    IBOutlet UIButton* sendButton;
    IBOutlet UISegmentedControl* typeSC;
    IBOutlet UIWebView* webView;
    IBOutlet UISwitch * holdSwitch;
    
    NSString* logString;
    
    NSString* lastResultString;
    
    Tapir::SignalDetector * signalDetector;
    Tapir::SignalAnalyzer * signalAnalyzer;
}

-(IBAction)startTracking:(id)sender;

@end
