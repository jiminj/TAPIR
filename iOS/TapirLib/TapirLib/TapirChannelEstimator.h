//
//  TapirChannelEstimator.h
//  TapirLib
//
//  Created by Jimin Jeon on 11/19/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>
//
//@protocol TapirChannelEstimator <NSObject>
//
//@end

@interface TapirLSChannelEstimator : NSObject /* <TapirChannelEstimator> */
{
    float * pilotIndex;
    DSPSplitComplex refPilotValue;
    int pilotLength;
    int channelLength;

    DSPSplitComplex channel;


}
- (void)setPilot:(const DSPSplitComplex *)value index:(const int *)index pilotLength:(const int)length channelLength:(const int)chLength;
- (void)channelEstimate:(const DSPSplitComplex *)src dest:(DSPSplitComplex *)dest;
- (void)removePilotsFromSignal:(const DSPSplitComplex *)src dest:(DSPSplitComplex *) dest;


@property (readonly) DSPSplitComplex channel;
@property (readonly) int channelLength;

@end
