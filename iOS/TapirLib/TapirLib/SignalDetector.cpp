//
//  SignalDetector.cpp
//  TapirLib
//
//  Created by Jimin Jeon on 1/15/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#include "SignalDetector.h"

namespace Tapir {
    SignalDetector::SignalDetector(int frameSize)
    : m_frameSize(frameSize),
    m_filtered(new float[m_frameSize]()),
    m_hpf(Tapir::TapirFilters::getTxRxHpf(frameSize))
    {
    };
    
    void SignalDetector::sendFrame(float * frame)
    {
        m_hpf->process(frame, m_filtered, m_frameSize);
    }
    
    SignalDetector::~SignalDetector()
    {
        delete [] m_filtered;
        delete m_hpf;
    }
    
    
}