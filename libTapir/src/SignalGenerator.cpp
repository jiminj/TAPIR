//
//  SignalGenerator.cpp
//  TapirLib
//
//  Created by Jimin Jeon on 1/25/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#include "../include/SignalGenerator.h"

namespace Tapir{

    SignalGenerator::SignalGenerator(float carrierFreq)
    : m_carrier(carrierFreq),
    m_input(new int[Tapir::Config::DATA_BIT_LENGTH]),
    m_encoded(new float[Tapir::Config::NO_DATA_SUBCARRIERS]),
    m_interleaved(new float[Tapir::Config::NO_DATA_SUBCARRIERS]),
    m_modulated({ .realp = new float[Tapir::Config::NO_DATA_SUBCARRIERS], .imagp = new float[Tapir::Config::NO_DATA_SUBCARRIERS] }),
    m_pilotAdded({ .realp = new float[Tapir::Config::NO_TOTAL_SUBCARRIERS] , .imagp=new float[Tapir::Config::NO_TOTAL_SUBCARRIERS] }),
    m_extended({.realp = new float[Tapir::Config::SAMPLE_LENGTH_EACH_SYMBOL](), .imagp = new float[Tapir::Config::SAMPLE_LENGTH_EACH_SYMBOL]()}),
    m_ifftData({.realp = new float[Tapir::Config::SAMPLE_LENGTH_EACH_SYMBOL], .imagp = new float[Tapir::Config::SAMPLE_LENGTH_EACH_SYMBOL] }),
    m_pilotMgr(new Tapir::PilotManager(&(Tapir::Config::PILOT_DATA), Tapir::Config::PILOT_LOCATIONS, Tapir::Config::NO_PILOT_SUBCARRIERS)),
    m_modulator(new Tapir::PskModulator(Tapir::Config::MODULATION_RATE)),
    m_encoder(new Tapir::ConvEncoder(Tapir::Config::TRELLIS_ARRAY)),
    m_interleaver(new Tapir::MatrixInterleaver(Tapir::Config::INTERLEAVER_ROWS, Tapir::Config::INTERLEAVER_COLS)),
    m_filter(Tapir::FilterCreator::create(calResultLength(Tapir::Config::MAX_SYMBOL_LENGTH), Tapir::FilterCreator::EQUIRIPPLE_19k_250)),
    m_fft(new Tapir::FFT(Tapir::Config::SAMPLE_LENGTH_EACH_SYMBOL))
    { };

    SignalGenerator::~SignalGenerator()
    {
        delete [] m_input;
        delete [] m_encoded;
        delete [] m_interleaved;
        delete [] m_modulated.realp;
        delete [] m_modulated.imagp;
        delete [] m_pilotAdded.realp;
        delete [] m_pilotAdded.imagp;
        delete [] m_extended.realp;
        delete [] m_extended.imagp;
        delete [] m_ifftData.realp;
        delete [] m_ifftData.imagp;
        
        delete m_pilotMgr;
        delete m_modulator;
        delete m_encoder;
        delete m_interleaver;
        delete m_filter;
        delete m_fft;
    };
    
    int SignalGenerator::calResultLength(int strLength)
    {
        int retVal = Tapir::Config::PREAMBLE_SAMPLE_LENGTH * 2 + Tapir::Config::SAMPLE_LENGTH_INTERVAL_AFTER_PREAMBLE
        + (Tapir::Config::SAMPLE_LENGTH_EACH_SYMBOL_WITH_EXTENSION + Tapir::Config::SAMPLE_LENGTH_GUARD_INTERVAL) * strLength
        - Tapir::Config::SAMPLE_LENGTH_GUARD_INTERVAL + Tapir::Config::FILTER_GUARD_LENGTH * 2;
        
        return retVal;
    };
    
    void SignalGenerator::generatePreamble(float *dest)
    {
        const int &lenPreamble = Tapir::Config::PREAMBLE_SAMPLE_LENGTH;
        
        TapirDSP::SplitComplex preamble;
        preamble.realp = new float[lenPreamble * 2];
        preamble.imagp = new float[lenPreamble * 2]();
        
        int lenForEachBit = (floor)(lenPreamble / Tapir::Config::PREAMBLE_BIT_LENGTH);
        for(int i=0; i<Tapir::Config::PREAMBLE_BIT_LENGTH ; ++i)
        {
            TapirDSP::vfill(Tapir::Config::PREAMBLE_BITS + i, preamble.realp + (i * lenForEachBit), lenForEachBit);
        }
        // TODO: LPF (for real and imag both)
        
        Tapir::iqModulate(&preamble, dest, lenPreamble, Tapir::Config::AUDIO_SAMPLE_RATE, m_carrier);
        
        Tapir::maximizeSignal(dest, dest, lenPreamble, Tapir::Config::AUDIO_MAX_VOLUME);
        TapirDSP::copy(dest, dest + lenPreamble, dest + lenPreamble);
        
        delete [] preamble.realp;
        delete [] preamble.imagp;
    };
    
