//
//  TAPIRReceiverTests.m
//  TAPIRReceiverTests
//
//  Created by dilu on 11/15/13.
//  Copyright (c) 2013 dilu. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <TapirLib/TapirTransform.h>
#import <TapirLib/TapirIqModulator.h>

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

    float initState = 0;
    float inc = 1;
    int length = 2048;
    
    DSPSplitComplex convResult;
    convResult.realp = malloc(sizeof(float) * length);
    convResult.imagp = malloc(sizeof(float) * length);
    
    vDSP_vramp(&initState, &inc, convResult.realp, 1, length);
    vDSP_vramp(&initState, &inc, convResult.imagp, 1, length);
    [TapirTransform fftComplex:&convResult dest:&convResult length:length];
    [TapirTransform nothing];
}

//
//- (void)testExample
//{
//    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
//}

@end
