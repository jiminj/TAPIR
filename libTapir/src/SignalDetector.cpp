//
//  SignalDetector.cpp
//  TapirLib
//
//  Created by Jimin Jeon on 1/15/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#include "../include/SignalDetector.h"
#include <tr1/functional>

namespace Tapir {
    SignalDetector::SignalDetector(const int frameSize, const float correlationThreshold, std::tr1::function<void(float *)> callback)
    : m_frameSize(frameSize),
    m_filtered( new float[m_frameSize]() ),
    m_copyIdx(0),
    m_resultLength(Config::LENGTH_INPUT_BUFFER),
    m_result( new float[m_resultLength]() ),
    m_hpf(Tapir::FilterCreator::create(frameSize, Tapir::FilterCreator::HAMMING_19k_50)),
    m_correlator(frameSize * 3, frameSize, Config::PREAMBLE_SAMPLE_LENGTH, correlationThreshold),
    m_corrBufferLength(Config::PREAMBLE_SAMPLE_LENGTH),
    m_isSignalFound(false),
    m_callback(callback)
    {
        std::cout<<"Result Length : " <<m_resultLength<<std::endl;
        std::cout<<"FrameSize :" <<m_frameSize<<std::endl;
        std::cout<<"Correlation Buffer Length : "<<m_corrBufferLength<<std::endl;
    };
    
    void SignalDetector::detect(const float * frame)
    {
        m_hpf->process(frame, m_filtered, m_frameSize);
        m_filtered = const_cast<float *>(frame);
        
        if(!m_isSignalFound) //not yet found
        {
            int firstBlkSize = 0;
            const float * foundDataFirstBlk = m_correlator.searchCorrelated(m_filtered, m_frameSize, firstBlkSize);
            if(foundDataFirstBlk != nullptr) //found!
            {
                TapirDSP::copy(foundDataFirstBlk, foundDataFirstBlk + firstBlkSize, m_result);
                m_copyIdx = firstBlkSize;
                m_isSignalFound = true;
            }
        }
        else
        {
            int remained = m_resultLength - m_copyIdx;
            if(remained > 0)
            {
                int cpSize = (remained > m_frameSize) ? m_frameSize : remained;
                TapirDSP::copy(frame, frame + cpSize, m_result + m_copyIdx);
                m_copyIdx += cpSize;
            }
            else //copy end
            {
                std::cout<<"Detected from SignalDetector!"<<std::endl;
                m_callback(m_result);
                //alert!
            }
        }
    };
    
    void SignalDetector::clear()
    {
        std::fill(m_result, m_result + m_resultLength, 0);
        std::fill(m_filtered, m_filtered + m_frameSize, 0);

        m_hpf->clearBuffer();
        m_correlator.reset();
        m_copyIdx = 0;
        m_isSignalFound = false;
    }
    
    SignalDetector::~SignalDetector()
    {
        delete [] m_filtered;
        delete [] m_result;
        
        delete m_hpf;
    };
    
    
}
