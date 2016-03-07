//
//  TrellisCode.cpp
//  TapirLib
//
//  Created by Jimin Jeon on 1/24/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#include "../include/TrellisCode.h"
#include <cstring>

namespace Tapir {
    
    TrellisCode::TrellisCode(const int g)
    :m_g(g),
    m_length(0)
    {
        //get the bit length of trellis code.
        m_length = 0;
        int _g = m_g;
        
        for( ; _g > 9 ; _g/=10 )
        { m_length += 3; }
        for( ; _g > 0; _g /= 2 )
        { ++m_length; }
        
        
        //Alloc and clear the array for code
        m_encodedCode = new float[m_length]();
        
        //encoding
        int arrayIdx = m_length - 1;
        
        _g = m_g;
        for(; _g > 0; _g /= 10)
        {
            int gLastDigit = _g % 10;
            int cnt = 3;
            while(gLastDigit > 0)
            {
                m_encodedCode[arrayIdx--] = static_cast<float>(gLastDigit % 2);
                gLastDigit /= 2;
                --cnt;
            }
            arrayIdx -= cnt;
        }
    };
    TrellisCode::TrellisCode(const TrellisCode& rhs)
    :m_g(rhs.m_g), m_length(rhs.m_length),
    m_encodedCode(new float[m_length])
    {
        TapirDSP::copy(rhs.m_encodedCode, rhs.m_encodedCode + m_length, m_encodedCode);
    };
    TrellisCode::~TrellisCode()
    {
        delete [] m_encodedCode;
    }
    
    void TrellisCode::extendTo(const int extLength)
    {
        int ext = extLength - m_length;
        if(ext > 0)
        {
            float * temp = new float[extLength];
            TapirDSP::copy(m_encodedCode, m_encodedCode + m_length, temp+ext);
            m_length = extLength;
            
            delete [] m_encodedCode;
            m_encodedCode = temp;
        }
    }
    int TrellisCode::getBitsAsInteger() const
    {
        int retVal = 0;
        for(int i=0; i<m_length; ++i)
        {
            retVal |= static_cast<int>(m_encodedCode[i]) << (m_length-i-1);
        }
        return retVal;
    }

};

