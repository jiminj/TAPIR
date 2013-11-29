//
//  TapirTrellisCode.m
//  TapirLib
//
//  Created by Jimin Jeon on 11/29/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import "TapirTrellisCode.h"


@implementation TapirTrellisCode
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

- (void)dealloc
{
    if(encodedCode != NULL)
    { free(encodedCode); }
}

- (int)getBitsAsInteger
{
    int retVal = 0;
    for(int i=0; i<length; ++i)
    {
        retVal |= ((int)encodedCode[i])<<(length-i-1);
    }
    return retVal;
}

@end



