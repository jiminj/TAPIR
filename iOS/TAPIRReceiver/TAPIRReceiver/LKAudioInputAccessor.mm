//
//  LKAudioInputAccessor.m
//  AudioBufferCorrelationTest
//
//  Created by dilu on 10/1/13.
//  Copyright (c) 2013 dilu. All rights reserved.
//

#import "LKAudioInputAccessor.h"
#import "TapirConfig.h"


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

    [aia newInputBuffer:static_cast<SInt16*>(inBuffer->mAudioData) length:inNumPackets];
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

-(void)prepareAudioInputWithCorrelationWindowSize:(int)windowSize andBacktrackBufferSize:(int)bufferSize
{

    
        // set audio format for recording
    aqData.mDataFormat.mFormatID         = kAudioFormatLinearPCM;
    aqData.mDataFormat.mSampleRate       = [cfg kAudioSampleRate];
    aqData.mDataFormat.mChannelsPerFrame = [cfg kAudioChannel];
    aqData.mDataFormat.mBitsPerChannel   = sizeof (SInt16)* 8;
    aqData.mDataFormat.mBytesPerPacket   =
    aqData.mDataFormat.mBytesPerFrame =
    aqData.mDataFormat.mChannelsPerFrame * sizeof (SInt16);
    aqData.mDataFormat.mFramesPerPacket  = 1;
    
    aqData.mDataFormat.mFormatFlags =
    kLinearPCMFormatFlagIsSignedInteger
    | kLinearPCMFormatFlagIsPacked;
    aqData.bufferByteSize = 1024;
    
    filter = Tapir::TapirFilters::getTxRxHpf(aqData.bufferByteSize / sizeof(SInt16));
    floatBuf = new float[aqData.bufferByteSize / sizeof(SInt16)];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0] ;
    
    AudioStreamBasicDescription asbd;
    bzero(&asbd, sizeof(asbd));
    asbd.mSampleRate = [cfg kAudioSampleRate];
    asbd.mFramesPerPacket = 1;
    asbd.mChannelsPerFrame = [cfg kAudioChannel];
    asbd.mBytesPerPacket = asbd.mBytesPerFrame = sizeof (SInt16);
    asbd.mBitsPerChannel = 8 * sizeof (SInt16);
    asbd.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    asbd.mFormatID = kAudioFormatLinearPCM;
    
    AudioFileCreateWithURL((__bridge CFURLRef)([NSURL fileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"audio.caf"]]), kAudioFileCAFType, &asbd, kAudioFileFlags_EraseFile, &audioFile);
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

-(void)newInputBuffer:(SInt16 *)inputBuffer length:(int)length
{
    vDSP_vflt16(inputBuffer, 1, floatBuf, 1, length);
    filter->process(floatBuf, floatBuf, length);
    for(int i=0; i<length;++i)
    {
        [correlationManager newSample:floatBuf[i]];
    }
}

-(void)restart{
    [correlationManager restart];
}
- (void)dealloc
{
    delete [] floatBuf;
    delete filter;
}
@end
