//
//  SoundPlayer.h
//  musiculesdev
//
//  Created by Dylan on 1/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "TapirConfig.h"

static const int kNumBuffers = 3;
static const float kShortMax = (float)(SHRT_MAX);

@protocol SonifierDelegate <NSObject>
-(void) sonifierFinished;
@end

@interface Sonifier : NSObject{

    id <SonifierDelegate> delegate;

    TapirConfig * cfg;

    AudioStreamBasicDescription audioDesc;
    AudioQueueRef audioQueue;
//    AudioQueueBufferRef buffer[NUM_BUFFERS];
    AudioQueueBufferRef buffer[kNumBuffers];
    UInt32 frameLength;
    
    float * audioData;
    int audioBufferByteSize;
    
    int dataLength;
    
    BOOL isPlaying;
    BOOL isDone;
    int doneCnt;
    NSLock * outputLock;

}

@property int dataLength;
@property id <SonifierDelegate> delegate;
@property (readonly) BOOL isDone;

- (id)initWithConfig:(TapirConfig *)_cfg;
- (void)transmit:(float *)audioData length:(int)len;
- (void)processAudioQueue:(AudioQueueRef)q buffer:(AudioQueueBufferRef)buf;

//+ (void)makeStereo;


@end