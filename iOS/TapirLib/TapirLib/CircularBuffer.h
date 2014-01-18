//
//  CircularBuffer.h
//  TapirLib
//
//  Created by Jimin Jeon on 1/15/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#ifndef __TapirLib__CircularBuffer__
#define __TapirLib__CircularBuffer__

#include <iostream>

namespace Tapir {
    
    template<typename _T>
    class CircularBuffer
    {
    public:
        CircularBuffer(int queueSize);
        virtual ~CircularBuffer();
        const _T * push(const _T data);
        const _T * push(const _T * data, const int size);

        const _T * getLast() const { return m_last; };
        const _T * getLast(int length);
        const _T * backtrackFromLast(int length) { if(length > m_queueSize) { return nullptr; } return m_last - length; };
        const _T * getLastFrom(const _T * btStartPoint, int length);
        
        void status();
        void clear();
        
    protected:
        int m_queueSize;
        int m_lastIdx;
        
        _T * m_realQueue;
        _T * const m_queue;
        _T * m_end;
        _T * m_last;

    };

    template<typename _T>
    CircularBuffer<_T>::CircularBuffer(int queueSize)
    :m_queueSize(queueSize),
    m_lastIdx(-1),
    m_realQueue(new _T[m_queueSize * 2]()),
    m_queue(m_realQueue + m_queueSize),
    m_end(m_queue + queueSize - 1),
    m_last(m_queue - 1)
    {};

    template<typename _T>
    CircularBuffer<_T>::~CircularBuffer()
    {
        delete [] m_realQueue;
    };
    
    template<typename _T>
    const _T * CircularBuffer<_T>::push(const _T data)
    {
        if(m_last == m_end)
        {
            m_last = m_queue;
            m_lastIdx = 0;
            
            *m_last = data;
        }
        else
        {
            *(++m_last) = data;
            ++m_lastIdx;
        }
        memcpy(m_last - m_queueSize, m_last, sizeof(_T));
        return m_last;
    };

    template<typename _T>
    const _T * CircularBuffer<_T>::push(const _T * data, const int size)
    {
        int  cpSize = size;
        _T * cpData = const_cast<_T *>(data);
        
        int remainedQueueLength = m_queueSize - m_lastIdx - 1;
        if(remainedQueueLength >= cpSize)
        {
            memcpy(m_last+1, cpData, sizeof(_T) * cpSize);
            memcpy(m_queue - cpSize, cpData, sizeof(_T) * cpSize);
            m_last += cpSize;
            m_lastIdx += cpSize;
            
        }
        else
        {
            int stOffset = m_lastIdx+1;
            if(stOffset >= m_queueSize)
            { stOffset = 0; }
            
             // only copy the length of queue, when new data size is larger than queue size
            if( cpSize > m_queueSize)
            {
                stOffset = (cpSize - remainedQueueLength) % m_queueSize;
                cpData = cpData + cpSize - m_queueSize;
                cpSize = m_queueSize;
                remainedQueueLength = cpSize - stOffset;
            }

            int firstHalfLength = cpSize - remainedQueueLength;
//            std::cout<<"firstHalfLength :"<<firstHalfLength<<" stOffset :"<<stOffset<<" remained:"<<remainedQueueLength<<std::endl;
            memcpy(m_queue + stOffset, cpData, sizeof(_T) * remainedQueueLength); //copy last half
            memcpy(m_queue, cpData + remainedQueueLength, sizeof(_T) * firstHalfLength); //copy first half

            //do the same for mirrored-buffer
            memcpy(m_realQueue + stOffset, cpData, sizeof(_T) * remainedQueueLength); //copy last half
            memcpy(m_realQueue, cpData + remainedQueueLength, sizeof(_T) * firstHalfLength); //copy first half
            
            m_last = m_queue + firstHalfLength - 1;
            m_lastIdx = firstHalfLength - 1;

        }
        return m_last;
        
    };
    
    template<typename _T>
    const _T * CircularBuffer<_T>::getLast(int length)
    {
        return getLastFrom(m_last, nullptr);
    };
    template<typename _T>
    const _T * CircularBuffer<_T>::getLastFrom(const _T * btStartPoint, int length)
    {
        if(length > m_queueSize)
        { return nullptr; };
        
        return btStartPoint - length + 1;
    };
    
    template<typename _T>
    void CircularBuffer<_T>::clear()
    {
        std::fill(m_queue, m_queue + m_queueSize, 0);
        m_last = m_queue;
        m_lastIdx = 0;
    };
    
    template<typename _T>
    void CircularBuffer<_T>::status()
    {
        for(int i=-m_queueSize; i<m_queueSize; ++i)
        {
            std::cout<<*(m_queue+i)<<"\t";
        }
        std::cout<<"("<<*m_last<<")["<<m_lastIdx<<"]";
        std::cout<<std::endl;
    };
};



#endif /* defined(__TapirLib__CircularQueue__) */
