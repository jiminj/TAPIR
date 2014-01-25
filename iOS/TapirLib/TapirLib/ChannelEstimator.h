//
//  ChannelEstimator.h
//  TapirLib
//
//  Created by Jimin Jeon on 1/23/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#ifndef __TapirLib__ChannelEstimator__
#define __TapirLib__ChannelEstimator__
#include <Accelerate/Accelerate.h>
#include "PilotManager.h"
namespace Tapir {
    class ChannelEstimator
    {
    public:
       virtual void estimateChannel(const DSPSplitComplex * src, DSPSplitComplex * dest) = 0;
    };
    
    class LSChannelEstimator : public ChannelEstimator
    {
    public:
        LSChannelEstimator(PilotManager * pilot, const int chLength);
        ~LSChannelEstimator();
        void estimateChannel(const DSPSplitComplex * src, DSPSplitComplex * dest);
    protected:
        void generateChannel(const DSPSplitComplex * pilotChannel);
        
        PilotManager * m_pilotInfo;
        int m_chLength;
        float * m_pilotIdx;
        
        DSPSplitComplex m_channel;
        
        DSPSplitComplex m_pilotRcvSignal;
        DSPSplitComplex m_pilotChannel;
    };
};

#endif /* defined(__TapirLib__ChannelEstimator__) */
