//
//  AutoCorrelator.h
//  TapirLib
//
//  Created by Jimin Jeon on 1/15/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#ifndef __TapirLib__AutoCorrelator__
#define __TapirLib__AutoCorrelator__
#include "CircularBuffer.h"
#include <Accelerate/Accelerate.h>

namespace Tapir {
    
    static const int kNumCorrBufferBlocks = 2;
    class AutoCorrelator
    {
    public:
        AutoCorrelator(const int lag, const float threshold);
        virtual ~AutoCorrelator();
        void calCorrelation(const float * newBuf, float * result, const int length);
        int searchMaximumPoint(const float * data, const int length) const;
        void clearBuffer();
        
    protected:

        int m_lag;
        float m_threshold;
        CircularBuffer<float> * m_inBuffer;
    };

}


#endif /* defined(__TapirLib__AutoCorrelator__) */
