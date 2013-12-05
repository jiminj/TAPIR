//
//  ViewController.h
//  TapirTransmitter
//
//  Created by Jimin Jeon on 12/3/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sonifier.h"

@interface ViewController : UIViewController{
    IBOutlet UITextField* inputText;
    float* encodedText;
    Sonifier* son;
    TapirMotherOfAllFilters* hpf;
}
-(IBAction)send:(id)sender;

@end
