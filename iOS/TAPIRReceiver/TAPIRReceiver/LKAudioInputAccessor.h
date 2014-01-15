//
//  LKAudioInputAccessor.h
//  AudioBufferCorrelationTest
//
//  Created by dilu on 10/1/13.
//  Copyright (c) 2013 dilu. All rights reserved.
//

#include <TapirLib/Filter.h>
#include <TapirLib/TapirLib.h>
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "LKCorrelationManager.h"
#import "TapirLib/TapirLib.h"
#import "TapirConfig.h"
#import <AVFoundation/AVFoundation.h>



@protocol correlationDelegate <NSObject>
-(void)newCorrelationValue:(float)value;
@end

static const int kNumberBuffers = 3;
@interface LKAudioInputAccessor : NSObject{

    TapirConfig * cfg;

    AudioStreamBasicDescription  audioDesc;
    AudioQueueRef                audioQueue;
    AudioQueueBufferRef          buffer[kNumberBuffers];
    AudioFileID                  mAudioFile;
    UInt32                       frameLength;
    
    LKCorrelationManager* correlationManager;
    
    Tapir::FilterFIR * filter;
    float *floatBuf;
    
    //    AudioFileID audioFile;
    //    NSString* documentsDirectory;
    //    int audioFileLength;

}

@property LKCorrelationManager* correlationManager;

-(void)prepareAudioInputWithCorrelationWindowSize:(int)windowSize andBacktrackBufferSize:(int)bufferSize;
-(void)startAudioInput;
-(void)stopAudioInput;


-(void)trace;
-(void)restart;
-(void)newInputBuffer:(SInt16 *)inputBuffer;
@end
