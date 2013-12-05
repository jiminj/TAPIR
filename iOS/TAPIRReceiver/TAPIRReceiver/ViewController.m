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
    
    logString = @"";
    

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)startTracking:(id)sender{
    
    [aia prepareAudioInputWithCorrelationWindowSize:[[TapirConfig getInstance] kPreambleLength] andBacktrackBufferSize:[[TapirConfig getInstance] kAudioBufferLength]];
    [aia startAudioInput];
}

-(void)correlationDetected:(NSNotification*)not{
    TapirConfig * cfg = [TapirConfig getInstance];
    TapirSignalAnalyzer * analyzer = [[TapirSignalAnalyzer alloc] initWithConfig:cfg];

    NSString * result = [analyzer analyze:(float*)([[[not userInfo] valueForKey:@"samples" ] intValue])];
    NSLog(@"%@",result);
    logString = [[NSString stringWithFormat:@"%@: %@\n", [NSDate date], result] stringByAppendingString:logString];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        //Your code goes in here
        outTF.text = logString;

    }];
    //AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    /*[manager GET:@"https://api-ssl.bitly.com" parameters:[NSString stringWithFormat:@"/v3/expand?access_token=%@&longUrl=%@", BITLY_API_KEY, result] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString* longURL = [[[[responseObject objectForKey:@"data"] objectForKey:@"expand"] objectAtIndex:0] objectForKey:@"long_url"];
        NSLog(longURL);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];*/
    //[aia restart];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
-(void)trace:(id)sender{
    [aia restart];
}
@end
