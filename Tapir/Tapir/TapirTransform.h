//
//  TapirTransform.h
//  Tapir
//
//  Created by Jimin Jeon on 11/16/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <Accelerate/Accelerate.h>

@interface TapirTransform : NSObject

+(void)fftComplex:(const DSPSplitComplex *)signal dest:(DSPSplitComplex *)dest length:(const int)fftLength;
+(void)iFftComplex:(const DSPSplitComplex *)signal dest:(DSPSplitComplex *)dest length:(const int)fftLength;

@property int transformLength;
@end
