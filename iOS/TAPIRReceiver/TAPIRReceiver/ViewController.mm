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
    auto callback = Tapir::ObjcFuncBridge<void(float *)>(self, @selector(signalDetected:));
    signalDetector = new Tapir::SignalDetector(frameSize, [DevicesSpecifications getThreshold],callback);
    signalAnalyzer = new Tapir::SignalAnalyzer(Tapir::Config::CARRIER_FREQUENCY_BASE + [DevicesSpecifications getReceiverFreqOffset]);
    
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
    }
    else
    {
        [aia stopAudioInput]; 
    }
}

-(void)signalDetected:(float *)result{
    
    lastResultString = [NSString stringWithCString:(signalAnalyzer->analyze(result)).c_str()
                                          encoding:[NSString defaultCStringEncoding]];
    
    const unsigned char firstChar = [lastResultString characterAtIndex:0];
    const unsigned char secondChar = [lastResultString characterAtIndex:1];
    unsigned int asciiCodeOfFirstChar = (unsigned int)(firstChar);
    
    int detectedCode = -1;
    if( (firstChar == secondChar) && (firstChar <= 124) && (firstChar >= 34))
    {
        if(firstChar > 69) // for 1 to 11
        {
            detectedCode = (asciiCodeOfFirstChar - 69) / 5;
        }
        else //for 12 to 19
        {
            detectedCode = (asciiCodeOfFirstChar + 26 ) / 5;
        }
    }
    if(detectedCode > 0)
    {
        //do something
    }
    NSLog(@"%@ // firstChar : %c(%u)", lastResultString, firstChar, asciiCodeOfFirstChar);
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];

    
    logString = [[NSString stringWithFormat:@"%@: %@ \t(FirstChar : %u)\n", [formatter stringFromDate:[NSDate date]], lastResultString, asciiCodeOfFirstChar] stringByAppendingString:logString];
    
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        //Your code goes in here
        outTF.text = logString;
        
        if(typeSC.selectedSegmentIndex==0){
            [webView loadHTMLString:@"" baseURL:nil];
        }else{
            [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://bit.ly/%@", lastResultString]]]];
        }
    }];
    
    signalDetector->clear();
}

-(void) dealloc
{
    delete signalDetector;
    delete signalAnalyzer;
}

@end
