//
//  TapirSignalGenerator.m
//  TapirTransmitter
//
//  Created by Jimin Jeon on 12/4/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import "TapirSignalGenerator.h"

@implementation TapirSignalGenerator

- (id) init
{
    return nil;
}
- (id)initWithConfig:(TapirConfig *)_cfg
{
    if(self == [super init])
    {
        cfg = _cfg;
        
        input = malloc(sizeof(int) * [cfg kDataBitLength]);
        encoded = malloc(sizeof(float) * [cfg kNoDataSubcarriers]);
        interleaved = malloc(sizeof(float) * [cfg kNoDataSubcarriers]);
        modulated.realp = malloc(sizeof(float) * [cfg kNoDataSubcarriers]);
        modulated.imagp = malloc(sizeof(float) * [cfg kNoDataSubcarriers]);
        pilotAdded.realp = malloc(sizeof(float) * [cfg kNoTotalSubcarriers]);
        pilotAdded.imagp = malloc(sizeof(float) * [cfg kNoTotalSubcarriers]);
        extended.realp = calloc([cfg kSymbolLength], sizeof(float));
        extended.imagp = calloc([cfg kSymbolLength], sizeof(float));
        ifftData.realp = malloc(sizeof(float) * [cfg kSymbolLength]);
        ifftData.imagp = malloc(sizeof(float) * [cfg kSymbolLength]);
        
//        DSPSplitComplex ifftData;
        pilotMgr = [[TapirPilotManager alloc] initWithPilot:[cfg kPilotData] index:[cfg kPilotLocation] length:[cfg kPilotLength]];
        modulator = [[TapirPskModulator alloc] initWithSymbolRate:[cfg kModulationRate]];
        interleaver = [[TapirMatrixInterleaver alloc] initWithNRows:[cfg kInterleaverRows] NCols:[cfg kInterleaverCols]];
        convEncoder = [[TapirConvEncoder alloc] initWithTrellisArray:[cfg kTrellisArray]];
//        vitdec = [[TapirViterbiDecoder alloc] initWithTrellisArray:[cfg kTrellisArray]];
        
    }
    return self;
}

- (void)encodeOneChar:(const char)src dest:(float *)dest;
{
    //Char to Int Array
    divdeIntIntoBits((int)src, input, [cfg kDataBitLength]);
    //Convolutional Encoding
    [convEncoder encode:input dest:encoded srcLength:[cfg kDataBitLength]];
    //Interleaver
    [interleaver interleave:encoded to:interleaved];
    //Modulation
    [modulator modulate:interleaved dest:&modulated length:[cfg kNoDataSubcarriers]];
    //Add pilot
    [pilotMgr addPilotTo:&modulated dest:&pilotAdded srcLength:[cfg kNoDataSubcarriers]];

    //reverse each half and extend for ifft
    int firstHalfLength = (floor)([cfg kNoTotalSubcarriers] / 2);
    int lastHalfLength = [cfg kNoTotalSubcarriers] - firstHalfLength;
    int lastHalfStPoint = [cfg kSymbolLength] - lastHalfLength;
    memcpy(extended.realp + lastHalfStPoint, pilotAdded.realp, lastHalfLength * sizeof(float));
    memcpy(extended.imagp + lastHalfStPoint, pilotAdded.imagp, lastHalfLength * sizeof(float));
    memcpy(extended.realp , pilotAdded.realp + firstHalfLength, firstHalfLength * sizeof(float));
    memcpy(extended.imagp , pilotAdded.imagp + firstHalfLength, firstHalfLength * sizeof(float));
    
    //ifft
    fftComplexInverse(&extended, &ifftData, [cfg kSymbolLength]);
    //LPF
    
    //frequency upconversion
    iqModulate(&ifftData, dest, [cfg kSymbolLength], [cfg kAudioSampleRate], [cfg kCarrierFrequency]);
    //prepend and append cyclic prefix
    
}

- (void) addPrefixAndPostfixWith:(const float *)src dest:(float *)dest
{
    
    if(dest + [cfg kCyclicPrefixLength] != src)
    {
        memcpy(dest + [cfg kCyclicPrefixLength], src, [cfg kSymbolLength] * sizeof(float));
    }
    memcpy(dest, src + [cfg kSymbolLength] - [cfg kCyclicPrefixLength], [cfg kCyclicPrefixLength] * sizeof(float));
    memcpy(dest + [cfg kCyclicPrefixLength] + [cfg kSymbolLength], src, [cfg kCyclicPostfixLength] * sizeof(float));
}

- (void) generatePreamble:(float *)dest
{
    DSPSplitComplex preamble;
    preamble.realp = malloc(sizeof(float) * [cfg kPreambleLength] * 2);
    preamble.imagp = calloc([cfg kPreambleLength] * 2, sizeof(float));
    
    int lenForEachBit = (floor)([cfg kPreambleLength] / [cfg kPreambleBitLength]);
    for(int i=0; i<[cfg kPreambleBitLength]; ++i)
    {
        vDSP_vfill([cfg kPreambleBit]+i, preamble.realp + (i * lenForEachBit), 1, lenForEachBit);
    }
    
    iqModulate(&preamble, dest, [cfg kPreambleLength], [cfg kAudioSampleRate], [cfg kCarrierFrequency]);
    maximizeSignal(dest, dest, [cfg kPreambleLength], [cfg kAudioMaxVolume]);
    memcpy(dest + [cfg kPreambleLength], dest, [cfg kPreambleLength] * sizeof(float));

    free(preamble.realp);
    free(preamble.imagp);
}

- (void) generateSignalWith:(NSString *)inputString dest:(float *)dest
{
    
    float * destPtr = dest;
  
    //Generate preamble
    [self generatePreamble:destPtr];
    destPtr += [cfg kPreambleLength] * 2 + [cfg kIntervalAfterPreamble];
    
    //Convert each char to signal
    for(int i=0; i<[inputString length]; ++i)
    {
        float * curPureSymbolSt = destPtr + [cfg kCyclicPrefixLength];

        char inputChar = [inputString characterAtIndex:i];
        [self encodeOneChar:inputChar dest:curPureSymbolSt ];
        maximizeSignal(curPureSymbolSt, curPureSymbolSt, [cfg kSymbolLength], [cfg kAudioMaxVolume]);
        [self addPrefixAndPostfixWith:curPureSymbolSt dest:destPtr];
        destPtr += [cfg kSymbolWithCyclicExtLength] + [cfg kGuardIntervalLength];
    }

}

- (int) calculateResultLength:(NSString *)string
{
    int retVal = 0;
    retVal = [cfg kPreambleLength] * 2 + [cfg kIntervalAfterPreamble]
            + ([cfg kSymbolWithCyclicExtLength]
            + [cfg kGuardIntervalLength]) * [string length]
            - [cfg kGuardIntervalLength];
    
    return retVal;
}

- (void) dealloc
{
    if(input != NULL) { free(input); }
    if(encoded != NULL) { free(encoded); }
    if(interleaved != NULL) { free(interleaved); }
    if(modulated.realp != NULL) { free(modulated.realp); }
    if(modulated.imagp != NULL) { free(modulated.imagp); }
    if(pilotAdded.realp != NULL) { free(pilotAdded.realp); }
    if(pilotAdded.imagp != NULL) { free(pilotAdded.imagp); }
    if(extended.realp != NULL) { free(extended.realp); }
    if(extended.imagp != NULL) { free(extended.imagp); }
    if(ifftData.realp != NULL) { free(ifftData.realp); }
    if(ifftData.imagp != NULL) { free(ifftData.imagp); }
}

@end
