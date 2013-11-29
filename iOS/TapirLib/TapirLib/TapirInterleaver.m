//
//  TapirInterleaver.m
//  TapirLib
//
//  Created by Jimin Jeon on 11/21/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import "TapirInterleaver.h"

@implementation TapirMatrixInterleaver
@synthesize nRows, nCols;

- (id)init
{
    return nil;
}

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
    vDSP_mtrans(source->realp, 1, dest->realp, 1, nCols, nRows);
    vDSP_mtrans(source->imagp, 1, dest->imagp, 1, nCols, nRows);
}

- (void)deinterleave:(DSPSplitComplex *)source to:(DSPSplitComplex *)dest
{
    vDSP_mtrans(source->realp, 1, dest->realp, 1, nRows, nCols);
    vDSP_mtrans(source->imagp, 1, dest->imagp, 1, nRows, nCols);
}

@end
