//
//  SignalAnalyzer.cpp
//  TapirLib
//
//  Created by Jimin Jeon on 1/25/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#include "../include/SignalAnalyzer.h"

namespace Tapir{
    SignalAnalyzer::SignalAnalyzer(float carrierFreq)
    :m_carrier(carrierFreq),
    m_convertedSignal({.realp=new float[Config::SAMPLE_LENGTH_EACH_SYMBOL], .imagp=new float[Config::SAMPLE_LENGTH_EACH_SYMBOL] }),
    m_roiSignal({.realp =new float[Config::NO_TOTAL_SUBCARRIERS], .imagp=new float[Config::NO_TOTAL_SUBCARRIERS]}),
    m_estimatedSignal({.realp =new float[Config::NO_TOTAL_SUBCARRIERS], .imagp=new float[Config::NO_TOTAL_SUBCARRIERS]}),
    m_pilotRemovedSignal({.realp =new float[Config::NO_DATA_SUBCARRIERS], .imagp=new float[Config::NO_DATA_SUBCARRIERS]}),
    m_demod(new float[Config::NO_DATA_SUBCARRIERS]),
    m_deinterleaved(new float[Config::NO_DATA_SUBCARRIERS]),
    m_decoded(new int[Config::DATA_BIT_LENGTH]),
    m_pilotMgr(new PilotManager(&(Config::PILOT_DATA), Config::PILOT_LOCATIONS, Config::NO_PILOT_SUBCARRIERS)),
    m_chanEstimator(new LSChannelEstimator(m_pilotMgr, Config::NO_TOTAL_SUBCARRIERS)),
    m_interleaver(new MatrixInterleaver(Config::INTERLEAVER_ROWS, Config::INTERLEAVER_COLS)),
    m_modulator(new PskModulator(Config::MODULATION_RATE)),
    m_decoder(new ViterbiDecoder(Config::TRELLIS_ARRAY)),
    m_fft(new Tapir::FFT(Tapir::Config::SAMPLE_LENGTH_EACH_SYMBOL))
    { };
    
    SignalAnalyzer::~SignalAnalyzer()
    {
        delete [] m_convertedSignal.realp;
        delete [] m_convertedSignal.imagp;
        delete [] m_roiSignal.realp;
        delete [] m_roiSignal.imagp;
        delete [] m_estimatedSignal.realp;
        delete [] m_estimatedSignal.imagp;
        delete [] m_pilotRemovedSignal.realp;
        delete [] m_pilotRemovedSignal.imagp;
        delete [] m_demod;
        delete [] m_deinterleaved;
        delete [] m_decoded;

        delete m_pilotMgr;
        delete m_chanEstimator;
        delete m_interleaver;
        delete m_modulator;
        delete m_decoder;
        delete m_fft;
    };
    
    void SignalAnalyzer::cutCentralRegion(const TapirDSP::SplitComplex *src, TapirDSP::SplitComplex *dest, const int signalLength, const int destLength, const int firstHalfLength)
    {
        int lastHalfCutLength = destLength - firstHalfLength;
        int sigLastHalfStIndex = signalLength - lastHalfCutLength;

        
        TapirDSP::copy(src->realp + sigLastHalfStIndex, src->realp + sigLastHalfStIndex + lastHalfCutLength, dest->realp);
        TapirDSP::copy(src->imagp + sigLastHalfStIndex, src->imagp + sigLastHalfStIndex + lastHalfCutLength, dest->imagp);
        TapirDSP::copy(src->realp, src->realp + firstHalfLength, dest->realp + lastHalfCutLength);
        TapirDSP::copy(src->imagp, src->imagp + firstHalfLength, dest->imagp + lastHalfCutLength);
        
        
    };
    
    char SignalAnalyzer::decodeBlock(const float *signal)
    {
        //Freq Downconversion & FFT, and cut central spectrum region
        Tapir::iqDemodulate(signal, &m_convertedSignal, Tapir::Config::SAMPLE_LENGTH_EACH_SYMBOL, Tapir::Config::AUDIO_SAMPLE_RATE, m_carrier);
        // TODO: LPF (for real & imag both)
        
        //FFT
        m_fft->transform(&m_convertedSignal, &m_convertedSignal, Tapir::FFT::FORWARD);
        cutCentralRegion(&m_convertedSignal, &m_roiSignal, Config::SAMPLE_LENGTH_EACH_SYMBOL, Config::NO_TOTAL_SUBCARRIERS, Config::NO_TOTAL_SUBCARRIERS/2);

        //Channel Estimation
        m_chanEstimator->estimateChannel(&m_roiSignal, &m_estimatedSignal);
        
        //Pilot Remove
        m_pilotMgr->removePilot(&m_estimatedSignal, &m_pilotRemovedSignal, Config::NO_TOTAL_SUBCARRIERS);
        
        //Demodulation
        m_modulator->demodulate(&m_pilotRemovedSignal, m_demod, Config::NO_DATA_SUBCARRIERS);
        
        //Deinterleaver
        m_interleaver->deinterleave(m_demod, m_deinterleaved);
        
        // Viterbi Decoding
        m_decoder->decode(m_deinterleaved, m_decoded, Config::NO_DATA_SUBCARRIERS);
        
        return  static_cast<char>(mergeBitsToIntegerValue(m_decoded, Config::DATA_BIT_LENGTH));
    };
    
    std::string SignalAnalyzer::analyze(float *signal)
    {
        std::string result("");
        
        int maxSymbolLength = Tapir::Config::MAX_SYMBOL_LENGTH;
        int symbolWithGuardIntervalSize = Tapir::Config::SAMPLE_LENGTH_GUARD_INTERVAL + Tapir::Config::SAMPLE_LENGTH_EACH_SYMBOL_WITH_EXTENSION;
        int cyclicPrefixLength = Tapir::Config::SAMPLE_LENGTH_CYCLIC_PREFIX;
        
        //skip preambleInterval
        float * ptr = signal + Tapir::Config::SAMPLE_LENGTH_INTERVAL_AFTER_PREAMBLE;
        for(int i=0;i < maxSymbolLength; ++i)
        {
            float * curSymbol = (ptr + cyclicPrefixLength);
            char decodedChar = decodeBlock(curSymbol);
            if(decodedChar == ASCII_ETX) { break; }
            else
            {
                result += decodedChar;
            }
            
            if( i != maxSymbolLength)
            {
                ptr += symbolWithGuardIntervalSize;
            }
        }
        return result;
    };
    
};
