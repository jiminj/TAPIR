//
//  ViewController.m
//  TapirTransmitter
//
//  Created by Jimin Jeon on 12/3/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import <TapirLib/TapirLib.h>


@interface ViewController ()

- (void)transmitString:(NSString*)textToBeSent through:(OutputChannel)outputCh;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    generator = new Tapir::SignalGenerator(Tapir::Config::CARRIER_FREQUENCY_BASE + [TapirFreqOffset getTransmitterFreqOffsetOfDevice]);
    sonifier = [[Sonifier alloc] initWithSampleRate:Tapir::Config::AUDIO_SAMPLE_RATE channel:Tapir::Config::AUDIO_CHANNEL];
    [sonifier setDelegate:self];
    
    bitlyShortener = [[LKBitlyUrlShortener alloc] init];
    [bitlyShortener setDelegate:self];
    
    
    textModeLabelText = @"Text (Max. 8 chars)";
    urlModeLabelText = @"URL";
    httpPrefix = @"http://";
    
    [sendTypeSC setSelectedSegmentIndex:0];
    [textLabel setText:textModeLabelText];
    [inputText setText:@""];
    
    [[sendBtn layer] setBorderColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor];
    [[sendBtn layer] setBorderWidth:1.0f];
    [[sendBtn layer] setCornerRadius:4.0f];
    [[sendBtn layer] setMasksToBounds:YES];
    
    
}

-(IBAction)typeSelection:(id)sender;
{
    UISegmentedControl * seg = (UISegmentedControl *) sender;
    if([seg selectedSegmentIndex] == 0 )
    {
        [textLabel setText:textModeLabelText];
        [inputText setText:@""];
    }
    else
    {
        [textLabel setText:urlModeLabelText];
        [inputText setText:httpPrefix];
    }
    
}

-(void)send:(id)sender{
    if(sendTypeSC.selectedSegmentIndex==0)
    {
        NSString * textToSend = [inputText text];
        if([textToSend length] >= 8)
        {
            textToSend = [textToSend substringToIndex:8];
        }
        if([sonifier isDone])
        { [self transmitString:textToSend through:LEFT]; }
        
    }
    else
    {
        NSString * urlToSend = [inputText text];
        if(![urlToSend hasPrefix:httpPrefix])
        {
            urlToSend = [NSString stringWithFormat:@"%@%@", httpPrefix, urlToSend];
        }
        [bitlyShortener shortenUrl:urlToSend];
        // => didFinishBitlyConvertFrom
    }
}


-(void)didFinishBitlyConvertFrom:(NSString *)original to:(NSString *)result by:(id)obj
{
    NSLog(@"Result: %@", result);
    if([result length] > 0)
    {
        OutputChannel outCh = LEFT;
        NSString * bitlyPostfix = [result substringFromIndex:14];

        if([sonifier isDone])
        { [self transmitString:bitlyPostfix through:outCh]; }
    }
}

- (void)transmitString:(NSString*)textToBeSent through:(OutputChannel)outputCh
{
    
    //Add ETX ascii code (end of the text)
    NSString* inputStr = [textToBeSent stringByAppendingFormat:@"%c", ASCII_ETX];
    if([inputStr length] > Tapir::Config::MAX_SYMBOL_LENGTH)
    {
        inputStr = [inputStr substringToIndex:Tapir::Config::MAX_SYMBOL_LENGTH];
    }
    std::string stdInputStr = std::string([inputStr UTF8String]);

    int resultLength = generator->calResultLength((int)[inputStr length]);

    encodedAudioData = new float[resultLength]();
    generator->generateSignal(stdInputStr, encodedAudioData, resultLength);
    
    [sonifier transmit:encodedAudioData length:resultLength];

    [sendBtn setEnabled:FALSE];
}

-(void) sonifierFinished
{
    delete [] encodedAudioData;
    NSLog(@"Finished");
    [sendBtn setEnabled:TRUE];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc
{
    delete [] encodedAudioData;
    delete generator;
}
@end
