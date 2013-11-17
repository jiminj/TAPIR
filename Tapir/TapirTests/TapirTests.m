//
//  TapirTests.m
//  TapirTests
//
//  Created by Jimin Jeon on 11/16/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import <XCTest/XCTest.h>
#include <AudioToolbox/AudioToolbox.h>

@interface TapirTests : XCTestCase

@end

@implementation TapirTests

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
//
//- (void)testExample
//{
//    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
//}


- (void)testLoadData
{

    NSString *filePath =[[NSBundle bundleForClass:[self class]] pathForResource:@"t" ofType: @".wav"];
    UInt32 length = 2048;
    Float32 * audioData = malloc(length * sizeof(Float32));
    [self readWavDataFrom:filePath to:audioData lengthOf:length];

    for( int i=0; i< length ; i++ )
    {
        NSLog(@"%f",audioData[i]);
    }
    
    
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
