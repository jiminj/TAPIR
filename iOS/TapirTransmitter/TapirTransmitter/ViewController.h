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
@interface ViewController : UIViewController<LKSimpleBitlyMagicDelegate>{
    IBOutlet UITextField* inputText;
    IBOutlet UITextField* inputText2;
    
    IBOutlet UILabel * textLabel;
    IBOutlet UIButton *sendBtn;
    
    float* encodedText;
    Sonifier* son;
    

    
    NSString * textModeLabelText;
    NSString * urlModeLabelText;
    NSString * httpPrefix;
    
    TapirMotherOfAllFilters* hpf;
    TapirMotherOfAllFilters* hpf2;
    IBOutlet UISegmentedControl* sendTypeSC;
    IBOutlet UISegmentedControl* sendTypeSC2;
    LKSimpleBitlyMagic* wizard;
    LKSimpleBitlyMagic* sorcerer;
}
-(IBAction)send:(id)sender;
-(IBAction)send2:(id)sender;


-(IBAction)typeSelection:(id)sender;
@end
