//
//  TapirDSP.h
//  TapirLib
//
//  Created by Jimin Jeon on 2/13/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#ifndef __TapirLib__TapirDSP__
#define __TapirLib__TapirDSP__

#ifdef __APPLE__
#include "TargetConditionals.h"
#include <Accelerate/Accelerate.h>
#endif

#if __ARM_NEON__
#include <arm_neon.h>
#endif


namespace TapirDSP {
    
//typedef
#ifdef __APPLE__
    typedef DSPComplex Complex;
    typedef DSPDoubleComplex DoubleComplex;
    typedef DSPSplitComplex SplitComplex;
    typedef DSPDoubleSplitComplex DoubleSplitComplex;

#else
    typedef struct Complex {
        float  real; float  imag;
    } Complex;
    typedef struct DoubleComplex {
        double real; double imag;
    } DoubleComplex;

    typedef struct SplitComplex {
        float  *realp; float  *imagp;
    } SplitComplex;
    typedef struct DoubleSplitComplex {
        double *realp; double *imagp;
    } DoubleSplitComplex;
#endif
    typedef unsigned long VecLength;
    typedef long          VecStride;
    
    
//copy
    template< class InputIt, class OutputIt >
    OutputIt copy( InputIt first, InputIt last, OutputIt d_first )
    { return std::copy(first, last, d_first); };

    void vadd(const float *__vDSP_A, vDSP_Stride __vDSP_IA, const float *__vDSP_B, vDSP_Stride __vDSP_IB, float *__vDSP_C, vDSP_Stride __vDSP_IC, vDSP_Length __vDSP_N);
    void vmul(const float *__vDSP_A, vDSP_Stride __vDSP_IA, const float *__vDSP_B, vDSP_Stride __vDSP_IB, float *__vDSP_C, vDSP_Stride __vDSP_IC, vDSP_Length __vDSP_N);
    
    
    void vsadd(const float *__vDSP_A, vDSP_Stride __vDSP_IA, const float *__vDSP_B, float *__vDSP_C, vDSP_Stride __vDSP_IC, vDSP_Length __vDSP_N);
    void vsmul(const float *__vDSP_A, vDSP_Stride __vDSP_IA, const float *__vDSP_B, float *__vDSP_C, vDSP_Stride __vDSP_IC, vDSP_Length __vDSP_N); //mul. with scalar
    void vsdiv(const float *__vDSP_A, vDSP_Stride __vDSP_IA, const float *__vDSP_B, float *__vDSP_C, vDSP_Stride __vDSP_IC, vDSP_Length __vDSP_N); //div by scalar
    
    void vsmsa(const float *__vDSP_A, vDSP_Stride __vDSP_IA, const float *__vDSP_B, const float *__vDSP_C, float *__vDSP_D, vDSP_Stride __vDSP_ID, vDSP_Length __vDSP_N);
    
    void vfix16(const float *__vDSP_A, vDSP_Stride __vDSP_IA, short *__vDSP_C, vDSP_Stride __vDSP_IC, vDSP_Length __vDSP_N); //float -> short
    void vfix32(const float *__vDSP_A, vDSP_Stride __vDSP_IA, int *__vDSP_C, vDSP_Stride __vDSP_IC, vDSP_Length __vDSP_N); //float -> int
    void vflt16(const short *__vDSP_A, vDSP_Stride __vDSP_IA, float *__vDSP_C, vDSP_Stride __vDSP_IC, vDSP_Length __vDSP_N); //short -> float
    void vflt32(const int *__vDSP_A, vDSP_Stride __vDSP_IA, float *__vDSP_C, vDSP_Stride __vDSP_IC, vDSP_Length __vDSP_N); //int -> float

    void vfill(const float *__vDSP_A, float *__vDSP_C, vDSP_Stride __vDSP_IA, vDSP_Length __vDSP_N); //fill

