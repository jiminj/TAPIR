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
    NSLog(@"didLoad");

    int frameSize = 1024;
    auto callback = Tapir::ObjcFuncBridge<void(float *)>(self, @selector(signalDetected:));
    signalDetector = new Tapir::SignalDetector(frameSize, callback);
    signalAnalyzer = new Tapir::SignalAnalyzer(Tapir::Config::CARRIER_FREQUENCY_BASE + [TapirFreqOffset getReceiverFreqOffset]);
    
    aia = [[LKAudioInputAccessor alloc] initWithFrameSize:frameSize detector:signalDetector];
}
- (void) viewWillAppear:(BOOL)animated
{
    [aia startAudioInput];
}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [aia stopAudioInput];
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
    NSString* resultString = [NSString stringWithCString:(signalAnalyzer->analyze(result)).c_str()
                                                encoding:[NSString defaultCStringEncoding]];

    resultString = [resultString substringToIndex:1];
    char resultChar = [resultString characterAtIndex:0];
    NSLog(resultString);
    signalDetector->clear();
//    
    if(resultChar >= '1' && resultChar <= '5')
    {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:resultString sender:self];
        });
    }
    
}

//DEALLOC IS NOT CALLED
-(void) dealloc
{
    NSLog(@"dealloc");
    delete signalDetector;
    delete signalAnalyzer;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    HTMLViewController* vc = segue.destinationViewController;
    vc.htmlPageName = [NSURL URLWithString:[[[NSURL fileURLWithPath:[[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/html/loader.html"]] absoluteString] stringByAppendingString:[NSString stringWithFormat:@"?id=%@",[segue identifier]]]];
}

@end
