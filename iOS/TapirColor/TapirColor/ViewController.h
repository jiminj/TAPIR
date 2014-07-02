//
//  ViewController.h
//  TapirColor
//
//  Created by Jimin Jeon on 7/1/14.
//  Copyright (c) 2014 AIMIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sonifier.h"
#import "LKAudioInputAccessor.h"
#import <TapirLib/TapirLib.h>

@interface ViewController : UIViewController<SonifierDelegate> {
    
    IBOutlet UISlider* sliderRed;
    IBOutlet UISlider* sliderGreen;
    IBOutlet UISlider* sliderBlue;
    
    IBOutlet UILabel* valRed;
    IBOutlet UILabel* valGreen;
    IBOutlet UILabel* valBlue;
    
    IBOutlet UIView * mainView;
    IBOutlet UIButton * btnTransmit;
    IBOutlet UISegmentedControl * segment;
    
    UIColor * bgColor;

    Sonifier* sonifier;
    
    LKAudioInputAccessor* aia;
    Tapir::SignalGenerator * generator;
    Tapir::SignalDetector * signalDetector;
    Tapir::SignalAnalyzer * signalAnalyzer;
    
    float * encodedAudioData;

    int convOffset;
    
}

-(IBAction)transmit:(id)sender;
-(IBAction)chgColor:(id)sender;
-(IBAction)statusChanged:(id)sender;
-(void)signalDetected:(float *)result;


@end
