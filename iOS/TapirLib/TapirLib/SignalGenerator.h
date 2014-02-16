//
//  SignalGenerator.h
//  TapirLib
//
//  Created by Jimin Jeon on 1/25/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#ifndef __TapirLib__SignalGenerator__
#define __TapirLib__SignalGenerator__

#include "TapirDSP.h"
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
        SignalGenerator(float carrierFreq);
        ~SignalGenerator();
        
        void generateSignal(const std::string& inputString, float * dest, int destLength);

        int calResultLength(int strLength);
        int calResultLength(const std::string& string)
        { return calResultLength(static_cast<int>( string.length() ) ); };
        
    private:
        void generatePreamble(float * dest);
        void encodeOneChar(const char src, float * dest);
        void addPrefixAndPostfix(const float * src, float * dest);
        
        float m_carrier;
        int * m_input;
        float * m_encoded;
        float * m_interleaved;

        
        TapirDSP::SplitComplex m_modulated;
        TapirDSP::SplitComplex m_pilotAdded;
        TapirDSP::SplitComplex m_extended;
        TapirDSP::SplitComplex m_ifftData;
        
        PilotManager * m_pilotMgr;
        PskModulator * m_modulator;
        ConvEncoder * m_encoder;
        MatrixInterleaver * m_interleaver;
        FilterFIR * m_filter;
        FFT * m_fft;
    };
}

#endif /* defined(__TapirLib__SignalGenerator__) */
