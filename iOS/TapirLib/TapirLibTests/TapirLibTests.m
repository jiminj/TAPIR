//
//  TapirLibTests.m
//  TapirLibTests
//
//  Created by Jimin Jeon on 11/18/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import <XCTest/XCTest.h>
#include <AudioToolbox/AudioToolbox.h>
#include "TapirLib.h"

@interface TapirLibTests : XCTestCase

@end

@implementation TapirLibTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//- (void)testExample
//{
//    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
//}

- (void)testInterleaver
{
    DSPSplitComplex src;
    DSPSplitComplex interleaved;
    DSPSplitComplex deinterleaved;
    int n = 15;
    
    src.realp = malloc(sizeof(float) * n);
    src.imagp = malloc(sizeof(float) * n);
    interleaved.realp = malloc(sizeof(float) * n);
    interleaved.imagp = malloc(sizeof(float) * n);
    deinterleaved.realp = malloc(sizeof(float) * n);
    deinterleaved.imagp = malloc(sizeof(float) * n);
    
    
    for(int i=1; i<=n; ++i)
    { src.realp[i-1] = i; }
    
    TapirInterleaver * interleaver = [[TapirInterleaver alloc] initWithNRows:3 NCols:5];
    [interleaver interleave:&src to:&interleaved];
    [interleaver deinterleave:&interleaved to:&deinterleaved];
    
    for(int i=0; i<n; ++i)
    {
        NSLog(@"%f => %f => %f", src.realp[i], interleaved.realp[i], deinterleaved.realp[i]);
    }
    
    free(src.realp); free(src.imagp);
    free(interleaved.realp); free(interleaved.imagp);
}

- (void)testModulation
{
    int symRate = 4;
    PskModulator * mod = [[PskModulator alloc] initWithSymbolRate:symRate initPhase:0];

    int n = 10;
    
    //Demodulation
    DSPSplitComplex testDemodValue;
    testDemodValue.realp = malloc(sizeof(float) * n);
    testDemodValue.imagp = malloc(sizeof(float) * n);
    
    int * result = malloc(sizeof(int) * n);
    float * phase = malloc(sizeof(float) * n);
    
    float phaseDiv = 2*M_PI / n;
    float mag = 1.0f;
    
    for(int i=0; i<n; ++i)
    {
        phase[i] = phaseDiv * i;
        testDemodValue.realp[i] = cosf(phase[i]) / mag;
        testDemodValue.imagp[i] = sinf(phase[i]) / mag;
    }

    [mod demodulate:&testDemodValue dest:result length:n];
    for(int i=0; i<n; ++i)
    {
        NSLog(@"%2f+%2fi (%2f)=> %d", testDemodValue.realp[i], testDemodValue.imagp[i], phase[i] * 180 / M_PI, result[i]);
    }

    //Modulation
    int * testModValue = malloc(sizeof(int) * n);
    for( int i=0; i<n; ++i)
    {
        testModValue[i] = (int)(arc4random() % symRate);
    }

    DSPSplitComplex testModResult;
    testModResult.realp = malloc(sizeof(float) * n);
    testModResult.imagp = malloc(sizeof(float) * n);
    
    
    int * testDemodValue2 = malloc(sizeof(int) * n);
    int * phaseInfo = malloc(sizeof(int)*n);
    DpskModulator *mod2 = [[DpskModulator alloc]initWithSymbolRate:symRate];
    [mod2 modulate:testModValue dest:&testModResult length:n];
    [mod demodulate:&testModResult dest:phaseInfo length:n];
    [mod2 demodulate:&testModResult dest:testDemodValue2 length:n];
    

    
    for(int i=0;i<n;++i)
    {
        NSLog(@"%d => %2f + %2fi (%d)=> %d",testModValue[i],testModResult.realp[i],testModResult.imagp[i], phaseInfo[i], testDemodValue2[i]);
    }
    
    
    free(testDemodValue.realp);
    free(testDemodValue.imagp);
    free(phase);
    free(result);
    
//    DbpskModulator * mod = [[DbpskModulator alloc] init];
    
//    int result = [TapirTransform calculateLogLength:2048];
//    NSLog(@"%d",result);
}

- (void)testConvert
{
    
    NSString *filePath =[[NSBundle bundleForClass:[self class]] pathForResource:@"t" ofType: @".wav"];
    UInt32 length = 2048;
    float * audioData = malloc(length * sizeof(float));
    [self readWavDataFrom:filePath to:audioData lengthOf:length];
    
    DSPSplitComplex convResult;
    convResult.realp = malloc(sizeof(float) * length);
    convResult.imagp = malloc(sizeof(float) * length);
    
    iqDemodulate(audioData,&convResult,2048, 44100, 20000);
    
    //    [converter iqDemodulate:audioData dest:&convResult withLength:length];
    
    //    for(int i=0; i<10; ++i)
    //    {
    //        NSLog(@"%d th result, %f, %f", i, convResult.realp[i], convResult.imagp[i]);
    //    }
    //    for(int i=length - 10;i<length; ++i)
    //    {
    //        NSLog(@"%d th result, %f, %f", i, convResult.realp[i], convResult.imagp[i]);
    //    }
    fftComplexForward(&convResult, &convResult, 2048);

    for(int i=0; i<10; ++i)
    {
        NSLog(@"%d th result, %f, %f", i, convResult.realp[i], convResult.imagp[i]);
    }
    for(int i=length - 10;i<length; ++i)
    {
        NSLog(@"%d th result, %f, %f", i, convResult.realp[i], convResult.imagp[i]);
    }

    free(audioData);
    free(convResult.realp);
    free(convResult.imagp);
    
    XCTAssertTrue(YES);
}

- (void)readWavDataFrom:(NSString *)filePath to:(Float32 *)audioData lengthOf:(UInt32)frameCount
{
    
    CFURLRef inputFileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                                          (CFStringRef)filePath,
                                                          kCFURLPOSIXPathStyle,
                                                          false);
    ExtAudioFileRef fileRef = NULL;
    ExtAudioFileOpenURL(inputFileURL, &fileRef);
    if( NULL == fileRef)
    { XCTFail(@"Failed to open the file"); }
    
    UInt32 propSize;
    AudioStreamBasicDescription descriptor;
    propSize = sizeof(descriptor);
    ExtAudioFileGetProperty(fileRef, kExtAudioFileProperty_FileDataFormat, &propSize, &descriptor);
    
    void * readBuffer = malloc(descriptor.mBytesPerFrame * descriptor.mChannelsPerFrame *frameCount);
    
    AudioBufferList bufferList;
    bufferList.mNumberBuffers = 1;
    bufferList.mBuffers[0].mNumberChannels = descriptor.mChannelsPerFrame;
    bufferList.mBuffers[0].mDataByteSize = frameCount * descriptor.mBytesPerFrame;
    bufferList.mBuffers[0].mData = readBuffer;
    
    ExtAudioFileRead(fileRef, &frameCount, &bufferList);
    
    for( int i=0; i< frameCount ; i++ )
    {
        audioData[i] = ((SInt16 *)readBuffer)[i] / 32768.0f;
    }
    
}

@end
