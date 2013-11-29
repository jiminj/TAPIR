//
//  TapirEncoder.m
//  TapirLib
//
//  Created by Jimin Jeon on 11/25/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import "TapirEncoder.h"


@interface TapirConvEncoder()

- (NSMutableArray *)allocTrelCode;
- (void)addTrellisCode:(TapirTrellisCode *)code;

@end


@implementation TapirConvEncoder
@synthesize trellisCodeLength;

- (NSMutableArray *)allocTrelCode
{
    if(trelCodeArr == NULL)
    {
        trelCodeArr = [[NSMutableArray alloc] init];
    }
    return trelCodeArr;
}
- (void)clearTrellisCode
{
    [trelCodeArr removeAllObjects];
    [self allocTrelCode];
}

- (id)init
{
    if(self = [super init])
    {
        [self allocTrelCode];
    }
    return self;
}

- (id)initWithTrellisCode:(TapirTrellisCode *)code
{
    if(self = [super init])
    {
        [self addTrellisCode:code];
    }
    return self;
}
- (id) initWithTrellisArray : (const NSMutableArray *)trelArray
{
    if(self = [super init])
    {
        [self addTrellisCodeWithTrellisArray:trelArray];
    }
    return self;
}

- (void)addTrellisCode:(TapirTrellisCode *)code
{
    [self allocTrelCode];
    int newLength = [code length];

    if(newLength > trellisCodeLength)
    {
        for(TapirTrellisCode * trelElem in trelCodeArr)
        {
            [trelElem extendTo:newLength];
        }
        trellisCodeLength = newLength;
    }
    else if(newLength < trellisCodeLength)
    {
        [code extendTo:trellisCodeLength];
    }

    [trelCodeArr addObject:code];
}

- (void)addTrellisCodeWithTrellisArray:(const NSMutableArray *)trelArray
{
    [self allocTrelCode];
    for(TapirTrellisCode * trelElem in trelArray)
    {
        if([trelElem isKindOfClass:[TapirTrellisCode class]])
        {
            [self addTrellisCode:trelElem];
        }
    }
}

- (float)getEncodingRate
{
    return (float)([trelCodeArr count]);
}

- (void)encode:(const int *)src dest:(float *)dest srcLength:(const int)srcLength
{
    //Convolutional Encoding
    
    
    
    
    int inputLength = (srcLength + trellisCodeLength - 1);
    float * input = calloc(inputLength, sizeof(float));
    vDSP_vflt32(src, 1, (input+trellisCodeLength-1), 1, srcLength);
//    memcpy((input+trellisCodeLength - 1), src, sizeof(float) * srcLength);
    
    
    int encodingRate = [self getEncodingRate];
    for(int i=0; i<encodingRate; ++i)
    {
        float * filt = [[trelCodeArr objectAtIndex:i] encodedCode] + trellisCodeLength - 1; //End of the array
        vDSP_conv(input, 1, filt, -1, dest + i, encodingRate, srcLength, trellisCodeLength);
    }
    int destLength = srcLength * encodingRate;
    for(int i=0; i<destLength; ++i)
    {
        dest[i] = fmodf(dest[i], 2.0f);
    }
    free(input);
}

@end

