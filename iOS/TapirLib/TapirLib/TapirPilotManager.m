//
//  TapirPilotManager.m
//  TapirLib
//
//  Created by Jimin Jeon on 12/4/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import "TapirPilotManager.h"

@implementation TapirPilotManager
@synthesize pilotLength;

- (id)initWithPilot:(DSPSplitComplex *)data index:(const int *)index length:(const int)length
{
    if(self = [super init])
    {
        [self setPilot:data index:index pilotLength:length];
    }
    return self;
}
- (id)initWithPilotIndex:(const int *)index length:(const int)length
{
    if(self = [super init])
    {
        [self setPilotIndex:index pilotLength:length];
    }
    return self;
}

- (void)setPilotIndex:(const int *)index pilotLength:(const int)length
{
    DSPSplitComplex nullData;
    nullData.realp = calloc(length, sizeof(int));
    nullData.imagp = calloc(length, sizeof(int));
    
    [self setPilot:&nullData index:index pilotLength:length];

    free(nullData.realp);
    free(nullData.imagp);
}

- (void)setPilot:(DSPSplitComplex *)data index:(const int *)index pilotLength:(const int)length;
{
    if(pilotIndex != NULL) { free(pilotIndex); }
    pilotIndex = malloc(sizeof(int) * length);
    
    if(pilotData.realp != NULL) { free(pilotData.realp); }
    if(pilotData.imagp != NULL) { free(pilotData.imagp); }
    pilotData.realp = malloc(sizeof(float) * length);
    pilotData.imagp = malloc(sizeof(float) * length);
    
    pilotLength = length;
    
    memcpy(pilotIndex, index, sizeof(int) * length);
    vDSP_zvmov(data, 1, &pilotData, 1, length);
}


- (void)addPilotTo:(const DSPSplitComplex *)src dest:(DSPSplitComplex *)dest srcLength:(int)srcLength
{
//    int * curPilotIdx = pilotIndex;
    int curPilotIdx = 0;
    int srcIdx = 0;
    int destLength = srcLength + pilotLength;

    for(int i=0; i< destLength; ++i)
    {
        if(i == pilotIndex[curPilotIdx])
        {
            dest->realp[i] = pilotData.realp[curPilotIdx];
            dest->imagp[i] = pilotData.imagp[curPilotIdx++];
        }
        else
        {
            dest->realp[i] = src->realp[srcIdx];
            dest->imagp[i] = src->imagp[srcIdx++];
        }
    }
}

- (void)removePilotFrom:(const DSPSplitComplex *)src dest:(DSPSplitComplex *)dest srcLength:(int)srcLength
{
    int *curPilot = pilotIndex;
    int destIdx = 0;
    
    for(int i=0; i<srcLength; ++i)
    {
        if(i == *curPilot)
        { ++curPilot; }
        else
        {
            dest->realp[destIdx] = src->realp[i];
            dest->imagp[destIdx++] = src->imagp[i];
        }
    }
}

- (int *)pilotIndex
{
    return pilotIndex;
}
- (DSPSplitComplex *)pilotData
{
    return &pilotData;
}

- (void)dealloc
{
    if(pilotIndex != NULL) { free(pilotIndex); }
    if(pilotData.realp != NULL) { free(pilotData.realp); }
    if(pilotData.imagp != NULL) { free(pilotData.imagp); }
}

@end
