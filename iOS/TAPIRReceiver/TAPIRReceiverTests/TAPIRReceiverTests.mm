//
//  TAPIRReceiverTests.m
//  TAPIRReceiverTests
//
//  Created by dilu on 11/15/13.
//  Copyright (c) 2013 dilu. All rights reserved.
//

#include <mach/mach_time.h>
#include <TapirLib/Filter.h>

#include "LKCorrelationManager.h"
#import <XCTest/XCTest.h>
#import <AudioToolbox/AudioToolbox.h>
#import <TapirLib/TapirLib.h>
#import <Accelerate/Accelerate.h>


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
//    TapirConfig * cfg = [TapirConfig getInstance];
//    TapirSignalAnalyzer * analyzer = [[TapirSignalAnalyzer alloc] initWithConfig:cfg];
//    
//    NSString *filePath =[[NSBundle bundleForClass:[self class]] pathForResource:@"t_20k_puresymbol" ofType: @".wav"];
////    float * audioData = malloc([cfg kSymbolLength] * sizeof(float));
//    float * audioData = new float[[cfg kSymbolLength]];
//    [self readWavDataFrom:filePath to:audioData lengthOf:[cfg kSymbolLength]];
//
////    [analyzer setSignalLength:[cfg kSymbolLength] resultLength:[cfg kNoTotalSubcarriers]];
//    char result = [analyzer decodeBlock:audioData];
//    
//    NSLog(@"RESULT => %c", result);
//    
    
    //Channel Estimate

//    TapirLSChannelEstimator * lschan = [[TapirLSChannelEstimator alloc] init];
//    [lschan setPilot:&kTapirPilotData index:kTapirPilotLocation pilotLength:kTapirPilotLength channelLength:kTapirTotalNoSubcarriers];
//    [lschan channelEstimate:&cutResult dest:&cutResult];
//    
//    DSPSplitComplex estimated;
//    estimated.realp = malloc(sizeof(float) * kTapirNoDataSubcarriers);
//    estimated.imagp = malloc(sizeof(float) * kTapirNoDataSubcarriers);
//    [lschan removePilotsFromSignal:&cutResult dest:&estimated];
//    
//    
//    
//    for(int i=0; i<kTapirTotalNoSubcarriers; ++i)
//    {
//        NSLog(@"[%d] = %f + %f", i, estimated.realp[i], estimated.imagp[i]);
//    }
    
    
    
    
//    delete [] audioData;
//    free(convResult.realp);
//    free(convResult.imagp);
//    free(cutResult.realp);
//    free(cutResult.imagp);
//    free(estimated.realp);
//    free(estimated.imagp);
    
    XCTAssertTrue(YES);

}

//
//- (void)testExample
//{
//    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
//}

