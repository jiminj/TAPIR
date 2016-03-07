//
//  Sonifier.h
//  TapirTransmitter
//
//  Created by Jimin Jeon on 12/3/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <Tapir/Tapir.h>

static const int kSonifierNumBuffers = 3;

@protocol SonifierDelegate <NSObject>
-(void) sonifierFinished;
@end

@interface Sonifier : NSObject{

    id <SonifierDelegate> delegate;

    AudioStreamBasicDescription audioDesc;
    AudioQueueRef audioQueue;
//    AudioQueueBufferRef buffer[NUM_BUFFERS];
    AudioQueueBufferRef buffer[kSonifierNumBuffers];
    UInt32 frameLength;
    
    float * audioData;
    int audioBufferByteSize;
    
    int dataLength;
    
    BOOL isPlaying;
    BOOL isDone;
    int doneCnt;
    NSLock * outputLock;

    float outputScalingFactor;

}

@property int dataLength;
@property id <SonifierDelegate> delegate;
@property (readonly) BOOL isDone;

//- (id)initWithConfig:(TapirConfig *)_cfg;
- (id)initWithSampleRate:(const float)sampleRate channel:(const int)ch;
- (void)transmit:(float *)audioData length:(int)len;
- (void)processAudioQueue:(AudioQueueRef)q buffer:(AudioQueueBufferRef)buf;

//+ (void)makeStereo;


@end