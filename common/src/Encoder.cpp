//
//  Encoder.cpp
//  TapirLib
//
//  Created by Jimin Jeon on 1/24/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#include "../include/Encoder.h"

namespace Tapir {

    
    ConvEncoder::ConvEncoder(const std::vector<TrellisCode>& trelArray)
    :m_trelArray(trelArray)
    {
        m_trelCodeLength = (m_trelArray.front()).getLength();
        //Maximum code length

        for(TrellisCode & code : m_trelArray)
        {
            int objLength = code.getLength();
            if(objLength < m_trelCodeLength)
            {
                code.extendTo(m_trelCodeLength - objLength);
            }
            else if (objLength > m_trelCodeLength)
            {
                m_trelCodeLength = objLength;
                for(TrellisCode & _code : m_trelArray)
                {
                    _code.extendTo(objLength - m_trelCodeLength);
                }
            }
        }
    };
    void ConvEncoder::encode(const int * src, float * dest, const int srcLength)
    {
        //Convolutional Encoding
        int inputLength = (srcLength + m_trelCodeLength - 1);
        float * input = new float[inputLength]();
        TapirDSP::vflt32(src, input + (m_trelCodeLength-1), srcLength);
        int encodingRate = static_cast<int>(m_trelArray.size());
        int destLength = srcLength * encodingRate;

        float * resultConvolution = new float[destLength];
        
        for(int i=0; i<encodingRate; ++i)
        {
            const float * filter = (m_trelArray.at(i)).getEncodedCode();
            TapirDSP::conv(input, filter, resultConvolution + (i * srcLength), srcLength, m_trelCodeLength);
        }
        TapirDSP::mtrans(resultConvolution, dest, srcLength, encodingRate);

        for(int i=0; i<destLength; ++i)
        {
            dest[i] = fmodf(dest[i], 2.0f);
        }
        
        delete [] input;
    };
    
}
