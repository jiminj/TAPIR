//
//  Interleaver.cpp
//  TapirLib
//
//  Created by Jimin Jeon on 1/23/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#include "Interleaver.h"

namespace Tapir {
    
    MatrixInterleaver::MatrixInterleaver(const int nRows, const int nCols)
    : m_nRows(nRows), m_nCols(nCols)
    {};
    
    void MatrixInterleaver::interleave(const float *src, float *dest) const
    {
        vDSP_mtrans(src, 1, dest, 1, m_nCols, m_nRows);
    };
    void MatrixInterleaver::deinterleave(const float *src, float *dest) const
    {
        vDSP_mtrans(src, 1, dest, 1, m_nRows, m_nCols);
    };
    
    void MatrixInterleaver::interleave(const TapirDSP::SplitComplex * src, const TapirDSP::SplitComplex * dest) const
    {
        vDSP_mtrans(src->realp, 1, dest->realp, 1, m_nCols, m_nRows);
        vDSP_mtrans(src->imagp, 1, dest->imagp, 1, m_nCols, m_nRows);
    }
    void MatrixInterleaver::deinterleave(const TapirDSP::SplitComplex * src, const TapirDSP::SplitComplex * dest) const
    {
        vDSP_mtrans(src->realp, 1, dest->realp, 1, m_nRows, m_nCols);
        vDSP_mtrans(src->imagp, 1, dest->imagp, 1, m_nRows, m_nCols);
    }
    
}