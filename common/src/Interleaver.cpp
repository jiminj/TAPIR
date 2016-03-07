//
//  Interleaver.cpp
//  TapirLib
//
//  Created by Jimin Jeon on 1/23/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#include "../include/Interleaver.h"

namespace Tapir {
    
    MatrixInterleaver::MatrixInterleaver(const int nRows, const int nCols)
    : m_nRows(nRows), m_nCols(nCols)
    {};
    
    void MatrixInterleaver::interleave(const float *src, float *dest) const
    {
        TapirDSP::mtrans(src, dest, m_nCols, m_nRows);
    };
    void MatrixInterleaver::deinterleave(const float *src, float *dest) const
    {
        TapirDSP::mtrans(src, dest, m_nRows, m_nCols);
    };
    
    void MatrixInterleaver::interleave(const TapirDSP::SplitComplex * src, const TapirDSP::SplitComplex * dest) const
    {
        TapirDSP::mtrans(src->realp, dest->realp, m_nCols, m_nRows);
        TapirDSP::mtrans(src->imagp, dest->imagp, m_nCols, m_nRows);
    }
    void MatrixInterleaver::deinterleave(const TapirDSP::SplitComplex * src, const TapirDSP::SplitComplex * dest) const
    {
        TapirDSP::mtrans(src->realp, dest->realp, m_nRows, m_nCols);
        TapirDSP::mtrans(src->imagp, dest->imagp, m_nRows, m_nCols);
    }
    
}
