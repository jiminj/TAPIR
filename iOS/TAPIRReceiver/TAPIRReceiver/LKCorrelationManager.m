//
//  LKCorrelationManager.m
//  AudioBufferCorrelationTest
//
//  Created by dilu on 11/12/13.
//  Copyright (c) 2013 dilu. All rights reserved.
//

#import "LKCorrelationManager.h"
#define CORRELATION_THRESHOLD 0.6

@implementation LKCorrelationManager

-(id)initWithCorrelationWindowSize:(int)size1 andBacktrackSize:(int)size2{
    if(self=[super init]){
        cfg = [TapirConfig getInstance];
        correlationWindowSize = size1;
        backtrackSize = size2;
        //the real sample data
        realBuffer = [[LKRealSampleBuffer alloc] initWithBufferLength:correlationWindowSize*4+[cfg kAudioBufferLength]];
        //sample buffer for correlation 1
        sampleBufferA = [[LKVirtualSampleBuffer alloc] initWithRealSampleBuffer:realBuffer offSet:0 andLength:correlationWindowSize];
        //sample buffer for correlation 2
        sampleBufferB = [[LKVirtualSampleBuffer alloc] initWithRealSampleBuffer:realBuffer offSet:correlationWindowSize andLength:correlationWindowSize];
        //this buffer stores correlation values
        correlationBuffer = [[LKRealSampleBuffer alloc] initWithBufferLength:5000];
        sumA = 0;
        sumB = 0;
        squareSumA = 0;
        squareSumB = 0;
        sumAB = 0;
        sumCor = 0;
        absSum =0;
        tt = 0;
        fileHandle = [NSFileHandle fileHandleForWritingAtPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"corr.txt"]];
        stop = NO;
        backtrackCounter = 0;
    }
    return self;
}

-(void)newSample:(float)value{
    
    //calculate new correlation value
    /*sumA-=[sampleBufferA lastSample];
    squareSumA-=[sampleBufferA lastSample]*[sampleBufferA lastSample];
    sumB-=[sampleBufferB lastSample];
    squareSumB-=[sampleBufferB lastSample]*[sampleBufferB lastSample];
    sumAB -= [ sampleBufferA lastSample]*[sampleBufferB lastSample];
    absSum-=fabs([sampleBufferA lastSample]);
    
    [realBuffer newSample:value];
    
    sumA+=[sampleBufferA sampleAt:0];
    squareSumA+=[sampleBufferA sampleAt:0]*[sampleBufferA sampleAt:0];
    sumB+=[sampleBufferB sampleAt:0];
    squareSumB+=[sampleBufferB sampleAt:0]*[sampleBufferB sampleAt:0];
    sumAB+=[sampleBufferA sampleAt:0]*[sampleBufferB sampleAt:0];
    absSum+=fabs([sampleBufferA sampleAt:0]);
    
    //add
    sumCor-=[correlationBuffer sampleAt:correlationBuffer.length-1];
    [correlationBuffer newSample:[self calculateCorrelation]];
    sumCor+=[correlationBuffer sampleAt:0];
     */
    [realBuffer newSample:value];
    /*vDSP_sve(sampleBufferA.samples, 1, &sumA, correlationWindowSize);
    vDSP_sve(sampleBufferB.samples, 1, &sumB, correlationWindowSize);
    vDSP_svesq(sampleBufferA.samples, 1, &squareSumA, correlationWindowSize);
    vDSP_svesq(sampleBufferB.samples, 1, &squareSumB, correlationWindowSize);
    vDSP_dotpr(sampleBufferA.samples, 1, sampleBufferB.samples, 1, &sumAB, correlationWindowSize);
    vDSP_svemg(sampleBufferA.samples, 1, &absSum, correlationWindowSize*2);
    
    [correlationBuffer newSample:[self calculateCorrelation]];*/
    
    //vDSP_sve(correlationBuffer.samples, 1, &sumCor, 800);
    
    //[fileHandle writeData:[[NSString stringWithFormat:@"%d\t%f\t%f\t%f\n",tt++, value, [correlationBuffer sampleAt:0], [correlationBuffer sampleAt:0]/absSum] dataUsingEncoding:NSUTF8StringEncoding]];
    /*if(realBuffer.samples[1599]>1000){
        [self trace];
        
    }*/
    
    if(stop){
        [correlationBuffer newSample:0];
        backtrackCounter++;
        if(backtrackCounter==[cfg kAudioBufferLength]){
            LKVirtualSampleBuffer* sampleLog = [[LKVirtualSampleBuffer alloc] initWithRealSampleBuffer:realBuffer offSet:maxIndex andLength:[cfg kAudioBufferLength]];
            float* s = [sampleLog samples];
            vDSP_vrvrs(s, 1, [cfg kAudioBufferLength]);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"correlationDetected" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:(int)s] forKey:@"samples"]];
            
        }
        if(backtrackCounter>=[cfg kAudioBufferLength]+40000){
            stop = NO;
            backtrackCounter = 0;
        }
        
        return;
    }else{
        vDSP_dotpr([sampleBufferA samples], 1, [sampleBufferB samples], 1, &xCorr, [cfg kPreambleLength]);
        vDSP_svemg([sampleBufferA samples], 1, &absSum, correlationWindowSize);
        [correlationBuffer newSample:xCorr/absSum];
    }
    if(fabs([correlationBuffer sampleAt:[cfg kPreambleLength] ]) > 2000){
        //[self trace];
        stop = YES;
        maxIndex = 0;
        for(int i = 1; i<correlationBuffer.length; i++){
            if(fabs([correlationBuffer sampleAt:i])>fabs([correlationBuffer sampleAt:maxIndex])){
                maxIndex=i;
            }
        }
        
        for(int i = 0; i<5000; i++)
            [fileHandle writeData:[[NSString stringWithFormat:@"%f\n", [correlationBuffer sampleAt:i]] dataUsingEncoding:NSUTF8StringEncoding]];
        
        
         

       // NSLog(@"c, %f", [correlationBuffer sampleAt:[cfg kPreambleLength] ]);
                 /*for(int i = 0; i<realBuffer.length; i++){
            [fileHandle writeData:[[NSString stringWithFormat:@"%f\t%f\n", [realBuffer sampleAt:i], [correlationBuffer sampleAt:i]] dataUsingEncoding:NSUTF8StringEncoding]];
            
        }
        NSLog(@"start from: %d", maxIndex);
        */
        
        sumA = 0;
        sumB = 0;
        squareSumA = 0;
        squareSumB = 0;
        sumAB = 0;
        sumCor = 0;
        absSum =0;
        //[realBuffer reset];
        [correlationBuffer reset];
    }
}

-(float)calculateCorrelation{
    float a,b,c,d,e,f,g,h,i;
    a = sumA*sumB/correlationWindowSize;
    b = sumAB - a;
    c = sumA*sumA/correlationWindowSize;
    d = squareSumA - c;
    e = sumB*sumB/correlationWindowSize;
    f = squareSumB - e;
    g = d*f;
    h = sqrtf(g);
    i = b/h;
    if(g<=0||h==0){
        i=0;
    }
    
   // float correlation = (sumAB - sumA*sumB/correlationWindowSize)/sqrtf((squareSumA-sumA*sumA/correlationWindowSize)*(squareSumB-sumB*sumB/correlationWindowSize));

    
    return i;
    
    
}
-(void)trace{
    NSLog(@"tracing current correlation buffer");
    for(int i = 0; i<2600; i++){
        [fileHandle writeData:[[NSString stringWithFormat:@"%f\n",realBuffer.samples[i]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
}
-(void)restart{
    stop = NO;
}
@end
