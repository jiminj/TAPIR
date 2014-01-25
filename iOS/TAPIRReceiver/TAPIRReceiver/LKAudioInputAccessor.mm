//
//  LKAudioInputAccessor.m
//  AudioBufferCorrelationTest
//
//  Created by dilu on 10/1/13.
//  Copyright (c) 2013 dilu. All rights reserved.
//

#import "LKAudioInputAccessor.h"

@implementation LKAudioInputAccessor

static void HandleInputBuffer (void                                *audioInput,
                               AudioQueueRef                       inAQ,
                               AudioQueueBufferRef                 inBuffer,
                               const AudioTimeStamp                *inStartTime,
                               UInt32                              inNumPackets,
                               const AudioStreamPacketDescription  *inPacketDesc )
{
    LKAudioInputAccessor *aia = (__bridge LKAudioInputAccessor *) audioInput;
    
    if (inNumPackets == 0 && aia->audioDesc.mBytesPerPacket != 0)
        inNumPackets = inBuffer->mAudioDataByteSize / aia->audioDesc.mBytesPerPacket;

    [aia newInputBuffer:static_cast<SInt16*>(inBuffer->mAudioData) length:inNumPackets];
    AudioQueueEnqueueBuffer (inAQ,inBuffer,0,NULL);
}

- (id) initWithFrameSize:(int)length detector:(Tapir::SignalDetector *)_detector
{
    if(self = [super init])
    {
        // set audio format for recording
        audioDesc.mSampleRate       = Tapir::Config::AUDIO_SAMPLE_RATE;
        audioDesc.mFormatID         = kAudioFormatLinearPCM;
        audioDesc.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
        audioDesc.mBitsPerChannel   = 8 * sizeof (SInt16);
        audioDesc.mChannelsPerFrame = 1;
        audioDesc.mBytesPerFrame    = audioDesc.mChannelsPerFrame * audioDesc.mBitsPerChannel / 8;
        audioDesc.mFramesPerPacket  = 1;
        audioDesc.mBytesPerPacket   = audioDesc.mBytesPerFrame * audioDesc.mFramesPerPacket;
        
        frameLength = length;
        filter = Tapir::TapirFilters::getTxRxHpf(frameLength);
        floatBuf = new float[frameLength];
        
        
        detector = _detector;
        
        // create audio input
        AudioQueueNewInput ( &audioDesc, HandleInputBuffer, (__bridge void *)(self), NULL, kCFRunLoopCommonModes, 0, &audioQueue);
        
        
        // prepare audio buffer
        for (int i = 0; i < kNumBuffers; ++i) {
            AudioQueueAllocateBuffer ( audioQueue, frameLength * audioDesc.mBytesPerFrame, &buffer[i]);
            AudioQueueEnqueueBuffer (audioQueue, buffer[i], 0, NULL);
        }
        
    }
    return self;
}

-(void)startAudioInput{
    AudioQueueStart(audioQueue, NULL);
}

-(void)stopAudioInput{
    AudioQueueStop(audioQueue, true);
}

-(void)newInputBuffer:(SInt16 *)inputBuffer length:(int)length
{
    vDSP_vflt16(inputBuffer, 1, floatBuf, 1, length);
    vDSP_vsdiv(floatBuf, 1, &kShortMax, floatBuf, 1, length);
    //convert SInt16 array to float, and scale them (set max value to 1.0)

    detector->detect(floatBuf);
}

- (void)dealloc
{
    for(int i=0; i<kNumBuffers; ++i)
    { AudioQueueFreeBuffer(audioQueue, buffer[i]); }
    AudioQueueDispose(audioQueue, true);
    delete [] floatBuf;
    delete filter;
}


@end