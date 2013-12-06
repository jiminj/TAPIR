//
//  TapirInterleaver.h
//  TapirLib
//
//  Created by Jimin Jeon on 11/21/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>

@protocol TapirInterleaver <NSObject>

- (void)interleave:(float *)source to:(float *)dest;
- (void)deinterleave:(float *)source to:(float *)dest;

@end

@interface TapirMatrixInterleaver : NSObject<TapirInterleaver>
{
    int nRows;
    int nCols;
}
- (id)initWithNRows:(const int)_nRows NCols:(const int)_nCols;
- (void)interleaveComplex:(DSPSplitComplex *)source to:(DSPSplitComplex *)dest;
- (void)deinterleaveComplex:(DSPSplitComplex *)source to:(DSPSplitComplex *)dest;


@property int nRows, nCols;
@end
