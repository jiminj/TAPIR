//
//  TapirChannelEstimator.h
//  TapirLib
//
//  Created by Jimin Jeon on 11/19/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>

@protocol TapirChannelEstimator <NSObject>

@end

@interface TapirLSChannelEstimator : NSObject<TapirChannelEstimator>
{
    float * pilotIndex;
    DSPSplitComplex refPilotValue;
    int pilotLength;
    
    DSPSplitComplex channel;
    int channelLength;
}
- (void)setPilot:(const DSPSplitComplex *)value index:(const int *)index length:(const int)length;

- (void)generateChannelWith:(const DSPSplitComplex *)pilotChannel channelLength:(const int)channelLength;

- (void)channelEstimate:(const DSPSplitComplex *)data length:(const int)length;

- (void)applyChannel:(const DSPSplitComplex *)src dest:(DSPSplitComplex *)dest;

@end
