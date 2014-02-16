//
//  Modulator.cpp
//  TapirLib
//
//  Created by Jimin Jeon on 1/23/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#include "Modulator.h"

namespace Tapir
{
    static const float TWO_PI = 2 * M_PI;

    PskModulator::PskModulator(const int symbolRate, const float initPhase, const float magnitude)
    :m_symbolRate(symbolRate),
    m_initialPhase(initPhase),
    m_magnitude(magnitude)
    {};
    
    void PskModulator::modulate(const float *src, TapirDSP::SplitComplex *dest, const int length) const
    {
        float phaseDiv = TWO_PI / m_symbolRate;

        float * phase = new float[length];
        TapirDSP::vsmsa(src, 1, &phaseDiv, &m_initialPhase, phase, 1, length);
        TapirDSP::vsincosf(dest->imagp, dest->realp, phase, &length);
        
        float amp = sqrt(m_magnitude);
        TapirDSP::vsmul(dest->realp, 1, &amp, dest->realp, 1, length);
        TapirDSP::vsmul(dest->imagp, 1, &amp, dest->imagp, 1, length);
        
        delete [] phase;
    };
    
    void PskModulator::demodulate(const TapirDSP::SplitComplex * src, float * dest, const int length) const
    {
        float * phase = new float[length];
        TapirDSP::zvphas(src, 1, phase, 1, length);

        float phaseDiv = TWO_PI / m_symbolRate;
        float startPhase = M_PI / m_symbolRate - m_initialPhase;
        
        // Set start point from 0 tO -pi/n, at n-psk, initPhase = 0;
        TapirDSP::vsadd(phase, 1, &startPhase, phase, 1, length);
        
        // [-pi : pi] => [ 0 : 2pi];
        for(int i=0; i<length; ++i)
        {
            while(phase[i] < 0)
            { phase[i] += TWO_PI; }
            if(phase[i] >= TWO_PI)
            { phase[i] -= TWO_PI; }
            
            dest[i] = floor(phase[i] / phaseDiv);
        }
        
        delete []phase;
    };
    void DpskModulator::modulate(const float *src, TapirDSP::SplitComplex *dest, const int length) const
    {
        float * diffMod = new float[length];
        int val = 0;
        
        diffMod[0] = 0;
        for(int i=0; i<length; ++i)
        {
            val += src[i];
            if(val >= m_symbolRate)
            { val -= m_symbolRate; }
            
            diffMod[i] = val;
        }
        PskModulator::modulate(diffMod, dest, length);

        delete [] diffMod;
    };
    
    void DpskModulator::demodulate(const TapirDSP::SplitComplex * src, float * dest, const int length) const
    {
        if(length > 0)
        {
            float * pskDemod = new float[length];
            PskModulator::demodulate(src, pskDemod, length);
            
            dest[0] = pskDemod[0];
            for(int i=1; i<length; ++i)
            {
                dest[i] = pskDemod[i] - pskDemod[i-1];
                if(dest[i] < 0)
                { dest[i] += m_symbolRate; }
            }
            delete [] pskDemod;
        }
    };
    
};
