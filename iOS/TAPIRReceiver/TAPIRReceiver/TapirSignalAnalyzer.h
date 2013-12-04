//
//  TapirSignalAnalyzer.h
//  TAPIRReceiver
//
//  Created by Jimin Jeon on 12/1/13.
//  Copyright (c) 2013 dilu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>
#import <TapirLib/TapirLib.h>
#import "TapirConfig.h"

@interface TapirSignalAnalyzer : NSObject
{

    DSPSplitComplex convertedSignal;
    DSPSplitComplex roiSignal;
    DSPSplitComplex estimatedSignal;
    DSPSplitComplex pilotRemovedSignal;

    float * demod;
    float * deinterleaved;
    int * decoded;
    
    TapirConfig * cfg;
    TapirPilotManager * pilotMgr;
    TapirLSChannelEstimator * chanEstimator;
    TapirPskModulator * modulator;
    TapirMatrixInterleaver * interleaver;
    TapirViterbiDecoder * vitdec;
    
}

-(char)decodeBlock:(const float *)signal;
-(id)initWithConfig:(TapirConfig *)cfg;


@end
