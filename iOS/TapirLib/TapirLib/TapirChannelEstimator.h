//
//  TapirChannelEstimator.h
//  TapirLib
//
//  Created by Jimin Jeon on 11/19/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>
#import "TapirPilotManager.h"

@interface TapirLSChannelEstimator : NSObject /* <TapirChannelEstimator> */
{
    TapirPilotManager * pilotInfo;
    float * fltPilotIndex;
    int channelLength;

    DSPSplitComplex channel;


}
- (id)initWithPilot:(TapirPilotManager *)_pilot channelLength:(const int)chLength;
- (void)setPilot:(TapirPilotManager *)_pilot channelLength:(const int)chLength;
- (void)channelEstimate:(const DSPSplitComplex *)src dest:(DSPSplitComplex *)dest;

@property (readonly) DSPSplitComplex channel;
@property (readonly) int channelLength;

@end
