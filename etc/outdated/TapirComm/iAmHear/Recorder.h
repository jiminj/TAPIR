//
//  Recorder.h
//  ParrotAim
//
//  Created by Seunghun Kim on 10. 5. 4..
//  Copyright 2010 카이스트. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioQueue.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "strDecoder.h"
#define kNumberBuffers  1                          // 1

typedef struct AQRecorderState {
    AudioStreamBasicDescription  mDataFormat;                   // 2
    AudioQueueRef                mQueue;                        // 3
    AudioQueueBufferRef          mBuffers[kNumberBuffers];      // 4
    AudioFileID                  mAudioFile;                    // 5
    UInt32                       bufferByteSize;                // 6
    SInt64                       mCurrentPacket;                // 7
    bool                         mIsRunning;                    // 8
	bool						rec;

    void*                    recorder;
    
} AQRecorderState;

@interface Recorder : NSObject {
	AQRecorderState aqData;   
	NSString* documentsDirectory;
	NSString* path;
    strDecoder* decoder;
    
    
    double input_values[44100];
    int input_index;
    double x[30];
    double y[30];
    double mean_vals[10];
    NSString* results;
    
    int index_updated;
    int updated;
    char signal_values[10];
    
    double threshold;
    
    int filter_freq;
}

@property (nonatomic, assign) AQRecorderState aqData;

//-(void)prepare;
//-(void)recordTo:(int)fileIndex;
-(void)start;
-(void)stop;
//-(Float32)traceLevel;
-(BOOL)isRec;
-(NSString*)getPath;
- (float) averagePower;
void DeriveBufferSize (
                       
                       AudioQueueRef                audioQueue,                  // 1
                       
                       AudioStreamBasicDescription  ASBDescription,             // 2
                       
                       Float64                      seconds,                     // 3
                       
                       UInt32                       *outBufferSize               // 4
                       
                       );

- (void) addFilter:(double) sample;
- (void) setMean_val;
- (double*) getMean_val;
- (void) setSignal:(double) val;
- (char*) getSignal;
- (int) getUpdated;
- (NSString*) getString;
- (void) setUpdated:(int) t;
- (void) setThreshold:(double) val;
- (double) getThreshold;
- (void) setFreq:(int) t;
- (int) getCheck;
@end
