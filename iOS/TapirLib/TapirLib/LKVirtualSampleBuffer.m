//
//  LKVirtualSampleBuffer.m
//  AudioBufferCorrelationTest
//
//  Created by dilu on 11/12/13.
//  Copyright (c) 2013 dilu. All rights reserved.
//

#import "LKVirtualSampleBuffer.h"

@implementation LKVirtualSampleBuffer
-(id)initWithRealSampleBuffer:(LKRealSampleBuffer *)buffer offSet:(int)offsetValue andLength:(int)lengthValue{
    if(self=[super init]){
        realBuffer = buffer;
        offset = offsetValue;
        length = lengthValue;
        samples = calloc(length, sizeof(float));
    }
    
    return self;
}
-(float)lastSample{
    return [realBuffer sampleAt:offset+length-1];
    //return samples[length-1];
}
-(float)sampleAt:(int)index{
    return [realBuffer sampleAt:offset+index];
    //return samples[index];
}
-(void)dealloc{
    free(samples);
}
-(float *)samples{
    int index = offset+realBuffer.firstSampleIndex;
    if(index>=realBuffer.length)index-=realBuffer.length;
    int firstHalfLength = realBuffer.length - index;
    if(firstHalfLength>length){
        firstHalfLength = length;
    }
    memcpy(samples, realBuffer.samples+index, sizeof(float)*firstHalfLength);
    if(firstHalfLength<length){
        memcpy(samples+firstHalfLength,realBuffer.samples,sizeof(float)*(length-firstHalfLength));
    }
    return samples;
}
@end
