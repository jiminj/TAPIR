//
//  Utilities.m
//  TapirLib
//
//  Created by Jimin Jeon on 11/20/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import "Utilities.h"

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
    
    TapirDSP::vramp(&initState, &inc, carrierIndex, 1, length);
    TapirDSP::vsincosf(carrier->imagp, carrier->realp, carrierIndex, &length);

    delete [] carrierIndex;
};

void scaleFloatSignal(const float * source, float * dest, const int length, const float scale)
{
    TapirDSP::vsmul(source, 1, &scale, dest, 1, length);
};
void scaleCompSignal(const TapirDSP::SplitComplex * source, TapirDSP::SplitComplex * dest, const int length, const float scale)
{
    scaleFloatSignal(source->realp, dest->realp, length, scale);
    scaleFloatSignal(source->imagp, dest->imagp, length, scale);
};

void maximizeSignal(const float * source, float * dest, const int length, const float maximum)
{
    float maxVal;
    TapirDSP::maxmgv(source, 1, &maxVal, length);
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
    TapirDSP::zrvmul(&carrier, 1, signal, 1, destSignal, 1, length);
    
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
    
    TapirDSP::vmul(signal->realp, 1, carrier.realp, 1, signal->realp, 1, length);
    TapirDSP::vmul(signal->imagp, 1, carrier.imagp, 1, signal->imagp, 1, length);

    TapirDSP::vadd(signal->realp, 1, signal->imagp,1 , destSignal, 1, length);
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
:m_logLen(calculateLogLength(fftLength)),
m_fftSetup(vDSP_create_fftsetup(m_logLen, FFT_RADIX2))
{};

FFT::~FFT()
{
    vDSP_destroy_fftsetup(m_fftSetup);
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
    
void FFT::transform(TapirDSP::SplitComplex *src, TapirDSP::SplitComplex *dest, Tapir::FFT::FftDirection direction)
{
    int fftDirection = (direction == FORWARD) ? FFT_FORWARD : FFT_INVERSE;
    vDSP_fft_zop(m_fftSetup, src, 1, dest, 1, m_logLen, fftDirection);
};
    
    
};

