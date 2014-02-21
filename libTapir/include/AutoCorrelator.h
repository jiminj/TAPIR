//
//  AutoCorrelator.h
//  TapirLib
//
//  Created by Jimin Jeon on 1/15/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#ifndef __TapirLib__AutoCorrelator__
#define __TapirLib__AutoCorrelator__
#include "CircularQueue.h"
#include "TapirDSP.h"
#include <vector>
#include <cmath>

namespace Tapir {

    class AutoCorrelator
    {
    public:
        AutoCorrelator(const int bufferSize, const int maxInputLength, const int lag, const float threshold);
        virtual ~AutoCorrelator();
        const float * searchCorrelated(const float * newInput, const int inputLength, int& resultLength);
        void reset();
        
    protected:
        AutoCorrelator(const AutoCorrelator&) = delete;
        int     m_lag;
        CircularQueue<float> * m_inBuffer;
        
        float m_threshold;
        bool m_isTracking;
        float * m_tracked;
        int m_trackedIdx;
        
        const float * m_resultData;
        
    };

}


#endif /* defined(__TapirLib__AutoCorrelator__) */
