//
//  PilotManager.h
//  TapirLib
//
//  Created by Jimin Jeon on 1/23/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#ifndef __TapirLib__PilotManager__
#define __TapirLib__PilotManager__


#include "TapirDSP.h"
namespace Tapir
{
    class PilotManager
    {
    public:
        PilotManager(const TapirDSP::SplitComplex * pilotData, const int * index , const int length);
        virtual ~PilotManager();
        
        void addPilot(const TapirDSP::SplitComplex * src, TapirDSP::SplitComplex * dest, const int srcLength);
        void removePilot(const TapirDSP::SplitComplex * src, TapirDSP::SplitComplex * dest, const int srcLength);

        const int * getPilotIndex(){ return m_pilotIndex; };
        const int getPilotLength(){ return m_pilotLength; };
        const TapirDSP::SplitComplex * getPilotData() { return &m_pilotData; };

    protected:
        int m_pilotLength;
        int * m_pilotIndex;
        
        TapirDSP::SplitComplex m_pilotData;
    };
}

#endif /* defined(__TapirLib__PilotManager__) */
