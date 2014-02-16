//
//  Utilities.h
//  TapirLib
//
//  Created by Jimin Jeon on 11/20/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#ifndef __TapirLib__Utilities__
#define __TapirLib__Utilities__

#include "TapirDSP.h"

namespace Tapir {
    
//Frequency Downconversion
void iqDemodulate(const float * signal, TapirDSP::SplitComplex * destSignal, const int length, const float samplingFreq, const float carrierFreq);

//Frequency Upconversion
void iqModulate(const TapirDSP::SplitComplex * signal, float * destSignal, const int length, const float samplingFreq, const float carrierFreq);


void scaleFloatSignal(const float * source, float * dest, const int length, const float scale);
void scaleCompSignal(const TapirDSP::SplitComplex * source, TapirDSP::SplitComplex * dest, const int length, const float scale);

void maximizeSignal(const float * source, float * dest, const int length, const float maximum);

int mergeBitsToIntegerValue(const int * intArray, int arrLength);
void divdeIntIntoBits(const int src, int * arr, int arrLength);
    
    
class FFT
{
public:
    enum FftDirection
    {
        FORWARD = 0,
        INVERSE
    };

    FFT(const int fftLength);
    virtual ~FFT();
    void transform(TapirDSP::SplitComplex * src, TapirDSP::SplitComplex * dest, FftDirection direction);
    
protected:
    int calculateLogLength(int length);
    int m_logLen;
    FFTSetup m_fftSetup;
};
    

}
#endif /* defined(__TapirLib__Utils__) */