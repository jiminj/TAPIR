//
//  SoundPlayer.m
//  musiculesdev
//
//  Created by Dylan on 1/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Sonifier.h"



@implementation Sonifier

@synthesize dataLength;
@synthesize isDone;
@synthesize delegate;


static void aqCallBack(void *in, AudioQueueRef q, AudioQueueBufferRef qb)
{
    Sonifier * thisInstance = (__bridge Sonifier *)in;
    [thisInstance processAudioQueue:q buffer:qb];
}


-(id)init{
    return nil;
}

- (id)initWithConfig:(TapirConfig *)_cfg
{
    if(self = [super init]) {
        cfg = _cfg;
		
        audioDesc.mSampleRate = [cfg kAudioSampleRate];
		audioDesc.mFormatID = kAudioFormatLinearPCM;
		audioDesc.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
        audioDesc.mBitsPerChannel = 8 * sizeof(SInt16);
		audioDesc.mChannelsPerFrame = [cfg kAudioChannel];
		audioDesc.mBytesPerFrame = audioDesc.mChannelsPerFrame * audioDesc.mBitsPerChannel / 8;
		audioDesc.mFramesPerPacket = 1;
		audioDesc.mBytesPerPacket = audioDesc.mBytesPerFrame * audioDesc.mFramesPerPacket;
        frameLength = 1024;
        isDone = TRUE;
        
        outputLock = [[NSLock alloc] init];
        
//        OSStatus err = AudioQueueNewOutput(&audioDesc, aqCallBack, (__bridge void *)(self), CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &audioQueue); // CFRunLoopGetCurrent()

        OSStatus err = AudioQueueNewOutput(&audioDesc, aqCallBack, (__bridge void *)(self), nil, kCFRunLoopCommonModes, 0, &audioQueue); // make a new thread for audio output

        
        audioBufferByteSize = audioDesc.mBytesPerFrame * frameLength; // 1 frame per packet, two shorts per frame = 4 * frames)
        
        if(err != noErr)
        {
            NSLog(@"ERR");
        }
        
        for(int i = 0; i < kNumBuffers; i++)
        {
            OSStatus err = AudioQueueAllocateBuffer(audioQueue, frameLength * audioDesc.mBytesPerFrame, &buffer[i]);
            if(err != noErr) {
                NSLog(@"err:%d\n", (unsigned int)err);
            }
        }
        
    }
    
	return self;
}

-(void)transmit:(float *)_audioData length:(int)len
{
    doneCnt = 0;
    isDone = FALSE;

    for(int i = 0; i < kNumBuffers; i++)
    {
        aqCallBack((__bridge void *)(self), audioQueue, buffer[i]); //prime buffer
    }

    dataLength = len; //set Frame Length
    audioData = _audioData;

    OSStatus err = AudioQueueStart(audioQueue, NULL);
    if(err != noErr)
    { NSLog(@"cannot play"); }
    
}


- (void)processAudioQueue:(AudioQueueRef)q buffer:(AudioQueueBufferRef)buf
{
    [outputLock lock];
    
    SInt16 * bufferData = (SInt16 *)buf->mAudioData;
	buf->mAudioDataByteSize = audioBufferByteSize;

    
    if(dataLength > 0) //isRunning
    {
        int copyLen;
        int newDataLength = 0;
        
        if(dataLength > frameLength)
        {
            copyLen = frameLength;
            newDataLength = dataLength - frameLength;
        }
        else
        {
            copyLen = dataLength;
            memset(bufferData+copyLen, 0, sizeof(SInt16) * (frameLength - dataLength));
            isDone = TRUE;
        }
        vDSP_vsmul(audioData, 1, &kShortMax, audioData, 1, copyLen); //maximize volume
        vDSP_vfix16(audioData, 1, bufferData, 1, copyLen); //float to SInt16

        audioData += copyLen;
        dataLength = newDataLength;
        
        AudioQueueEnqueueBuffer(q, buf, 0, NULL);
        [outputLock unlock];

    }
    else
    {

        if(isDone)
        {
            [outputLock unlock];
            if(++doneCnt >= kNumBuffers)
            {
                OSStatus err = AudioQueueStop(q, true);
                if(err!=noErr)
                {
                    NSLog(@"Cannot Stop");
                }
                [delegate sonifierFinished];
            }

        }
        else //For Primary Buffer
        {
            memset(bufferData, 0, frameLength * sizeof(SInt16));
            AudioQueueEnqueueBuffer(q, buf, 0, NULL);
            [outputLock unlock];
        }
    }
}

-(void)dealloc {
    AudioQueueDispose(audioQueue, true);
}
@end