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

    AudioStreamBasicDescription audioDesc;
    AudioQueueRef queue;
    AudioQueueBufferRef buffer[NUM_BUFFERS];
    UInt32 frameCount;
    
    float * audioData;
    
    int dataLength;
    
    BOOL isPlaying;
    BOOL isDone;
    int doneCnt;

}

@property int dataLength;
@property id <SonifierDelegate> delegate;
@property BOOL isPlaying;

- (id)initWithConfig:(TapirConfig *)_cfg;
- (void)transmit:(float *)audioData length:(int)len;
- (void)processAudioQueue:(AudioQueueRef)q buffer:(AudioQueueBufferRef)buf;

//+ (void)makeStereo;


@end