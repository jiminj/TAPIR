//
//  ViewController.m
//  TAPIRReceiver
//
//  Created by dilu on 11/15/13.
//  Copyright (c) 2013 dilu. All rights reserved.
//

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

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)startTracking:(id)sender{
    [aia prepareAudioInputWithCorrelationWindowSize:400 andBacktrackBufferSize:1000];
    [aia startAudioInput];
}

-(void)correlationDetected:(NSNotification*)not{
    //outTF.text = [outTF.text stringByAppendingFormat:@"new signal detected\nmax correlation : %f", [[[not userInfo] valueForKey:@"maxCorrelation"] floatValue]];
    NSLog(@"new signal detected\nmax correlation : %f", [[[not userInfo] valueForKey:@"maxCorrelation"] floatValue]);
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
-(void)trace:(id)sender{
    [aia trace];
}
@end
