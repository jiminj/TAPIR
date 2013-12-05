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
#import "TapirConfig.h"
#import "TapirSignalAnalyzer.h"
//#import "AFNetworking.h"
#define BITLY_API_KEY ***REMOVED***

@interface ViewController : UIViewController<UITextFieldDelegate>{
    LKAudioInputAccessor* aia;
    IBOutlet UITextField* windowTF;
    IBOutlet UITextField* bufferTF;
    IBOutlet UITextView* outTF;
    NSString* logString;
}

-(IBAction)startTracking:(id)sender;
-(IBAction)trace:(id)sender;
@end
