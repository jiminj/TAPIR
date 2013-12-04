//
//  TapirSignalGenerator.h
//  TapirTransmitter
//
//  Created by Jimin Jeon on 12/4/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>
#import <TapirLib/TapirLib.h>
#import "TapirConfig.h"

@interface TapirSignalGenerator : NSObject
{
    int * input;
    float * encoded; 
    float * interleaved;
    DSPSplitComplex modulated;
    DSPSplitComplex pilotAdded;
    DSPSplitComplex extended;
    DSPSplitComplex ifftData;

    
    
    TapirConfig * cfg;
    TapirPilotManager * pilotMgr;
    TapirPskModulator * modulator;
    TapirMatrixInterleaver * interleaver;
    TapirConvEncoder * convEncoder;
}
- (id) initWithConfig:(TapirConfig *)_cfg;

- (void) generateSignalWith:(char *)string dest:(float *)dest;
- (void) encodeOneChar:(const char)src dest:(float *)dest;
- (void) addPrefixWith:(const float *)src dest:(float *)dest;
- (void) applyHpf:(float *)input output:(float *)output;
- (void) generatePreamble:(float *)dest;

@end
