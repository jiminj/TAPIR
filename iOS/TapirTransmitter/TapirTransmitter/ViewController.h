//
//  ViewController.h
//  TapirTransmitter
//
//  Created by Jimin Jeon on 12/3/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sonifier.h"
#import "TapirLib/TapirLib.h"
#import <LKBitlyUrlShortener.h>

//#import "LKBitlyUrlShortener.h"

typedef enum
{
    LEFT = 0,
    RIGHT
} OutputChannel;



@interface ViewController : UIViewController<LKBitlyUrlConverterDelegate, SonifierDelegate>{
    IBOutlet UITextField* inputText;
    IBOutlet UITextField* inputText2;
    
    IBOutlet UILabel * textLabel;
    IBOutlet UIButton *sendBtn;
    
    IBOutlet UISegmentedControl* sendTypeSC;
    IBOutlet UISegmentedControl* sendTypeSC2;
    
    float* encodedAudioData;
    Sonifier* sonifier;
    
//    TapirSignalGenerator * generator;
    Tapir::SignalGenerator * generator;
    
    NSString * textModeLabelText;
    NSString * urlModeLabelText;
    NSString * httpPrefix;


    LKBitlyUrlShortener* bitlyShortener;
}
-(IBAction)send:(id)sender;
//-(IBAction)send2:(id)sender;



-(IBAction)typeSelection:(id)sender;
@end
