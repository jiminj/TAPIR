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
    if(self = [super init])
    {

        input = new int[ Tapir::Config::DATA_BIT_LENGTH];
        encoded = new float [ Tapir::Config::NO_DATA_SUBCARRIERS];
        interleaved = new float [ Tapir::Config::NO_DATA_SUBCARRIERS];
        modulated.realp = new float[Tapir::Config::NO_DATA_SUBCARRIERS];
        modulated.imagp = new float[Tapir::Config::NO_DATA_SUBCARRIERS];
        pilotAdded.realp = new float[Tapir::Config::NO_TOTAL_SUBCARRIERS];
        pilotAdded.imagp = new float[Tapir::Config::NO_TOTAL_SUBCARRIERS];
        extended.realp = new float[Tapir::Config::SAMPLE_LENGTH_EACH_SYMBOL]();
        extended.imagp = new float[Tapir::Config::SAMPLE_LENGTH_EACH_SYMBOL]();
        ifftData.realp = new float[Tapir::Config::SAMPLE_LENGTH_EACH_SYMBOL];
        ifftData.imagp = new float[Tapir::Config::SAMPLE_LENGTH_EACH_SYMBOL];
        carrierFreq = Tapir::Config::CARRIER_FREQUENCY_BASE + Tapir::Config::CARRIER_FREQUENCY_TRANSMIT_OFFSET;

        
        m_pilotMgr = new Tapir::PilotManager(&(Tapir::Config::PILOT_DATA), Tapir::Config::PILOT_LOCATIONS, Tapir::Config::NO_PILOT_SUBCARRIERS);
        
        m_modulator = new Tapir::PskModulator(Tapir::Config::MODULATION_RATE);
        m_interleaver = new Tapir::MatrixInterleaver(Tapir::Config::INTERLEAVER_ROWS, Tapir::Config::INTERLEAVER_COLS);
        m_encoder = new Tapir::ConvEncoder(Tapir::Config::TRELLIS_ARRAY);
        
        m_filter = Tapir::TapirFilters::getTxRxHpf([self calculateResultLengthOfStringWithLength:Tapir::Config::MAX_SYMBOL_LENGTH]);
        
    }
    return self;
}

- (void)encodeOneChar:(const char)src dest:(float *)dest;
{
    //Char to Int Array
//    Tapir::divdeIntIntoBits((int)src, input, [cfg kDataBitLength]);
    Tapir::divdeIntIntoBits((int)src, input, Tapir::Config::DATA_BIT_LENGTH);
    //Convolutional Encoding
    m_encoder->encode(input, encoded, Tapir::Config::DATA_BIT_LENGTH);
    //Interleaver
    m_interleaver->interleave(encoded, interleaved);
    //Modulation
    m_modulator->modulate(interleaved, &modulated, Tapir::Config::NO_DATA_SUBCARRIERS);
    
    //Add pilot
    m_pilotMgr->addPilot(&modulated, &pilotAdded, Tapir::Config::NO_DATA_SUBCARRIERS);
    

    //reverse each half and extend for ifft
    int firstHalfLength = (floor)(Tapir::Config::NO_TOTAL_SUBCARRIERS / 2);
    int lastHalfLength = Tapir::Config::NO_TOTAL_SUBCARRIERS - firstHalfLength;
    int lastHalfStPoint = Tapir::Config::SAMPLE_LENGTH_EACH_SYMBOL - lastHalfLength;

    memcpy(extended.realp + lastHalfStPoint, pilotAdded.realp, lastHalfLength * sizeof(float));
    memcpy(extended.imagp + lastHalfStPoint, pilotAdded.imagp, lastHalfLength * sizeof(float));
    memcpy(extended.realp , pilotAdded.realp + firstHalfLength, firstHalfLength * sizeof(float));
    memcpy(extended.imagp , pilotAdded.imagp + firstHalfLength, firstHalfLength * sizeof(float));
    
    //ifft
    Tapir::fftComplexInverse(&extended, &ifftData, Tapir::Config::SAMPLE_LENGTH_EACH_SYMBOL);

    // TODO: LPF (for real and imag both)
    
    //frequency upconversion
    Tapir::iqModulate(&ifftData, dest, Tapir::Config::SAMPLE_LENGTH_EACH_SYMBOL, Tapir::Config::AUDIO_SAMPLE_RATE, carrierFreq);
    //prepend and append cyclic prefix
    
}

