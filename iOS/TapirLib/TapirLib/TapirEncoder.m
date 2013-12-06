//
//  TapirEncoder.m
//  TapirLib
//
//  Created by Jimin Jeon on 11/25/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import "TapirEncoder.h"


@implementation TapirConvEncoder
@synthesize trellisCodeLength;


- (id) initWithTrellisArray : (NSArray *)trelArray
{
    if(self = [super init])
    {
        trelCodeArr = [NSArray arrayWithArray:trelArray];
        
        trellisCodeLength = [[trelCodeArr objectAtIndex:0] length];
        for(int i=1; i<[trelCodeArr count]; ++i)
        {
            int objLength = [[trelArray objectAtIndex:i] length];
            if(objLength < trellisCodeLength)
            {
                [[trelArray objectAtIndex:i] extendTo:(trellisCodeLength-objLength)];
            }
            else if(objLength > trellisCodeLength)
            {
                trellisCodeLength = objLength;
                for(int j=0; j<i; ++j)
                {
                    [[trelArray objectAtIndex:j] extendTo:(objLength - trellisCodeLength)];
                }
            }
        }
        
    }
    return self;
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
    vDSP_vflt32(src, 1, input + (trellisCodeLength-1), 1, srcLength);
    
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

