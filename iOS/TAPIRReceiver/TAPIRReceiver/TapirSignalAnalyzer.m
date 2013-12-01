//
//  TapirSignalAnalyzer.m
//  TAPIRReceiver
//
//  Created by Jimin Jeon on 12/1/13.
//  Copyright (c) 2013 dilu. All rights reserved.
//

#import "TapirSignalAnalyzer.h"
#import "TapirConfig.h"

@implementation TapirSignalAnalyzer

//- (void)cutSymbolDataRegion()

-(void)analyzeSignal:(const DSPSplitComplex *)signal
{
    //
    
    //FFT
    
    //Cut central spectrum region
    
    //Channel Estimation
    TapirLSChannelEstimator * estimator = [[TapirLSChannelEstimator alloc]init];
    
    
    //Demodulation
    
    //Deinterpolation
    
    // Viterbi Decoder

//    NSMutableArray * treArr = [[NSMutableArray alloc] init];
//    [treArr addObject:[[TapirTrellisCode alloc] initWithG:7]];
//    [treArr addObject:[[TapirTrellisCode alloc] initWithG:5]];
//    
//    TapirViterbiDecoder * vitdec = [[TapirViterbiDecoder alloc] initWithTrellisArray:treArr];
//    
//    float input[] = {0,0,1,1,0,1,1,0,0,1,0,0,1,0,1,1};
//    int dest[8];
//    
//    [vitdec decode:input dest:dest srcLength:16];
    
    
    
    
}

@end
