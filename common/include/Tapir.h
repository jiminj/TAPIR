//
//  Tapir.h
//  Tapir
//
//  Created by Jimin Jeon on 3/7/16.
//  Copyright © 2016 Jimin Jeon. All rights reserved.
//

#ifndef TapirLib_TapirLib_h
#define TapirLib_TapirLib_h

#ifdef __APPLE__
    #import <UIKit/UIKit.h>

    //! Project version number for Tapir.
    FOUNDATION_EXPORT double TapirVersionNumber;

    //! Project version string for Tapir.
    FOUNDATION_EXPORT const unsigned char TapirVersionString[];

    // In this header, you should import all the public headers of your framework using statements like #import <Tapir/PublicHeader.h>
    #import "DevicesSpecifications.h"
    #include "ObjcFuncBridge.h"
#endif

#include "TapirDSP.h"
#include "Config.h"
#include "PilotManager.h"
#include "ChannelEstimator.h"
#include "Interleaver.h"
#include "Modulator.h"

#include "Utilities.h"
#include "Filter.h"
#include "CircularQueue.h"
#include "AutoCorrelator.h"
#include "SignalDetector.h"
#include "TrellisCode.h"
#include "Encoder.h"
#include "Decoder.h"

#include "SignalAnalyzer.h"
#include "SignalGenerator.h"

#endif