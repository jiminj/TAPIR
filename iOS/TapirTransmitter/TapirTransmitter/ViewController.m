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
    
    TapirConfig * cfg = [TapirConfig getInstance];
    TapirSignalGenerator * generator = [[TapirSignalGenerator alloc] initWithConfig:cfg];
    
    NSString * inputStr = @"te";
    if([inputStr length] > [cfg kMaximumSymbolLength])
    {
        inputStr = [inputStr substringToIndex:[cfg kMaximumSymbolLength]];
    }
    else if([inputStr length] < [cfg kMaximumSymbolLength])
    {
        inputStr = [inputStr stringByAppendingFormat:@"%c", ASCII_ETX];
    }
    int resultLength = [generator calculateResultLength:inputStr];
    float * result = calloc(resultLength, sizeof(float));
    [generator generateSignalWith:inputStr dest:result];

    
    
    NSFileHandle * fileHandle = [NSFileHandle fileHandleForWritingAtPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"genResult.txt"]];
    NSMutableString * resultString = [[NSMutableString alloc] init];
    for(int i=0; i<resultLength; ++i)
    {
        [resultString appendFormat:@"%f\n",result[i]];
    }
    [fileHandle writeData:[resultString dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
