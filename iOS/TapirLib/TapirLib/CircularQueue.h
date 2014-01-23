//
//  CircularQueue.h
//  TapirLib
//
//  Created by Jimin Jeon on 1/15/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#ifndef __TapirLib__CircularQueue__
#define __TapirLib__CircularQueue__
#include <algorithm>

namespace Tapir {
    
    template<typename _T>
    class CircularQueue
    {
    public:
        CircularQueue(int queueSize, int bufferSize);
        virtual ~CircularQueue();
        const _T * push(const _T data);
        const _T * push(const _T * data, const int size);

        const _T * getLast() const { return m_last; };
        const _T * getLast(int length);

        const _T * getLastFrom(const _T * btStartPoint, int length);
        const _T * getQueue() { return m_queue;};
        int getQueueSize() { return m_queueSize;};
        
//        void status();
        void clear();

        
    protected:
        const int m_queueSize;
        const int m_bufferSize;
        int m_lastIdx;
        int m_bufferSavedStIdx;
        
        _T * m_realQueue;
        _T * const m_queue;
        
        _T * m_end;
        
        _T * m_bufferSavedStPos;
        _T * m_last;

    };

    template<typename _T>
    CircularQueue<_T>::CircularQueue(int queueSize, int bufferSize)
    :m_queueSize(queueSize),
    m_bufferSize(bufferSize),
    m_lastIdx(-1),
    m_bufferSavedStIdx(queueSize - bufferSize),
    m_realQueue(new _T[m_queueSize + bufferSize]()),
    m_queue(m_realQueue + bufferSize),
    m_end(m_queue + queueSize - 1),
    m_bufferSavedStPos(m_queue + queueSize - bufferSize),
    m_last(m_queue - 1)
    {
    };

    template<typename _T>
    CircularQueue<_T>::~CircularQueue()
    {
        delete [] m_realQueue;
    };

    
    template<typename _T>
    const _T * CircularQueue<_T>::push(const _T data)
    {
        return push(&data, 1);
    };

    template<typename _T>
    const _T * CircularQueue<_T>::push(const _T * data, const int size)
    {
        int  pushSize = size;
        const _T * pushData = data;
        
        _T * pushStPos = m_last + 1;
        int pushStIdx = m_lastIdx + 1;
        if(pushStPos > m_end)
        {
            pushStPos = m_queue;
            pushStIdx = 0;
        }
        
        int remainedQueueLength = m_queueSize - pushStIdx;
        if(remainedQueueLength >= pushSize)
        {
            memcpy(pushStPos, pushData, sizeof(_T) * pushSize);
            m_lastIdx = pushStIdx + pushSize - 1;
            m_last = pushStPos + pushSize - 1;
            
            //copy to buffer
            if( m_lastIdx >= m_bufferSavedStIdx)
            {
                _T * bufCopyStartPos;
                int bufCopyStartIdx;
                if( pushStIdx > m_bufferSavedStIdx)
                {
                    bufCopyStartPos = pushStPos;
                    bufCopyStartIdx = pushStIdx;
                }
                else
                {
                    bufCopyStartPos = m_bufferSavedStPos;
                    bufCopyStartIdx = m_bufferSavedStIdx;
                }
                int bufCopySize = m_lastIdx - bufCopyStartIdx + 1;
                
                memcpy(m_queue - (m_queueSize - bufCopyStartIdx), bufCopyStartPos, sizeof(_T) * bufCopySize);
            }
            
        }
        else // longer than remained length
        {
             // only copy the length of queue, when new data size is larger than queue size
            if( pushSize > m_queueSize)
            {
                pushStIdx = (pushSize - remainedQueueLength) % m_queueSize;
                pushData = pushData + pushSize - m_queueSize;
                pushSize = m_queueSize;
                remainedQueueLength = pushSize - pushStIdx;
            }

            int firstHalfLength = pushSize - remainedQueueLength;
            memcpy(m_queue + pushStIdx, pushData, sizeof(_T) * remainedQueueLength); //copy last half
            memcpy(m_queue, pushData + remainedQueueLength, sizeof(_T) * firstHalfLength); //copy first half

            //copy for buffer
            int bufCopyStIdx;
            _T * bufCopyStPos;
            if(pushStIdx > m_bufferSavedStIdx)
            {
                bufCopyStPos = pushStPos;
                bufCopyStIdx = pushStIdx;
            }
            else
            {
                bufCopyStPos = m_bufferSavedStPos;
                bufCopyStIdx = m_bufferSavedStIdx;
            }
            int bufCopySize = m_queueSize - bufCopyStIdx;
            
            memcpy(m_queue - bufCopySize, pushStPos, sizeof(_T) * bufCopySize); //copy
            
            m_last = m_queue + firstHalfLength - 1;
            m_lastIdx = firstHalfLength - 1;

        }
        return m_last;
        
    };
    
    template<typename _T>
    const _T * CircularQueue<_T>::getLast(int length)
    {
        return getLastFrom(m_last, length);
    };
    template<typename _T>
    const _T * CircularQueue<_T>::getLastFrom(const _T * btStartPoint, int length)
    {
        const _T * ret = btStartPoint - length;
        
        if(ret < m_realQueue)
        { return ret + m_queueSize; }
        else
        { return ret; }
    };
    
    
    template<typename _T>
    void CircularQueue<_T>::clear()
    {
        std::fill(m_realQueue, m_queue + m_queueSize, 0);
        m_last = m_queue - 1;
        m_lastIdx = 0;
    };
//
//    template<typename _T>
//    void CircularQueue<_T>::status()
//    {
//        for(int i= - m_bufferSize; i<0; ++i)
//        {
//            std::cout<<*(m_queue+i)<<"\t";
//        }
//        std::cout<<"||\t";
//        for(int i=0; i<m_queueSize; ++i)
//        {
//            std::cout<<*(m_queue+i)<<"\t";
//        }
//        std::cout<<"("<<*m_last<<")["<<m_lastIdx<<"]";
//        std::cout<<std::endl;
//    };
};



#endif /* defined(__TapirLib__CircularQueue__) */
