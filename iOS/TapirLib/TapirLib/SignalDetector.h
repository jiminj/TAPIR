//
//  SignalDetector.h
//  TapirLib
//
//  Created by Jimin Jeon on 1/15/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#ifndef __TapirLib__SignalDetector__
#define __TapirLib__SignalDetector__

#include "Filter.h"

namespace Tapir {
    class SignalDetector
    {
    public:
        SignalDetector(int frameSize);
        void sendFrame(float * frame);
        virtual ~SignalDetector();
    private:
        int m_frameSize;

        float * m_filtered;
        Filter * m_hpf;
        
    };
}
#endif /* defined(__TapirLib__SignalDetector__) */
