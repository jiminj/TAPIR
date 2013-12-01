//
//  TAPIRReceiverTests.m
//  TAPIRReceiverTests
//
//  Created by dilu on 11/15/13.
//  Copyright (c) 2013 dilu. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AudioToolbox/AudioToolbox.h>
#import <TapirLib/TapirLib.h>
#import "TapirConfig.h"

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

- (void)testLoadLibrary
{
}

- (void)testAnalyzeTapir
{
    
    TapirConfig();
    
    TapirTrellisCode * trellis1 = [[TapirTrellisCode alloc] initWithG:171];
    TapirTrellisCode * trellis2 = [[TapirTrellisCode alloc] initWithG:133];
    
    kTapirTrellisArray = [NSArray arrayWithObjects: trellis1, trellis2, nil];
    
    
    NSString *filePath =[[NSBundle bundleForClass:[self class]] pathForResource:@"t_20k_puresymbol" ofType: @".wav"];

    
    float * audioData = malloc(kTapirSymbolLength * sizeof(float));
    [self readWavDataFrom:filePath to:audioData lengthOf:kTapirSymbolLength];
    
    
    
    DSPSplitComplex convResult;
    convResult.realp = malloc(sizeof(float) * kTapirSymbolLength);
    convResult.imagp = malloc(sizeof(float) * kTapirSymbolLength);
    
    iqDemodulate(audioData,&convResult, kTapirSymbolLength, kTapirAudioSampleRate, kTapirCarrierFrequency);
    fftComplexForward(&convResult, &convResult, kTapirSymbolLength);

    DSPSplitComplex cutResult;
    cutResult.realp = malloc(sizeof(float) * 16);
    cutResult.imagp = malloc(sizeof(float) * 16);
    
    cutCentralRegions(&convResult, &cutResult, kTapirSymbolLength, 16);
    
    
    
    free(audioData);
    free(convResult.realp);
    free(convResult.imagp);
    
    XCTAssertTrue(YES);

}

//
//- (void)testExample
//{
//    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
//}



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
