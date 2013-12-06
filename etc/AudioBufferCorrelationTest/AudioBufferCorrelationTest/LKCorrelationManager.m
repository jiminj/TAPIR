//
//  LKCorrelationManager.m
//  AudioBufferCorrelationTest
//
//  Created by dilu on 11/12/13.
//  Copyright (c) 2013 dilu. All rights reserved.
//

#import "LKCorrelationManager.h"
#define CORRELATION_THRESHOLD 0.5

@implementation LKCorrelationManager
-(id)initWithCorrelationWindowSize:(int)size1 andBacktrackSize:(int)size2{
    if(self=[super init]){
        correlationWindowSize = size1;
        backtrackSize = size2;
        
        realBuffer = [[LKRealSampleBuffer alloc] initWithBufferLength:correlationWindowSize*3+backtrackSize];
        sampleBufferA = [[LKVirtualSampleBuffer alloc] initWithRealSampleBuffer:realBuffer offSet:0 andLength:correlationWindowSize];
        sampleBufferB = [[LKVirtualSampleBuffer alloc] initWithRealSampleBuffer:realBuffer offSet:correlationWindowSize andLength:correlationWindowSize];
        correlationBuffer = [[LKRealSampleBuffer alloc] initWithBufferLength:correlationWindowSize*2];
        sumA = 0;
        sumB = 0;
        squareSumA = 0;
        squareSumB = 0;
        sumAB = 0;
        sumCor = 0;
    }
    return self;
}

-(void)newSample:(float)value{
    sumA-=[sampleBufferA lastSample];
    squareSumA-=[sampleBufferA lastSample]*[sampleBufferA lastSample];
    sumB-=[sampleBufferB lastSample];
    squareSumB-=[sampleBufferB lastSample]*[sampleBufferB lastSample];
    sumAB -= [ sampleBufferA lastSample]*[sampleBufferB lastSample];
    
    [realBuffer newSample:value];
    
    sumA+=[sampleBufferA sampleAt:0];
    squareSumA+=[sampleBufferA sampleAt:0]*[sampleBufferA sampleAt:0];
    sumB+=[sampleBufferB sampleAt:0];
    squareSumB+=[sampleBufferB sampleAt:0]*[sampleBufferB sampleAt:0];
    sumAB+=[sampleBufferA sampleAt:0]*[sampleBufferB sampleAt:0];
    
    sumCor-=[correlationBuffer sampleAt:correlationBuffer.length-1];
    [correlationBuffer newSample:[self calculateCorrelation]];
    sumCor+=[correlationBuffer sampleAt:0];
    
    if(sumCor/correlationBuffer.length>CORRELATION_THRESHOLD){
        int maxIndex = 0;
        for(int i = 1; i<correlationBuffer.length; i++){
            if([correlationBuffer sampleAt:i]>[correlationBuffer sampleAt:maxIndex]){
                maxIndex=i;
            }
        }
        LKVirtualSampleBuffer* sampleLog = [[LKVirtualSampleBuffer alloc] initWithRealSampleBuffer:realBuffer offSet:maxIndex andLength:backtrackSize];
        NSLog(@"sampleLog");
    }
}

-(float)calculateCorrelation{
    return (sumAB - sumA*sumB/correlationWindowSize)/sqrtf((squareSumA-sumA*sumA/correlationWindowSize)*(squareSumB-sumB*sumB/correlationWindowSize));
}

@end
