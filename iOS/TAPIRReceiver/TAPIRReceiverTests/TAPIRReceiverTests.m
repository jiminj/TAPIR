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
#import "TapirSignalAnalyzer.h"

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
    float * audioData = malloc([cfg kSymbolLength] * sizeof(float));
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
    
    
    
    
    free(audioData);
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
