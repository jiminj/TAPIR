//
//  TapirInterleaver.m
//  TapirLib
//
//  Created by Jimin Jeon on 11/21/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import "TapirInterleaver.h"

@implementation TapirInterleaver
@synthesize nRows, nCols;

- (id)initWithNRows:(const int)_nRows NCols:(const int)_nCols
{
    if(self = [super init])
    {
        [self setNRows:_nRows];
        [self setNCols:_nCols];
    }
    return self;
}
- (void)interleave:(DSPSplitComplex *)source to:(DSPSplitComplex *)dest
{
    int cnt = 0;
    for(int i=0; i<nRows; ++i)
    {
        for(int j=0; j<nCols; ++j)
        {
            int order = nRows * j + i;
            dest->realp[order] = source->realp[cnt];
            dest->imagp[order] = source->imagp[cnt++];
        }
    }
}

- (void)deinterleave:(DSPSplitComplex *)source to:(DSPSplitComplex *)dest
{
    int cnt = 0;
    for(int i=0; i<nRows; ++i)
    {
        for(int j=0; j<nCols; ++j)
        {
            int order = nRows * j + i;
            dest->realp[cnt] = source->realp[order];
            dest->imagp[cnt++] = source->imagp[order];
        }
    }
}

@end
