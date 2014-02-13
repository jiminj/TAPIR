//
//  Modulator.h
//  TapirLib
//
//  Created by Jimin Jeon on 1/23/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#ifndef __TapirLib__Modulator__
#define __TapirLib__Modulator__

#include "TapirDSP.h"

namespace Tapir {
    
    class Modulator
    {
        virtual void modulate(const float * src, TapirDSP::SplitComplex * dest, const int length) const = 0;
        virtual void demodulate(const TapirDSP::SplitComplex * src, float * dest, const int length) const = 0;
    };
    
    class PskModulator : public Modulator
    {
    public:
        PskModulator(const int symbolRate, const float initPhase = 0.f, const float magnitude = 1.f);
        virtual void modulate(const float * src, TapirDSP::SplitComplex * dest, const int length) const;
        virtual void demodulate(const TapirDSP::SplitComplex * src, float * dest, const int length) const;
        
    protected:
        int m_symbolRate;
        float m_initialPhase;
        float m_magnitude;
        
    };
    class DpskModulator : public PskModulator
    {
    public:
        DpskModulator(const int symbolRate, const float initPhase = 0.f, const float magnitude = 1.f)
        :PskModulator(symbolRate, initPhase, magnitude) {};
        
        void modulate(const float * src, TapirDSP::SplitComplex * dest, const int length) const;
        void demodulate(const TapirDSP::SplitComplex * src, float * dest, const int length) const;
    };

    
}


#endif /* defined(__TapirLib__Modulator__) */