    void vramp(const float *__vDSP_A, const float *__vDSP_B, float *__vDSP_C, vDSP_Stride __vDSP_IC, vDSP_Length __vDSP_N);
    
    void vrvrs(float *__vDSP_C, vDSP_Stride __vDSP_IC, vDSP_Length __vDSP_N);
    
    void vindex(const float *__vDSP_A, const float *__vDSP_B, vDSP_Stride __vDSP_IB, float *__vDSP_C, vDSP_Stride __vDSP_IC, vDSP_Length __vDSP_N);

    void vgenp(const float *__vDSP_A, vDSP_Stride __vDSP_IA, const float *__vDSP_B, vDSP_Stride __vDSP_IB, float *__vDSP_C, vDSP_Stride __vDSP_IC, vDSP_Length __vDSP_N, vDSP_Length __vDSP_M);
    
    void maxmgv(const float *__vDSP_A, vDSP_Stride __vDSP_IA, float *__vDSP_C, vDSP_Length __vDSP_N);
    
    void conv(const float *__vDSP_A, vDSP_Stride __vDSP_IA, const float *__vDSP_F, vDSP_Stride __vDSP_IF, float *__vDSP_C, vDSP_Stride __vDSP_IC, vDSP_Length __vDSP_N, vDSP_Length __vDSP_P); //convolution
    void dotpr(const float *__vDSP_A, vDSP_Stride __vDSP_IA, const float *__vDSP_B, vDSP_Stride __vDSP_IB, float *__vDSP_C, vDSP_Length __vDSP_N);
    
    void svemg(const float *__vDSP_A, vDSP_Stride __vDSP_IA, float *__vDSP_C, vDSP_Length __vDSP_N);
    
    void maxvi(const float *__vDSP_A, vDSP_Stride __vDSP_IA, float *__vDSP_C, vDSP_Length *__vDSP_I, vDSP_Length __vDSP_N);
    
    void mtrans(const float *__vDSP_A, vDSP_Stride __vDSP_IA, float *__vDSP_C, vDSP_Stride __vDSP_IC, vDSP_Length __vDSP_M, vDSP_Length __vDSP_N);
    
    void zvmov(const DSPSplitComplex *__vDSP_A, vDSP_Stride __vDSP_IA, const DSPSplitComplex *__vDSP_C, vDSP_Stride __vDSP_IC, vDSP_Length __vDSP_N);
    
    void zvmul(const DSPSplitComplex *__vDSP_A, vDSP_Stride __vDSP_IA, const DSPSplitComplex *__vDSP_B, vDSP_Stride __vDSP_IB, const DSPSplitComplex *__vDSP_C, vDSP_Stride __vDSP_IC, vDSP_Length __vDSP_N, int __vDSP_Conjugate);
    
    void zvdiv(const DSPSplitComplex *__vDSP_B, vDSP_Stride __vDSP_IB, const DSPSplitComplex *__vDSP_A, vDSP_Stride __vDSP_IA, const DSPSplitComplex *__vDSP_C, vDSP_Stride __vDSP_IC, vDSP_Length __vDSP_N);
    
    void zrvmul(const DSPSplitComplex *__vDSP_A, vDSP_Stride __vDSP_IA, const float *__vDSP_B, vDSP_Stride __vDSP_IB, const DSPSplitComplex *__vDSP_C, vDSP_Stride __vDSP_IC, vDSP_Length __vDSP_N);
    
    void zvconj(const DSPSplitComplex *__vDSP_A, vDSP_Stride __vDSP_IA, const DSPSplitComplex *__vDSP_C, vDSP_Stride __vDSP_IC, vDSP_Length __vDSP_N);
    
    void zvphas(const DSPSplitComplex *__vDSP_A, vDSP_Stride __vDSP_IA, float *__vDSP_C, vDSP_Stride __vDSP_IC, vDSP_Length __vDSP_N);
    
    
    
    void vsincosf (float * z, float * y, const float * x , const int * n);
    
};




#endif /* defined(__TapirLib__TapirDSP__) */
