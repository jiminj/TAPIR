//
//  TAPIRReceiverTests.m
//  TAPIRReceiverTests
//
//  Created by dilu on 11/15/13.
//  Copyright (c) 2013 dilu. All rights reserved.
//


#include <TapirLib/Filter.h>

#import <XCTest/XCTest.h>
#import <AudioToolbox/AudioToolbox.h>
#import <TapirLib/TapirLib.h>
#import "TapirConfig.h"
#import "TapirSignalAnalyzer.h"
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
    TapirConfig * cfg = [TapirConfig getInstance];
    TapirSignalAnalyzer * analyzer = [[TapirSignalAnalyzer alloc] initWithConfig:cfg];
    
    NSString *filePath =[[NSBundle bundleForClass:[self class]] pathForResource:@"t_20k_puresymbol" ofType: @".wav"];
//    float * audioData = malloc([cfg kSymbolLength] * sizeof(float));
    float * audioData = new float[[cfg kSymbolLength]];
    [self readWavDataFrom:filePath to:audioData lengthOf:[cfg kSymbolLength]];

//    [analyzer setSignalLength:[cfg kSymbolLength] resultLength:[cfg kNoTotalSubcarriers]];
    char result = [analyzer decodeBlock:audioData];
    
    NSLog(@"RESULT => %c", result);
    
    
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
    
    
    
    
    delete [] audioData;
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
    float audioData[20000];
    [self readWavDataFrom:filePath to:audioData lengthOf:20000];
    
    
    
    int step = 1024;
    float result1[20000];
    float result2[20000];
    
    Tapir::FilterFIR * filter = Tapir::TapirFilters::getTxRxHpf(step);
    
    for(int i=0; i<20000; i+=step)
    {
        filter->process(audioData + i, result1 + i, step);
    }
    [self writeData:result1 toFile:@"genResult1.txt" lengthOf:20000];
    
    TapirMotherOfAllFilters* filter_orig = [TapirMotherOfAllFilters createHPF1];;
    for(int i=0; i<20000; ++i)
    {
        [filter_orig next:audioData[i] writeTo:&result2[i] ];
    }
    [self writeData:result2 toFile:@"genResult2.txt" lengthOf:20000];
    
    
}

- (void)writeData:(float *)data toFile:(NSString *)filePath lengthOf:(UInt32)length
{
    // File write
    
    NSFileHandle * fileHandle = [NSFileHandle fileHandleForWritingAtPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:filePath]];
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

@end
