//
//  Config.cpp
//  TapirLib
//
//  Created by Jimin Jeon on 1/21/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#include "../include/Config.h"


namespace Tapir {

    const float Config::AUDIO_SAMPLE_RATE = 44100.f;
    const int   Config::AUDIO_CHANNEL = 1;
    const float Config::AUDIO_MAX_VOLUME = 1.0f;

    const int   Config::PREAMBLE_BIT_LENGTH = 4;
    const float Config::PREAMBLE_BITS [] = {-1.f, -1.f, -1.f, 1.f};
    const float Config::PREAMBLE_BANDWIDTH = 441.f;

//    const int   Config::PREAMBLE_BIT_LENGTH = 7;
//    const float Config::PREAMBLE_BITS [] = {-1.f, -1.f, -1.f, 1.f, 1.f, -1.f, 1.f};
//    const float Config::PREAMBLE_BANDWIDTH = 882.f;
    
    const int   Config::PREAMBLE_SAMPLE_LENGTH = static_cast<int>(AUDIO_SAMPLE_RATE / PREAMBLE_BANDWIDTH * PREAMBLE_BIT_LENGTH);
    
    const int   Config::MAX_SYMBOL_LENGTH = 8;
//    const int   Config::SAMPLE_LENGTH_EACH_SYMBOL = 2048;
    const int   Config::SAMPLE_LENGTH_EACH_SYMBOL = 1024;
    const int   Config::SAMPLE_LENGTH_CYCLIC_PREFIX = Config::SAMPLE_LENGTH_EACH_SYMBOL / 2;
    const int   Config::SAMPLE_LENGTH_CYCLIC_POSTFIX = Config::SAMPLE_LENGTH_EACH_SYMBOL / 4;
    const int   Config::SAMPLE_LENGTH_GUARD_INTERVAL = 0;
    const int   Config::SAMPLE_LENGTH_INTERVAL_AFTER_PREAMBLE = Config::SAMPLE_LENGTH_EACH_SYMBOL / 2;
    const int   Config::SAMPLE_LENGTH_EACH_SYMBOL_WITH_EXTENSION = Config::SAMPLE_LENGTH_CYCLIC_PREFIX + Config::SAMPLE_LENGTH_CYCLIC_POSTFIX + Config::SAMPLE_LENGTH_EACH_SYMBOL;
    
    const int   Config::LENGTH_INPUT_BUFFER =   Config::SAMPLE_LENGTH_INTERVAL_AFTER_PREAMBLE +
                                                Config::SAMPLE_LENGTH_EACH_SYMBOL_WITH_EXTENSION * Config::MAX_SYMBOL_LENGTH +
                                                Config::SAMPLE_LENGTH_GUARD_INTERVAL * (Config::MAX_SYMBOL_LENGTH - 1);
    
    
    const float Config::CARRIER_FREQUENCY_BASE = 20000.f;
    const float Config::CARRIER_FREQUENCY_TRANSMIT_OFFSET = 0.0f;
    const float Config::CARRIER_FREQUENCY_RECEIVE_OFFSET = 0.0f;

    const int   Config::NO_DATA_SUBCARRIERS = 16;
    const int   Config::NO_PILOT_SUBCARRIERS = 4;
    const int   Config::NO_TOTAL_SUBCARRIERS = Config::NO_DATA_SUBCARRIERS + Config::NO_PILOT_SUBCARRIERS;

    float Config::pilotRealp[] = {1.f, 1.f, 1.f, -1.f};
    float Config::pilotImagp[] = {0.f, 0.f, 0.f, 0.f};

    const TapirDSP::SplitComplex Config::PILOT_DATA = { .realp=Config::pilotRealp, .imagp=Config::pilotImagp };
    
    const int   Config::PILOT_LOCATIONS [] = {3, 7, 11, 15};
    const int   Config::MODULATION_RATE = 2;
    const int   Config::INTERLEAVER_ROWS = 4;
    const int   Config::INTERLEAVER_COLS = Config::NO_DATA_SUBCARRIERS / Config::INTERLEAVER_ROWS;
    
    const static TrellisCode trelArr[2] = {TrellisCode(171), TrellisCode(133)};
    const std::vector<TrellisCode> Config::TRELLIS_ARRAY(trelArr, trelArr + sizeof(trelArr) / sizeof(trelArr[0]) );
//    const unsigned long Config::ENCODING_RATE = TRELLIS_ARRAY.size();

    const unsigned long Config::ENCODING_RATE = 2;
    const int   Config::DATA_BIT_LENGTH = NO_DATA_SUBCARRIERS / ENCODING_RATE;
    
    const int   Config::FILTER_GUARD_LENGTH = 250;
//    const float Config::CORRELATOR_THRESHOLD = 0.5f;
    
    
};
