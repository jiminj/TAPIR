//
//  Decoder.h
//  TapirLib
//
//  Created by Jimin Jeon on 1/24/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#ifndef __TapirLib__Decoder__
#define __TapirLib__Decoder__
#include <vector>
#include <Accelerate/Accelerate.h>
#include "TrellisCode.h"

namespace Tapir {
    
    class Decoder
    {
        virtual void decode(const float * src, int * dest, const int srcLength) = 0;
    };
    
    class ViterbiDecoder : public Decoder
    {
    public:
        ViterbiDecoder(const std::vector<TrellisCode>& trelArray);
        ~ViterbiDecoder();
        int getEncodingRate() const { return m_noTrellis;};
        void decode(const float * src, int * dest, const int srcLength) { decode(src, dest, srcLength, 0); };
        void decode(const float * src, int * dest, const int srcLength, const int extLength);
        
    protected:
        void genTables(const std::vector<TrellisCode>& trelArray);
        inline int calHammingDistance(int a, int b) const;
        
    private:
        
        int m_noTrellis; //No. of trellis code used
        int m_noRegisterBits; // No. of register bits in Trellis Code (constraint Length - 1)
        int m_noStates; // No. of states enabled
        int m_noInfoTableCols; // Number of cases for input, obviously should be 2
        
        int ** m_nextStateRouteTable;
        int ** m_outputTable;
    };
    
    
    inline int ViterbiDecoder::calHammingDistance(int a, int b) const
    {
        int retVal = 0;
        while( (a != 0) || (b != 0) )
        {
            retVal += ((a & 1) ^ (b & 1));
            a >>= 1;
            b >>= 1;
        }
        return retVal;
    };
    
    
};

#endif /* defined(__TapirLib__Decoder__) */

