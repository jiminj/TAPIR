//
//  LKAudioInputAccessor.m
//  AudioBufferCorrelationTest
//
//  Created by dilu on 10/1/13.
//  Copyright (c) 2013 dilu. All rights reserved.
//

#import "LKAudioInputAccessor.h"

#define SELF_CORRELATION true


@implementation LKAudioInputAccessor
@synthesize correlationOffset = _correlationOffset;
@synthesize correlationSampleSize = _correlationSampleSize;
@synthesize aqData;
@synthesize delegate;

static void HandleInputBuffer (
                               void                                *audioInput,
                               AudioQueueRef                       inAQ,
                               AudioQueueBufferRef                 inBuffer,
                               const AudioTimeStamp                *inStartTime,
                               UInt32                              inNumPackets,
                               const AudioStreamPacketDescription  *inPacketDesc
){
    LKAudioInputAccessor *aia = (__bridge LKAudioInputAccessor *) audioInput;
    
    if (inNumPackets == 0 &&
        aia.aqData.mDataFormat.mBytesPerPacket != 0)
        inNumPackets =
        inBuffer->mAudioDataByteSize / aia.aqData.mDataFormat.mBytesPerPacket;
    
    short* buffer = inBuffer->mAudioData;
    short sampleValue;
    
    if(SELF_CORRELATION){
        for(int i = 0; i<inNumPackets; i++){
            sampleValue = buffer[i];
            [aia advanceIndices];
            [aia subtractLastSample];
            [aia writeNewSampleValue:sampleValue];
            [aia addNewSample];
            float correlation = [aia calculateCorrelation];
            [aia.delegate newCorrelationValue:correlation];
        }
    }else{
        for(int i = 0; i<inNumPackets; i++){
            float correlation = [aia calculateCorrelationWithReferenceWithANewSampleValue:sampleValue];
            [aia.delegate newCorrelationValue:correlation];
        }
    }
    
    AudioQueueEnqueueBuffer (inAQ,inBuffer,0,NULL);
    
}

