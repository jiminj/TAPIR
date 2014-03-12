//
//  TapirTest.h
//  TapirTest
//
//  Created by Jimin Jeon on 3/6/14.
//  Copyright (c) 2014 AIMIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TapirTest : NSObject {}

+ (void)testVramp;
+ (void)testVrvrs;
+ (void)testSvemg;
+ (void)testMaxv;
+ (void)testMaxmgv;
+ (void)testMaxvi;
+ (void)testZvmov;
+ (void)testZvmul;
+ (void)testZvdiv;
+ (void)testZvconj;
+ (void)testZvphas;

+ (void)testVvsincosf;
+ (void)testVindex;
+ (void)testMtrans;
+ (void)testVgenp;
+ (void)testOps;
+ (void)testConvert;

+ (void)testDotpr;
+ (void)testConvolution;
+ (void)testConvolution2;

+ (void)testFft;
+ (void)testZtocCtoz;

@end
