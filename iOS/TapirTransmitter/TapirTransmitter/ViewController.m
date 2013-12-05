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
    
    
    NSString * inputStr = @"test";
    TapirConfig * cfg = [TapirConfig getInstance];
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
    
}

-(void)send:(id)sender{

    //convert NSString * to Float *
    TapirConfig * cfg = [TapirConfig getInstance];
    TapirSignalGenerator * generator = [[TapirSignalGenerator alloc] initWithConfig:cfg];
    
    //Add ETX ascii code (end of the text)
    NSString* inputStr = [inputText.text stringByAppendingFormat:@"%c", ASCII_ETX];
    if([inputStr length] > [cfg kMaximumSymbolLength])
    {
        inputStr = [inputStr substringToIndex:[cfg kMaximumSymbolLength]];
    }
    
    int resultLength = [generator calculateResultLength:inputStr];
    if(encodedText != NULL) { free(encodedText); }
    encodedText = calloc(resultLength, sizeof(float));
    [generator generateSignalWith:inputStr dest:encodedText];
    [son transmit:encodedText length:resultLength ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc
{
    if(encodedText != NULL) { free(encodedText); }
}
@end