- (void) addPrefixAndPostfixWith:(const float *)src dest:(float *)dest
{
    const int &lenCyclicPrefix = Tapir::Config::SAMPLE_LENGTH_CYCLIC_PREFIX;
    const int &lenEachSymbol =Tapir::Config::SAMPLE_LENGTH_EACH_SYMBOL;
    const int &lenCyclicPostfix = Tapir::Config::SAMPLE_LENGTH_CYCLIC_POSTFIX;
    
    if( (dest + lenCyclicPrefix) != src)
    {
        memcpy(dest + lenCyclicPrefix, src, lenEachSymbol * sizeof(float));
    }
    memcpy(dest, src + lenEachSymbol - lenCyclicPrefix, lenCyclicPrefix * sizeof(float));
    memcpy(dest + lenCyclicPrefix + lenEachSymbol, src, lenCyclicPostfix * sizeof(float));
    
}

- (void) generatePreamble:(float *)dest
{
    const int &lenPreamble = Tapir::Config::PREAMBLE_SAMPLE_LENGTH;

    DSPSplitComplex preamble;
    preamble.realp = new float[lenPreamble * 2];
    preamble.imagp = new float[lenPreamble * 2]();
    
    int lenForEachBit = (floor)(lenPreamble / Tapir::Config::PREAMBLE_BIT_LENGTH);
    for(int i=0; i<Tapir::Config::PREAMBLE_BIT_LENGTH ; ++i)
    {
        vDSP_vfill(Tapir::Config::PREAMBLE_BITS + i, preamble.realp + (i * lenForEachBit), 1, lenForEachBit);
    }
    // TODO: LPF (for real and imag both)
    
    Tapir::iqModulate(&preamble, dest, lenPreamble, Tapir::Config::AUDIO_SAMPLE_RATE, carrierFreq);
    Tapir::maximizeSignal(dest, dest, lenPreamble, Tapir::Config::AUDIO_MAX_VOLUME);
    memcpy(dest + lenPreamble, dest, lenPreamble * sizeof(float));

    delete [] preamble.realp;
    delete [] preamble.imagp;
}

- (void) generateSignalWith:(NSString *)inputString dest:(float *)dest length:(int)destLength
{
    
    float * destPtr = dest;

    //Generate preamble
    [self generatePreamble:destPtr];
    destPtr += Tapir::Config::PREAMBLE_SAMPLE_LENGTH * 2 + Tapir::Config::SAMPLE_LENGTH_INTERVAL_AFTER_PREAMBLE;
    
    //Convert each char to signal
    int strLen = [inputString length];
    for(int i=0; i< strLen; ++i)
    {
        float * curSymbolPtr = destPtr + Tapir::Config::SAMPLE_LENGTH_CYCLIC_PREFIX;

        char inputChar = [inputString characterAtIndex:i ];
        [self encodeOneChar:inputChar dest:curSymbolPtr ];
         
        Tapir::maximizeSignal(curSymbolPtr, curSymbolPtr, Tapir::Config::SAMPLE_LENGTH_EACH_SYMBOL, Tapir::Config::AUDIO_MAX_VOLUME);
        [self addPrefixAndPostfixWith:curSymbolPtr dest:destPtr];

        if( i != [inputString length] -1 )
        {
            destPtr += Tapir::Config::SAMPLE_LENGTH_EACH_SYMBOL_WITH_EXTENSION + Tapir::Config::SAMPLE_LENGTH_GUARD_INTERVAL;
            //To prevent to access unallocated space.
        }
    }

    m_filter->process(dest, dest, destLength);
    m_filter->clearBuffer();
    Tapir::maximizeSignal(dest, dest, destLength, Tapir::Config::AUDIO_MAX_VOLUME);
}

- (int) calculateResultLengthOfStringWithLength:(int)stringLength
{
    int retVal = 0;


    retVal = Tapir::Config::PREAMBLE_SAMPLE_LENGTH * 2 + Tapir::Config::SAMPLE_LENGTH_INTERVAL_AFTER_PREAMBLE
    + (Tapir::Config::SAMPLE_LENGTH_EACH_SYMBOL_WITH_EXTENSION + Tapir::Config::SAMPLE_LENGTH_GUARD_INTERVAL) * (int)stringLength
    - Tapir::Config::SAMPLE_LENGTH_GUARD_INTERVAL + Tapir::Config::FILTER_GUARD_LENGTH;
    
    return retVal;
}

- (void) dealloc
{
    delete m_filter;
    delete m_pilotMgr;
    delete m_interleaver;
    delete m_modulator;
    delete m_encoder;
    
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
