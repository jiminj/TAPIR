//
//  TapirLib.h
//  TapirLib
//
//  Created by Jimin Jeon on 11/20/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#ifndef TapirLib_TapirLib_h
#define TapirLib_TapirLib_h

//New CPP Library
#ifdef __cplusplus
#include "ObjcFuncBridge.h"

#include "Config.h"
#include "PilotManager.h"
#include "ChannelEstimator.h"
#include "Interleaver.h"
#include "Modulator.h"

#include "TapirDsp.h"
#include "Filter.h"
#include "CircularQueue.h"
#include "AutoCorrelator.h"
#include "SignalDetector.h"
#include "TrellisCode.h"
#include "Encoder.h"

#endif


//#import "TapirEncoder.h"
#import "TapirDecoder.h"
#import "TapirTrellisCode.h"
//#import "TapirModulator.h"

#endif
