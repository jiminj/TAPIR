//
//  ViewController.m
//  TapirColor
//
//  Created by Jimin Jeon on 7/1/14.
//  Copyright (c) 2014 AIMIA. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [UIApplication sharedApplication].idleTimerDisabled=YES;
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    int frameSize = 1024;
    
    generator = new Tapir::SignalGenerator(Tapir::Config::CARRIER_FREQUENCY_BASE +
                                           [DevicesSpecifications getTransmitterFreqOffset]);
    sonifier = [[Sonifier alloc] initWithSampleRate:Tapir::Config::AUDIO_SAMPLE_RATE channel:Tapir::Config::AUDIO_CHANNEL];
    [sonifier setDelegate:self];

    
    auto callback = Tapir::ObjcFuncBridge<void(float *)>(self, @selector(signalDetected:));
    signalDetector = new Tapir::SignalDetector(frameSize, [DevicesSpecifications getThreshold],callback);
    signalAnalyzer = new Tapir::SignalAnalyzer(Tapir::Config::CARRIER_FREQUENCY_BASE + [DevicesSpecifications getReceiverFreqOffset]);
    
    aia = [[LKAudioInputAccessor alloc] initWithFrameSize:frameSize detector:signalDetector];
    
    [self colorChanged:NULL];
    convOffset = 48;
    
    
    [aia startAudioInput];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)transitBackgroundColor:(UIColor *)newColor
{
    [UIView animateWithDuration:1.0 animations:^{
        CGFloat rcvColorVal[4];
        [mainView setBackgroundColor:newColor];
        [newColor getRed:&rcvColorVal[0] green:&rcvColorVal[1] blue:&rcvColorVal[2] alpha:&rcvColorVal[3]];

        [sliderRed setValue:rcvColorVal[0]];
        [sliderGreen setValue:rcvColorVal[1]];
        [sliderBlue setValue:rcvColorVal[2]];
        
    }];
}

-(IBAction)colorChanged:(id)sender
{
    float redVal = (float)((int)([sliderRed value] * 10)) / 10;
    float greenVal = (float)((int)([sliderGreen value] * 10)) / 10;
    float blueVal = (float)((int)([sliderBlue value] * 10)) / 10;

    bgColor = [UIColor colorWithRed:redVal green:greenVal blue:blueVal alpha:1.0f];
    [sliderRed setValue:redVal];
    [sliderGreen setValue:greenVal];
    [sliderBlue setValue:blueVal];

    [self transitBackgroundColor:bgColor];
}

-(IBAction)chgColor:(id)sender
{
    int randVal[3];
    srand(time(NULL));
    
    bgColor = [UIColor colorWithRed:(CGFloat)((rand() % 11)) / 10
                              green:(CGFloat)((rand() % 11)) / 10
                               blue:(CGFloat)((rand() % 11)) / 10
                              alpha:1.0f];
    
    [self transitBackgroundColor:bgColor];
}


- (IBAction)transmit:(id)sender
{

    CGFloat redVal, greenVal, blueVal, alphaVal;
    [bgColor getRed:&redVal green:&greenVal blue:&blueVal alpha:&alphaVal];
    NSLog(@"Value! : %f %f %f",redVal,greenVal,blueVal);
    char redCharVal, greenCharVal, blueCharVal;
    
    redCharVal = (int)(redVal * 10) + convOffset;
    greenCharVal = (int)(greenVal * 10) + convOffset;
    blueCharVal = (int)(blueVal * 10) + convOffset;
    
    
    NSString* inputStr = [NSString stringWithFormat:@"%c%c%c", redCharVal,greenCharVal,blueCharVal];
    inputStr = [inputStr stringByAppendingString:inputStr];
    NSLog(@"%@",inputStr);
    [self transmitString:inputStr];
}


- (void)transmitString:(NSString*)textToBeSent
{
    [aia stopAudioInput];
    
    std::string stdInputStr = std::string([textToBeSent UTF8String]);
    int resultLength = generator->calResultLength((int)[textToBeSent length]);
    
    encodedAudioData = new float[resultLength]();
    generator->generateSignal(stdInputStr, encodedAudioData, resultLength);
    [sonifier transmit:encodedAudioData length:resultLength];
    
    [btnTransmit setEnabled:FALSE];
}


-(void)signalDetected:(float *)result{
    
    CGFloat rcvValue[3];
    
    NSString * resultString = [NSString stringWithCString:(signalAnalyzer->analyze(result)).c_str()
                                          encoding:[NSString defaultCStringEncoding]];
    
    NSString * resultStringFirstHalf = [resultString substringWithRange:NSRange{0,3}];
    NSString * resultStringLastHalf = [resultString substringWithRange:NSRange{3,3}];
    
    bool isOkay = true;
    if([resultStringFirstHalf isEqualToString:resultStringLastHalf])
    {
        for(int i=0; i<3; ++i)
        {
            rcvValue[i] = ([resultStringFirstHalf characterAtIndex:i] - convOffset) / 10.f;
            if( (rcvValue[i] < 0) && (rcvValue[i] > 1) )
            { isOkay = false; }
        }
    }
    else
    { isOkay = false; }

    if(isOkay != true)
    {
        signalDetector->clear();
        return;
    }
    
    UIColor * rcvColor = [UIColor colorWithRed:rcvValue[0] green:rcvValue[1] blue:rcvValue[2] alpha:1.0f];
    
    NSLog(@"Success, %f, %f, %f", rcvValue[0], rcvValue[1], rcvValue[2]);
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        //Your code goes in here
        CGFloat rcvColorVal[4];
        [rcvColor getRed:&rcvColorVal[0] green:&rcvColorVal[1] blue:&rcvColorVal[2] alpha:&rcvColorVal[3]];

        if(segment.selectedSegmentIndex==0)
        {
            bgColor = rcvColor;
        }
        else
        {
            CGFloat bgColorVal[4];
            [bgColor getRed:&bgColorVal[0] green:&bgColorVal[1] blue:&bgColorVal[2] alpha:&bgColorVal[3]];
            
            float newBgColorVal[4];
            for(int i=0; i<4; ++i)
            {
                int tempVal = ((rcvColorVal[i] + bgColorVal[i]) * 10) / 2;
                newBgColorVal[i] = tempVal / 10.0f;
            }
            bgColor = [UIColor colorWithRed:newBgColorVal[0] green:newBgColorVal[1] blue:newBgColorVal[2] alpha:newBgColorVal[3]];
        }
        [self transitBackgroundColor:bgColor];

//        
//        if(typeSC.selectedSegmentIndex==0){
//            [webView loadHTMLString:@"" baseURL:nil];
//        }else{
//            [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://bit.ly/%@", lastResultString]]]];
//        }
        
    }];
    
    signalDetector->clear();
}



-(void) sonifierFinished
{
    delete [] encodedAudioData;
    NSLog(@"Finished");
    [btnTransmit setEnabled:TRUE];
    [aia startAudioInput];
}


-(void) dealloc
{
    delete [] encodedAudioData;
    delete generator;
    delete signalDetector;
    delete signalAnalyzer;
}

@end
