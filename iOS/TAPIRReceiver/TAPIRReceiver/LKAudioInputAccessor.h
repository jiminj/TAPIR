//
//  LKAudioInputAccessor.h
//  AudioBufferCorrelationTest
//
//  Created by dilu on 10/1/13.
//  Copyright (c) 2013 dilu. All rights reserved.
//

#import <TapirLib/TapirLib.h>
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "TapirConfig.h"
#import "TapirSignalAnalyzer.h"
#import <AVFoundation/AVFoundation.h>


static const float kShortMax = (float)(SHRT_MAX);

static const int kNumBuffers = 3;
@interface LKAudioInputAccessor : NSObject{

    TapirConfig * cfg;
    TapirSignalAnalyzer * analyzer;
    AudioStreamBasicDescription  audioDesc;
    AudioQueueRef                audioQueue;
    AudioQueueBufferRef          buffer[kNumBuffers];
    AudioFileID                  mAudioFile;
    UInt32                       frameLength;
    
    Tapir::FilterFIR * filter;
    float *floatBuf;
    Tapir::SignalDetector * detector;

}

- (id) initWithFrameSize:(int)length detector:(Tapir::SignalDetector *)_detector;
-(void)startAudioInput;
-(void)stopAudioInput;

-(void)newInputBuffer:(SInt16 *)inputBuffer;
@end
