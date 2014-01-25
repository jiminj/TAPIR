//
//  ViewController.m
//  TAPIRReceiver
//
//  Created by dilu on 11/15/13.
//  Copyright (c) 2013 dilu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import "LKAudioInputAccessor.h"

@interface ViewController ()

@end


@implementation ViewController

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    logString = @"";

    int frameSize = 1024;
    auto callback = Tapir::ObjcFuncBridge<void(float *)>(self, @selector(correlationDetected:));
    signalDetector = new Tapir::SignalDetector(frameSize, callback);
    signalAnalyzer = new Tapir::SignalAnalyzer([TapirFreqOffset getReceiverFreqOffset]);
    
    aia = [[LKAudioInputAccessor alloc] initWithFrameSize:frameSize detector:signalDetector];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)statusChanged:(id)sender
{
    if([rcvSwitch isOn])
    {
        [aia startAudioInput];
        NSLog(@"START");
    }
    else
    {
        [aia stopAudioInput];
        NSLog(@"STOP");        
    }
}

-(void)correlationDetected:(float *)result{
    
    lastResultString = [NSString stringWithCString:(signalAnalyzer->analyze(result)).c_str()
                                          encoding:[NSString defaultCStringEncoding]];
    NSLog(@"%@", lastResultString);
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    logString = [[NSString stringWithFormat:@"%@: %@\n", [formatter stringFromDate:[NSDate date]], lastResultString] stringByAppendingString:logString];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        //Your code goes in here
        outTF.text = logString;
    }];
    if(typeSC.selectedSegmentIndex==0){
        [webView loadHTMLString:@"" baseURL:nil];
    }else{
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://bit.ly/%@", lastResultString]]]];
    }
    
    
    signalDetector->clear();
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void) dealloc
{
    delete signalDetector;
    delete signalAnalyzer;
}

@end
