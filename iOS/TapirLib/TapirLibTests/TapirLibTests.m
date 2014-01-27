//
//  TapirLibTests.m
//  TapirLibTests
//
//  Created by Jimin Jeon on 11/18/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

//#include "CircularQueue.h"
#include "TapirLib.h"
#import <XCTest/XCTest.h>
#import <AudioToolbox/AudioToolbox.h>



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

- (void)testMisc
{
//    int test[6] = {0,1,0,1,1,1};
//    int result = mergeBitsToIntegerValue(test, 6);
//    NSLog(@"%d", result);
}


- (void)testDecoder
{
    /*
    NSMutableArray * treArr = [[NSMutableArray alloc] init];
    [treArr addObject:[[TapirTrellisCode alloc] initWithG:7]];
    [treArr addObject:[[TapirTrellisCode alloc] initWithG:5]];

    TapirViterbiDecoder * vitdec = [[TapirViterbiDecoder alloc] initWithTrellisArray:treArr];
    
    float z[] = {0,0,1,1, 0,1,1,0, 0,1,1,0, 1,0,1,1};
    float z2[] = {0,0,1,1, 0,1,1,0, 0,1,1,0, 1,0,0,0};
    int dest[8];
    int dest2[8];
    
    [vitdec decode:z dest:dest srcLength:16];
    [vitdec decode:z2 dest:dest2 srcLength:16];
     */
    
}

- (void)testEncoder
{
//    int gTest = 13;
//    TrellisCode * trel = [[TrellisCode alloc] init];
//    [trel encode:gTest];
//    
//    float * test = malloc(sizeof(float) * 5);
//    float * test2 = malloc(sizeof(float) * 4);
//    for(int i =0; i<5; ++i)
//    {
//        *(test+i) = (float)i;
//    }
//    memcpy(test2, test+1, 4 * sizeof(float));
//    for(int i =0; i<4; ++i)
//    {
//        NSLog(@"%f",test2[i]);
//    }
    
//    
//    TrellisCode * trel = [[TrellisCode alloc] initWithG:23];
//    NSLog(@"%d",[trel codeLength]);
//    float * trelData = [trel code];
//    for(int i=0; i<[trel codeLength]; ++i)
//    {
//        NSLog(@"%d => %f", i, trelData[i]);
//    }
//    [trel extendTo:8];
//    NSLog(@"Extend ==> %d",[trel codeLength]);
//
//    trelData = [trel code];
//    for(int i=0; i<[trel codeLength]; ++i)
//    {
//        NSLog(@"%d => %f", i, trelData[i]);
//    }
//    
    

    /*
    NSMutableArray * treArr = [[NSMutableArray alloc] init];
    [treArr addObject:[[TapirTrellisCode alloc] initWithG:171]];
    [treArr addObject:[[TapirTrellisCode alloc] initWithG:133]];
//    float input[] = {.0f, 1.0f, 1.0f, 1.0f, .0f, 1.0f, .0f, .0f};
    int input[] = {0,1,1,1,0,1,0,0};
    TapirConvEncoder *enc = [[TapirConvEncoder alloc] initWithTrellisArray:treArr];
    float * encoded = calloc(16, sizeof(float));
    int * decoded = malloc(sizeof(int) * 8);
    
    [enc encode:input dest:encoded srcLength:8];
    
    TapirViterbiDecoder * vitdec = [[TapirViterbiDecoder alloc] initWithTrellisArray:treArr];
    
    [vitdec decode:encoded dest:decoded srcLength:16];
    
    
    
    NSLog(@"tbLen = %d ", [enc trellisCodeLength]);
    for(int i=0; i<16; ++i)
    {
        NSLog(@"%d => %f", i, encoded[i]);
    }
    for(int i=0; i<8; ++i)
    {
        NSLog(@"%d => %d", i, decoded[i]);
    }
     
     */
    
    //    TrellisCode * trel = [[TrellisCode alloc]initWithG:171];
//    TrellisCode * trel2 = [[T]]
//    float * trelData = [trel code];
//    for(int i=0; i<[trel length]; ++i)
//    {
//        NSLog(@"%d => %f", i, trelData[i]);
//    }

    
//    [treArr addObject:[[TrellisCode alloc] initWithG:177]];
    
//    [enc addTrellisCodeWithTrellisArray:treArr];
}


