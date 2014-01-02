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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    aia = [[LKAudioInputAccessor alloc] init];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(correlationDetected:) name:@"correlationDetected" object:nil];
    
    logString = @"";
    
    
    [aia prepareAudioInputWithCorrelationWindowSize:[[TapirConfig getInstance] kPreambleLength] andBacktrackBufferSize:[[TapirConfig getInstance] kAudioBufferLength]];
    [aia startAudioInput];
    
    [[sendButton layer] setBorderColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor];
    [[sendButton layer] setBorderWidth:1.0f];
    [[sendButton layer] setCornerRadius:4.0f];
    [[sendButton layer] setMasksToBounds:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)startTracking:(id)sender{
    
    [self trace:nil];
}

-(void)correlationDetected:(NSNotification*)not{
    TapirConfig * cfg = [TapirConfig getInstance];
    TapirSignalAnalyzer * analyzer = [[TapirSignalAnalyzer alloc] initWithConfig:cfg];

    lastResultString = [analyzer analyze:(float*)([[[not userInfo] valueForKey:@"samples" ] intValue])];
    
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
    
    [sendButton setEnabled:YES];
    

}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
-(void)trace:(id)sender{
    [aia restart];
    
    [sendButton setEnabled:NO];
}
@end
