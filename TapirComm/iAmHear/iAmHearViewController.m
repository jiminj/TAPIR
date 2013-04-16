//
//  iAmHearViewController.m
//  iAmHear
//
//  Created by Luke Kim on 7/15/11.
//  Copyright 2011 KAIST. All rights reserved.
//

#import "iAmHearViewController.h"

@implementation iAmHearViewController

@synthesize peakLabel;
@synthesize signalLabel;
@synthesize strLabel;
@synthesize signalGraph;
@synthesize thresholdLabel;
@synthesize webView;
@synthesize segmentedControl1;
@synthesize segmentedControl2;



- (void)dealloc
{
    [peakLabel release];
    [recorder release];
    [signalLabel release];
    [signalGraph release];
    [strLabel release];
    [thresholdLabel release];
    [webView release];
    [segmentedControl1 release];
    [segmentedControl2 release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    pre_meanVal = 0;
    recorder = [[Recorder alloc] init];
    [recorder start];

    thresholdsVal[0] = 0.025;  // 800
    thresholdsVal[1] = 0.025;  // 2k
    thresholdsVal[2] = 0.038;  // 5k
    thresholdsVal[3] = 0.030;  // 10k
    thresholdsVal[4] = 0.012;  // 12k
    thresholdsVal[5] = 0.013;  // 14k
    thresholdsVal[6] = 0.013;  // 15k
    thresholdsVal[7] = 0.005;  // 16k
    thresholdsVal[8] = 0.008;  // 17k
    thresholdsVal[9] = 0.003;  // 18k
    thresholdsVal[10] = 0.002;  //20k
 
    [segmentedControl1 setSelectedSegmentIndex:-1];
    [segmentedControl2 setSelectedSegmentIndex:-1];
    
    [NSTimer scheduledTimerWithTimeInterval:0.0001 target:self selector:@selector(meanVal:) userInfo:nil repeats:YES];
}


- (void)viewDidUnload
{

    [signalLabel release];
    signalLabel = nil;
    [self setSignalLabel:nil];
    [signalGraph release];
    signalGraph = nil;
    [self setSignalGraph:nil];
    [self setStrLabel:nil];
    [self setThresholdLabel:nil];
    [self setWebView:nil];
    [self setSegmentedControl1:nil];
    [self setSegmentedControl2:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



-(void)meanVal:(NSTimer*)timer{

    
    double* meanVals = [recorder getMean_val];
    char* signals = [recorder getSignal];
    if([recorder getUpdated] >= 1){
        
        [recorder setUpdated:0];
        
        [signalGraph setThreshold:thresholdsVal[freqIndex]];
        [signalGraph setVals:meanVals];
        [signalGraph setNeedsDisplay];
        
        [peakLabel setText:[NSString stringWithFormat:@"%2.10lf",meanVals[9]]];
        
    
        [strLabel setText:[recorder getString]];
        if([recorder getCheck] > 0){
            NSLog(@"loadURL reset");
            loadURL = 0;
        }
        
        if([recorder getCheck] == 0 && loadURL == 0){
            //if([recorder getString] != ""){
            NSLog(@"URLRequest");
                [webView  loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[recorder getString]]]];
                loadURL = 1;
            //}
        }
       
    }
    
    [thresholdLabel setText:[NSString stringWithFormat:@"%1.3lf",[recorder getThreshold]]];
    
    
    [signalLabel setText:[NSString stringWithUTF8String:signals]];
    
    
    
    
    
}

- (IBAction)setFreq:(id)sender {
    UISegmentedControl *segmentedControl = segmentedControl1;
    //NSLog(@"%d",[segmentedControl selectedSegmentIndex]);
    int index = [segmentedControl selectedSegmentIndex];
    
    freqIndex = index;
    
    [recorder setFreq:index];
    
    [recorder setThreshold:thresholdsVal[index]];
    
    [segmentedControl2 setSelectedSegmentIndex:-1];
    
    
}

- (IBAction)setFreq2:(id)sender {
    UISegmentedControl *segmentedControl = segmentedControl2;
    //NSLog(@"%d",[segmentedControl selectedSegmentIndex]);
    int index = [segmentedControl selectedSegmentIndex];
    if(index < 5){
        freqIndex = index+6;
        [recorder setFreq:index+6];
    
        [recorder setThreshold:thresholdsVal[index+6]];
    }
    else{
        [segmentedControl setSelectedSegmentIndex:-1];
    }
    [segmentedControl1 setSelectedSegmentIndex:-1];

}

-(void)connectClient:(NSString*)addr{
    struct sockaddr_in clientaddr;
    
    
    
    clientaddr.sin_family = AF_INET;
    clientaddr.sin_port = htons(1986);
    clientaddr.sin_addr.s_addr = inet_addr([addr UTF8String]);
    
    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    
    if( sockfd < 0){
        NSLog(@"socket creation error");
    }
    
    else if(connect(sockfd,(struct sockaddr *) &clientaddr, sizeof(clientaddr)) < 0){
        NSLog(@"socket connection error");
    }
    else
        NSLog(@"connection ok");
    
    
}

-(void)sendClient:(NSString*)msg{
    
    if(write(sockfd,[msg UTF8String], strlen([msg UTF8String])) < 0){
        NSLog(@"message send error");
    }
    else{
      //  NSLog(@"message send ok");
    }
}



- (IBAction)thresholdInc:(id)sender {
    thresholdsVal[freqIndex] = [recorder getThreshold] + 0.001;
    [recorder setThreshold:thresholdsVal[freqIndex]];
}

- (IBAction)thresholdDec:(id)sender {
    thresholdsVal[freqIndex] = [recorder getThreshold] - 0.001;
    [recorder setThreshold:thresholdsVal[freqIndex]];
}

- (IBAction)strDel:(id)sender {
    [strLabel setText:[NSString stringWithFormat:@""]];
}
@end
