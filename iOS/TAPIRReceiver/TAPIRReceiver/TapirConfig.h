//
//  TapirConfig.h
//  TAPIRReceiver
//
//  Created by Jimin Jeon on 12/1/13.
//  Copyright (c) 2013 dilu. All rights reserved.
//

#import <TapirLib/TapirLib.h>

@interface TapirConfig : NSObject
{
    Float64 kAudioSampleRate;
    
    int     kAudioChannel;
    int     kAudioBitsPerChannel;

    int     kIntervalAfterPreamble;
    int     kSymbolLength;
    int     kCyclicPrefixLength;
    int     kCyclicPostfixLength;
    int     kGuardIntervalLength;

    float   kCarrierFrequency;
    int     kNoDataSubcarriers;

    //For Channel Estimator
    int     kPilotLength;
    int     kNoTotalSubcarriers;
    int *   kPilotLocation;

    DSPSplitComplex kPilotData;

    
    //For modulator
    int     kModulationRate;
    
    
    //For Interleaver
    int     kInterleaverRows;
    int     kInterleaverCols;
    
    //For Decoder
    
    int kDecoderExtTracebackLength;
    NSArray * kTrellisArray;
    int kEncodingRate;
    int kDataBitLength;
    
}

+(TapirConfig *)getInstance;

//aditional getters
-(DSPSplitComplex *) kPilotData;
-(int *) kPilotLocation;

@property (readonly, nonatomic) Float64 kAudioSampleRate;
@property (readonly, nonatomic) int     kAudioChannel;
@property (readonly, nonatomic) int     kAudioBitsPerChannel;

@property (readonly, nonatomic) int     kSymbolLength;
@property (readonly, nonatomic) int     kCyclicPrefixLength;
@property (readonly, nonatomic) int     kCyclicPostfixLength;
@property (readonly, nonatomic) int     kGuardIntervalLength;

@property (readonly, nonatomic) int     kIntervalAfterPreamble;

@property (readonly, nonatomic) float   kCarrierFrequency;
@property (readonly, nonatomic) int     kNoDataSubcarriers;

//For Channel Estimator
@property (readonly, nonatomic) int     kPilotLength;
@property (readonly, nonatomic) int     kNoTotalSubcarriers;

@property (readonly, nonatomic) int     kModulationRate;

@property (readonly, nonatomic) int     kInterleaverRows;
@property (readonly, nonatomic) int     kInterleaverCols;

@property (readonly, nonatomic) int     kDecoderExtTracebackLength;

@property (readonly, nonatomic) NSArray * kTrellisArray;
@property (readonly, nonatomic) int     kEncodingRate;
@property (readonly, nonatomic) int     kDataBitLength;
@end


//For Interleaver
//static const int kTapirInterleaveRows = 4;
//static const int kTapirInterleaveCols =