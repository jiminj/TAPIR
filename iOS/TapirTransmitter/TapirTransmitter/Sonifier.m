//
//  SoundPlayer.m
//  musiculesdev
//
//  Created by Dylan on 1/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Sonifier.h"
#define pulsePeriod 4410

@implementation Sonifier

@synthesize aqData;
@synthesize phaseIncrement;
@synthesize currentPhase;
@synthesize indexCount;
@synthesize period;
@synthesize smooth;
@synthesize samples;
@synthesize length;
@synthesize samples2;
@synthesize length2;

//float smoothing[245] = {0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1,1,1,1,1,1,0.9,0.8,0.7,0.6,0.5,0.4,0.3,0.2,0.1};
//float smoothing[24] = {0.0078125,0.015625,0.03125,0.0625,0.125,0.25,0.5,1,1,1,1,1,1,1,1,1,1,0.5,0.25,0.125,0.0625,0.03125,0.015625,0.0078125};

static void aqCallBack(void *in, AudioQueueRef q, AudioQueueBufferRef qb) {
    Sonifier *data = (__bridge Sonifier *)in;
    SInt16 *buffer = (SInt16 *)qb->mAudioData;
	qb->mAudioDataByteSize = sizeof(SInt16)* data.aqData.frameCount; // 1 frame per packet, two shorts per frame = 4 * frames

    
    for(int i = 0; i<data.aqData.frameCount*2; i+=2){
        if(data.length>0){
            buffer[i] =( *(++data.samples))* 30000;
            --data.length;
        }else{
            buffer[i]=0;
        }
        if(data.length2>0){
            buffer[i+1] =( *(++data.samples2))* 30000;
            --data.length2;
        }else{
            buffer[i+1]=0;
        }
    }

	AudioQueueEnqueueBuffer(q, qb, 0, NULL);
     
}   
-(id)init{
	if(self = [super init]) {
        TapirConfig* cfg = [TapirConfig getInstance];
		aqData.dataFormat.mSampleRate = [cfg kAudioSampleRate];
		aqData.dataFormat.mFormatID = kAudioFormatLinearPCM;
		aqData.dataFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger|kAudioFormatFlagIsPacked;
		aqData.dataFormat.mBitsPerChannel = [cfg kAudioBitsPerChannel] * sizeof (SInt16);
		aqData.dataFormat.mChannelsPerFrame = 2;
        aqData.dataFormat.mBytesPerFrame = aqData.dataFormat.mChannelsPerFrame*aqData.dataFormat.mBitsPerChannel/8;
		aqData.dataFormat.mFramesPerPacket = 1;
		aqData.dataFormat.mBytesPerPacket = aqData.dataFormat.mBytesPerFrame * aqData.dataFormat.mFramesPerPacket;
		aqData.frameCount = 1024;
        //samples = malloc(sizeof(float)*[cfg kAudioBufferLength]);
        length = 0;
        length2 = 0;
        
		AudioQueueNewOutput(&aqData.dataFormat, aqCallBack, (__bridge void *)(self), CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &aqData.queue); // CFRunLoopGetCurrent()
		smooth = NO;
        [self setFreq:18000];
        currentPhase = 0;
        indexCount = 0;
		for(int i = 0; i < NUM_BUFFERS; i++) {
			
			UInt32 err = AudioQueueAllocateBuffer(aqData.queue, aqData.frameCount * aqData.dataFormat.mBytesPerFrame, &aqData.buffers[i]);
			if(err) {
				NSLog(@"err:%d\n");
			}
			
			aqCallBack((__bridge void *)(self), aqData.queue, aqData.buffers[i]); //prime buffer
		}
        
        
		
		//AudioQueueSetParameter(aqData.queue, kAudioQueueParam_Volume, 1.0f);
		
	}
	
	return self;
	
}

-(void)setFreq:(float)freq{
    phaseIncrement = 2*3.141592*freq/44100;
    
    period = 100*44100/freq;
}

-(void)start {
	AudioQueueStart(aqData.queue, NULL);
}

-(void)stop {
	AudioQueueStop(aqData.queue, true);
}

-(void)dealloc {
	AudioQueueDispose(aqData.queue, true);
}

-(void)transmit:(float *)sampleArray length:(int)l{
    samples = sampleArray;
    length = l;
}
-(void)transmitRight:(float *)sampleArray length:(int)l{
    samples2 = sampleArray;
    length2 = l;
}
@end  