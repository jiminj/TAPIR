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

//typedef struct AQDataType {
//    AudioStreamBasicDescription dataFormat;
//    AudioQueueRef queue;
//    AudioQueueBufferRef buffers[NUM_BUFFERS];
//    UInt32 frameCount;	
//} AQDataType;




@protocol SonifierDelegate <NSObject>
-(void) sonifierFinished;
@end

@interface Sonifier : NSObject{

    id <SonifierDelegate> delegate;

    TapirConfig * cfg;
//    AQDataType aqData;

    AudioStreamBasicDescription audioDesc;
    AudioQueueRef queue;
    AudioQueueBufferRef buffer[NUM_BUFFERS];
    UInt32 frameCount;
    
    float * audioData;

//    float* samples;
//    int length;
//    int length2;
//    float* samples2;
    
    int dataLength;
    
    BOOL isPlaying;
    BOOL isDone;
    int doneCnt;
    
    float * curDataPosition;
//    BOOL isBufferInit;
}

//@property (nonatomic, assign) AQDataType aqData;
//@property float* samples;
//@property int length;
//@property float* samples2;
@property int dataLength;
@property id <SonifierDelegate> delegate;
@property BOOL isPlaying;
//@property BOOL isBufferInit;
//@property delegate;

- (id)initWithConfig:(TapirConfig *)_cfg;
- (void)transmit:(float *)audioData length:(int)len;
- (void)processAudioQueue:(AudioQueueRef)q buffer:(AudioQueueBufferRef)buf;

- (void)makeStereo;


//- (void)start;
//- (void)stop;
//-(void)setFreq:(float)freq;
//- (void)transmit:(float*)sampleArray length:(int)len outputChannel:(unsigned int)outputCh;


@end