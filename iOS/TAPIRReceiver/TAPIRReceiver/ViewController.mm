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
    
    logString = @"";

    [[sendButton layer] setBorderColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor];
    [[sendButton layer] setBorderWidth:1.0f];
    [[sendButton layer] setCornerRadius:4.0f];
    [[sendButton layer] setMasksToBounds:YES];
    

    int frameSize = 1024;
    auto callback = Tapir::ObjcFuncBridge<void(float *)>(@selector(correlationDetected:),self );
    signalDetector = new Tapir::SignalDetector(frameSize, callback);
    signalAnalyzer = new Tapir::SignalAnalyzer();
    
    aia = [[LKAudioInputAccessor alloc] initWithFrameSize:frameSize detector:signalDetector];


    tapirDetected = new float[Tapir::Config::MAX_SYMBOL_LENGTH];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)startTracking:(id)sender{
    [sendButton setEnabled:NO];
    [aia startAudioInput];
}


-(void)correlationDetected:(float *)result{
    
    lastResultString = [NSString stringWithCString:(signalAnalyzer->analyze(result)).c_str()
                                          encoding:[NSString defaultCStringEncoding]];
    NSLog(@"%@", lastResultString);
    
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
    
    
    signalDetector->clear();
    
    if(![holdSwitch isOn])
    {
        [aia stopAudioInput];
        [sendButton setEnabled:YES];
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void) dealloc
{
    delete signalDetector;
    delete [] tapirDetected;
}

@end
