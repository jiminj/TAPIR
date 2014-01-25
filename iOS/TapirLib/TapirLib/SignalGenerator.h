//
//  SignalGenerator.h
//  TapirLib
//
//  Created by Jimin Jeon on 1/25/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#ifndef __TapirLib__SignalGenerator__
#define __TapirLib__SignalGenerator__

#include <Accelerate/Accelerate.h>

#include "Config.h"
#include "PilotManager.h"
#include "Modulator.h"
#include "Encoder.h"
#include "Interleaver.h"
#include "Filter.h"
#include "Utilities.h"

namespace Tapir {

    class SignalGenerator
    {
    public:
        SignalGenerator(float freqOffset = 0.f);
        ~SignalGenerator();
        
        void generateSignal(const std::string& inputString, float * dest, int destLength);

        int calResultLength(int strLength);
        int calResultLength(const std::string& string)
        { return calResultLength(static_cast<int>( string.length() ) ); };
        void setFreqOffset(float freqOffset)
        { m_carrier = Config::CARRIER_FREQUENCY_BASE + freqOffset;};
        
    private:
        void generatePreamble(float * dest);
        void encodeOneChar(const char src, float * dest);
        void addPrefixAndPostfix(const float * src, float * dest);
        
        float m_carrier;
        int * m_input;
        float * m_encoded;
        float * m_interleaved;

        
        DSPSplitComplex m_modulated;
        DSPSplitComplex m_pilotAdded;
        DSPSplitComplex m_extended;
        DSPSplitComplex m_ifftData;
        
        PilotManager * m_pilotMgr;
        PskModulator * m_modulator;
        ConvEncoder * m_encoder;
        MatrixInterleaver * m_interleaver;
        FilterFIR * m_filter;
    };
}

#endif /* defined(__TapirLib__SignalGenerator__) */
