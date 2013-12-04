//
//  TapirPilotManager.h
//  TapirLib
//
//  Created by Jimin Jeon on 12/4/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>

@interface TapirPilotManager : NSObject
{
    int * pilotIndex;
    int pilotLength;
    DSPSplitComplex pilotData;
}
- (id)initWithPilotIndex:(const int *)index length:(const int)length;
- (id)initWithPilot:(DSPSplitComplex *)data index:(const int *)index length:(const int)length;
- (void)setPilotIndex:(const int *)index pilotLength:(const int)length;
- (void)setPilot:(DSPSplitComplex *)data index:(const int *)index pilotLength:(const int)length;

- (void)removePilotFrom:(const DSPSplitComplex *)src dest:(DSPSplitComplex *) dest srcLength:(int)srcLength;
- (void)addPilotTo:(const DSPSplitComplex *)src dest:(DSPSplitComplex *)dest srcLength:(int)srcLength;

- (int *)pilotIndex;
- (DSPSplitComplex *)pilotData;


@property (readonly) int pilotLength;
@end
