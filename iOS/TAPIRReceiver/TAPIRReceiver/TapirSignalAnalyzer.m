//
//  TapirSignalAnalyzer.m
//  TAPIRReceiver
//
//  Created by Jimin Jeon on 12/1/13.
//  Copyright (c) 2013 dilu. All rights reserved.
//

#import "TapirSignalAnalyzer.h"
#import "TapirConfig.h"

@interface TapirSignalAnalyzer()

-(void) cutCentralRegion:(const DSPSplitComplex *)src dest:(DSPSplitComplex * )dest signalLength:(const int)signalLength destLength:(const int)destLength firstHalfLength:(const int)fHalfLength;
@end

@implementation TapirSignalAnalyzer

- (id) init
{
    return nil;
}
//- (void)cutSymbolDataRegion()

- (id)initWithConfig:(TapirConfig *)_cfg
{
    if(self == [super init])
    {
        cfg = _cfg;
        
        convertedSignal.realp = malloc(sizeof(float) * [cfg kSymbolLength]);
        convertedSignal.imagp = malloc(sizeof(float) * [cfg kSymbolLength]);
        roiSignal.realp = malloc(sizeof(float) * [cfg kNoTotalSubcarriers]);
        roiSignal.imagp = malloc(sizeof(float) * [cfg kNoTotalSubcarriers]);
        estimatedSignal.realp = malloc(sizeof(float) * [cfg kNoTotalSubcarriers]);
        estimatedSignal.imagp = malloc(sizeof(float) * [cfg kNoTotalSubcarriers]);
        pilotRemovedSignal.realp = malloc(sizeof(float) * [cfg kNoDataSubcarriers]);
        pilotRemovedSignal.imagp = malloc(sizeof(float) * [cfg kNoDataSubcarriers]);

        demod = malloc(sizeof(float) * [cfg kNoDataSubcarriers]);
        deinterleaved = malloc(sizeof(float) * [cfg kNoDataSubcarriers]);
        decoded = malloc(sizeof(int) * [cfg kDataBitLength]);
        
        chanEstimator = [[TapirLSChannelEstimator alloc] init];
        [chanEstimator setPilot:[cfg kPilotData] index:[cfg kPilotLocation] pilotLength:[cfg kPilotLength] channelLength:[cfg kNoTotalSubcarriers]];
        
        modulator = [[TapirPskModulator alloc] initWithSymbolRate:[cfg kModulationRate]];
        interleaver = [[TapirMatrixInterleaver alloc] initWithNRows:[cfg kInterleaverRows] NCols:[cfg kInterleaverCols]];
        vitdec = [[TapirViterbiDecoder alloc] initWithTrellisArray:[cfg kTrellisArray]];
        
    }
    return self;
    
}


- (void) cutCentralRegion:(const DSPSplitComplex *)src dest:(DSPSplitComplex * )dest signalLength:(const int)signalLength destLength:(const int)destLength firstHalfLength:(const int)fHalfLength
{
    int lastHalfCutLength = destLength - fHalfLength;
    int sigLastHalfStPoint = signalLength - lastHalfCutLength;
    int cpLHMemSize = lastHalfCutLength * sizeof(float);
    int cpFHMemSize = fHalfLength * sizeof(float);
    
    memcpy(dest->realp, src->realp + sigLastHalfStPoint, cpLHMemSize);
    memcpy(dest->imagp, src->imagp + sigLastHalfStPoint, cpLHMemSize);
    memcpy(dest->realp + lastHalfCutLength, src->realp, cpFHMemSize);
    memcpy(dest->imagp + lastHalfCutLength, src->imagp, cpFHMemSize);
}

-(char)analyzeSignal:(const float *)signal
{
    //Freq Downconversion & FFT, and cut central spectrum region
    iqDemodulate(signal, &convertedSignal, [cfg kSymbolLength], [cfg kAudioSampleRate], [cfg kCarrierFrequency]);

    //LowPassFilter!
    
    
    fftComplexForward(&convertedSignal, &convertedSignal, [cfg kSymbolLength]);
    
    [self cutCentralRegion:&convertedSignal dest:&roiSignal signalLength:[cfg kSymbolLength] destLength:[cfg kNoTotalSubcarriers] firstHalfLength:[cfg kNoTotalSubcarriers]/2];

    //Channel Estimation
    [chanEstimator channelEstimate:&roiSignal dest:&estimatedSignal];
    [chanEstimator removePilotsFromSignal:&estimatedSignal dest:&pilotRemovedSignal];

    //Demodulation
    [modulator demodulate:&pilotRemovedSignal dest:demod length:[cfg kNoDataSubcarriers]];
    //Deinterleaver
    [interleaver deinterleave:demod to:deinterleaved];
    
    // Viterbi Decoding
    [vitdec decode:deinterleaved dest:decoded srcLength:[cfg kNoDataSubcarriers] extLength:[cfg kDecoderExtTracebackLength]];
    
    return ((char)mergeBitsToIntegerValue(decoded, [cfg kDataBitLength]));

}

- (void)dealloc
{
    if(convertedSignal.realp != NULL) { free(convertedSignal.realp); }
    if(convertedSignal.imagp != NULL)  { free(convertedSignal.imagp);}
    if(roiSignal.realp != NULL) {free(roiSignal.realp);}
    if(roiSignal.imagp != NULL) {free(roiSignal.imagp);}
    if(estimatedSignal.realp != NULL) {free(estimatedSignal.realp);}
    if(estimatedSignal.imagp != NULL) {free(estimatedSignal.imagp);}
    if(pilotRemovedSignal.realp != NULL) {free(pilotRemovedSignal.realp);}
    if(pilotRemovedSignal.realp != NULL) {free(pilotRemovedSignal.imagp);}
    if(demod != NULL) {free(demod);}
    if(deinterleaved != NULL) { free(deinterleaved); }
    if(decoded != NULL) {free(decoded); }
    
}

@end
