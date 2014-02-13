//
//  ChannelEstimator.h
//  TapirLib
//
//  Created by Jimin Jeon on 1/23/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#ifndef __TapirLib__ChannelEstimator__
#define __TapirLib__ChannelEstimator__

#include "TapirDSP.h"
#include "PilotManager.h"

namespace Tapir {
    class ChannelEstimator
    {
    public:
       virtual void estimateChannel(const TapirDSP::SplitComplex * src, TapirDSP::SplitComplex * dest) = 0;
    };
    
    class LSChannelEstimator : public ChannelEstimator
    {
    public:
        LSChannelEstimator(PilotManager * pilot, const int chLength);
        ~LSChannelEstimator();
        void estimateChannel(const TapirDSP::SplitComplex * src, TapirDSP::SplitComplex * dest);
    protected:
        void generateChannel(const TapirDSP::SplitComplex * pilotChannel);
        
        PilotManager * m_pilotInfo;
        int m_chLength;
        float * m_pilotIdx;
        
        TapirDSP::SplitComplex m_channel;
        
        TapirDSP::SplitComplex m_pilotRcvSignal;
        TapirDSP::SplitComplex m_pilotChannel;
    };
};

#endif /* defined(__TapirLib__ChannelEstimator__) */
