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

@interface TapirSignalAnalyzer : NSObject
{

    DSPSplitComplex convertedSignal;
    DSPSplitComplex roiSignal;
    DSPSplitComplex estimatedSignal;
    DSPSplitComplex pilotRemovedSignal;

    float * demod;
    float * deinterleaved;
    int * decoded;
    
//    TapirConfig * cfg;
//    TapirPilotManager * pilotMgr;
    Tapir::PilotManager * m_pilotMgr;
//    TapirLSChannelEstimator * chanEstimator;
    Tapir::LSChannelEstimator * m_chanEstimator;
    //    TapirMatrixInterleaver * interleaver;
    Tapir::MatrixInterleaver * m_interleaver;
//    TapirPskModulator * modulator;
    Tapir::PskModulator * m_modulator;

    Tapir::ViterbiDecoder * m_decoder;
//    TapirViterbiDecoder * vitdec;
    
}

-(char)decodeBlock:(const float *)signal;
-(NSString *)analyze:(float *)signal;

@end
