//
//  LKAudioInputAccessor.h
//  AudioBufferCorrelationTest
//
//  Created by dilu on 10/1/13.
//  Copyright (c) 2013 dilu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "LKCorrelationManager.h"
#import "TapirLib/TapirLib.h"
#import "TapirConfig.h"
#import <AVFoundation/AVFoundation.h>

@protocol correlationDelegate <NSObject>
-(void)newCorrelationValue:(float)value;
@end

static const int kNumberBuffers = 3;                            // 1
struct AQRecorderState {
    AudioStreamBasicDescription  mDataFormat;                   // 2
    AudioQueueRef                mQueue;                        // 3
    AudioQueueBufferRef          mBuffers[kNumberBuffers];      // 4
    AudioFileID                  mAudioFile;                    // 5
    UInt32                       bufferByteSize;                // 6
    SInt64                       mCurrentPacket;                // 7
    bool                         mIsRunning;                    // 8
};
@interface LKAudioInputAccessor : NSObject{
    TapirConfig * cfg;
    struct AQRecorderState aqData;
    int _correlationSampleSize;
    int _correlationOffset;
    float* sampleBufferA;
    int sampleBufferAIndex;
    int sampleBufferBIndex;
    float* sampleBufferB;
    float sumA;
    float sumB;
    float squareSumA;
    float squareSumB;
    float sumAB;
    BOOL sampleBSumCalculated;
    id<correlationDelegate> delegate;
    LKCorrelationManager* correlationManager;
    LKBiquadHPF* hpf;
    TapirMotherOfAllFilters* filter;
    AudioFileID audioFile;
    NSString* documentsDirectory;
    int audioFileLength;

}
@property int correlationSampleSize;
@property int correlationOffset;
@property struct AQRecorderState aqData;
@property id<correlationDelegate> delegate;
@property LKCorrelationManager* correlationManager;

-(void)prepareAudioInputWithCorrelationWindowSize:(int)windowSize andBacktrackBufferSize:(int)bufferSize;
-(void)startAudioInput;
-(void)stopAudioInput;
-(void)advanceIndices;
-(void)subtractLastSample;
-(void)writeNewSampleValue:(float)value;
-(void)addNewSample;
-(float)calculateCorrelation;
-(float)calculateCorrelationWithReferenceWithANewSampleValue:(float)value;
-(void)trace;
-(void)newSample:(SInt16)sample;
@end
