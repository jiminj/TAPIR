//
//  TAPIRReceiverTests.m
//  TAPIRReceiverTests
//
//  Created by dilu on 11/15/13.
//  Copyright (c) 2013 dilu. All rights reserved.
//

#include <mach/mach_time.h>
#include <assert.h>
#import <XCTest/XCTest.h>
#import <AudioToolbox/AudioToolbox.h>
#import <TapirLib/TapirLib.h>
#import <Accelerate/Accelerate.h>
#include <mach/mach.h>
#include <unistd.h>

@interface TAPIRReceiverTests : XCTestCase

@end

@implementation TAPIRReceiverTests

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

- (void)testAnalyzeTapir
{
    XCTAssertTrue(YES);
}

- (void)testExample
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testConvData
{
    int cnt=4;
    float * fsrc = new float[cnt];
    short * ssrc = new short[cnt];
    int * isrc = new int[cnt];
    
    short * sdest = new short[cnt];
    int * idest = new int[cnt];
    float * fdest1 = new float[cnt];
    float * fdest2 = new float[cnt];
    
    for(int i=0; i<cnt; ++i)
    {
        fsrc[i] = (float) rand() / RAND_MAX * 5.0f;
        ssrc[i] = (short) (rand() % 10);
        isrc[i] = rand();
    }
    TapirDSP::vfix16(fsrc, 1, sdest, 1, cnt);
    
    NSMutableString *fsrcStr = [NSMutableString new];
    NSMutableString *sdestStr = [NSMutableString new];
    for(int i=0; i<cnt; ++i)
    {
        [fsrcStr appendFormat:@"%f\t", fsrc[i]];
        [sdestStr appendFormat:@"%d\t", sdest[i]];
    }
    
    NSLog(@"%@", fsrcStr);
    NSLog(@"%@", sdestStr);
    
    //    for(int i=0; i<cnt; ++i)
    //    {
    //        LOGD("float src[%d] : %f", i, fsrc[i]);
    //        LOGD("toShort[%d] : %d", i, sdest[i]);
    //        LOGD("toInt[%d] : %d", i, idest[i]);
    //
    //        LOGD("short src[%d] : %d", i, ssrc[i]);
    //        LOGD("toFloat[%d] : %f", i, fdest1[i]);
    //
    //        LOGD("int src[%d] : %d", i, isrc[i]);
    //        LOGD("toFloat[%d] : %f", i, fdest2[i]);
    //        //        LOGD("div[%d] : %f", i, divDest[i]);
    //        //        LOGD("multiply and add[%d] : %f", i, mulAccDest[i]);
    //    }
    
    delete [] fsrc;
    delete [] ssrc;
    delete [] isrc;
    
    delete [] sdest;
    delete [] idest;
    delete [] fdest1;
    delete [] fdest2;
    
}

- (void)writeData:(const float *)data toFile:(NSString *)filePath lengthOf:(UInt32)length
{
    // File write
    NSString * docFilePath =[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:filePath];
    NSFileHandle * fileHandle = [NSFileHandle fileHandleForWritingAtPath:docFilePath];
    if(fileHandle == NULL)
    {
        [[NSFileManager defaultManager] createFileAtPath:docFilePath contents:nil attributes:nil];
        fileHandle = [NSFileHandle fileHandleForWritingAtPath:docFilePath];
    }
    NSMutableString * resultString = [[NSMutableString alloc] init];
    for(int i=0; i<length; ++i)
    {
        [resultString appendFormat:@"%f\n",data[i]];
    }
    [fileHandle writeData:[resultString dataUsingEncoding:NSUTF8StringEncoding]];
    
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

- (void)testPlatform
{
    int cnt = 10;
    float src[cnt];
    float dest[cnt];
    srand((unsigned int)time(NULL));
    for(int i=0; i<cnt; ++i)
    {
        src[i] = (float) rand() / RAND_MAX * 5.0f;
    }
    float test = 0.5;
    TapirDSP::vsadd(src, &test, dest, cnt);
    NSMutableString * srcString = [NSMutableString stringWithString:@""];
    NSMutableString * destString = [NSMutableString stringWithString:@""];
    for(int i=0; i<cnt; ++i)
    {
        [srcString appendFormat:@"%f\t",src[i]];
        [destString appendFormat:@"%f\t",dest[i]];
    }
    NSLog(srcString);
    NSLog(destString);
};
- (void)testMaxvi
{
    int cnt = 100;
    int loop = 10000;
    
    float * src = new float[cnt];
    float * dest = new float;

    uint64_t stTime, edTime;
    TapirDSP::VecLength maxIdx;
    srand((unsigned int)time(NULL));
    for(int i=0; i<cnt; ++i)
    { src[i] = (float) rand() / RAND_MAX * 5.0f; }
    
    stTime = mach_absolute_time();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::maxvi(src, dest, &maxIdx, cnt);
    }
    edTime = mach_absolute_time();
    
    NSLog(@"RESULT : %f // %d", *dest, maxIdx);
    NSLog(@"elapsed : %d", edTime - stTime);
    
    stTime = mach_absolute_time();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::maxvi(src, 1, dest, &maxIdx, cnt);
    }
    edTime = mach_absolute_time();
    
    NSLog(@"RESULT : %f // %d", *dest, maxIdx);
    NSLog(@"elapsed : %d", edTime - stTime);
    
    delete [] src;
    delete dest;
    
}

/*
- (void)testUse
{

    NSString *filePath =[[NSBundle bundleForClass:[self class]] pathForResource:@"sony" ofType: @".wav"];
    float audioData[30720] = {};
    [self readWavDataFrom:filePath to:audioData lengthOf:30720];
    [self writeData:detector.m_result toFile:@"corr.txt" lengthOf:detector.m_resultLength];

    const uint64_t startTime1 = mach_absolute_time();
    const uint64_t endTime1 = mach_absolute_time();
    const uint64_t elapsedMTU1 = endTime1 - startTime1;
    const uint64_t elapsedMTU2 = endTime2 - startTime2;
    mach_timebase_info_data_t info;
    mach_timebase_info(&info);

//    // Get elapsed time in nanoseconds:
    const double elapsedNS1 = (double)elapsedMTU1 * (double)info.numer / (double)info.denom;
    const double elapsedNS2 = (double)elapsedMTU2 * (double)info.numer / (double)info.denom;
    NSLog(@" New : %f us \t Old : %f us", elapsedNS1/1000, elapsedNS2/1000);
    
}
*/



@end
