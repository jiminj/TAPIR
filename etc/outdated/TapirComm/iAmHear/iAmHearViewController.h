//
//  iAmHearViewController.h
//  iAmHear
//
//  Created by Luke Kim on 7/15/11.
//  Copyright 2011 KAIST. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Recorder.h"
#import "iAmhearServer.h"
#import "iAmHearGraph.h"
#import "strDecoder.h"

@interface iAmHearViewController : UIViewController<UITextFieldDelegate> {
    Recorder* recorder;

    iAmHearGraph *signalGraph;
    UILabel *signalLabel;
    UILabel *peakLabel;
    int sockfd;
    double pre_meanVal;
    
    int loadURL;
    double thresholdsVal[11];
    int freqIndex;
}
- (IBAction)thresholdInc:(id)sender;
- (IBAction)thresholdDec:(id)sender;

- (IBAction)strDel:(id)sender;
@property (nonatomic, retain) IBOutlet UILabel *peakLabel;
@property (retain, nonatomic) IBOutlet UILabel *signalLabel;
@property (retain, nonatomic) IBOutlet UILabel *strLabel;
@property (retain, nonatomic) IBOutlet iAmHearGraph *signalGraph;
@property (retain, nonatomic) IBOutlet UILabel *thresholdLabel;
@property (retain, nonatomic) IBOutlet UIWebView *webView;
@property (retain, nonatomic) IBOutlet UISegmentedControl *segmentedControl1;
@property (retain, nonatomic) IBOutlet UISegmentedControl *segmentedControl2;

- (IBAction)setFreq:(id)sender;
- (IBAction)setFreq2:(id)sender;

-(void)connectClient:(NSString*)addr;
-(void)sendClient:(NSString*)msg;
@end
