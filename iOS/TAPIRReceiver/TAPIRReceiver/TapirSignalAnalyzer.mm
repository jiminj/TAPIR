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

- (id)initWithConfig:(TapirConfig *)_cfg
{
    if(self = [super init])
    {
        cfg = _cfg;

        convertedSignal.realp = new float[Tapir::Config::SAMPLE_LENGTH_EACH_SYMBOL];
        convertedSignal.imagp = new float[Tapir::Config::SAMPLE_LENGTH_EACH_SYMBOL];
        
        roiSignal.realp = new float[Tapir::Config::NO_TOTAL_SUBCARRIERS];
        roiSignal.imagp = new float[Tapir::Config::NO_TOTAL_SUBCARRIERS];
        estimatedSignal.realp = new float[Tapir::Config::NO_TOTAL_SUBCARRIERS];
        estimatedSignal.imagp = new float[Tapir::Config::NO_TOTAL_SUBCARRIERS];
        pilotRemovedSignal.realp = new float[Tapir::Config::NO_DATA_SUBCARRIERS];
        pilotRemovedSignal.imagp = new float[Tapir::Config::NO_DATA_SUBCARRIERS];

        demod = new float[Tapir::Config::NO_DATA_SUBCARRIERS];
        deinterleaved = new float[Tapir::Config::NO_DATA_SUBCARRIERS];
        decoded = new int[[cfg kDataBitLength]];

        m_pilotMgr = new Tapir::PilotManager(&(Tapir::Config::PILOT_DATA), Tapir::Config::PILOT_LOCATIONS, Tapir::Config::NO_PILOT_SUBCARRIERS);

        m_chanEstimator = new Tapir::LSChannelEstimator(m_pilotMgr, Tapir::Config::NO_TOTAL_SUBCARRIERS);
//        m_interleaver = [[TapirMatrixInterleaver alloc] initWithNRows:(Tapir::Config::INTERLEAVER_ROWS) NCols:(Tapir::Config::INTERLEAVER_COLS)];
        m_interleaver = new Tapir::MatrixInterleaver((Tapir::Config::INTERLEAVER_ROWS), (Tapir::Config::INTERLEAVER_COLS));
        
//        modulator = [[TapirPskModulator alloc] initWithSymbolRate:Tapir::Config::MODULATION_RATE];
        m_modulator = new Tapir::PskModulator(Tapir::Config::MODULATION_RATE);
        
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

-(char)decodeBlock:(const float *)signal
{
    //Freq Downconversion & FFT, and cut central spectrum region
//    Tapir::iqDemodulate(signal, &convertedSignal, [cfg kSymbolLength], [cfg kAudioSampleRate], [cfg kCarrierFrequency] + [cfg kCarrierFrequencyReceiverOffset]);
    Tapir::iqDemodulate(signal, &convertedSignal, Tapir::Config::SAMPLE_LENGTH_EACH_SYMBOL, Tapir::Config::AUDIO_SAMPLE_RATE, Tapir::Config::CARRIER_FREQUENCY_BASE + Tapir::Config::CARRIER_FREQUENCY_RECEIVE_OFFSET);
    // TODO: LPF (for real & imag both)
    
    //FFT
    Tapir::fftComplexForward(&convertedSignal, &convertedSignal, Tapir::Config::SAMPLE_LENGTH_EACH_SYMBOL);
    
    [self cutCentralRegion:&convertedSignal
                      dest:&roiSignal
              signalLength:(Tapir::Config::SAMPLE_LENGTH_EACH_SYMBOL)
                destLength:(Tapir::Config::NO_TOTAL_SUBCARRIERS)
           firstHalfLength:(Tapir::Config::NO_TOTAL_SUBCARRIERS/2)];

    //Channel Estimation
//    [chanEstimator channelEstimate:&roiSignal dest:&estimatedSignal];
    m_chanEstimator->estimateChannel(&roiSignal, &estimatedSignal);
    
    //Pilot Remove
//    [pilotMgr removePilotFrom:&estimatedSignal dest:&pilotRemovedSignal srcLength:Tapir::Config::NO_TOTAL_SUBCARRIERS];
    m_pilotMgr->removePilot(&estimatedSignal, &pilotRemovedSignal, Tapir::Config::NO_TOTAL_SUBCARRIERS);
    
    //Demodulation
//    [modulator demodulate:&pilotRemovedSignal dest:demod length:(Tapir::Config::NO_DATA_SUBCARRIERS)];
    m_modulator->demodulate(&pilotRemovedSignal, demod, Tapir::Config::NO_DATA_SUBCARRIERS);
    
    //Deinterleaver
//    [interleaver deinterleave:demod to:deinterleaved];
    m_interleaver->deinterleave(demod, deinterleaved);


    // Viterbi Decoding
    [vitdec decode:deinterleaved dest:decoded srcLength:(Tapir::Config::NO_DATA_SUBCARRIERS)];
    return ((char)Tapir::mergeBitsToIntegerValue(decoded, [cfg kDataBitLength]));

}

-(NSString *)analyze:(float *)signal
{
    NSMutableString * result = [[NSMutableString alloc] init];
    
    int maxSymbolLength = Tapir::Config::MAX_SYMBOL_LENGTH;
    int symbolWithGuardIntervalSize = Tapir::Config::SAMPLE_LENGTH_GUARD_INTERVAL + Tapir::Config::SAMPLE_LENGTH_EACH_SYMBOL_WITH_EXTENSION;
    int cyclicPrefixLength = Tapir::Config::SAMPLE_LENGTH_CYCLIC_PREFIX;
    
    //skip preambleInterval
    float * ptr = signal + Tapir::Config::SAMPLE_LENGTH_INTERVAL_AFTER_PREAMBLE;
    for(int i=0;i < maxSymbolLength; ++i)
    {
        float * curSymbol = (ptr + cyclicPrefixLength);
        char decodedChar = [self decodeBlock:curSymbol];
        if(decodedChar == ASCII_ETX) { break; }
        else
        {
            [result appendFormat:@"%c", decodedChar];
        }
        
        if( i != maxSymbolLength)
        {
            ptr += symbolWithGuardIntervalSize;
        }
    }
    return (NSString *)result;
    
}

- (void)dealloc
{

    delete [] convertedSignal.realp;
    delete [] convertedSignal.imagp;
    delete [] roiSignal.realp;
    delete [] roiSignal.imagp;
    delete [] estimatedSignal.realp;
    delete [] estimatedSignal.imagp;
    delete [] pilotRemovedSignal.realp;
    delete [] pilotRemovedSignal.imagp;
    delete [] demod;
    delete [] deinterleaved;
    delete [] decoded;
    
    delete m_chanEstimator;
    delete m_pilotMgr;
    delete m_interleaver;
    delete m_modulator;
    
}

@end
