//
//  Utilities.m
//  TapirLib
//
//  Created by Jimin Jeon on 11/20/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#include "../include/Utilities.h"

//IQ Modulation
namespace Tapir {

static void generateCarrier(TapirDSP::SplitComplex * carrier, const int length, const float samplingFreq, const float carrierFreq)
{
    // MATLAB code
    // tC = (0:1/Fs:(length(signal)-1)/Fs);
    // Carrier = exp(1i * (2 * pi * Fc * tC) )';
    
    float initState = 0;
    float inc = 2 * M_PI * carrierFreq/(float)samplingFreq;
    float * carrierIndex = new float[length];
    
    TapirDSP::vramp(&initState, &inc, carrierIndex, length);
    TapirDSP::vvsincosf(carrier->imagp, carrier->realp, carrierIndex, length);

    delete [] carrierIndex;
};

void scaleFloatSignal(const float * source, float * dest, const int length, const float scale)
{
    TapirDSP::vsmul(source, &scale, dest, length);
};

void scaleCompSignal(const TapirDSP::SplitComplex * source, TapirDSP::SplitComplex * dest, const int length, const float scale)
{
    scaleFloatSignal(source->realp, dest->realp, length, scale);
    scaleFloatSignal(source->imagp, dest->imagp, length, scale);
};

void maximizeSignal(const float * source, float * dest, const int length, const float maximum)
{
    float maxVal;
    TapirDSP::maxmgv(source, &maxVal, length);
    scaleFloatSignal(source, dest, length, maximum / maxVal);
};


void iqDemodulate(const float * signal, TapirDSP::SplitComplex * destSignal, const int length, const float samplingFreq, const float carrierFreq)
{
    //    MATLAB Code
    //    realRx = signal .* real(carrier);
    //    imagRx = signal .* imag(carrier);
    //    basebandSig = realRx + 1i*imagRx;
    
    TapirDSP::SplitComplex carrier;
    carrier.realp = new float[length];
    carrier.imagp = new float[length];
    //    float scale = sqrt(2.f);
    float scale = M_SQRT2;
    
    generateCarrier(&carrier, length, samplingFreq, carrierFreq);
    scaleCompSignal(&carrier, &carrier, length, scale);
    TapirDSP::zrvmul(&carrier, signal, destSignal, length);
    
    delete [] carrier.realp;
    delete [] carrier.imagp;
};

void iqModulate(const TapirDSP::SplitComplex * signal, float * destSignal, const int length, const float samplingFreq, const float carrierFreq)
{
    //    MATLAB Code
    //    rePulse = real(signal) .* real(carrier);
    //    imPulse = imag(signal) .* imag(carrier);
    //    modulatedSig = rePulse + imPulse;
    
    TapirDSP::SplitComplex carrier;
    carrier.realp = new float[length];
    carrier.imagp = new float[length];

    generateCarrier(&carrier, length, samplingFreq, carrierFreq);
    
    TapirDSP::vmul(signal->realp, carrier.realp, signal->realp, length);
    TapirDSP::vmul(signal->imagp, carrier.imagp, signal->imagp, length);

    TapirDSP::vadd(signal->realp, signal->imagp, destSignal, length);
    scaleFloatSignal(destSignal, destSignal, length, 2.0f);
    
    delete [] carrier.realp;
    delete [] carrier.imagp;
};


int mergeBitsToIntegerValue(const int * intArray, int arrLength)
{
    int retVal = 0;
    for(int i=0; i<arrLength; ++i)
    {
        retVal += (intArray[i] & 1) << (arrLength - 1 - i);
    }
    return retVal;
};
void divdeIntIntoBits(const int src, int * arr, int arrLength)
{
    int input = src;
    for(int i = 0; i < arrLength; ++i)
    {
        arr[arrLength - i - 1] = (input & 1);
        input >>= 1;
    }
};

    
    
//FFT
    
FFT::FFT(const int fftLength)
: 
#ifdef __APPLE__
m_logLen(calculateLogLength(fftLength))
, m_fftSetup( vDSP_create_fftsetup(m_logLen, FFT_RADIX2) )
#elif ARM_ANDROID
m_length(fftLength)
, m_srcSeperated(new TapirDSP::Complex[fftLength])
, m_destSeperated(new TapirDSP::Complex[fftLength])
, m_fftSetup(ne10_fft_alloc_c2c_float32(fftLength))
#endif
{ 
#if ARM_ANDROID
    ne10_init(); 
#endif
};

FFT::~FFT()
{
#ifdef __APPLE__
    vDSP_destroy_fftsetup(m_fftSetup);
#elif ARM_ANDROID
    delete [] m_srcSeperated;
    delete [] m_destSeperated;
    NE10_FREE(m_fftSetup);
#endif
};
    
void FFT::transform(TapirDSP::SplitComplex *src, TapirDSP::SplitComplex *dest, Tapir::FFT::FftDirection direction)
{
#ifdef __APPLE__
    int fftDirection = (direction == FORWARD) ? FFT_FORWARD : FFT_INVERSE;
    vDSP_fft_zop(m_fftSetup, src, 1, dest, 1, m_logLen, fftDirection);
#elif ARM_ANDROID
    TapirDSP::ztoc(src, m_srcSeperated, m_length);
    ne10_fft_c2c_1d_float32((ne10_fft_cpx_float32_t *)(m_destSeperated), (ne10_fft_cpx_float32_t *)(m_srcSeperated), m_fftSetup->twiddles, m_fftSetup->factors, m_length, (int)direction);
    TapirDSP::ctoz(m_destSeperated, dest, m_length);
#endif
};
 

int FFT::calculateLogLength(int length)
{
    int count = 0;
    while(length > 0)
    {
        length >>= 1;
        ++count;
    }
    --count;
    return count;
};
   
    
};

