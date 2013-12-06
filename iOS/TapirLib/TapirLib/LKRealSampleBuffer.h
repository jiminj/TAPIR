//
//  LKRealSampleBuffer.h
//  AudioBufferCorrelationTest
//
//  Created by dilu on 11/12/13.
//  Copyright (c) 2013 dilu. All rights reserved.
//

#import <Foundation/Foundation.h>

// real sample buffer
// holds real data
// works as a circular list

@interface LKRealSampleBuffer : NSObject{
    
    float* samples;
    int length;
    int firstSampleIndex;
}

@property(readonly) float* samples;
@property(readonly) int length;
@property(readonly) int firstSampleIndex;

-(id)initWithBufferLength:(int)bufferLength;
-(float)sampleAt:(int)index;
-(void)newSample:(float)newSample;
-(void)reset;
@end
