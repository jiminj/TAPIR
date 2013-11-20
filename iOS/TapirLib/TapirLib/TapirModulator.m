//
//  TapirModulator.m
//  TapirLib
//
//  Created by Jimin Jeon on 11/19/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import "TapirModulator.h"
#import <Accelerate/Accelerate.h>

const float kTwoPi = 2 * M_PI;

@implementation PskModulator
@synthesize symbolRate, initialPhase, magnitude;


// Stuuuuuuupid objective-c constructors *****
-(id)init //default constructor
{
    return [self initWithSymbolRate:2 initPhase:0.f magnitude:1.0f];;
}
-(id)initWithSymbolRate:(int)_symbolRate
{
    return [self initWithSymbolRate:_symbolRate initPhase:0.f magnitude:1.0f];
}
-(id)initWithSymbolRate:(int)_symbolRate initPhase:(float)_initPhase
{
    return [self initWithSymbolRate:_symbolRate initPhase:_initPhase magnitude:1.0f];
}
-(id)initWithSymbolRate:(int)_symbolRate initPhase:(float)_initPhase magnitude:(float)_magnitude
{
    if(self = [super init])
    {
        [self setSymbolRate:_symbolRate];
        [self setInitialPhase:_initPhase];
        [self setMagnitude:_magnitude];
    }
    return self;
}


-(void)modulate:(const int *)source dest:(DSPSplitComplex *)dest length:(const int)length
{
    float phaseDiv = kTwoPi / symbolRate;
    
    float * fSrc = malloc(sizeof(float) * length);
    vDSP_vflt32(source, 1, fSrc, 1, length);
    
    //Phase = 2*pi*value/symbolRate + initPhase
    float * phase = malloc(sizeof(float) * length);
    vDSP_vsmsa(fSrc, 1, &phaseDiv, &initialPhase, phase, 1, length);
    vvsincosf(dest->imagp, dest->realp, phase, &length);

    float amp = sqrt(magnitude);
    vDSP_vsmul(dest->realp, 1, &amp, dest->realp, 1, length);
    vDSP_vsmul(dest->imagp, 1, &amp, dest->imagp, 1, length);
    
    free(phase);
    free(fSrc);

}

-(void)demodulate:(const DSPSplitComplex *)source dest:(int *)dest length:(const int)length
{
    float * phase = malloc(sizeof(float) * length);
    vDSP_zvphas(source, 1, phase, 1, length);
    
    //    float twoPi = 2 * M_PI;
    float phaseDiv = kTwoPi / symbolRate;
    float startPhase = M_PI / symbolRate - initialPhase;
    
    // Set start point from 0 tO -pi/n, at n-psk, initPhase = 0;
    vDSP_vsadd(phase, 1, &startPhase, phase, 1, length);
    
    // [-pi : pi] => [ 0 : 2pi];
    for(int i=0; i<length; ++i)
    {
        while(phase[i] < 0)
        { phase[i] += kTwoPi; }
        if(phase[i] >= kTwoPi)
        { phase[i] -= kTwoPi; }
        
        dest[i] = floor(phase[i] / phaseDiv);
    }
    
    free(phase);
}

@end

@implementation DpskModulator
-(void)modulate:(const int *)source dest:(DSPSplitComplex *)dest length:(const int)length
{
    int * diffMod = malloc(sizeof(int) * length);
    int val = 0;

    diffMod[0] = 0;
    for(int i=0; i<length; ++i)
    {
        val += source[i];
        if(val > symbolRate)
        { val -= symbolRate; }
        
        diffMod[i] = val;
    }
    
    [super modulate:diffMod dest:dest length:length];
    free(diffMod);
}
-(void)demodulate:(const DSPSplitComplex *)source dest:(int *)dest length:(const int)length
{
    [super demodulate:source dest:dest length:length];
}
@end
