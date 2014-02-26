//
//  SignalDetector.h
//  TapirLib
//
//  Created by Jimin Jeon on 1/15/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#ifndef __TapirLib__SignalDetector__
#define __TapirLib__SignalDetector__

#include "Config.h"
#include "Filter.h"
#include "AutoCorrelator.h"
#include <tr1/functional>
#include <iostream>

namespace Tapir {
    
    class SignalDetector
    {
    public:
        SignalDetector(const int frameSize, const float correlationThreshold, std::tr1::function<void(float *)> callback);
        virtual ~SignalDetector();
        
        void detect(const float * frame);
        void clear();
        
        float * getLastResult() { return m_result; };
        int getAudioBufferLength() { return m_resultLength; };
        
    protected:
        int m_frameSize;
        
        float * m_filtered;
        
        int m_copyIdx;
        int m_resultLength;
        float * m_result;

        Filter * m_hpf;

        AutoCorrelator m_correlator;
        int m_corrBufferLength;
        bool m_isSignalFound;


        std::tr1::function<void(float *)> m_callback;
    };
}
#endif /* defined(__TapirLib__SignalDetector__) */
