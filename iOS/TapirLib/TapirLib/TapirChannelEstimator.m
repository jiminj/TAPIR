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
    DSPSplitComplex pilotOfRcvSignal;
    DSPSplitComplex pilotChannel;
}
- (void)generateChannelWith:(const DSPSplitComplex *)pilotChannel;

@end

@implementation TapirLSChannelEstimator
@synthesize channel;
@synthesize channelLength;

- (id)initWithPilot:(TapirPilotManager *)_pilot channelLength:(const int)chLength
{
    if(self = [super init])
    {
        [self setPilot:_pilot channelLength:chLength];
    }
    return self;
}

- (void)setPilot:(TapirPilotManager *)_pilot channelLength:(const int)chLength
{
    pilotInfo = _pilot;

    channelLength = chLength;
    
    free(channel.realp);
    free(channel.imagp);
    channel.realp = malloc(sizeof(float) * channelLength);
    channel.imagp = malloc(sizeof(float) * channelLength);

    free(pilotOfRcvSignal.realp);
    free(pilotOfRcvSignal.imagp);
    pilotOfRcvSignal.realp = malloc(sizeof(float) * [pilotInfo pilotLength]);
    pilotOfRcvSignal.imagp = malloc(sizeof(float) * [pilotInfo pilotLength]);
    
    free(pilotChannel.realp);
    free(pilotChannel.imagp);
    pilotChannel.realp = malloc(sizeof(float) * [pilotInfo pilotLength]);
    pilotChannel.imagp = malloc(sizeof(float) * [pilotInfo pilotLength]);
    
    free(fltPilotIndex);
    fltPilotIndex = malloc(sizeof(float) * [pilotInfo pilotLength]);
    vDSP_vflt32([pilotInfo pilotIndex], 1, fltPilotIndex, 1, [pilotInfo pilotLength]);

}

- (void)generateChannelWith:(const DSPSplitComplex *)_pilotChannel
{
    bool isFirstElemAdded = false;
    bool isLastElemAdded = false;
    int pilotLength = [pilotInfo pilotLength];
    int extLength = pilotLength;
    int * pilotIndex = [pilotInfo pilotIndex];
    
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
    
    
    float * extPilotIndex = malloc(sizeof(float) * extLength);
    DSPSplitComplex extPilotChannel;
    extPilotChannel.realp = malloc(sizeof(float) * extLength);
    extPilotChannel.imagp = malloc(sizeof(float) * extLength);
    
    //Copy (except first&last elems, if they needed)
    int stPos = (int)isFirstElemAdded;
    int edPos = pilotLength + stPos;
    for(int i=stPos; i<edPos; ++i)
    {
        extPilotIndex[i] = fltPilotIndex[i-stPos];
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
            float sampleDist = extPilotIndex[2] - extPilotIndex[1];
            slope.real = (extPilotChannel.realp[2] - extPilotChannel.realp[1]) / sampleDist;
            slope.imag = (extPilotChannel.imagp[2] - extPilotChannel.imagp[1]) / sampleDist;
            
            float newDist = extPilotIndex[1] - extPilotIndex[0];
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
            float sampleDist = extPilotIndex[extLength - 2] - extPilotIndex[extLength - 3];
            slope.real = (extPilotChannel.realp[extLength - 2] - extPilotChannel.realp[extLength - 3]) / sampleDist;
            slope.imag = (extPilotChannel.imagp[extLength - 2] - extPilotChannel.imagp[extLength - 3]) / sampleDist;
            float newDist = extPilotIndex[extLength - 1] - extPilotIndex[extLength - 2];
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
    vDSP_vindex(src->realp, fltPilotIndex, 1, pilotOfRcvSignal.realp, 1, [pilotInfo pilotLength]);
    vDSP_vindex(src->imagp, fltPilotIndex, 1, pilotOfRcvSignal.imagp, 1, [pilotInfo pilotLength]);
    vDSP_zvdiv([pilotInfo pilotData], 1, &pilotOfRcvSignal, 1, &pilotChannel, 1, [pilotInfo pilotLength]);

    [self generateChannelWith:&pilotChannel];
    
    //Conjugate and multiply
    vDSP_zvconj(&channel, 1, &channel, 1, channelLength);
    vDSP_zvmul(src, 1, &channel, 1, dest, 1, channelLength, 1 );
    
}

- (void)dealloc
{
    free(channel.realp);
    free(channel.imagp); 
    free(pilotOfRcvSignal.realp);
    free(pilotOfRcvSignal.imagp);
    free(fltPilotIndex);
}

@end
