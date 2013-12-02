//
//  LKVirtualSampleBuffer.m
//  AudioBufferCorrelationTest
//
//  Created by dilu on 11/12/13.
//  Copyright (c) 2013 dilu. All rights reserved.
//

#import "LKVirtualSampleBuffer.h"

@implementation LKVirtualSampleBuffer
@synthesize samples;
-(id)initWithRealSampleBuffer:(LKRealSampleBuffer *)buffer offSet:(int)offsetValue andLength:(int)lengthValue{
    if(self=[super init]){
        realBuffer = buffer;
        offset = offsetValue;
        length = lengthValue;
        samples = realBuffer.samples+offsetValue;
    }
    
    return self;
}
-(float)lastSample{
    //return [realBuffer sampleAt:offset+length-1];
    return samples[length-1];
}
-(float)sampleAt:(int)index{
    //return [realBuffer sampleAt:offset+index];
    return samples[index];
}
@end
