//
//  Config.h
//  TapirLib
//
//  Created by Jimin Jeon on 1/21/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#ifndef __TapirLib__Config__
#define __TapirLib__Config__

//#include <Accelerate/Accelerate.h>
#include <vector>
#include "TapirDSP.h"
#include "TrellisCode.h"

#define ASCII_ETX 0x03

namespace Tapir{
    class Config
    {
    public:
        
        Config() = delete;

        static const float  AUDIO_SAMPLE_RATE;
        static const int    AUDIO_CHANNEL;
        static const float  AUDIO_MAX_VOLUME;

        static const int    PREAMBLE_BIT_LENGTH;
        static const float  PREAMBLE_BITS [];
        
        static const float  PREAMBLE_BANDWIDTH;
        static const int    PREAMBLE_SAMPLE_LENGTH;
        
        static const int    MAX_SYMBOL_LENGTH;
        static const int    SAMPLE_LENGTH_EACH_SYMBOL;
        static const int    SAMPLE_LENGTH_CYCLIC_PREFIX;
        static const int    SAMPLE_LENGTH_CYCLIC_POSTFIX;
        static const int    SAMPLE_LENGTH_EACH_SYMBOL_WITH_EXTENSION;
        static const int    SAMPLE_LENGTH_INTERVAL_AFTER_PREAMBLE;
        static const int    SAMPLE_LENGTH_GUARD_INTERVAL;
        
        static const int    LENGTH_INPUT_BUFFER;
        
        static const float  CARRIER_FREQUENCY_BASE;
        static const float  CARRIER_FREQUENCY_TRANSMIT_OFFSET;
        static const float  CARRIER_FREQUENCY_RECEIVE_OFFSET;
        
        static const int    NO_DATA_SUBCARRIERS;
        static const int    NO_PILOT_SUBCARRIERS;
        static const int    NO_TOTAL_SUBCARRIERS;
        static const int    PILOT_LOCATIONS [];
        
        static const TapirDSP::SplitComplex     PILOT_DATA;
        
        static const int    MODULATION_RATE;
        static const int    INTERLEAVER_ROWS;
        static const int    INTERLEAVER_COLS;
        
//        static const std::vector<TrellisCode> TRELLIS_ARRAY;
        static const unsigned long ENCODING_RATE;
        static const int    DATA_BIT_LENGTH;
        
        static const int    FILTER_GUARD_LENGTH;
//        static const float  CORRELATOR_THRESHOLD;
    private:
        
        static float pilotRealp [];
        static float pilotImagp [];
        
    };

}

#endif /* defined(__TapirLib__Config__) */
