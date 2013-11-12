//
//  ViewController.m
//  AudioBufferCorrelationTest
//
//  Created by dilu on 9/25/13.
//  Copyright (c) 2013 dilu. All rights reserved.
//

#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface ViewController ()

@end

@implementation ViewController
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

static void HandleInputBuffer (
                               void                                *aqData,             // 1
                               AudioQueueRef                       inAQ,                // 2
                               AudioQueueBufferRef                 inBuffer,            // 3
                               const AudioTimeStamp                *inStartTime,        // 4
                               UInt32                              inNumPackets,        // 5
                               const AudioStreamPacketDescription  *inPacketDesc        // 6
){
    struct AQRecorderState *pAqData = (struct AQRecorderState *) aqData;               // 1
    
    if (inNumPackets == 0 &&                                             // 2
        pAqData->mDataFormat.mBytesPerPacket != 0)
        inNumPackets =
        inBuffer->mAudioDataByteSize / pAqData->mDataFormat.mBytesPerPacket;
    
    short* buffer = inBuffer->mAudioData;
    short sampleValue;
    for(int i = 0; i<inNumPackets; i++){
        sampleValue = buffer[i];
    }

    AudioQueueEnqueueBuffer (                                            // 6
                             inAQ,
                             inBuffer,
                             0,
                             NULL
                             );

}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    struct AQRecorderState aqData;                                       // 1
    
    aqData.mDataFormat.mFormatID         = kAudioFormatLinearPCM; // 2
    aqData.mDataFormat.mSampleRate       = 44100.0;               // 3
    aqData.mDataFormat.mChannelsPerFrame = 1;                     // 4
    aqData.mDataFormat.mBitsPerChannel   = 16;                    // 5
    aqData.mDataFormat.mBytesPerPacket   =                        // 6
    aqData.mDataFormat.mBytesPerFrame =
    aqData.mDataFormat.mChannelsPerFrame * sizeof (SInt16);
    aqData.mDataFormat.mFramesPerPacket  = 1;                     // 7
    
    aqData.mDataFormat.mFormatFlags =                             // 9
    kLinearPCMFormatFlagIsBigEndian
    | kLinearPCMFormatFlagIsSignedInteger
    | kLinearPCMFormatFlagIsPacked;
    aqData.bufferByteSize = 1024;
    
    AudioQueueNewInput (                              // 1
                        &aqData.mDataFormat,                          // 2
                        HandleInputBuffer,                            // 3
                        &aqData,                                      // 4
                        NULL,                                         // 5
                        kCFRunLoopCommonModes,                        // 6
                        0,                                            // 7
                        &aqData.mQueue                                // 8
                        );
    
    UInt32 dataFormatSize = sizeof (aqData.mDataFormat);       // 1
    
    AudioQueueGetProperty (                                    // 2
                           aqData.mQueue,                                         // 3
                           kAudioQueueProperty_StreamDescription,                 // 4
                           // in Mac OS X, instead use
                           //    kAudioConverterCurrentInputStreamDescription
                           &aqData.mDataFormat,                                   // 5
                           &dataFormatSize                                        // 6
                           );
    

    
    
    for (int i = 0; i < kNumberBuffers; ++i) {           // 1
        AudioQueueAllocateBuffer (                       // 2
                                  aqData.mQueue,                               // 3
                                  aqData.bufferByteSize,                              // 4
                                  &aqData.mBuffers[i]                          // 5
                                  );
        
        AudioQueueEnqueueBuffer (                        // 6
                                 aqData.mQueue,                               // 7
                                 aqData.mBuffers[i],                          // 8
                                 0,                                           // 9
                                 NULL                                         // 10
                                 );
    }
    
    aqData.mCurrentPacket = 0;                           // 1
    aqData.mIsRunning = true;                            // 2
    
    AudioQueueStart (                                    // 3
                     aqData.mQueue,                                   // 4
                     NULL                                             // 5
                     );
                      // 9
    
    
}
/*
-(void)dealloc{
    // Wait, on user interface thread, until user stops the recording
    AudioQueueStop (                                     // 6
                    aqData.mQueue,                                   // 7
                    true                                             // 8
                    );
    
    aqData.mIsRunning = false;
    [super dealloc]
}*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

