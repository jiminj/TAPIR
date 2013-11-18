//
//  TapirTransform.m
//  Tapir
//
//  Created by Jimin Jeon on 11/16/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import "TapirTransform.h"
#include <Accelerate/Accelerate.h>

@implementation TapirTransform

+(void)fftComplex:(const DSPSplitComplex *)signal dest:(DSPSplitComplex *)dest length:(const int)fftLength
{
    int logLen = floorf(log2f(fftLength));
    FFTSetup setup = vDSP_create_fftsetup(logLen, FFT_RADIX2);
    vDSP_fft_zop(setup, signal, 1, dest, 1, logLen, FFT_FORWARD);
}
+(void)iFftComplex:(const DSPSplitComplex *)signal dest:(DSPSplitComplex *)dest length:(const int)fftLength
{
    int logLen = floorf(log2f(fftLength));
    FFTSetup setup = vDSP_create_fftsetup(logLen, FFT_RADIX2);
    vDSP_fft_zop(setup, signal, 1, dest, 1, logLen, FFT_INVERSE);
}

@end
