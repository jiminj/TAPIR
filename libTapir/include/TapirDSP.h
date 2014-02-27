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
#elif defined(__arm__) && defined(__ANDROID__)
#define ARM_ANDROID 1
#include <NE10.h>
#endif
#if __ARM_NEON__
#include <arm_neon.h>
#endif

#include <algorithm>

namespace TapirDSP {
    
//typedef
#ifdef ARM_ANDROID
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
    
    typedef ne10_uint32_t VecLength;
    typedef long          VecStride;
    
#else
    //using vDSP
    typedef DSPComplex Complex;
    typedef DSPDoubleComplex DoubleComplex;
    typedef DSPSplitComplex SplitComplex;
    typedef DSPDoubleSplitComplex DoubleSplitComplex;
    typedef vDSP_Length VecLength;
    typedef vDSP_Stride VecStride;
#endif

    

//copy
    template< class InputIt, class OutputIt >
    OutputIt copy( InputIt first, InputIt last, OutputIt d_first )
    { return std::copy(first, last, d_first); };

    //new
    void init();
    
    //***** new ******
    void vadd(const float *src1, const float *src2, float *dest, VecLength length);
    void vmul(const float *src1, const float *src2, float *dest, VecLength length);
    //scalar operation
    void vsadd(const float * src, const float * scalSrc, float * dest, VecLength length);
    void vsmul(const float * src, const float * scalSrc, float * dest, VecLength length); 
    void vsdiv(const float * src, const float * scalSrc, float * dest, VecLength length); 
    void vsmsa(const float * src, const float * scalSrcMul, const float *scalSrcAdd, float * dest, VecLength length); //multiply and add  

    //conversion
    void vfix16(const float * src, short * dest, VecLength length);
    void vfix32(const float * src, int * dest, VecLength length);
    void vflt16(const short * src, float * dest, VecLength length);
    void vflt32(const int * src, float* dest, VecLength length);

    void vrvrs(float * src, VecLength length); //reverse
    void vfill(const float * src, float * dest, VecLength length); //fill
    void vramp(const float * src1, const float * src2, float * dest, VecLength length);
    void vindex(const float * src1, const float * idx, float * dest, VecLength length);
    void vgenp(const float * src1, const float * src2, float * dest, VecLength destLength, VecLength srcLength);

    //old
    void vadd(const float *__vDSP_A, VecStride __vDSP_IA, const float *__vDSP_B, VecStride __vDSP_IB, float *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N);
    void vmul(const float *__vDSP_A, VecStride __vDSP_IA, const float *__vDSP_B, VecStride __vDSP_IB, float *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N);

    void vsadd(const float *__vDSP_A, VecStride __vDSP_IA, const float *__vDSP_B, float *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N);
    void vsmul(const float *__vDSP_A, VecStride __vDSP_IA, const float *__vDSP_B, float *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N); //mul. with scalar
    void vsdiv(const float *__vDSP_A, VecStride __vDSP_IA, const float *__vDSP_B, float *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N); //div by scalar
    void vsmsa(const float *__vDSP_A, VecStride __vDSP_IA, const float *__vDSP_B, const float *__vDSP_C, float *__vDSP_D, VecStride __vDSP_ID, VecLength __vDSP_N);
    
    void vfix16(const float *__vDSP_A, VecStride __vDSP_IA, short *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N); //float -> short
    void vfix32(const float *__vDSP_A, VecStride __vDSP_IA, int *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N); //float -> int
    void vflt16(const short *__vDSP_A, VecStride __vDSP_IA, float *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N); //short -> float
    void vflt32(const int *__vDSP_A, VecStride __vDSP_IA, float *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N); //int -> float

    void vrvrs(float *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N); //reverse
    void vfill(const float *__vDSP_A, float *__vDSP_C, VecStride __vDSP_IA, VecLength __vDSP_N); //fill
    void vramp(const float *__vDSP_A, const float *__vDSP_B, float *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N);
    void vindex(const float *__vDSP_A, const float *__vDSP_B, VecStride __vDSP_IB, float *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N);

    void vgenp(const float *__vDSP_A, VecStride __vDSP_IA, const float *__vDSP_B, VecStride __vDSP_IB, float *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N, VecLength __vDSP_M);
    
    void maxmgv(const float *__vDSP_A, VecStride __vDSP_IA, float *__vDSP_C, VecLength __vDSP_N);
    
    void conv(const float *__vDSP_A, VecStride __vDSP_IA, const float *__vDSP_F, VecStride __vDSP_IF, float *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N, VecLength __vDSP_P); //convolution
    void dotpr(const float *__vDSP_A, VecStride __vDSP_IA, const float *__vDSP_B, VecStride __vDSP_IB, float *__vDSP_C, VecLength __vDSP_N);
    
    void svemg(const float *__vDSP_A, VecStride __vDSP_IA, float *__vDSP_C, VecLength __vDSP_N);
    
    void maxvi(const float *__vDSP_A, VecStride __vDSP_IA, float *__vDSP_C, VecLength *__vDSP_I, VecLength __vDSP_N);
    
    void mtrans(const float *__vDSP_A, VecStride __vDSP_IA, float *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_M, VecLength __vDSP_N);
    
    void zvmov(const SplitComplex *__vDSP_A, VecStride __vDSP_IA, const SplitComplex *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N);
    
    void zvmul(const SplitComplex *__vDSP_A, VecStride __vDSP_IA, const SplitComplex *__vDSP_B, VecStride __vDSP_IB, const SplitComplex *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N, int __vDSP_Conjugate);
    
    void zvdiv(const SplitComplex *__vDSP_B, VecStride __vDSP_IB, const SplitComplex *__vDSP_A, VecStride __vDSP_IA, const SplitComplex *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N);
    
    void zrvmul(const SplitComplex *__vDSP_A, VecStride __vDSP_IA, const float *__vDSP_B, VecStride __vDSP_IB, const SplitComplex *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N);
    
    void zvconj(const SplitComplex *__vDSP_A, VecStride __vDSP_IA, const SplitComplex *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N);
    
    void zvphas(const SplitComplex *__vDSP_A, VecStride __vDSP_IA, float *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N);
    
    
    
    void vsincosf (float * z, float * y, const float * x , const int * n);
    
};




#endif /* defined(__TapirLib__TapirDSP__) */
