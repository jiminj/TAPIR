//
//  LKRealSampleBuffer.m
//  AudioBufferCorrelationTest
//
//  Created by dilu on 11/12/13.
//  Copyright (c) 2013 dilu. All rights reserved.
//

#import "LKRealSampleBuffer.h"



@implementation LKRealSampleBuffer
@synthesize samples;
@synthesize length;
@synthesize firstSampleIndex;
-(id)initWithBufferLength:(int)bufferLength{
    if(self=[super init]){
        length = bufferLength;
        samples = malloc(length*sizeof(float));
        for(int i = 0; i<length; i++){
            samples[i] = 0;
        }
        firstSampleIndex = 0;
    }
    return self;
}
-(float)sampleAt:(int)index{
    return samples[(firstSampleIndex+index)%length];
}
-(void)newSample:(float)newSample{
    firstSampleIndex--;
    if(firstSampleIndex<0)firstSampleIndex+=length;
    samples[firstSampleIndex]=newSample;
}
-(void)dealloc{
    free(samples);
}
@end
