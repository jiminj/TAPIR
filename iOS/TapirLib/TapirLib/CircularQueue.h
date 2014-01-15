//
//  CircularQueue.h
//  TapirLib
//
//  Created by Jimin Jeon on 1/15/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#ifndef __TapirLib__CircularQueue__
#define __TapirLib__CircularQueue__

#include <iostream>

namespace Tapir {
    
    template<typename _T>
    class CircularQueue
    {
    public:
        CircularQueue(int queueSize);
        virtual ~CircularQueue();
        const _T * getEndOfQueue() { return m_end; };
        const _T * getLast() { return m_last; };
      
        const _T * push(const _T data);
        const _T * push(const _T * data, const int size);

//        void status();
        
    protected:
        int m_queueSize;
        int m_lastIdx;
        
        _T * m_queue;
        _T * m_end;
        _T * m_last;

    };

    template<typename _T>
    CircularQueue<_T>::CircularQueue(int queueSize)
    :m_queueSize(queueSize), m_lastIdx(-1), m_queue(new _T[m_queueSize]()), m_end(m_queue + queueSize - 1), m_last(m_queue - 1)
    {};

    template<typename _T>
    CircularQueue<_T>::~CircularQueue()
    {
        delete [] m_queue;
    };
    
    template<typename _T>
    const _T * CircularQueue<_T>::push(const _T data)
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
        return m_last;
    };

    template<typename _T>
    const _T * CircularQueue<_T>::push(const _T * data, const int size)
    {
        int  cpSize = size;
        _T * cpData = const_cast<_T *>(data);
        
        int remainedQueueLength = m_queueSize - m_lastIdx - 1;
        if(remainedQueueLength >= cpSize)
        {
            memcpy(m_last+1, cpData, sizeof(_T) * cpSize);
            m_last += cpSize;
            m_lastIdx += cpSize;
            
        }
        else
        {
            int stOffset = m_lastIdx+1;
             // only copy the length of queue, when new data size is larger than queue size
            if( cpSize > m_queueSize)
            {
                stOffset = (cpSize - remainedQueueLength) % m_queueSize;
                cpData = cpData + cpSize - m_queueSize;
                cpSize = m_queueSize;
                remainedQueueLength = cpSize - stOffset;

            }

            int firstHalfLength = cpSize - remainedQueueLength;
            memcpy(m_queue + stOffset, cpData, sizeof(_T) * remainedQueueLength);
            memcpy(m_queue, cpData + remainedQueueLength, sizeof(_T) * (cpSize - remainedQueueLength));
            
            m_last = m_queue + firstHalfLength - 1;
            m_lastIdx = firstHalfLength - 1;

        }
        return m_last;
        
    }
    
//    
//    template<typename _T>
//    void CircularQueue<_T>::status()
//    {
//        for(int i=0; i<m_queueSize; ++i)
//        {
//            std::cout<<*(m_queue+i)<<"\t";
//        }
//        std::cout<<"("<<*m_last<<")["<<m_lastIdx<<"]";
//        std::cout<<std::endl;
//    }
//    
};



#endif /* defined(__TapirLib__CircularQueue__) */
