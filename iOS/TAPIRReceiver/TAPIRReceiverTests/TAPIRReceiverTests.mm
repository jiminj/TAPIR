//
//  TAPIRReceiverTests.m
//  TAPIRReceiverTests
//
//  Created by dilu on 11/15/13.
//  Copyright (c) 2013 dilu. All rights reserved.
//

#include <mach/mach_time.h>
#include <TapirLib/Filter.h>

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
    XCTAssertTrue(YES);
}

- (void)testExample
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
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
