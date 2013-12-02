//
//  TapirChannelEstimator.m
//  TapirLib
//
//  Created by Jimin Jeon on 11/19/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import "TapirChannelEstimator.h"

@interface TapirLSChannelEstimator()
{
    DSPSplitComplex rcvPilotValue;
    DSPSplitComplex pilotChannel;
}
- (void)generateChannelWith:(const DSPSplitComplex *)pilotChannel;

@end

@implementation TapirLSChannelEstimator
@synthesize channel;
@synthesize channelLength;
- (void)setPilot:(const DSPSplitComplex *)value index:(const int *)index pilotLength:(const int)length channelLength:(const int)chLength
{
    //Memory deallocation for safe
    if(pilotIndex != NULL)
    {
        free(pilotIndex);
        pilotIndex = NULL;
    }
    if( (refPilotValue.realp != NULL))
    {
        free(refPilotValue.realp);
        free(refPilotValue.imagp);
    }

    pilotLength = length;
    channelLength = chLength;
    
    pilotIndex = malloc(sizeof(float) * pilotLength);
    refPilotValue.realp = malloc(sizeof(float) * pilotLength);
    refPilotValue.imagp = malloc(sizeof(float) * pilotLength);

    channel.realp = malloc(sizeof(float) * channelLength);
    channel.imagp = malloc(sizeof(float) * channelLength);
    
    rcvPilotValue.realp = malloc(sizeof(float) * pilotLength);
    rcvPilotValue.imagp = malloc(sizeof(float) * pilotLength);
    pilotChannel.realp = malloc(sizeof(float) * pilotLength);
    pilotChannel.imagp = malloc(sizeof(float) * pilotLength);
    
    //copy
    vDSP_vflt32(index, 1, pilotIndex, 1, length);
    vDSP_zvmov(value, 1, &refPilotValue, 1, length);

}

- (void)generateChannelWith:(const DSPSplitComplex *)_pilotChannel
{
    bool isFirstElemAdded = false;
    bool isLastElemAdded = false;
    int extLength = pilotLength;
    
    if(pilotIndex[0] != 0)
    {
        isFirstElemAdded = true;
        ++extLength;
    }
    if(pilotIndex[pilotLength - 1] != pilotLength - 1)
    {
        isLastElemAdded = true;
        ++extLength;
    }
    
    
    float * extPilotIndex = malloc(sizeof(int) * extLength);
    DSPSplitComplex extPilotChannel;
    extPilotChannel.realp = malloc(sizeof(float) * extLength);
    extPilotChannel.imagp = malloc(sizeof(float) * extLength);
    
    //Copy (except first&last elems, if they needed)
    int stPos = (int)isFirstElemAdded;
    int edPos = pilotLength + stPos;
    for(int i=stPos; i<edPos; ++i)
    {
        extPilotIndex[i] = pilotIndex[i-stPos];
        extPilotChannel.realp[i] = _pilotChannel->realp[i-stPos];
        extPilotChannel.imagp[i] = _pilotChannel->imagp[i-stPos];
    }
    
    //Add first & last elem
    if(isFirstElemAdded)
    {
        extPilotIndex[0] = 0;
        if(pilotLength < 2)
        {
            extPilotChannel.realp[0] = _pilotChannel->realp[0];
            extPilotChannel.imagp[0] = _pilotChannel->imagp[0];
        }
        else
        {
            DSPComplex slope;
            float sampleDist = (float)(extPilotIndex[2] - extPilotIndex[1]);
            slope.real = (extPilotChannel.realp[2] - extPilotChannel.realp[1]) / sampleDist;
            slope.imag = (extPilotChannel.imagp[2] - extPilotChannel.imagp[1]) / sampleDist;
            
            float newDist = (float)(extPilotIndex[1] - extPilotIndex[0]);
            extPilotChannel.realp[0] = extPilotChannel.realp[1] - slope.real * newDist;
            extPilotChannel.imagp[0] = extPilotChannel.imagp[1] - slope.imag * newDist;
        }
    }
    if(isLastElemAdded)
    {
        extPilotIndex[extLength - 1] = (float)channelLength;
        if(pilotLength < 2)
        {
            extPilotChannel.realp[extLength - 1] = _pilotChannel->realp[0];
            extPilotChannel.imagp[extLength - 1] = _pilotChannel->imagp[0];
        }
        else
        {
            DSPComplex slope;
            float sampleDist = (float)(extPilotIndex[extLength - 2] - extPilotIndex[extLength - 3]);
            slope.real = (extPilotChannel.realp[extLength - 2] - extPilotChannel.realp[extLength - 3]) / sampleDist;
            slope.imag = (extPilotChannel.imagp[extLength - 2] - extPilotChannel.imagp[extLength - 3]) / sampleDist;
            float newDist = (float)(extPilotIndex[extLength - 1] - extPilotIndex[extLength - 2]);
            extPilotChannel.realp[extLength - 1] = extPilotChannel.realp[extLength - 2] + slope.real * newDist;
            extPilotChannel.imagp[extLength - 1] = extPilotChannel.imagp[extLength - 2] + slope.imag * newDist;
        }
    }

    //Generate Channel
    vDSP_vgenp(extPilotChannel.realp, 1, extPilotIndex, 1, channel.realp, 1, channelLength, extLength);
    vDSP_vgenp(extPilotChannel.imagp, 1, extPilotIndex, 1, channel.imagp, 1, channelLength, extLength);

    free(extPilotIndex);
    free(extPilotChannel.realp);
    free(extPilotChannel.imagp);
    
}


- (void)channelEstimate:(const DSPSplitComplex *)src dest:(DSPSplitComplex *)dest
{
    //Save Pilot Value
    vDSP_vindex(src->realp, pilotIndex, 1, rcvPilotValue.realp, 1, pilotLength);
    vDSP_vindex(src->imagp, pilotIndex, 1, rcvPilotValue.imagp, 1, pilotLength);
    vDSP_zvdiv(&refPilotValue, 1, &rcvPilotValue, 1, &pilotChannel, 1, pilotLength);

    [self generateChannelWith:&pilotChannel];
    
    //Conjugate and multiply
    vDSP_zvconj(&channel, 1, &channel, 1, channelLength);
    vDSP_zvmul(src, 1, &channel, 1, dest, 1, channelLength, 1 );
    
}

- (void)removePilotsFromSignal:(const DSPSplitComplex *)src dest:(DSPSplitComplex *)dest
{
    float *curPilot = pilotIndex;
    int destIdx = 0;
    
    for(int i=0; i<channelLength; ++i)
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

- (void)dealloc
{
    if(pilotIndex != NULL) { free(pilotIndex); }
    if(refPilotValue.realp != NULL) { free(refPilotValue.realp); }
    if(refPilotValue.imagp != NULL){ free(refPilotValue.imagp); }
    if(channel.realp != NULL) { free(channel.realp); }
    if(channel.imagp != NULL) { free(channel.imagp); }
    if(rcvPilotValue.realp != NULL) { free(rcvPilotValue.realp); }
    if(rcvPilotValue.imagp != NULL) { free(rcvPilotValue.imagp); }
    
}

@end