-(void)prepareAudioInput{
    aqData.mDataFormat.mFormatID         = kAudioFormatLinearPCM;
    aqData.mDataFormat.mSampleRate       = 44100.0;
    aqData.mDataFormat.mChannelsPerFrame = 1;
    aqData.mDataFormat.mBitsPerChannel   = 16;
    aqData.mDataFormat.mBytesPerPacket   =
    aqData.mDataFormat.mBytesPerFrame =
    aqData.mDataFormat.mChannelsPerFrame * sizeof (SInt16);
    aqData.mDataFormat.mFramesPerPacket  = 1;
    
    aqData.mDataFormat.mFormatFlags =
    kLinearPCMFormatFlagIsBigEndian
    | kLinearPCMFormatFlagIsSignedInteger
    | kLinearPCMFormatFlagIsPacked;
    aqData.bufferByteSize = 1024;
    
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
    
    if(SELF_CORRELATION){
        aqData.mCurrentPacket = 0;

        if(_correlationSampleSize<1) _correlationSampleSize = 1024;
        if(_correlationOffset<1) _correlationOffset = 1024;
        
        sampleBufferA = malloc(2*_correlationSampleSize);
        sampleBufferB = malloc(2*(_correlationSampleSize+_correlationOffset));
        sampleBufferAIndex = -1;
        sampleBufferBIndex = -1;
        for(int i = 0; i<_correlationSampleSize; i++){
            sampleBufferA[i] = 0.0;
        }
        for(int i = 0; i<_correlationOffset+_correlationSampleSize; i++){
            sampleBufferB[i] = 0.0;
        }
    }else{
        aqData.mCurrentPacket = 0;
        
        if(_correlationSampleSize<1) _correlationSampleSize = 1024;
        sampleBufferA = malloc(2*_correlationSampleSize);
        sampleBufferB = malloc(2*_correlationSampleSize);
        sampleBufferAIndex = -1;
        sampleBufferBIndex = -1;
        for(int i = 0; i<_correlationSampleSize; i++){
            sampleBufferA[i] = 0.0;
        }
        for(int i = 0; i<_correlationSampleSize; i++){
            sampleBufferB[i] = 0.0;
        }
    }
    sumA = 0;
    sumB = 0;
    squareSumA = 0;
    squareSumB = 0;
    sumAB = 0;
    sampleBSumCalculated = NO;
    
}
-(void)startAudioInput{
    AudioQueueStart(aqData.mQueue, NULL);
}
-(void)stopAudioInput{
    AudioQueueStop(aqData.mQueue, true);
}
-(void)advanceIndices{
    sampleBufferAIndex++;
    if(sampleBufferAIndex>=_correlationSampleSize)sampleBufferAIndex=0;
    sampleBufferBIndex++;
    if(sampleBufferBIndex>=(_correlationSampleSize+_correlationOffset))sampleBufferBIndex=0;
}
-(void)subtractLastSample{
    sumA -= sampleBufferA[sampleBufferAIndex];
    squareSumA -= sampleBufferA[sampleBufferAIndex]*sampleBufferA[sampleBufferAIndex];
    sumB -= sampleBufferB[sampleBufferBIndex];
    squareSumB -= sampleBufferB[sampleBufferBIndex]*sampleBufferB[sampleBufferBIndex];
    sumAB -= sampleBufferA[sampleBufferAIndex]*sampleBufferB[sampleBufferBIndex];
}
-(void)writeNewSampleValue:(float)value{
    sampleBufferA[sampleBufferAIndex] = value;
    sampleBufferB[sampleBufferBIndex] = value;
}
-(void)addNewSample{
    sumA += sampleBufferA[sampleBufferAIndex];
    squareSumA += sampleBufferA[sampleBufferAIndex]*sampleBufferA[sampleBufferAIndex];
    int sampleBufferBOffsetIndex = sampleBufferBIndex+_correlationOffset;
    if(sampleBufferBOffsetIndex>=(_correlationOffset+_correlationSampleSize)){
        sampleBufferBOffsetIndex-=(_correlationOffset+_correlationSampleSize);
    }
    sumB += sampleBufferB[sampleBufferBOffsetIndex];
    squareSumB += sampleBufferB[sampleBufferBOffsetIndex]*sampleBufferB[sampleBufferBOffsetIndex];
    sumAB += sampleBufferA[sampleBufferAIndex]*sampleBufferB[sampleBufferBOffsetIndex];
}
-(float)calculateCorrelation{
    return (sumAB - sumA*sumB/_correlationSampleSize)/sqrtf((squareSumA-sumA*sumA/_correlationSampleSize)*(squareSumB-sumB*sumB/_correlationSampleSize));
}
-(float)calculateCorrelationWithReferenceWithANewSampleValue:(float)value{
    if(!sampleBSumCalculated){
        for(int i = 0; i<_correlationSampleSize; i++){
            sumB+=sampleBufferB[i];
            squareSumB+=sampleBufferB[i]*sampleBufferB[i];
        }
        sampleBSumCalculated = YES;
    }
    
    [self advanceIndices];
    sampleBufferA[sampleBufferAIndex] = value;
    
    sumA = 0;
    squareSumB = 0;
    sumAB = 0;
    for(int i = 0; i<_correlationSampleSize; i++){
        [self advanceIndices];
        sumA += sampleBufferA[sampleBufferAIndex];
        squareSumA += sampleBufferA[sampleBufferAIndex]*sampleBufferA[sampleBufferAIndex];
        sumAB += sampleBufferA[sampleBufferAIndex]*sampleBufferB[i];
    }
    
    return (sumAB - sumA*sumB/_correlationSampleSize)/sqrtf((squareSumA-sumA*sumA/_correlationSampleSize)*(squareSumB-sumB*sumB/_correlationSampleSize));
    
}
@end
