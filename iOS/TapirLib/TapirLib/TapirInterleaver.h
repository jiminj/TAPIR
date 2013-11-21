//
//  TapirInterleaver.h
//  TapirLib
//
//  Created by Jimin Jeon on 11/21/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>

@interface TapirInterleaver : NSObject
{
    int nRows;
    int nCols;
}
- (id)initWithNRows:(const int)_nRows NCols:(const int)_nCols;
- (void)interleave:(DSPSplitComplex *)source to:(DSPSplitComplex *)dest;
- (void)deinterleave:(DSPSplitComplex *)source to:(DSPSplitComplex *)dest;


@property int nRows, nCols;
@end
