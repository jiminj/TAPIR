//
//  TapirChannelEstimator.m
//  TapirLib
//
//  Created by Jimin Jeon on 11/19/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import "TapirChannelEstimator.h"

@implementation TapirLSChannelEstimator

- (void)setPilot:(const DSPSplitComplex *)value index:(const int *)index length:(const int)length
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
    pilotIndex = malloc(sizeof(float) * pilotLength);
    refPilotValue.realp = malloc(sizeof(float) * pilotLength);
    refPilotValue.imagp = malloc(sizeof(float) * pilotLength);
    
    //copy
    vDSP_vflt32(index, 1, pilotIndex, 1, length);
    vDSP_zvmov(value, 1, &refPilotValue, 1, length);
}

- (void)generateChannelWith:(const DSPSplitComplex *)pilotChannel channelLength:(const int)_channelLength
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
    
    NSLog(@"%d",extLength);
    
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
        extPilotChannel.realp[i] = pilotChannel->realp[i-stPos];
        extPilotChannel.imagp[i] = pilotChannel->imagp[i-stPos];
    }

    //Add first & last elem
    if(isFirstElemAdded)
    {
        extPilotIndex[0] = 0;
        if(pilotLength < 2)
        {
            extPilotChannel.realp[0] = pilotChannel->realp[0];
            extPilotChannel.imagp[0] = pilotChannel->imagp[0];
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
        extPilotIndex[extLength - 1] = (float)_channelLength;
        if(pilotLength < 2)
        {
            extPilotChannel.realp[extLength - 1] = pilotChannel->realp[0];
            extPilotChannel.imagp[extLength - 1] = pilotChannel->imagp[0];
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
    channel.realp = malloc(sizeof(float) * _channelLength);
    channel.imagp = malloc(sizeof(float) * _channelLength);
    
    vDSP_vgenp(extPilotChannel.realp, 1, extPilotIndex, 1, channel.realp, 1, _channelLength, extLength);
    vDSP_vgenp(extPilotChannel.imagp, 1, extPilotIndex, 1, channel.imagp, 1, _channelLength, extLength);

//    for(int i=0; i<_channelLength; ++i)
//    {
//        NSLog(@"%d => %f + %fi", i, channel.realp[i], channel.imagp[i]);
//    }

    free(extPilotIndex);
    free(extPilotChannel.realp);
    free(extPilotChannel.imagp);
}


- (void)channelEstimate:(const DSPSplitComplex *)data length:(const int)length
{
    DSPSplitComplex rcvPilotValue;
    rcvPilotValue.realp = malloc(sizeof(float) * pilotLength);
    rcvPilotValue.imagp = malloc(sizeof(float) * pilotLength);
    
    //Save Pilot Value
    vDSP_vindex(data->realp, pilotIndex, 1, rcvPilotValue.realp, 1, pilotLength);
    vDSP_vindex(data->imagp, pilotIndex, 1, rcvPilotValue.imagp, 1, pilotLength);
    

    DSPSplitComplex pilotChannel;
    pilotChannel.realp = malloc(sizeof(float) * pilotLength);
    pilotChannel.imagp = malloc(sizeof(float) * pilotLength);
    vDSP_zvdiv(&rcvPilotValue, 1, &refPilotValue, 1, &pilotChannel, 1, pilotLength);
    
    [self generateChannelWith:&pilotChannel channelLength:length];
    
    free(rcvPilotValue.realp);
    free(rcvPilotValue.imagp);
    
}

- (void)applyChannel:(const DSPSplitComplex *)src dest:(DSPSplitComplex *)dest
{
    vDSP_zvmul(src, 1, &channel, 1, dest, 1, channelLength, 1);
}

- (void)dealloc
{
    if(pilotIndex != NULL)
    { free(pilotIndex); }
    if(refPilotValue.realp != NULL)
    {
        free(refPilotValue.realp);
        free(refPilotValue.imagp);
    }
    if(channel.realp != NULL)
    {
        free(channel.realp);
        free(channel.imagp);
    }

}

@end
