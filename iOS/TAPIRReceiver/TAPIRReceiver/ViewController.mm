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
    signalDetector = new Tapir::SignalDetector(frameSize, callback);
    signalAnalyzer = new Tapir::SignalAnalyzer(Tapir::Config::CARRIER_FREQUENCY_BASE + [TapirFreqOffset getReceiverFreqOffset]);
    
    aia = [[LKAudioInputAccessor alloc] initWithFrameSize:frameSize detector:signalDetector];
    
    [aia startAudioInput];
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
    NSString* resultString;
    if([resultString isEqualToString:@"1"]){
        [self performSegueWithIdentifier:@"1" sender:self];
    }else if([resultString isEqualToString:@"2"]){
        [self performSegueWithIdentifier:@"2" sender:self];
    }else if([resultString isEqualToString:@"3"]){
        [self performSegueWithIdentifier:@"3" sender:self];
    }else if([resultString isEqualToString:@"4"]){
        [self performSegueWithIdentifier:@"4" sender:self];
    }else if([resultString isEqualToString:@"5"]){
        [self performSegueWithIdentifier:@"5" sender:self];
    }
    
    signalDetector->clear();
}



-(void) dealloc
{
    delete signalDetector;
    delete signalAnalyzer;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    HTMLViewController* vc = segue.destinationViewController;
    
    if([segue.identifier isEqualToString:@"1"]){
        vc.htmlPageName = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/html/1.html"];
    }else if([segue.identifier isEqualToString:@"2"]){
        vc.htmlPageName = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/html/2.html"];
    }else if([segue.identifier isEqualToString:@"3"]){
        vc.htmlPageName = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/html/3.html"];
    }else if([segue.identifier isEqualToString:@"4"]){
        vc.htmlPageName = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/html/4.html"];
    }else if([segue.identifier isEqualToString:@"5"]){
        vc.htmlPageName = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/html/5.html"];
    }
}

@end
