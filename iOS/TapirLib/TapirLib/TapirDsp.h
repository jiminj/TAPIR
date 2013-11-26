//
//  TapirDsp.h
//  TapirLib
//
//  Created by Jimin Jeon on 11/20/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <Accelerate/Accelerate.h>

//Frequency Downconversion
void iqDemodulate(const float * signal, DSPSplitComplex * destSignal, const int length, const float samplingFreq, const float carrierFreq);

//Frequency Upconversion
void iqModulate(const DSPSplitComplex * signal, float * destSignal, const int length, const float samplingFreq, const float carrierFreq);


//FFT
void fftComplexForward(const DSPSplitComplex * signal, DSPSplitComplex * dest, const int fftLength);
void fftComplexInverse(const DSPSplitComplex * signal, DSPSplitComplex * dest, const int fftLength);
