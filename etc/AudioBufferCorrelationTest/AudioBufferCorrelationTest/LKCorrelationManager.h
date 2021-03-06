//
//  LKCorrelationManager.h
//  AudioBufferCorrelationTest
//
//  Created by dilu on 11/12/13.
//  Copyright (c) 2013 dilu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LKRealSampleBuffer.h"
#import "LKVirtualSampleBuffer.h"

@interface LKCorrelationManager : NSObject{
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
    LKRealSampleBuffer* correlationBuffer;
    float sumCor;
}

-(id)initWithCorrelationWindowSize:(int)size1 andBacktrackSize:(int)size2;
-(void)newSample:(float)value;
-(float)calculateCorrelation;
@end
