//
//  LKCorrelationManager.h
//  AudioBufferCorrelationTest
//
//  Created by dilu on 11/12/13.
//  Copyright (c) 2013 dilu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TapirLib/TapirLib.h"
#import "TapirConfig.h"

@interface LKCorrelationManager : NSObject{
    TapirConfig * cfg;
    LKRealSampleBuffer* realBuffer;
    int correlationWindowSize;
    int backtrackSize;
    LKVirtualSampleBuffer* sampleBufferA;
    LKVirtualSampleBuffer* sampleBufferB;
    float sumA;
    float sumB;
    float squareSumA;
    float squareSumB;
    float sumAB;
    float absSum;
    LKRealSampleBuffer* correlationBuffer;
    float sumCor;
    NSFileHandle* fileHandle;
    long tt;
    BOOL stop;
    float xCorr;
}

-(id)initWithCorrelationWindowSize:(int)size1 andBacktrackSize:(int)size2;
-(void)newSample:(float)value;
-(float)calculateCorrelation;
-(void)trace;
@end
