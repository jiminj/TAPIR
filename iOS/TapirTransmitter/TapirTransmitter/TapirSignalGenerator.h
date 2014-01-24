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
    float carrierFreq;
    
    DSPSplitComplex modulated;
    DSPSplitComplex pilotAdded;
    DSPSplitComplex extended;
    DSPSplitComplex ifftData;
    
    TapirConfig * cfg;
    Tapir::PilotManager * m_pilotMgr;

    Tapir::PskModulator * m_modulator;
//    TapirConvEncoder * convEncoder;
    Tapir::ConvEncoder * m_encoder;
    
    Tapir::MatrixInterleaver * m_interleaver;
    
    Tapir::FilterFIR * m_filter;
    
}
- (id) initWithConfig:(TapirConfig *)_cfg;

- (int) calculateResultLengthOfStringWithLength:(int)stringLength;
- (void) generateSignalWith:(NSString *)inputString dest:(float *)dest length:(int)destLength;
- (void) encodeOneChar:(const char)src dest:(float *)dest;
- (void) addPrefixAndPostfixWith:(const float *)src dest:(float *)dest;
- (void) generatePreamble:(float *)dest;

//- (void) applyHpf:(float *)input output:(float *)output;

@end
