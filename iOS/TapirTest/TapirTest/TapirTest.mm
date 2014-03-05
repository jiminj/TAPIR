//
//  TapirTest.m
//  TapirTest
//
//  Created by Jimin Jeon on 3/6/14.
//  Copyright (c) 2014 AIMIA. All rights reserved.
//

#import "TapirTest.h"
#include <mach/mach_time.h>
#include <assert.h>
#import <TapirLib/TapirLib.h>
#import <Accelerate/Accelerate.h>
#include <mach/mach.h>
#include <unistd.h>


@implementation TapirTest

+ (void)testRamp
{
    int cnt = 103;
    float * dest = new float[cnt]();
    
    float init = 0.5f;
    float inc = 1.1f;
    
    //    for(int loop = 0; loop < 5; ++loop)
    //    {
    uint64_t stTime, edTime;
    
    stTime = mach_absolute_time();
    for(int j=0; j<10000; ++j)
    {
        for(int i=0; i<cnt; ++i)
        {
            dest[i] = init + inc * i;
        }
    }
    edTime = mach_absolute_time();
    //    Nanoseconds elapsedNano = AbsoluteToNanoseconds( *(AbsoluteTime *) &elapsed );
    delete [] dest; dest = new float[cnt]();
    NSLog(@"Fill : %llu", edTime - stTime);
    
    stTime = mach_absolute_time();
    for(int j=0; j<10000; ++j)
    {
        TapirDSP::vramp(&init, &inc, dest, cnt);
    }
    edTime = mach_absolute_time();
    //    for(int i=0; i<5; ++i)
    //    { NSLog(@"[%d] %f", i, dest[i]);}
    //    for(int i=cnt-5; i<cnt; ++i)
    //    { NSLog(@"[%d] %f", i, dest[i]);}
    NSLog(@"vramp : %llu", edTime - stTime);
    delete [] dest; dest = new float[cnt]();
    stTime = mach_absolute_time();
    for(int j=0; j<10000; ++j)
    {
        TapirDSP::vramp(&init, &inc, dest, 1, cnt);
    }
    edTime = mach_absolute_time();
    //    for(int i=0; i<5; ++i)
    //    { NSLog(@"[%d] %f", i, dest[i]);}
    //    for(int i=cnt-5; i<cnt; ++i)
    //    { NSLog(@"[%d] %f", i, dest[i]);}
    
    NSLog(@"vDSP : %llu", edTime - stTime);
    //    };
    
    delete [] dest;
    
}

+ (void)testMaxVal
{
    int cnt = 103;
    int loop = 10000;
    
    float * src = new float[cnt];
    float * dest = new float;
    
    uint64_t stTime, edTime;
    
    srand((unsigned int)time(NULL));
    for(int i=0; i<cnt; ++i)
    { src[i] = (float) rand() / RAND_MAX * 5.0f - 5.f; }
    stTime = mach_absolute_time();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::maxv(src, dest, cnt);
    }
    edTime = mach_absolute_time();
    
    //    for(int i=0; i<cnt; ++i)
    //    {
    //        NSLog(@"[%d], %f",i, src[i]);
    //    }
    NSLog(@"RESULT : %f", *dest);
    NSLog(@"elapsed : %llu", edTime - stTime);
    
    stTime = mach_absolute_time();
    for(int i=0; i<loop; ++i)
    {
        vDSP_maxv(src, 1, dest, cnt);
    }
    edTime = mach_absolute_time();
    
    //    for(int i=0; i<cnt; ++i)
    //    {
    //        NSLog(@"[%d], %f",i, src[i]);
    //    }
    NSLog(@"RESULT : %f", *dest);
    NSLog(@"elapsed : %llu", edTime - stTime);
    
    delete [] src;
    delete dest;
}

