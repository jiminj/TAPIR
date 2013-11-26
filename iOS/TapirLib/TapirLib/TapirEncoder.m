//
//  TapirEncoder.m
//  TapirLib
//
//  Created by Jimin Jeon on 11/25/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import "TapirEncoder.h"

@implementation TrellisCode
@synthesize length;
@synthesize encodedCode;

//Trellis Code Generator

- (id)initWithG : (int)_g
{
    if(self = [super init])
    {
        [self encode:_g];
    }
    return self;
}

-(void) encode:(int) _g
{
    g = _g;
    int gClone = _g;

    //get the length of trellis code.
    length = 0;
    
    for( ; gClone > 9 ; gClone/=10 )
    { length += 3; }
    for( ; gClone > 0; gClone /= 2 )
    { ++length; }
    

    //Alloc and clear the array for code
    if(encodedCode != NULL)
    {
        free(encodedCode);
        encodedCode = NULL;
    }
    encodedCode = calloc(length, sizeof(float));

    //encoding
    int arrayIdx = length - 1;
    
    for(; _g > 0; _g /= 10)
    {
        int gLastDigit = _g % 10;
        int cnt = 3;
        while(gLastDigit > 0)
        {
            encodedCode[arrayIdx--] = (float) (gLastDigit % 2);
            gLastDigit /= 2;
            --cnt;
        }
        arrayIdx -= cnt;
    }
}

- (void)extendTo : (int)extLength
{
    int ext = extLength - length;
    if(ext > 0)
    {
        float * temp = calloc(extLength, sizeof(float));
        memcpy((temp+ext), encodedCode, length * sizeof(float));
        length = extLength;
        
        free(encodedCode);
        encodedCode = temp;
        
    }
}

- (void) dealloc
{
    if(encodedCode != NULL)
    { free(encodedCode); }
}

@end


@implementation TapirConvEncoder
@synthesize trelCodeArr;

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

- (id)initWithTrellisCode:(TrellisCode *)code
{
    if(self = [super init])
    {
        [self addTrellisCode:code];
    }
    return self;
}
- (id) initWithTrellisG : (const int)trellisG
{
    if(self = [super init])
    {
        [self addTrellisCodeWithG:trellisG];
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

- (void)addTrellisCode:(TrellisCode *)code
{
    [self allocTrelCode];
    int newLength = [code length];

    if(newLength > trelCodeLen)
    {
        for(TrellisCode * trelElem in trelCodeArr)
        {
            [trelElem extendTo:newLength];
        }
        trelCodeLen = newLength;
    }
    else if(newLength < trelCodeLen)
    {
        [code extendTo:trelCodeLen];
    }

    [trelCodeArr addObject:code];
}
- (void)addTrellisCodeWithG:(const int)g
{
    [self allocTrelCode];
    TrellisCode * newTrel = [[TrellisCode alloc] initWithG:g];
    [self addTrellisCode:newTrel];
}
- (void)addTrellisCodeWithTrellisArray:(const NSMutableArray *)trelArray
{
    [self allocTrelCode];
    for(TrellisCode * trelElem in trelArray)
    {
        if([trelElem isKindOfClass:[TrellisCode class]])
        {
            [self addTrellisCode:trelElem];
        }
    }
}

- (float)getEncodingRate
{
    return (float)([trelCodeArr count]);
}

- (void)encode:(const float *)src dest:(float *)dest srcLength:(const int)srcLength
{
    //Convolutional Encoding
    
    int inputLength = (srcLength + trelCodeLen - 1);
    float * input = calloc(inputLength, sizeof(float));
    memcpy((input+trelCodeLen - 1), src, sizeof(float) * srcLength);

    int encodingRate = [self getEncodingRate];
    for(int i=0; i<encodingRate; ++i)
    {
        float * filt = [[trelCodeArr objectAtIndex:i] encodedCode] + trelCodeLen - 1; //End of the array
        vDSP_conv(input, 1, filt, -1, dest + i, encodingRate, srcLength, trelCodeLen);
    }
    
    free(input);
}
- (void)decode:(const float *)src dest:(float *)dest
{
    //Viterbi Decoding
    
}


@end
