//
//  AutoCorrelator.cpp
//  TapirLib
//
//  Created by Jimin Jeon on 1/15/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#include "AutoCorrelator.h"

namespace Tapir {
    AutoCorrelator::AutoCorrelator(const int lag, const float threshold)
    : m_lag(lag), m_threshold(threshold), m_inBuffer(new CircularBuffer<float>(m_lag * 3))
    {
    };
    AutoCorrelator::~AutoCorrelator()
    {
        delete m_inBuffer;
    }
    void AutoCorrelator::clearBuffer()
    {
        m_inBuffer->clear();
    };
    void AutoCorrelator::calCorrelation(const float * newBuf, float * result, const int length)
    {
        m_inBuffer->push(newBuf, length);
        
        const float * backtrackStartPoint;
        const float * lastHalf;
        const float * firstHalf;
        float mag;
        
        for(int i=0; i<length; ++i)
        {
            backtrackStartPoint = m_inBuffer->backtrackFromLast(length - i - 1);
            lastHalf = m_inBuffer->getLastFrom(backtrackStartPoint, m_lag);
            firstHalf = m_inBuffer->getLastFrom(backtrackStartPoint, 2 * m_lag);

            vDSP_dotpr(firstHalf, 1, lastHalf, 1, result+i, length);
            vDSP_svemg(lastHalf, 1, &mag, length);
            vDSP_vsdiv(result, 1, &mag, result, 1, length);
        }
    };
    
    int AutoCorrelator::searchMaximumPoint(const float * data, const int length) const
    {
//        int idx = 0;
//        for(idx=0; idx<length; ++idx)
//        {
//            if(data[idx] > m_threshold)
//            { break; }
//        }
//        
//        if(idx == )
//        { return idx; }
//        
//        float maxVal = data[idx];
//        for(int i=idx; i<length; ++i)
//        {
//            if(data[idx] > maxVal)
//            {
//                
//            }
//        }
        return 0;
    };
    
}