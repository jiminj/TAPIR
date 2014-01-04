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
@synthesize isPlaying;
//@synthesize isBufferInit;
@synthesize delegate;
//@synthesize aqData;

//@synthesize samples;
//@synthesize length;
//@synthesize samples2;
//@synthesize length2;


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
		audioDesc.mFormatFlags = kAudioFormatFlagIsSignedInteger|kAudioFormatFlagIsPacked;
        audioDesc.mBitsPerChannel = 8 * sizeof(SInt16);
		audioDesc.mChannelsPerFrame = [cfg kAudioChannel];
		audioDesc.mBytesPerFrame = audioDesc.mChannelsPerFrame * audioDesc.mBitsPerChannel / 8;
		audioDesc.mFramesPerPacket = 1;
		audioDesc.mBytesPerPacket = audioDesc.mBytesPerFrame * audioDesc.mFramesPerPacket;
        frameCount = 1024;
        
        OSStatus err = AudioQueueNewOutput(&audioDesc, aqCallBack, (__bridge void *)(self), CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &queue); // CFRunLoopGetCurrent()
        if(err != noErr)
        {
            NSLog(@"ERR");
        }
        
        for(int i = 0; i < NUM_BUFFERS; i++)
        {
            OSStatus err = AudioQueueAllocateBuffer(queue, frameCount * audioDesc.mBytesPerFrame, &buffer[i]);
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

    for(int i = 0; i < NUM_BUFFERS; i++)
    {
        aqCallBack((__bridge void *)(self), queue, buffer[i]); //prime buffer
    }

    [self setDataLength:len];
    audioData = _audioData;

    OSStatus err = AudioQueueStart(queue, NULL);
    if(err != noErr)
    { NSLog(@"cannot play"); }
    
}


- (void)processAudioQueue:(AudioQueueRef)q buffer:(AudioQueueBufferRef)buf
{


    SInt16 *bufferData = (SInt16 *)buf->mAudioData;
	buf->mAudioDataByteSize = audioDesc.mChannelsPerFrame * frameCount * sizeof(SInt16); // 1 frame per packet, two shorts per frame = 4 * frames)
    
//    NSLog(@"callback - %d of %d",dataLength, buf->mAudioData);
    float shortMax = (float)(SHRT_MAX);
    if(dataLength > 0) //isRunning
    {
        int copyLen;
        int newDataLength = 0;
        
        if(dataLength > frameCount)
        {
            copyLen = frameCount;
            newDataLength = dataLength - frameCount;
        }
        else
        {
            copyLen = dataLength;
            memset(bufferData+copyLen, 0, sizeof(SInt16) * (frameCount - dataLength));
            isDone = TRUE;
        }
        vDSP_vsmul(audioData, 1, &shortMax, audioData, 1, copyLen);
        vDSP_vfix16(audioData, 1, bufferData, 1, copyLen);

        audioData += copyLen;
        dataLength = newDataLength;
        
        AudioQueueEnqueueBuffer(q, buf, 0, NULL);
    }
    else
    {
        if(isDone)
        {
            if(++doneCnt >= NUM_BUFFERS)
            {
                OSStatus err = AudioQueueStop(q, true);
                if(err!=noErr)
                {
                    NSLog(@"Cannot Stop");
                }
                [delegate sonifierFinished];
            }
        }
        else
        {
            memset(bufferData, 0, frameCount * sizeof(SInt16));
            AudioQueueEnqueueBuffer(q, buf, 0, NULL);
        }
    }
}

-(void)dealloc {
    AudioQueueDispose(queue, true);
}
@end