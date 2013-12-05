//
//  LKAudioInputAccessor.m
//  AudioBufferCorrelationTest
//
//  Created by dilu on 10/1/13.
//  Copyright (c) 2013 dilu. All rights reserved.
//

#import "LKAudioInputAccessor.h"
#import "TapirConfig.h"

#define SELF_CORRELATION true


@implementation LKAudioInputAccessor
@synthesize correlationOffset = _correlationOffset;
@synthesize correlationSampleSize = _correlationSampleSize;
@synthesize aqData;
@synthesize delegate;
@synthesize correlationManager;

static void HandleInputBuffer (
                               void                                *audioInput,
                               AudioQueueRef                       inAQ,
                               AudioQueueBufferRef                 inBuffer,
                               const AudioTimeStamp                *inStartTime,
                               UInt32                              inNumPackets,
                               const AudioStreamPacketDescription  *inPacketDesc
){
    LKAudioInputAccessor *aia = (__bridge LKAudioInputAccessor *) audioInput;
    
    if (inNumPackets == 0 && aia.aqData.mDataFormat.mBytesPerPacket != 0)
        inNumPackets = inBuffer->mAudioDataByteSize / aia.aqData.mDataFormat.mBytesPerPacket;
    
    SInt16* buffer = inBuffer->mAudioData;

    for(int i = 0; i<inNumPackets; i++){
        [aia newSample:buffer[i]];
    }
    
    AudioQueueEnqueueBuffer (inAQ,inBuffer,0,NULL);
    
}

- (id) init
{
    if(self = [super init])
    {
        cfg = [TapirConfig getInstance];
    }
    return self;
}

-(void)prepareAudioInputWithCorrelationWindowSize:(int)windowSize andBacktrackBufferSize:(int)bufferSize{
    //hpf = [[LKBiquadHPF alloc] init];
    filter = [TapirMotherOfAllFilters createHPF1];
    
        // set audio format for recording
    aqData.mDataFormat.mFormatID         = kAudioFormatLinearPCM;
    aqData.mDataFormat.mSampleRate       = [cfg kAudioSampleRate];
    aqData.mDataFormat.mChannelsPerFrame = [cfg kAudioChannel];
    aqData.mDataFormat.mBitsPerChannel   = sizeof (SInt16)* [cfg kAudioBitsPerChannel];
    aqData.mDataFormat.mBytesPerPacket   =
    aqData.mDataFormat.mBytesPerFrame =
    aqData.mDataFormat.mChannelsPerFrame * sizeof (SInt16);
    aqData.mDataFormat.mFramesPerPacket  = 1;
    
    aqData.mDataFormat.mFormatFlags =
    kLinearPCMFormatFlagIsSignedInteger
    | kLinearPCMFormatFlagIsPacked;
    aqData.bufferByteSize = 1024;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0] ;
    
    AudioStreamBasicDescription asbd;
    bzero(&asbd, sizeof(asbd));
    asbd.mSampleRate = [cfg kAudioSampleRate];
    asbd.mFramesPerPacket = 1;
    asbd.mChannelsPerFrame = [cfg kAudioChannel];
    asbd.mBytesPerPacket = asbd.mBytesPerFrame = sizeof (SInt16);
    asbd.mBitsPerChannel = [cfg kAudioBitsPerChannel] * sizeof (SInt16);
    asbd.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    asbd.mFormatID = kAudioFormatLinearPCM;
    
    OSStatus err = AudioFileCreateWithURL((__bridge CFURLRef)([NSURL fileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"audio.caf"]]), kAudioFileCAFType, &asbd, kAudioFileFlags_EraseFile, &audioFile);
    audioFileLength =0;

    
    // create audio input
    AudioQueueNewInput (
                        &aqData.mDataFormat,
                        HandleInputBuffer,
                        (__bridge void *)(self),
                        NULL,
                        kCFRunLoopCommonModes,
                        0,
                        &aqData.mQueue
                        );
    
    UInt32 dataFormatSize = sizeof (aqData.mDataFormat);
    
    AudioQueueGetProperty (
                           aqData.mQueue,
                           kAudioQueueProperty_StreamDescription,
                           // in Mac OS X, instead use
                           //    kAudioConverterCurrentInputStreamDescription
                           &aqData.mDataFormat,
                           &dataFormatSize
                           );
    
    // prepare audio buffer
    for (int i = 0; i < kNumberBuffers; ++i) {
        AudioQueueAllocateBuffer (
                                  aqData.mQueue,
                                  aqData.bufferByteSize,
                                  &aqData.mBuffers[i]
                                  );
        
        AudioQueueEnqueueBuffer (
                                 aqData.mQueue,
                                 aqData.mBuffers[i],
                                 0,
                                 NULL
                                 );
    }
    
    //init correlation manager
    correlationManager = [[LKCorrelationManager alloc] initWithCorrelationWindowSize:windowSize andBacktrackSize:bufferSize];
}

-(void)startAudioInput{
    AudioQueueStart(aqData.mQueue, NULL);
}

-(void)stopAudioInput{
    AudioQueueStop(aqData.mQueue, true);
}
-(void)trace{
    [correlationManager trace];
}
-(void)newSample:(SInt16)sample{
    // test code for file recording
    //float fileteredSample = [hpf next:sample];
    float filteredSample = 0;
    [filter next:sample*1.0 writeTo:&filteredSample];
    //filteredSample*=10;
   /*SInt16 s = filteredSample;
    UInt32 n = 1;
    OSStatus err = AudioFileWritePackets(audioFile, NO, 1, nil, audioFileLength, &n, &s);
    audioFileLength+=n;*/
    
    
    [correlationManager newSample:filteredSample];
}
-(void)restart{
    [correlationManager restart];
}
@end
