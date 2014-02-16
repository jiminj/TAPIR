//
//  SignalAnalyzer.h
//  TapirLib
//
//  Created by Jimin Jeon on 1/25/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#ifndef __TapirLib__SignalAnalyzer__
#define __TapirLib__SignalAnalyzer__


#include <string>
#include "TapirDSP.h"
#include "Config.h"
#include "ChannelEstimator.h"
#include "Interleaver.h"
#include "Modulator.h"
#include "Decoder.h"
#include "Utilities.h"

namespace Tapir {
    class SignalAnalyzer
    {
    public:
        SignalAnalyzer(float carrierFreq);
        virtual ~SignalAnalyzer();
        char decodeBlock(const float * signal);
        std::string analyze(float * signal);
        void setFreqOffset(float freqOffset)
        { m_carrier = Config::CARRIER_FREQUENCY_BASE + freqOffset;};
        
    private:
        void cutCentralRegion(const TapirDSP::SplitComplex * src, TapirDSP::SplitComplex * dest, const int signalLength, const int destLength, const int firstHalfLength);
                              
        TapirDSP::SplitComplex m_convertedSignal;
        TapirDSP::SplitComplex m_roiSignal;
        TapirDSP::SplitComplex m_estimatedSignal;
        TapirDSP::SplitComplex m_pilotRemovedSignal;
        
        float m_carrier;
        float * m_demod;
        float * m_deinterleaved;
        int * m_decoded;
        
        PilotManager * m_pilotMgr;
        LSChannelEstimator * m_chanEstimator;
        MatrixInterleaver * m_interleaver;
        PskModulator * m_modulator;
        ViterbiDecoder * m_decoder;
        FFT * m_fft;
    };
};


#endif /* defined(__TapirLib__SignalAnalyzer__) */