- (void)testFilter
{
    NSString *filePath =[[NSBundle bundleForClass:[self class]] pathForResource:@"test19" ofType: @".wav"];
    float audioData[40000] = {};
    [self readWavDataFrom:filePath to:audioData lengthOf:40000];
    

    int step = 1024;
    float result1[40000] = {};
    float result2[40000] = {};
    
    Tapir::FilterFIR * filter = Tapir::TapirFilters::getTxRxHpf(step);
    const uint64_t startTime1 = mach_absolute_time();
    for(int i=0; i<40000; i+=step)
    {
        filter->process(audioData + i, result1 + i, step);
    }
//    [self writeData:result1 toFile:@"genResult1.txt" lengthOf:40000];
    const uint64_t endTime1 = mach_absolute_time();

//    TapirMotherOfAllFilters* filter_orig = [TapirMotherOfAllFilters createHPF1];;
//    
//    const uint64_t startTime2 = mach_absolute_time();
//    for(int i=0; i<40000; ++i)
//    {
//        [filter_orig next:audioData[i] writeTo:&result2[i] ];
//    }
//    [self writeData:result2 toFile:@"genResult2.txt" lengthOf:40000];
//    const uint64_t endTime2 = mach_absolute_time();
    
    
    const uint64_t elapsedMTU1 = endTime1 - startTime1;
//    const uint64_t elapsedMTU2 = endTime2 - startTime2;
    mach_timebase_info_data_t info;
    mach_timebase_info(&info);
    
    // Get elapsed time in nanoseconds:
    const double elapsedNS1 = (double)elapsedMTU1 * (double)info.numer / (double)info.denom;
//    const double elapsedNS2 = (double)elapsedMTU2 * (double)info.numer / (double)info.denom;
    
//    NSLog(@"Filter1 : %f, Filter2 : %f", elapsedNS1, elapsedNS2);
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

-(void)testNew
{
    float * testf = new float[100];
    for(int i=0; i<100; ++i)
    {
        NSLog(@"%d",testf[i]);
    };
}

-(void) testQueue
{
//    Tapir::CircularQueue<float> q(12, 4);
//
//    
//    float enque[8] = {99, 100, 101,102,103,104,105, 106};
//    float enque2[4] = {0.7,0.4,0.2,0.4};
//    float enque3[2] = {300,301};
////    q.push(enque, 7);
//////    q.status();
//    
//    for(int i=1; i<=3; ++i)
//    {
//        q.push(enque2, 4);
//        q.status();
//    }
//    for(int i=1; i<=3; ++i)
//    {
//        q.push(enque3, 2);
//        q.status();
//    }
//    for(int i=0; i<10; ++i)
//    {
//    }
//    
//
//    
//    q.push(enque2, 4);
//    q.status();
//    q.push(enque3, 2);
//    q.status();
//    
//    
//    q.push(enque, 8);
//    q.status();
////    std::cout<<*(q.getLast())<<std::endl;
//    int backtrack = 4;
//    const int * lastElem = q.getLast(backtrack);
//
//    std::cout<<"RESULT : ";
//    for(int i=0; i<backtrack; ++i)
//    {
//        std::cout<<*(lastElem+i)<<" ";
//    }
//    std::cout<<std::endl;
//
//    q.status();
    
}

- (void)testCorrelator
{
//    BOOL trackingFlag = NO;
    NSString *filePath =[[NSBundle bundleForClass:[self class]] pathForResource:@"sony" ofType: @".wav"];
    float audioData[30720] = {};
    [self readWavDataFrom:filePath to:audioData lengthOf:30720];

    int step = 1024;
    float filtered[30720] = {};
    float result[30720] = {};
    int signalLength = 30270;
    Tapir::SignalDetector detector(1024);
    LKCorrelationManager * correlationManager = [[LKCorrelationManager alloc] initWithCorrelationWindowSize:400 andBacktrackSize:Tapir::Config::LENGTH_INPUT_BUFFER];
    
//    NSLog(@"RESULT LENGTH : %d",detector.m_resultLength);
    
    
    const uint64_t startTime1 = mach_absolute_time();
    for(int i=0; i<30720; i+=step)
    {
        detector.detect(audioData + i);
    }
    const uint64_t endTime1 = mach_absolute_time();
    const uint64_t startTime2 = mach_absolute_time();
    for(int i=0; i<30720;++i)
    {
        [correlationManager newSample:audioData[i]];
    }
    const uint64_t endTime2 = mach_absolute_time();
    
//    [self writeData:filtered toFile:@"filtered.txt" lengthOf:30720];
    
    [self writeData:detector.m_result toFile:@"corr.txt" lengthOf:detector.m_resultLength];
    
    
//
//    const uint64_t startTime1 = mach_absolute_time();
//    const uint64_t endTime1 = mach_absolute_time();
    const uint64_t elapsedMTU1 = endTime1 - startTime1;
    const uint64_t elapsedMTU2 = endTime2 - startTime2;
    mach_timebase_info_data_t info;
    mach_timebase_info(&info);
//
//    // Get elapsed time in nanoseconds:
    const double elapsedNS1 = (double)elapsedMTU1 * (double)info.numer / (double)info.denom;
    const double elapsedNS2 = (double)elapsedMTU2 * (double)info.numer / (double)info.denom;
    NSLog(@" New : %f us \t Old : %f us", elapsedNS1/1000, elapsedNS2/1000);
//
    
}




@end