    void SignalGenerator::encodeOneChar(const char src, float *dest)
    {
        //Char to Int Array

        Tapir::divdeIntIntoBits((int)src, m_input, Tapir::Config::DATA_BIT_LENGTH);
        //Convolutional Encoding
        m_encoder->encode(m_input, m_encoded, Tapir::Config::DATA_BIT_LENGTH);
        //Interleaver
        m_interleaver->interleave(m_encoded, m_interleaved);
        //Modulation
        m_modulator->modulate(m_interleaved, &m_modulated, Tapir::Config::NO_DATA_SUBCARRIERS);
        
        //Add pilot
        m_pilotMgr->addPilot(&m_modulated, &m_pilotAdded, Tapir::Config::NO_DATA_SUBCARRIERS);
        
        
        //reverse each half and extend for ifft
        int firstHalfLength = (floor)(Tapir::Config::NO_TOTAL_SUBCARRIERS / 2);
        int lastHalfLength = Tapir::Config::NO_TOTAL_SUBCARRIERS - firstHalfLength;
        int lastHalfStPoint = Tapir::Config::SAMPLE_LENGTH_EACH_SYMBOL - lastHalfLength;

        TapirDSP::copy(m_pilotAdded.realp, m_pilotAdded.realp + lastHalfLength, m_extended.realp + lastHalfStPoint);
        TapirDSP::copy(m_pilotAdded.imagp, m_pilotAdded.imagp + lastHalfLength, m_extended.imagp + lastHalfStPoint);
        TapirDSP::copy(m_pilotAdded.realp + firstHalfLength, m_pilotAdded.realp + 2 * firstHalfLength, m_extended.realp);
        TapirDSP::copy(m_pilotAdded.imagp + firstHalfLength, m_pilotAdded.imagp + 2 * firstHalfLength, m_extended.imagp);
        
        //ifft
        m_fft->transform(&m_extended, &m_ifftData, Tapir::FFT::INVERSE);
        
        // TODO: LPF (for real and imag both)

        //frequency upconversion
        Tapir::iqModulate(&m_ifftData, dest, Tapir::Config::SAMPLE_LENGTH_EACH_SYMBOL, Tapir::Config::AUDIO_SAMPLE_RATE, m_carrier);
        //prepend and append cyclic prefix
    };
    
    void SignalGenerator::addPrefixAndPostfix(const float *src, float *dest)
    {
        const int &lenCyclicPrefix = Tapir::Config::SAMPLE_LENGTH_CYCLIC_PREFIX;
        const int &lenEachSymbol =Tapir::Config::SAMPLE_LENGTH_EACH_SYMBOL;
        const int &lenCyclicPostfix = Tapir::Config::SAMPLE_LENGTH_CYCLIC_POSTFIX;
        
        if( (dest + lenCyclicPrefix) != src)
        {
            TapirDSP::copy(src, src + lenEachSymbol, dest + lenCyclicPrefix);
        }
        
        TapirDSP::copy(src + lenEachSymbol - lenCyclicPrefix, src + lenEachSymbol, dest);
        TapirDSP::copy(src, src + lenCyclicPostfix, dest + lenCyclicPrefix + lenEachSymbol);
    };
    
    void SignalGenerator::generateSignal(const std::string &inputString, float *dest, int destLength)
    {

        float * destPtr = dest + Tapir::Config::FILTER_GUARD_LENGTH;
        
        //Generate preamble
        generatePreamble(destPtr);
        destPtr += Tapir::Config::PREAMBLE_SAMPLE_LENGTH * 2 + Tapir::Config::SAMPLE_LENGTH_INTERVAL_AFTER_PREAMBLE;
        
        //Convert each char to signal
        int strLen = static_cast<int>(inputString.length());
        const char * cStrInput = inputString.c_str();
        const char * inputChar;
        
        for(int i=0; i< strLen; ++i)
        {
            float * curSymbolPtr = destPtr + Tapir::Config::SAMPLE_LENGTH_CYCLIC_PREFIX;
            inputChar = cStrInput + i;

            encodeOneChar(*(inputChar), curSymbolPtr);
            Tapir::maximizeSignal(curSymbolPtr, curSymbolPtr, Tapir::Config::SAMPLE_LENGTH_EACH_SYMBOL, Tapir::Config::AUDIO_MAX_VOLUME);
            addPrefixAndPostfix(curSymbolPtr, destPtr);
            if( i != strLen - 1 )
            {
                destPtr += Tapir::Config::SAMPLE_LENGTH_EACH_SYMBOL_WITH_EXTENSION + Tapir::Config::SAMPLE_LENGTH_GUARD_INTERVAL;
                //To prevent to access unallocated space.
            }
        }

        m_filter->process(dest, dest, destLength);
        m_filter->clearBuffer();
        Tapir::maximizeSignal(dest, dest, destLength, Tapir::Config::AUDIO_MAX_VOLUME);

    }
    
    
    
    
};
