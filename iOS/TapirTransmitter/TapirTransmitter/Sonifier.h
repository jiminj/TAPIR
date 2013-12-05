//
//  SoundPlayer.h
//  musiculesdev
//
//  Created by Dylan on 1/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "TapirConfig.h"
#define NUM_BUFFERS 3
#define SAMPLE_RATE 44100.0f

typedef struct AQDataType {
    AudioStreamBasicDescription dataFormat;
    AudioQueueRef queue;
    AudioQueueBufferRef buffers[NUM_BUFFERS];
    UInt32 frameCount;	
} AQDataType;


@interface Sonifier : NSObject {
    AQDataType aqData;
    float phaseIncrement;
    float currentPhase;
    int indexCount;
    int period;
    BOOL smooth;
    float* samples;
    int length;
}

@property (nonatomic, assign) AQDataType aqData;
@property float phaseIncrement;
@property float currentPhase;
@property int indexCount;
@property int period;
@property BOOL smooth;
@property float* samples;
@property int length;

-(void)start;
-(void)stop;
-(void)setFreq:(float)freq;
-(void)transmit:(float*)sampleArray length:(int)l;

@end  