- (void)testPilot
{
    /*
    float pilotReal[4] = { 1.f, 1.f, 1.f, -1.f };
    float pilotImag[4] = { 0., 0., 0., 0.};
    int loc[4] = {3, 7, 11, 15};
    DSPSplitComplex pilot;
    pilot.realp = pilotReal;
    pilot.imagp = pilotImag;
    
    
    DSPSplitComplex origSignal;
    origSignal.realp = malloc(sizeof(float) * 16);
    origSignal.imagp = malloc(sizeof(float) * 16);
    
    DSPSplitComplex removedSignal;
    removedSignal.realp = malloc(sizeof(float) * 16);
    removedSignal.imagp = malloc(sizeof(float) * 16);
    
    DSPSplitComplex destSignal;
    destSignal.realp = malloc(sizeof(float) * 20);
    destSignal.imagp = malloc(sizeof(float) * 20);
    
    for(int i=0; i<16; ++i)
    {
        origSignal.realp[i] = (float) i;
        origSignal.imagp[i] = (float) (-i);
    }
    
    TapirPilotManager * pilotMag = [[TapirPilotManager alloc] initWithPilot:&pilot index:loc length:4];
    
    [pilotMag addPilotTo:&origSignal dest:&destSignal srcLength:16];
    [pilotMag removePilotFrom:&destSignal dest:&removedSignal srcLength:20];
    
    NSLog(@"Pilot Test");
    NSLog(@"==Original==");
    for(int i=0; i<16; ++i)
    {
        NSLog(@"[%d] = %.2f + %.2f", i ,origSignal.realp[i], origSignal.imagp[i]);
    }
    NSLog(@"==Added==");
    for(int i=0; i<20; ++i)
    {
        NSLog(@"[%d] = %.2f + %.2f", i ,destSignal.realp[i], destSignal.imagp[i]);
    }
    NSLog(@"==Removed==");
    for(int i=0; i<16; ++i)
    {
        NSLog(@"[%d] = %.2f + %.2f", i ,removedSignal.realp[i], removedSignal.imagp[i]);
    }

    free(origSignal.realp);
    free(origSignal.imagp);
    free(removedSignal.realp);
    free(removedSignal.imagp);
    free(destSignal.realp);
    free(destSignal.imagp);
    */
}

- (void)testChannelEstimation
{
    int size = 20;

    float pilotReal[4] = { 1.f, 1.f, 1.f, -1.f };
    float pilotImag[4] = { 0., 0., 0., 0.};
    
    DSPSplitComplex pilot;
    pilot.realp = pilotReal;
    pilot.imagp = pilotImag;

    int loc[4] = {3, 7, 11, 15};
//    float index[4] = { 0.f, 2.f, 13.f, 16.f};

//    vDSP_vindex(testData, index, 1, picked, 1, 4);

//    for(int i=0; i<4; ++i)
//    {
//        NSLog(@"%f",picked[i]);
//    }

    float lsEstReal[4] = {156.43f, 154.73f, 137.09f, 105.55f};
    float lsEstImag[4] = {-79.93f, -114.81f, -142.31f, -158.51f};

    DSPSplitComplex lsEst;
    lsEst.realp = lsEstReal;
    lsEst.imagp = lsEstImag;
    
//    TapirLSChannelEstimator * lschan = [[TapirLSChannelEstimator alloc] init];
//    [lschan setPilot:&pilot index:loc length:4];
//    [lschan generateChannelWith:&lsEst channelLength:size];

}

- (void)testInterleaver
{
    /*
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
    //    vDSP_mtrans

    TapirMatrixInterleaver * interleaver = [[TapirMatrixInterleaver alloc] initWithNRows:3 NCols:5];
    [interleaver interleave:&src to:&interleaved];
    [interleaver deinterleave:&interleaved to:&deinterleaved];
    
    for(int i=0; i<n; ++i)
    {
        NSLog(@"%f => %f => %f", src.realp[i], interleaved.realp[i], deinterleaved.realp[i]);
    }
    
    free(src.realp); free(src.imagp);
    free(interleaved.realp); free(interleaved.imagp);
     */
}

- (void)testModulation
{
    /*
    int symRate = 4;
    TapirPskModulator * mod = [[TapirPskModulator alloc] initWithSymbolRate:symRate initPhase:0];

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
    TapirDpskModulator *mod2 = [[TapirDpskModulator alloc]initWithSymbolRate:symRate];
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
    */
    
//    DbpskModulator * mod = [[DbpskModulator alloc] init];
    
//    int result = [TapirTransform calculateLogLength:2048];
//    NSLog(@"%d",result);
}

- (void)testConvert
{
    
    /*
    NSString *filePath =[[NSBundle bundleForClass:[self class]] pathForResource:@"t" ofType: @".wav"];
    UInt32 length = 2048;
    float * audioData = malloc(length * sizeof(float));
    [self readWavDataFrom:filePath to:audioData lengthOf:length];
    
    DSPSplitComplex convResult;
    convResult.realp = malloc(sizeof(float) * length);
    convResult.imagp = malloc(sizeof(float) * length);
    
    iqDemodulate(audioData,&convResult,2048, 44100, 20000);
    
     */
    //    [converter iqDemodulate:audioData dest:&convResult withLength:length];
    
    //    for(int i=0; i<10; ++i)
    //    {
    //        NSLog(@"%d th result, %f, %f", i, convResult.realp[i], convResult.imagp[i]);
    //    }
    //    for(int i=length - 10;i<length; ++i)
    //    {
    //        NSLog(@"%d th result, %f, %f", i, convResult.realp[i], convResult.imagp[i]);
    //    }
    /*
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
     */
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
