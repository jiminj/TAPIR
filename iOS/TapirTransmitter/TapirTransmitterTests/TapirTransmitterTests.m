//
//  TapirTransmitterTests.m
//  TapirTransmitterTests
//
//  Created by Jimin Jeon on 12/3/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Accelerate/Accelerate.h>

#import <TapirLib/TapirLib.h>
#import "TapirConfig.h"
#import "TapirSignalGenerator.h"

@interface TapirTransmitterTests : XCTestCase

@end

@implementation TapirTransmitterTests

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
- (void)testGenerator
{
    TapirConfig * cfg = [TapirConfig getInstance];
    TapirSignalGenerator * generator = [[TapirSignalGenerator alloc] initWithConfig:cfg];
//    TapirPskModulator * mod;
    char input = 't';
    float * output = malloc(sizeof(float) * [cfg kSymbolWithCyclicExtLength]);
    [generator encodeOneChar:input dest:(output + [cfg kCyclicPrefixLength]) ];
    [generator addPrefixWith:(output + [cfg kCyclicPrefixLength]) dest:output];
    
    DSPSplitComplex preamble;
    preamble.realp = malloc(sizeof(float) * [cfg kPreambleLength] * 2);
    preamble.imagp = calloc([cfg kPreambleLength] * 2, sizeof(float));
    float * upconvPreamble = malloc(sizeof(float) * [cfg kPreambleLength] * 2);
    
    float * pb = preamble.realp;
    [generator generatePreamble:pb];
    memcpy(pb + [cfg kPreambleLength], pb, [cfg kPreambleLength] * sizeof(float));
    iqModulate(&preamble, upconvPreamble, [cfg kPreambleLength] * 2, [cfg kAudioSampleRate], [cfg kCarrierFrequency]);

    free(preamble.realp);
    free(preamble.imagp);
    free(output);
}

@end
