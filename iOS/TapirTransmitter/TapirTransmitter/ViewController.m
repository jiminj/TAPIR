//
//  ViewController.m
//  TapirTransmitter
//
//  Created by Jimin Jeon on 12/3/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import "ViewController.h"
#import <TapirLib/TapirLib.h>
#import "TapirConfig.h"
#import "TapirSignalGenerator.h"

@interface ViewController ()

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
    
    
    wizard = [[LKSimpleBitlyMagic alloc] init];
    wizard.delegate = self;
    
    
    sorcerer = [[LKSimpleBitlyMagic alloc] init];
    sorcerer.delegate = self;
    
}

-(void)send:(id)sender{
    [self transmitString:@"b"];
    [self transmitString2:@"M"];
}
-(void)send2:(id)sender{
    if(sendTypeSC2.selectedSegmentIndex==0){
        [self transmitString2:inputText2.text];
    }else{
        [sorcerer bottleMagic:inputText2.text];
    }
}
-(void)magic:(int)spellName transformed:(NSString *)original into:(NSString *)result by:(id)caster{
    if(caster==wizard){
        [self transmitString:[result substringFromIndex:14]];
    }else{
        [self transmitString2:[result substringFromIndex:14]];
    }
}
-(void)magic:(int)spellName failedToTransform:(NSString *)original by:(id)caster{
    
}

-(void)transmitString:(NSString*)textToBeSent{
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
    [generator generateSignalWith:inputStr dest:encodedText];
    hpf = [TapirMotherOfAllFilters createHPF1];
    for(int i = 0; i<resultLength; i++){
        [hpf next:encodedText[i] writeTo:encodedText+i];
    }
    [son transmit:encodedText length:resultLength ];
}
-(void)transmitString2:(NSString*)textToBeSent{
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
    [generator generateSignalWith:inputStr dest:encodedText];
    hpf2 = [TapirMotherOfAllFilters createHPF1];
    for(int i = 0; i<resultLength; i++){
        [hpf2 next:encodedText[i] writeTo:encodedText+i];
    }
    [son transmitRight:encodedText length:resultLength ];
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
