//
//  TapirIqModulator.m
//  Tapir
//
//  Created by Jimin Jeon on 11/17/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import "TapirIqModulator.h"
#include <Accelerate/Accelerate.h>
#include <math.h>

@implementation TapirIqModulator

+ (void) generateCarrier:(DSPSplitComplex *)carrier length:(const int)_length samplingFreq:(const float)samplingFreq carrierFreq:(const float)carrierFreq;
{
    // MATLAB code
    // tC = (0:1/Fs:(length(signal)-1)/Fs);
    // Carrier = exp(1i * (2 * pi * Fc * tC) )';
    
    float initState = 0;
    float inc = 2 * M_PI * carrierFreq/(float)samplingFreq;
    float * carrierIndex = malloc(sizeof(float) * _length);
    
    vDSP_vramp(&initState, &inc, carrierIndex, 1, _length);
    vvsincosf(carrier->imagp, carrier->realp, carrierIndex, &_length);
    
    free(carrierIndex);
    
    return;
}

+ (void) scaleFloatSignal:(const float *)source dest:(float *)dest length:(const int)_length scale:(const float)_scale
{
    vDSP_vsmul(source, 1, &_scale, dest, 1, _length);
    return;
}
+ (void) scaleCompSignal:(const DSPSplitComplex *)source dest:(DSPSplitComplex *)dest length:(const int)_length scale:(const float)_scale
{
    [self scaleFloatSignal:source->realp dest:dest->realp length:_length scale:_scale ];
    [self scaleFloatSignal:source->imagp dest:dest->imagp length:_length scale:_scale ];
    return;
}

+ (void) iqDemodulate:(const float *)signal dest:(DSPSplitComplex *)destSignal length:(const int)length samplingFreq:(const float)samplingFreq carrierFreq:(const float)carrierFreq;
{
    //    MATLAB Code
    //    realRx = signal .* real(carrier);
    //    imagRx = signal .* imag(carrier);
    //    basebandSig = realRx + 1i*imagRx;
    
    DSPSplitComplex carrier;
    carrier.realp = malloc(sizeof(float) * length);
    carrier.imagp = malloc(sizeof(float) * length);
    float scale = sqrt(2.f);
    
    [self generateCarrier:&carrier length:length samplingFreq:samplingFreq carrierFreq:carrierFreq];
    [self scaleCompSignal:&carrier dest:&carrier length:length scale:scale];
    vDSP_zrvmul(&carrier, 1, signal, 1, destSignal, 1, length);
    
    free(carrier.realp);
    free(carrier.imagp);
    return;
}

+ (void) iqModulate:(const DSPSplitComplex *)signal dest:(float *)destSignal length:(const int)length samplingFreq:(const float)samplingFreq carrierFreq:(const float)carrierFreq;
{
    //    MATLAB Code
    //    rePulse = real(signal) .* real(carrier);
    //    imPulse = imag(signal) .* imag(carrier);
    //    modulatedSig = rePulse + imPulse;
    
    DSPSplitComplex carrier;
    carrier.realp = malloc(sizeof(float) * length);
    carrier.imagp = malloc(sizeof(float) * length);
    [self generateCarrier:&carrier length:length samplingFreq:samplingFreq carrierFreq:carrierFreq];
    
    vDSP_vmul(signal->realp, 1, carrier.realp, 1, signal->realp, 1, length);
    vDSP_vmul(signal->imagp, 1, carrier.imagp, 1, signal->imagp, 1, length);
    vDSP_vsadd(signal->realp, 1, signal->imagp, destSignal, 1, length);
    [self scaleFloatSignal:destSignal dest:destSignal length:length scale:2.0f];
    
    free(carrier.realp);
    free(carrier.imagp);
    return;
}

@end
