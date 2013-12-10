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
    
    AVAudioSession* session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [aia prepareAudioInputWithCorrelationWindowSize:[[TapirConfig getInstance] kPreambleLength] andBacktrackBufferSize:[[TapirConfig getInstance] kAudioBufferLength]];
    [aia startAudioInput];
    webView.allowsInlineMediaPlayback = YES;
    webView.mediaPlaybackRequiresUserAction = NO;
    
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
    
    
    if([lastResultString isEqualToString:@"b"]){
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://dilu.kaist.ac.kr/mwa/437.html"]]];
    }else if([lastResultString isEqualToString:@"M"]){
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://dilu.kaist.ac.kr/mwa/438.html"]]];
    }
    
    [sendButton setEnabled:YES];
    
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
/*
-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortraitUpsideDown;
}

-(BOOL)shouldAutorotate{
    return NO;
}*/
-(void)trace:(id)sender{
    [aia restart];
    
    [sendButton setEnabled:NO];
}
@end