+ (void)testRvrs
{
    for(int loop = 0; loop < 10; ++loop)
    {
        
        int cnt = 10000;
        float * src = new float[cnt]();
        uint64_t stTime, edTime;
        
        for(int i=0; i< cnt; ++i)
        { src[i] = (float) rand() / RAND_MAX * 40000.0f; }
        //
        stTime = mach_absolute_time();
        for(int i=0; i< 1000; ++i)
        {
            float temp;
            float * srcLoop = src;
            float * srcBackward = srcLoop + cnt - 1;
            while(srcLoop < srcBackward)
            {
                temp = *srcLoop;
                *(srcLoop++) = *srcBackward;
                *(srcBackward--) = temp;
            }
        }
        edTime = mach_absolute_time();
        
        NSLog(@"Fill : %llu",(edTime - stTime));
        
        
        stTime = mach_absolute_time();
        for(int i=0; i<1000; ++i)
        { TapirDSP::vrvrs(src, cnt); }
        edTime = mach_absolute_time();
        NSLog(@"vrvrs : %llu", edTime - stTime);
        
        stTime = mach_absolute_time();
        for(int i=0; i<1000; ++i)
        {TapirDSP::vrvrs(src, 1, cnt);}
        edTime = mach_absolute_time();
        
        NSLog(@"vdsp : %llu", edTime - stTime);
        
        delete [] src;
        
    }
    
}

+ (void)testSvemg
{
    int cnt = 2048;
    int loop = 10000;
    
    float * src = new float[cnt];
    float * dest = new float;
    
    uint64_t stTime, edTime;
    srand((unsigned int)time(NULL));
    for(int i=0; i<cnt; ++i)
    { src[i] = (float) rand() / RAND_MAX * 5.0f; }
    
    stTime = mach_absolute_time();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::svemg_cpp(src, dest, cnt);
    }
    edTime = mach_absolute_time();
    NSLog(@"RESULT : %f", *dest);
    NSLog(@"Loop : elapsed : %llu", edTime - stTime);
    
    stTime = mach_absolute_time();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::svemg_neon(src, dest, cnt);
    }
    edTime = mach_absolute_time();
    
    NSLog(@"RESULT : %f", *dest);
    NSLog(@"NEON elapsed : %llu", edTime - stTime);
    
    stTime = mach_absolute_time();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::svemg(src, dest, cnt);
    }
    edTime = mach_absolute_time();
    
    NSLog(@"RESULT : %f", *dest);
    NSLog(@"vDSP elapsed : %llu", edTime - stTime);
    
    delete [] src;
    delete dest;
    
};



+ (void)testMaxvi
{
    int cnt = 2048;
    int loop = 10000;
    
    float * src = new float[cnt];
    float * dest = new float;
    
    uint64_t stTime, edTime;
    TapirDSP::VecLength maxIdx;
    srand((unsigned int)time(NULL));
    for(int i=0; i<cnt; ++i)
    { src[i] = (float) rand() / RAND_MAX * 5.0f - 2.5f;}
    
    
    stTime = mach_absolute_time();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::maxvi_cpp(src, dest, &maxIdx, cnt);
    }
    edTime = mach_absolute_time();
    
    NSLog(@"RESULT : %f // %lu", *dest, maxIdx);
    NSLog(@"elapsed : %llu", edTime - stTime);
    
    
    stTime = mach_absolute_time();
    for(int i=0; i<loop; ++i)
    {
//        TapirDSP::maxv(src, dest, cnt);
//        TapirDSP::maxvi_neon(src, dest, &maxIdx, cnt);
    }
    edTime = mach_absolute_time();
    
    NSLog(@"RESULT : %f // %lu", *dest, maxIdx);
    NSLog(@"elapsed : %llu", edTime - stTime);
    
    stTime = mach_absolute_time();
    for(int i=0; i<loop; ++i)
    {
//        TapirDSP::maxv(src, 1, dest, cnt);
        TapirDSP::maxvi(src, dest, &maxIdx, cnt);
    }
    edTime = mach_absolute_time();
    
    NSLog(@"RESULT : %f // %lu", *dest, maxIdx);
    NSLog(@"elapsed : %llu", edTime - stTime);
    
    delete [] src;
    delete dest;
    
}

@end
