//
//  LKAudioInputAccessor.h
//  AudioBufferCorrelationTest
//
//  Created by dilu on 10/1/13.
//  Copyright (c) 2013 dilu. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#import <TapirLib/TapirLib.h>
//#import "Sonifier.h"
//
//static const float kShortMax = (float)(SHRT_MAX);
//static const int kNumBuffers = 3;

@interface LKAudioInputAccessor : NSObject{

    AudioStreamBasicDescription  audioDesc;
    AudioQueueRef                audioQueue;
    AudioQueueBufferRef          buffer[kNumBuffers];
    AudioFileID                  mAudioFile;
    UInt32                       frameLength;

    AVAudioSession *             audioSession;
    

    float *floatBuf;
    Tapir::SignalDetector * detector;

    
}

- (id) initWithFrameSize:(int)length detector:(Tapir::SignalDetector *)_detector;
-(void)startAudioInput;
-(void)stopAudioInput;
-(void)newInputBuffer:(SInt16 *)inputBuffer length:(int)length;

-(void)audioSessionRouteChanged:(NSNotification*)noti;
@end
