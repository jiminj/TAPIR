//
//  TapirConfig.h
//  TAPIRReceiver
//
//  Created by Jimin Jeon on 12/1/13.
//  Copyright (c) 2013 dilu. All rights reserved.
//

#import <TapirLib/TapirLib.h>

static const Float64 kTapirAudioSampleRate = 44100.f;
static const int    kTapirAudioChannel = 1;
static const int    kTapirAudioBitsPerChannel = 16;

static const int    kTapirSymbolLength = 2048;
static const int    kTapirCyclicPrefixLength = kTapirSymbolLength / 2;
static const int    kTapirCyclicPostfixLength = kTapirSymbolLength / 4;
static const int    kTapirGuardInterval = 0;

static const int    kTapirIntervalAfterPreamble = kTapirSymbolLength / 2;



static const float  kTapirCarrierFrequency = 20000;
static const int    kTapirNoSubcarriers = 16;

//For Channel Estimator
static const float  kTapirPilotDataReal[4] = { 1.f, 1.f, 1.f, -1.f };
static const float  kTapirPilotDataImag[4] = { .0f, .0f, .0f, .0f  };
static const int    kTapirPilotLocation[4] = { 3, 7, 11, 15 };

//For Decoder
static const int    kTapirDecoderTracebackLength = 4;
extern NSArray *    kTapirTrellisArray;

void TapirConfig();

//For Interleaver
//static const int kTapirInterleaveRows = 4;
//static const int kTapirInterleaveCols =