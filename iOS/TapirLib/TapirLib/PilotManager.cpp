//
//  PilotManager.cpp
//  TapirLib
//
//  Created by Jimin Jeon on 1/23/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#include "PilotManager.h"

namespace Tapir {
    
    PilotManager::PilotManager(const DSPSplitComplex * pilotData, const int * index, const int length)
    :m_pilotLength(length),
    m_pilotIndex( new int[m_pilotLength] ),
    m_pilotData( { .realp = new float[m_pilotLength], .imagp = new float[m_pilotLength] } )
    {
        memcpy(m_pilotIndex, index, sizeof(int) * m_pilotLength);
        vDSP_zvmov(pilotData, 1, &m_pilotData, 1, m_pilotLength);
    };

    PilotManager::~PilotManager()
    {
        delete m_pilotIndex;
        delete [] m_pilotData.realp;
        delete [] m_pilotData.imagp;
    };
    
    void PilotManager::addPilot(const DSPSplitComplex * src, DSPSplitComplex * dest, const int srcLength)
    {
        //    int * curPilotIdx = pilotIndex;
        int curPilotIdx = 0;
        int srcIdx = 0;
        int destLength = srcLength + m_pilotLength;

        for(int i=0; i< destLength; ++i)
        {
            if(i == m_pilotIndex[curPilotIdx])
            {
                dest->realp[i] = m_pilotData.realp[curPilotIdx];
                dest->imagp[i] = m_pilotData.imagp[curPilotIdx++];
            }
            else
            {
                dest->realp[i] = src->realp[srcIdx];
                dest->imagp[i] = src->imagp[srcIdx++];
            }
        }
    };
    
    void PilotManager::removePilot(const DSPSplitComplex * src, DSPSplitComplex * dest, const int srcLength)
    {
        int *curPilot = m_pilotIndex;
        int destIdx = 0;

        for(int i=0; i<srcLength; ++i)
        {
            if(i == *curPilot)
            { ++curPilot; }
            else
            {
                dest->realp[destIdx] = src->realp[i];
                dest->imagp[destIdx++] = src->imagp[i];
            }
        }
        
    };
    
}
