//
//  Encoder.h
//  TapirLib
//
//  Created by Jimin Jeon on 1/24/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#ifndef __TapirLib__Encoder__
#define __TapirLib__Encoder__

#include <vector>
#include <Accelerate/Accelerate.h>
#include "TrellisCode.h"

namespace Tapir {
    class Encoder
    {
        virtual void encode(const int * src, float * dest, const int srcLength) = 0;
    };
    
    class ConvEncoder : public Encoder
    {
    public:
        ConvEncoder(const std::vector<TrellisCode>& trelArray);
        void encode(const int * src, float * dest, const int srcLength);
        float getEncodingRate() const { return static_cast<float>(m_trelArray.size()); };
        
    private:
        std::vector<TrellisCode> m_trelArray;
        int m_trelCodeLength;
        
    };
};

#endif /* defined(__TapirLib__Encoder__) */
