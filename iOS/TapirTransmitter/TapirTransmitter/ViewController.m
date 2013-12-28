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
#import "TapirConfig.h"
#import "TapirSignalGenerator.h"

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
    
    son = [[Sonifier alloc] init];
    [son start];
    
    
    wizard = [[LKBitlyUrlShortener alloc] init];
    [wizard setDelegate:self];
    
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
        [wizard shortenUrl:urlToSend];
    }
    
}

//-(void)send2:(id)sender{
//    if(sendTypeSC2.selectedSegmentIndex==0){
//        [self transmitString2:inputText2.text];
//    }else{
//        [sorcerer shortenUrl:inputText2.text];
//    }
//}

-(void)didFinishBitlyConvertFrom:(NSString *)original to:(NSString *)result by:(id)obj{

    if([result length] > 0)
    {
        OutputChannel outCh;
        NSString * bitlyPostfix = [result substringFromIndex:14];
        if(obj == wizard){
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
    TapirConfig * cfg = [TapirConfig getInstance];
    TapirSignalGenerator * generator = [[TapirSignalGenerator alloc] initWithConfig:cfg];
    
    //Add ETX ascii code (end of the text)
    NSString* inputStr = [textToBeSent stringByAppendingFormat:@"%c", ASCII_ETX];
    if([inputStr length] > [cfg kMaximumSymbolLength])
    {
        inputStr = [inputStr substringToIndex:[cfg kMaximumSymbolLength]];
    }
    
    int resultLength = [generator calculateResultLength:inputStr];
    free(encodedText);
    encodedText = calloc(resultLength, sizeof(float));
    [generator generateSignalWith:inputStr dest:encodedText length:resultLength];
    
    [son transmit:encodedText length:resultLength through:outputCh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc
{
    free(encodedText);
}
@end
