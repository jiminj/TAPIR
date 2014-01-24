//
//  AutoCorrelator.cpp
//  TapirLib
//
//  Created by Jimin Jeon on 1/15/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#include "AutoCorrelator.h"

namespace Tapir {
    AutoCorrelator::AutoCorrelator(const int bufferSize, const int maxInputLength, const int lag, const float threshold)
    : m_lag(lag),
    m_inBuffer(new CircularQueue<float>(bufferSize, maxInputLength)),
    m_threshold(threshold),
    m_isTracking(false),
    m_tracked(new float[m_lag]),
    m_trackedIdx(0),
    m_resultData(nullptr)
    {
    };
    AutoCorrelator::~AutoCorrelator()
    {
        delete [] m_tracked;
        delete m_inBuffer;
    }
    void AutoCorrelator::reset()
    {
        m_inBuffer->clear();
        std::fill(m_tracked, m_tracked+m_lag, 0);
        m_trackedIdx = 0;
        m_resultData = nullptr;
        m_isTracking = false;
    };

    const float * AutoCorrelator::searchCorrelated(const float * newInput, const int inputLength, int& resultLength)
    {
        m_inBuffer->push(newInput, inputLength);
        
        
        int backTrackLength;
        const float * lastHalf;
        const float * firstHalf;
        float corrResult;
        float mag;
        resultLength = 0;
        
        for(int i=0; i<inputLength; ++i)
        {
            backTrackLength = inputLength - i - 1;
            lastHalf = m_inBuffer->getLast( backTrackLength + m_lag);
            firstHalf = m_inBuffer->getLast( backTrackLength + 2 * m_lag);
            
            vDSP_dotpr(firstHalf, 1, lastHalf, 1, &corrResult, m_lag);
            vDSP_svemg(lastHalf, 1, &mag, m_lag);
            corrResult /= (mag / m_lag);
            corrResult = fabsf(corrResult);

            if((!m_isTracking) && (corrResult > m_threshold))
            {
//                std::cout<<"Orig_CORR : "<<origCorr<<std::endl;
//                std::cout<<"CORR : "<<corrResult<<std::endl;
//                std::cout<<"Mag : "<<(mag / m_lag)<<std::endl;
                m_isTracking = true;
                m_tracked[m_trackedIdx] = corrResult;
                m_resultData = m_inBuffer->getLast(backTrackLength);
            }
            else if(m_isTracking)
            {
                if(++m_trackedIdx < m_lag)
                { m_tracked[m_trackedIdx] = corrResult; }
                else //tracking done
                {
                    unsigned long maxIdx;
                    float maxVal;
                    vDSP_maxvi(m_tracked, 1, &maxVal, &maxIdx, m_lag);
                    m_resultData += maxIdx;
//                    std::cout<<"MAX Corr val : "<<maxVal<<std::endl;
                    if(m_resultData > m_inBuffer->getLast())
                    {
                        m_resultData -= m_inBuffer->getQueueSize();
                    }
                    resultLength = static_cast<int>(m_inBuffer->getLast() - m_resultData + 1);
//                    std::cout<<"Mag : "<<mag<<std::endl;
                    return m_resultData;
                }
            }
        }
        return nullptr;
    };

 }