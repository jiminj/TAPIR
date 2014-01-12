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
	// Do any additional setup after loading the view, typically from a nib.
    
//    NSString * inputStr = @"test";
//    TapirConfig * cfg = [TapirConfig getInstance];
// File write
    
//    NSFileHandle * fileHandle = [NSFileHandle fileHandleForWritingAtPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"genResult.txt"]];
//    NSMutableString * resultString = [[NSMutableString alloc] init];
//    for(int i=0; i<resultLength; ++i)
//    {
//        [resultString appendFormat:@"%f\n",result[i]];
//    }
//    [fileHandle writeData:[resultString dataUsingEncoding:NSUTF8StringEncoding]];

    cfg = [TapirConfig getInstance];
    generator = [[TapirSignalGenerator alloc] initWithConfig:cfg];

    
    sonifier = [[Sonifier alloc] initWithConfig:[TapirConfig getInstance]];
    [sonifier setDelegate:self];
//    [son start];
    
    
    bitlyShortener = [[LKBitlyUrlShortener alloc] init];
    [bitlyShortener setDelegate:self];
    
    sorcerer = [[LKBitlyUrlShortener alloc] init];
    [sorcerer setDelegate:self];
    
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
        [self transmitString:textToSend through:LEFT];
        
    }
    else
    {
        NSString * urlToSend = [inputText text];
        if(![urlToSend hasPrefix:httpPrefix])
        {
            urlToSend = [NSString stringWithFormat:@"%@%@", httpPrefix, urlToSend];
        }
        [bitlyShortener shortenUrl:urlToSend];
//        [self transmitString:urlToSend through:LEFT];
    }
    
}


-(void)didFinishBitlyConvertFrom:(NSString *)original to:(NSString *)result by:(id)obj
{
    NSLog(@"Result: %@", result);
    if([result length] > 0)
    {
        OutputChannel outCh;
        NSString * bitlyPostfix = [result substringFromIndex:14];
        if(obj == bitlyShortener){
            outCh = LEFT;
        }else{
            outCh = RIGHT;
        }
        [self transmitString:bitlyPostfix through:outCh];
    }
}

- (void)transmitString:(NSString*)textToBeSent through:(OutputChannel)outputCh
{
    //convert NSString * to Float *
//    TapirConfig * cfg = [TapirConfig getInstance];
//    TapirSignalGenerator * generator = [[TapirSignalGenerator alloc] initWithConfig:cfg];
    
    //Add ETX ascii code (end of the text)
    NSString* inputStr = [textToBeSent stringByAppendingFormat:@"%c", ASCII_ETX];
    if([inputStr length] > [cfg kMaximumSymbolLength])
    {
        inputStr = [inputStr substringToIndex:[cfg kMaximumSymbolLength]];
    }
    int resultLength = [generator calculateResultLengthOfStringWithLength:[inputStr length]];

    encodedAudioData = new float[resultLength]();

    [generator generateSignalWith:inputStr dest:encodedAudioData length:resultLength];
    
    [sonifier transmit:encodedAudioData length:resultLength];
    [sendBtn setEnabled:FALSE];
}

-(void) sonifierFinished
{
    delete [] encodedAudioData;
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
}
@end
