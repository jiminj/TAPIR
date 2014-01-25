//
//  SignalAnalyzer.h
//  TapirLib
//
//  Created by Jimin Jeon on 1/25/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#ifndef __TapirLib__SignalAnalyzer__
#define __TapirLib__SignalAnalyzer__
#include <Accelerate/Accelerate.h>
#include <string>
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
        SignalAnalyzer();
        virtual ~SignalAnalyzer();
        char decodeBlock(const float * signal);
        std::string analyze(float * signal);
        
    private:
        void cutCentralRegion(const DSPSplitComplex * src, DSPSplitComplex * dest, const int signalLength, const int destLength, const int fHalfLength);
                              
        DSPSplitComplex m_convertedSignal;
        DSPSplitComplex m_roiSignal;
        DSPSplitComplex m_estimatedSignal;
        DSPSplitComplex m_pilotRemovedSignal;
        
        float * m_demod;
        float * m_deinterleaved;
        int * m_decoded;
        
        PilotManager * m_pilotMgr;
        LSChannelEstimator * m_chanEstimator;
        MatrixInterleaver * m_interleaver;
        PskModulator * m_modulator;
        ViterbiDecoder * m_decoder;
    };
};


#endif /* defined(__TapirLib__SignalAnalyzer__) */
