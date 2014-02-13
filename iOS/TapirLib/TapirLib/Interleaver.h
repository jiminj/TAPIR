//
//  Interleaver.h
//  TapirLib
//
//  Created by Jimin Jeon on 1/23/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#ifndef __TapirLib__Interleaver__
#define __TapirLib__Interleaver__

#include "TapirDSP.h"

namespace Tapir{

    class Interleaver
    {
        virtual void interleave(const float * src, float * dest) const = 0;
        virtual void deinterleave(const float * src, float * dest) const = 0;
        virtual void interleave(const TapirDSP::SplitComplex * src, const TapirDSP::SplitComplex * dest) const = 0;
        virtual void deinterleave(const TapirDSP::SplitComplex * src, const TapirDSP::SplitComplex * dest) const = 0;
    };
    
    class MatrixInterleaver : public Interleaver
    {
    public:
        MatrixInterleaver(const int nRows, const int nCols);
        void interleave(const float * src, float * dest) const;
        void interleave(const TapirDSP::SplitComplex * src, const TapirDSP::SplitComplex * dest) const;
        
        void deinterleave(const float * src, float * dest) const;
        void deinterleave(const TapirDSP::SplitComplex * src, const TapirDSP::SplitComplex * dest) const;
        
    protected:
        int m_nRows;
        int m_nCols;
    };
}

#endif /* defined(__TapirLib__Interleaver__) */
