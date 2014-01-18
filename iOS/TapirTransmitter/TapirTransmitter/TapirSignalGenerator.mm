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
    if(self = [super init])
    {
        cfg = _cfg;
        
        input = new int[[cfg kDataBitLength]];
        encoded = new float [[cfg kNoDataSubcarriers]];
        interleaved = new float[[cfg kNoDataSubcarriers]];
        modulated.realp = new float[[cfg kNoDataSubcarriers]];
        modulated.imagp = new float[[cfg kNoDataSubcarriers]];
        pilotAdded.realp = new float[[cfg kNoTotalSubcarriers]];
        pilotAdded.imagp = new float[[cfg kNoTotalSubcarriers]];
        extended.realp = new float[[cfg kSymbolLength]]();
        extended.imagp = new float[[cfg kSymbolLength]]();
        ifftData.realp = new float[[cfg kSymbolLength]];
        ifftData.imagp = new float[[cfg kSymbolLength]];
        carrierFreq = [cfg kCarrierFrequency] + [cfg kCarrierFrequencyTransmitterOffset];
        
//        DSPSplitComplex ifftData;
        pilotMgr = [[TapirPilotManager alloc] initWithPilot:[cfg kPilotData] index:[cfg kPilotLocation] length:[cfg kPilotLength]];
        modulator = [[TapirPskModulator alloc] initWithSymbolRate:[cfg kModulationRate]];
        interleaver = [[TapirMatrixInterleaver alloc] initWithNRows:[cfg kInterleaverRows] NCols:[cfg kInterleaverCols]];
        convEncoder = [[TapirConvEncoder alloc] initWithTrellisArray:[cfg kTrellisArray]];
        
        filter = Tapir::TapirFilters::getTxRxHpf([self calculateResultLengthOfStringWithLength:[cfg kMaximumSymbolLength]]);
        
//        hpf = [TapirMotherOfAllFilters createHPF1];
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

    // TODO: LPF (for real and imag both)
    
    //frequency upconversion
    iqModulate(&ifftData, dest, [cfg kSymbolLength], [cfg kAudioSampleRate], carrierFreq);
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
    preamble.realp = new float[[cfg kPreambleLength] * 2];
    preamble.imagp = new float[[cfg kPreambleLength] * 2]();
    
    int lenForEachBit = (floor)([cfg kPreambleLength] / [cfg kPreambleBitLength]);
    for(int i=0; i<[cfg kPreambleBitLength]; ++i)
    {
        vDSP_vfill([cfg kPreambleBit]+i, preamble.realp + (i * lenForEachBit), 1, lenForEachBit);
    }
    // TODO: LPF (for real and imag both)
    
    iqModulate(&preamble, dest, [cfg kPreambleLength], [cfg kAudioSampleRate], carrierFreq);
    maximizeSignal(dest, dest, [cfg kPreambleLength], [cfg kAudioMaxVolume]);
    memcpy(dest + [cfg kPreambleLength], dest, [cfg kPreambleLength] * sizeof(float));

    delete [] preamble.realp;
    delete [] preamble.imagp;
}

- (void) generateSignalWith:(NSString *)inputString dest:(float *)dest length:(int)destLength
{
    
    float * destPtr = dest;
    
    //Generate preamble
    [self generatePreamble:destPtr];
    destPtr += [cfg kPreambleLength] * 2 + [cfg kIntervalAfterPreamble];
    
    //Convert each char to signal
    for(int i=0; i<[inputString length]; ++i)
    {
        float * curSymbolPtr = destPtr + [cfg kCyclicPrefixLength];

        char inputChar = [inputString characterAtIndex:i];
        [self encodeOneChar:inputChar dest:curSymbolPtr ];
         
        maximizeSignal(curSymbolPtr, curSymbolPtr, [cfg kSymbolLength], [cfg kAudioMaxVolume]);
        [self addPrefixAndPostfixWith:curSymbolPtr dest:destPtr];

        if( i != [inputString length] -1 )
        {
            destPtr += [cfg kSymbolWithCyclicExtLength] + [cfg kGuardIntervalLength];
            //To prevent to access unallocated space.
        }
    }

    filter->process(dest, dest, destLength);
    filter->clearBuffer();
    maximizeSignal(dest, dest, destLength, [cfg kAudioMaxVolume]);
}

- (int) calculateResultLengthOfStringWithLength:(int)stringLength
{
    int retVal = 0;
    retVal = [cfg kPreambleLength] * 2 + [cfg kIntervalAfterPreamble]
            + ([cfg kSymbolWithCyclicExtLength] + [cfg kGuardIntervalLength]) * (int)stringLength
            - [cfg kGuardIntervalLength] + [cfg kFilterDelayGuardLength];
    
    return retVal;
}

- (void) dealloc
{
    delete filter;
    delete [] input;
    delete [] encoded;
    delete [] interleaved;
    delete [] modulated.realp;
    delete [] modulated.imagp;
    delete [] pilotAdded.realp;
    delete [] pilotAdded.imagp;
    delete [] extended.realp;
    delete [] extended.imagp;
    delete [] ifftData.realp;
    delete [] ifftData.imagp;
}

@end
