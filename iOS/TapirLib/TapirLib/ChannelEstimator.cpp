//
//  ChannelEstimator.cpp
//  TapirLib
//
//  Created by Jimin Jeon on 1/23/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#include "ChannelEstimator.h"

namespace Tapir {

    LSChannelEstimator::LSChannelEstimator(PilotManager * pilot, const int chLength)
    : m_pilotInfo(pilot),
    m_chLength(chLength),
    m_pilotIdx(new float[m_pilotInfo->getPilotLength()]),
    m_channel({.realp = new float[m_chLength], .imagp = new float[m_chLength]}),
    m_pilotRcvSignal({.realp = new float[m_pilotInfo->getPilotLength()], .imagp = new float[m_pilotInfo->getPilotLength()]}),
    m_pilotChannel({.realp = new float[m_pilotInfo->getPilotLength()], .imagp = new float[m_pilotInfo->getPilotLength()]})
    {
        vDSP_vflt32(m_pilotInfo->getPilotIndex(), 1, m_pilotIdx, 1, m_pilotInfo->getPilotLength());
    };

    LSChannelEstimator::~LSChannelEstimator()
    {
        delete [] m_pilotIdx;
        delete [] m_channel.realp;
        delete [] m_channel.imagp;
        delete [] m_pilotRcvSignal.realp;
        delete [] m_pilotRcvSignal.imagp;
        delete [] m_pilotChannel.realp;
        delete [] m_pilotChannel.imagp;
    };
    
    void LSChannelEstimator::estimateChannel(const DSPSplitComplex *src, DSPSplitComplex *dest)
    {
        //Save Pilot Value
        const DSPSplitComplex * pilotData = m_pilotInfo->getPilotData();
        vDSP_vindex(src->realp, m_pilotIdx, 1, m_pilotRcvSignal.realp, 1, m_pilotInfo->getPilotLength() );
        vDSP_vindex(src->imagp, m_pilotIdx, 1, m_pilotRcvSignal.imagp, 1, m_pilotInfo->getPilotLength() );
        vDSP_zvdiv(pilotData, 1, &m_pilotRcvSignal, 1, &m_pilotChannel, 1, m_pilotInfo->getPilotLength());
        
        generateChannel(&m_pilotChannel);

        //Conjugate and multiply
        vDSP_zvconj(&m_channel, 1, &m_channel, 1, m_chLength);
        vDSP_zvmul(src, 1, &m_channel, 1, dest, 1, m_chLength, 1 );
        
    };
    void LSChannelEstimator::generateChannel(const DSPSplitComplex *pilotChannel)
    {
        bool isFirstElemAdded = false;
        bool isLastElemAdded = false;
        int pilotLength = m_pilotInfo->getPilotLength();
        int extLength = pilotLength;
        const int * pilotIndex = m_pilotInfo->getPilotIndex();
        
        if(pilotIndex[0] != 0)
        {
            isFirstElemAdded = true;
            ++extLength;
        }
        if(pilotIndex[pilotLength - 1] != pilotLength - 1)
        {
            isLastElemAdded = true;
            ++extLength;
        }
        
        
        float * extPilotIndex = new float[extLength];
        DSPSplitComplex extPilotChannel;
        extPilotChannel.realp = new float[extLength];
        extPilotChannel.imagp = new float[extLength];

        //Copy (except first&last elems, if they needed)
        int stPos = (int)isFirstElemAdded;
        int edPos = pilotLength + stPos;
        for(int i=stPos; i<edPos; ++i)
        {
            extPilotIndex[i] = m_pilotIdx[i-stPos];
            extPilotChannel.realp[i] = pilotChannel->realp[i-stPos];
            extPilotChannel.imagp[i] = pilotChannel->imagp[i-stPos];
        }
        
        //Add first & last elem
        if(isFirstElemAdded)
        {
            extPilotIndex[0] = 0;
            if(pilotLength < 2)
            {
                extPilotChannel.realp[0] = pilotChannel->realp[0];
                extPilotChannel.imagp[0] = pilotChannel->imagp[0];
            }
            else
            {
                DSPComplex slope;
                float sampleDist = extPilotIndex[2] - extPilotIndex[1];
                slope.real = (extPilotChannel.realp[2] - extPilotChannel.realp[1]) / sampleDist;
                slope.imag = (extPilotChannel.imagp[2] - extPilotChannel.imagp[1]) / sampleDist;
                
                float newDist = extPilotIndex[1] - extPilotIndex[0];
                extPilotChannel.realp[0] = extPilotChannel.realp[1] - slope.real * newDist;
                extPilotChannel.imagp[0] = extPilotChannel.imagp[1] - slope.imag * newDist;
            }
        }
        
        
        if(isLastElemAdded)
        {
            extPilotIndex[extLength - 1] = static_cast<float>(m_chLength);
            if(pilotLength < 2)
            {
                extPilotChannel.realp[extLength - 1] = pilotChannel->realp[0];
                extPilotChannel.imagp[extLength - 1] = pilotChannel->imagp[0];
            }
            else
            {
                DSPComplex slope;
                float sampleDist = extPilotIndex[extLength - 2] - extPilotIndex[extLength - 3];
                slope.real = (extPilotChannel.realp[extLength - 2] - extPilotChannel.realp[extLength - 3]) / sampleDist;
                slope.imag = (extPilotChannel.imagp[extLength - 2] - extPilotChannel.imagp[extLength - 3]) / sampleDist;
                float newDist = extPilotIndex[extLength - 1] - extPilotIndex[extLength - 2];
                extPilotChannel.realp[extLength - 1] = extPilotChannel.realp[extLength - 2] + slope.real * newDist;
                extPilotChannel.imagp[extLength - 1] = extPilotChannel.imagp[extLength - 2] + slope.imag * newDist;
            }
        }
        
        //Generate Channel
        vDSP_vgenp(extPilotChannel.realp, 1, extPilotIndex, 1, m_channel.realp, 1, m_chLength, extLength);
        vDSP_vgenp(extPilotChannel.imagp, 1, extPilotIndex, 1, m_channel.imagp, 1, m_chLength, extLength);
   
        delete [] extPilotIndex;
        delete [] extPilotChannel.realp;
        delete [] extPilotChannel.imagp;

    };
    
};
