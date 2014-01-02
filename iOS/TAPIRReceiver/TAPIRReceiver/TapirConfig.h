//
//  TapirConfig.h
//  TAPIRReceiver
//
//  Created by Jimin Jeon on 12/1/13.
//  Copyright (c) 2013 dilu. All rights reserved.
//

#define ASCII_ETX 0x03

#import <TapirLib/TapirLib.h>

typedef enum
{
    LEFT = 0,
    RIGHT
} OutputChannel;

@interface TapirConfig : NSObject
{
    //For Audio Setup
    Float64 kAudioSampleRate;
    
    int     kAudioChannel;
//    int     kAudioBitsPerChannel;
    float   kAudioMaxVolume;

    
    //for preamble
    int     kPreambleBitLength;
    float   kPreambleBandwidth;
    int     kPreambleLength;
    float * kPreambleBit;
    
    int     kMaximumSymbolLength;
    
    int     kIntervalAfterPreamble;
    int     kSymbolLength;
    int     kCyclicPrefixLength;
    int     kCyclicPostfixLength;
    int     kSymbolWithCyclicExtLength;
    int     kGuardIntervalLength;

    int     kAudioBufferLength;
    
    
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
    
    
    //For FilterDelay
    int kFilterDelayGuardLength;
    
}

+(TapirConfig *)getInstance;

//aditional getters
-(DSPSplitComplex *) kPilotData;
-(int *) kPilotLocation;
-(float *) kPreambleBit;

@property (readonly, nonatomic) Float64 kAudioSampleRate;
@property (readonly, nonatomic) int     kAudioChannel;
@property (readonly, nonatomic) float   kAudioMaxVolume;
//@property (readonly, nonatomic) int     kAudioBitsPerChannel;
@property (readonly, nonatomic) int     kMaximumSymbolLength;

@property (readonly, nonatomic) int     kPreambleBitLength;
@property (readonly, nonatomic) float   kPreambleBandwidth;
@property (readonly, nonatomic) int     kPreambleLength;

@property (readonly, nonatomic) int     kSymbolLength;
@property (readonly, nonatomic) int     kCyclicPrefixLength;
@property (readonly, nonatomic) int     kCyclicPostfixLength;
@property (readonly, nonatomic) int     kGuardIntervalLength;
@property (readonly, nonatomic) int     kSymbolWithCyclicExtLength;

@property (readonly, nonatomic) int     kAudioBufferLength;

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

@property (readonly, nonatomic) int     kFilterDelayGuardLength;

@end


//For Interleaver
//static const int kTapirInterleaveRows = 4;
//static const int kTapirInterleaveCols =