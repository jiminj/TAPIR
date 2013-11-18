//
//  TapirIqModulator.h
//  Tapir
//
//  Created by Jimin Jeon on 11/17/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <Accelerate/Accelerate.h>

@interface TapirIqModulator : NSObject  

+ (void) iqDemodulate:(const float *)signal dest:(DSPSplitComplex *)destSignal length:(const int)length samplingFreq:(const float)samplingFreq carrierFreq:(const float)carrierFreq;
+ (void) iqModulate:(const DSPSplitComplex *)signal dest:(float *)destSignal length:(const int)length samplingFreq:(const float)samplingFreq carrierFreq:(const float)carrierFreq;

@end
