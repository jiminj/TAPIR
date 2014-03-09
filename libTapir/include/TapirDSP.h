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
#include <iostream>

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
    
    typedef unsigned long VecLength;
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

    float vsinf(float x);
    float vcosf(float x);
    float vatan2f(float y, float x);

    void vadd_cpp(const float *src1, const float *src2, float *dest, VecLength length);
    void vmul_cpp(const float *src1, const float *src2, float *dest, VecLength length);
    //scalar operation
    void vsadd_cpp(const float * src, const float * scalSrc, float * dest, VecLength length);
    void vsmul_cpp(const float * src, const float * scalSrc, float * dest, VecLength length);
    void vsdiv_cpp(const float * src, const float * scalSrc, float * dest, VecLength length);
    void vsmsa_cpp(const float * src, const float * scalSrcMul, const float *scalSrcAdd, float * dest, VecLength length); //multiply and add

    void vfix16_cpp(const float * src, short * dest, VecLength length);
    void vfix32_cpp(const float * src, int * dest, VecLength length);
    void vflt16_cpp(const short * src, float * dest, VecLength length);
    void vflt32_cpp(const int * src, float* dest, VecLength length);

    void vrvrs_cpp(float * src, VecLength length); //reverse
    void vfill_cpp(const float * src, float * dest, VecLength length); //fill
    void vramp_cpp(const float * scalInit, const float * scalInc, float * dest, VecLength length);

    void vindex_cpp(const float * src, const float * idx, float * dest, VecLength length);
    void mtrans_cpp(const float * src, float * dest, VecLength lengthM, VecLength lengthN);
    void vgenp_cpp(const float * src, const float * idx, float * dest, VecLength destLength, VecLength srcLength);

    void vvsincosf_cpp(float * z, float * y, const float * x, VecLength length);
    void vvatan2f_cpp(float * z, const float * y, const float * x, VecLength length);
    
    void maxv_cpp(const float * src, float * dest, VecLength length);
    void maxmgv_cpp(const float * src, float * dest, VecLength length);
    void maxvi_cpp(const float * src, float * maxVal, VecLength * maxIdx, VecLength length);
    void svemg_cpp(const float * src, float * dest, VecLength length);

    void zvconj_cpp(const SplitComplex * src, const SplitComplex * dest, VecLength length);
    void zvmov_cpp(const SplitComplex * src, const SplitComplex * dest, VecLength length);
    void zvmul_cpp(const SplitComplex * src1, const SplitComplex * src2, const SplitComplex * dest, VecLength length, int conjFlag);
    void zvdiv_cpp(const SplitComplex * srcDen, const SplitComplex * srcNum, const SplitComplex * dest, VecLength length);
    inline void zvphas_cpp(const SplitComplex * src, float * dest, VecLength length)
    { vvatan2f_cpp(dest, src->imagp, src->realp, length); }

    //neon implementation
    void vadd_neon(const float *src1, const float *src2, float *dest, VecLength length);
    void vmul_neon(const float *src1, const float *src2, float *dest, VecLength length);

    void vsadd_neon(const float * src, const float * scalSrc, float * dest, VecLength length);
    void vsmul_neon(const float * src, const float * scalSrc, float * dest, VecLength length);
    void vsdiv_neon(const float * src, const float * scalSrc, float * dest, VecLength length);
    void vsmsa_neon(const float * src, const float * scalSrcMul, const float *scalSrcAdd, float * dest, VecLength length); //multiply and add

    void vfix16_neon(const float * src, short * dest, VecLength length);
    void vfix32_neon(const float * src, int * dest, VecLength length);
    void vflt16_neon(const short * src, float * dest, VecLength length);
    void vflt32_neon(const int * src, float* dest, VecLength length);

    void vrvrs_neon(float * src, VecLength length); //reverse
    void vfill_neon(const float * src, float * dest, VecLength length); //fill
    void vramp_neon(const float * scalInit, const float * scalInc, float * dest, VecLength length);

    
    //skipped; limitedly used for small numbers (no big performance enhancement)
    inline void vindex_neon(const float * src, const float * idx, float * dest, VecLength length)
    { vindex_cpp(src, idx, dest, length); }
    inline void mtrans_neon(const float * src, float * dest, VecLength lengthM, VecLength lengthN)
    { mtrans_cpp(src, dest, lengthM, lengthN); }
    inline void vgenp_neon(const float * src, const float * idx, float * dest, VecLength destLength, VecLength srcLength)
    { vgenp_cpp(src, idx, dest, destLength, srcLength); } //cpp version is faster
    
    void vvsincosf_neon(float * z, float * y, const float * x, VecLength length);
    void vvatan2f_neon(float * z, const float * y, const float * x, VecLength length);

    void maxv_neon(const float * src, float * dest, VecLength length);
    void maxmgv_neon(const float * src, float * dest, VecLength length);
    inline void maxvi_neon(const float * src, float * maxVal, VecLength * maxIdx, VecLength length)
    { maxvi_cpp(src, maxVal, maxIdx, length); }
    void svemg_neon(const float * src, float * dest, VecLength length);

    void zvconj_neon(const SplitComplex * src, const SplitComplex * dest, VecLength length);
    inline void zvmov_neon(const SplitComplex * src, const SplitComplex * dest, VecLength length)
    { zvmov_cpp(src, dest, length);}; // cpp version is faster
    void zvmul_neon(const SplitComplex * src1, const SplitComplex * src2, const SplitComplex * dest, VecLength length, int conjFlag);
    void zvdiv_neon(const SplitComplex * srcDen, const SplitComplex * srcNum, const SplitComplex * dest, VecLength length);
    inline void zvphas_neon(const SplitComplex * src, float * dest, VecLength length)
    { vvatan2f_neon(dest, src->imagp, src->realp, length); }

    //skipped ****
    void conv(const float * src1, const float * src2, float * dest, VecLength lengthSrc1, VecLength lengthSrc2); //convolution
    void corr(const float * src1, const float * src2, float * dest, VecLength lengthSrc1, VecLength lengthSrc2); //correlation
    void dotpr(const float * src1, const float * src2, float * dest, VecLength length);
    //***** skipped
 
    inline void vadd(const float *src1, const float *src2, float *dest, VecLength length)
    {
    #ifdef ARM_ANDROID
        #ifdef __ARM_NEON__
            vadd_neon(src1, src2, dest, length);
        #else
            vadd_cpp(src1, src2, dest, length);
        #endif
    #else
        ::vDSP_vadd(src1, 1, src2, 1,dest, 1, length);
    #endif
    };
    
    inline void vmul(const float *src1, const float *src2, float *dest, VecLength length)
    {
    #ifdef ARM_ANDROID
        #ifdef __ARM_NEON__
            vmul_neon(src1, src2, dest, length);
        #else
            vmul_cpp(src1, src2, dest, length);
        #endif
    #else
        ::vDSP_vmul(src1, 1, src2, 1,dest, 1, length);
    #endif
    };
    
    inline void vsadd(const float * src, const float * scalSrc, float * dest, VecLength length)
    {
    #ifdef ARM_ANDROID
        #ifdef __ARM_NEON__
            vsadd_neon(src, scalSrc, dest, length);
        #else
            vsadd_cpp(src, scalSrc, dest, length);
        #endif
    #else
        ::vDSP_vsadd(src, 1, scalSrc, dest, 1, length);
    #endif

    };
    inline void vsmul(const float * src, const float * scalSrc, float * dest, VecLength length)
    {
    #ifdef ARM_ANDROID
        #ifdef __ARM_NEON__
            vsmul_neon(src, scalSrc, dest, length);
        #else
            vsmul_cpp(src, scalSrc, dest, length);
        #endif
    #else
        ::vDSP_vsmul(src, 1, scalSrc, dest, 1, length);
    #endif

    };
    inline void vsdiv(const float * src, const float * scalSrc, float * dest, VecLength length)
    {
    #ifdef ARM_ANDROID
        #ifdef __ARM_NEON__
            vsdiv_neon(src, scalSrc, dest, length);
        #else
            vsdiv_cpp(src, scalSrc, dest, length);
        #endif
    #else
        ::vDSP_vsdiv(src, 1, scalSrc, dest, 1, length);
    #endif

    };
    inline void vsmsa(const float * src, const float * scalSrcMul, const float *scalSrcAdd, float * dest, VecLength length) //multiply and add
    {
    #ifdef ARM_ANDROID
        #ifdef __ARM_NEON__
            vsmsa_neon(src, scalSrcMul, scalSrcAdd, dest, length);
        #else
            vsmsa_cpp(src, scalSrcMul, scalSrcAdd, dest, length);
        #endif
    #else
        ::vDSP_vsmsa(src, 1, scalSrcMul, scalSrcAdd, dest, 1, length);
    #endif

    };
    
   
    //conversion
    inline void vfix16(const float * src, short * dest, VecLength length)
    {
    #ifdef ARM_ANDROID
        #ifdef __ARM_NEON__
            vfix16_neon(src, dest, length);
        #else
            vfix16_cpp(src, dest, length);
        #endif
    #else
        ::vDSP_vfix16(src, 1, dest, 1, length);
    #endif
    };
    inline void vfix32(const float * src, int * dest, VecLength length)
    {
    #ifdef ARM_ANDROID
        #ifdef __ARM_NEON__
            vfix32_neon(src, dest, length);
        #else
            vfix32_cpp(src, dest, length);
        #endif
    #else
        ::vDSP_vfix32(src, 1, dest, 1, length);
    #endif
    };
    inline void vflt16(const short * src, float * dest, VecLength length)
    {
    #ifdef ARM_ANDROID
        #ifdef __ARM_NEON__
            vflt16_neon(src, dest, length);
        #else
            vflt16_cpp(src, dest, length);
        #endif
    #else
        ::vDSP_vflt16(src, 1, dest, 1, length);

    #endif
    };
    inline void vflt32(const int * src, float* dest, VecLength length)
    {
    #ifdef ARM_ANDROID
        #ifdef __ARM_NEON__
            vflt32_neon(src, dest, length);
        #else
            vflt32_cpp(src, dest, length);
        #endif
    #else
        ::vDSP_vflt32(src, 1, dest, 1, length);
    #endif
    };
 
    inline void vrvrs(float * src, VecLength length) //reverse
    {
    #ifdef ARM_ANDROID
        #ifdef __ARM_NEON__
            vrvrs_neon(src, length);
        #else
            vrvrs_cpp(src, length);
        #endif
    #else
        ::vDSP_vrvrs(src, 1, length);
    #endif
    }
    inline void vfill(const float * src, float * dest, VecLength length) //fill
    {
    #ifdef ARM_ANDROID
        #ifdef __ARM_NEON__
            vfill_neon(src, dest, length);
        #else
            vfill_cpp(src, dest, length);
        #endif
    #else
        ::vDSP_vfill(src, dest, 1, length);
    #endif
    }
    inline void vramp(const float * scalInit, const float * scalInc, float * dest, VecLength length)
    {
    #ifdef ARM_ANDROID
        #ifdef __ARM_NEON__
            vramp_neon(scalInit, scalInc, dest, length);
        #else
            vramp_cpp(scalInit, scalInc, dest, length);
        #endif
    #else
        ::vDSP_vramp(scalInit, scalInc, dest, 1, length);
    #endif
    };
    
    inline void vindex(const float * src, const float * idx, float * dest, VecLength length)
    {
    #ifdef ARM_ANDROID
        vindex_cpp(src, idx, dest, length);
    #else
        ::vDSP_vindex(src, idx, 1, dest, 1, length);
    #endif
        
    };
    
    inline void vgenp(const float * src, const float * idx, float * dest, VecLength destLength, VecLength srcLength)
    {
    #ifdef ARM_ANDROID
        vgenp_cpp(src, idx, dest, destLength, srcLength);
    #else
        ::vDSP_vgenp(src, 1, idx, 1, dest, 1, destLength, srcLength);
    #endif
    };
    
    inline void mtrans(const float * src, float * dest, VecLength lengthM, VecLength lengthN)
    {
    #ifdef ARM_ANDROID
        #ifdef __ARM_NEON__
            mtrans_neon(src, dest, lengthM, lengthN);
        #else
            mtrans_cpp(src, dest, lengthM, lengthN);
        #endif
    #else
        ::vDSP_mtrans(src, 1, dest, 1, lengthM, lengthN);
    #endif
    };
    
    inline void vvsincosf(float * z, float * y, const float * x , VecLength length)
    {
    #ifdef ARM_ANDROID
        #ifdef __ARM_NEON__
            vvsincosf_neon(z,y,x,length);
        #else
            vvsincosf_cpp(z,y,x,length);
        #endif
    #else
        int intLen = static_cast<int>(length);
        ::vvsincosf(z, y, x, &intLen);
    #endif
    };
    inline void vvatan2f(float * z, const float * y, const float * x, VecLength length)
    {
    #ifdef ARM_ANDROID
        #ifdef __ARM_NEON__
            vvtan2f_neon(z,y,x, length);
        #else
            vvtan2f_cpp(z,y,x,n, length);
        #endif
    #else
        int n = static_cast<int>(length);
        ::vvatan2f(z, y, x, &n);
    #endif
    };
    
    inline void maxv(const float * src, float * dest, VecLength length)
    {
    #ifdef ARM_ANDROID
        #ifdef __ARM_NEON__
            maxv_neon(src,dest,length);
        #else
            maxv_cpp(src,dest,length);
        #endif
    #else
        ::vDSP_maxv(src, 1, dest, length);
    #endif
    };
    inline void maxmgv(const float * src, float * dest, VecLength length)
    {
    #ifdef ARM_ANDROID
        #ifdef __ARM_NEON__
            maxmgv_neon(src,dest,length);
        #else
            maxmgv_cpp(src,dest,length);
        #endif
    #else
        ::vDSP_maxmgv(src, 1, dest, length);
    #endif
    };
    inline void svemg(const float * src, float * dest, VecLength length)
    {
    #ifdef ARM_ANDROID
        #ifdef __ARM_NEON__
            svemg_neon(src,dest,length);
        #else
            svemg_cpp(src,dest,length);
        #endif
    #else
        ::vDSP_svemg(src, 1, dest, length);
    #endif
    };
    inline void maxvi(const float * src, float * maxVal, VecLength * maxIdx, VecLength length)
    {
    #ifdef ARM_ANDROID
        maxvi_cpp(src, maxVal, maxIdx, length);
    #else
        ::vDSP_maxvi(src, 1, maxVal, maxIdx, length);
    #endif
    };
    
    inline void zvmov(const SplitComplex * src, const SplitComplex * dest, VecLength length)
    {
    #ifdef ARM_ANDROID
        zvmov_cpp(src,dest,length);
    #else
        ::vDSP_zvmov(src, 1, dest, 1, length);
    #endif
    };
    inline void zvmul(const SplitComplex * src1, const SplitComplex * src2, const SplitComplex * dest, VecLength length, int conjFlag)
    {
    #ifdef ARM_ANDROID
        #ifdef __ARM_NEON__
            zvmul_neon(src1,src2,dest,length, conjFlag);
        #else
            zvmul_cpp(src1,src2,dest,length, conjFlag);
        #endif
    #else
        ::vDSP_zvmul(src1, 1, src2, 1, dest, 1, length, conjFlag);
    #endif
    };
    inline void zvconj(const SplitComplex * src, const SplitComplex * dest, VecLength length)
    {
    #ifdef ARM_ANDROID
        #ifdef __ARM_NEON__
            zvconj_neon(src, dest, length);
        #else
            zvconj_cpp(src, dest, length);
        #endif
    #else
        ::vDSP_zvconj(src, 1, dest, 1, length);
    #endif
    };
    inline void zvdiv(const SplitComplex * srcDen, const SplitComplex * srcNum, const SplitComplex * dest, VecLength length)
    {
    #ifdef ARM_ANDROID
        #ifdef __ARM_NEON__
            zvdiv_neon(srcDen, srcNum, dest, length);
        #else
            zvdiv_cpp(srcDen, srcNum, dest, length);
        #endif
    #else
        ::vDSP_zvdiv(srcDen, 1, srcNum, 1, dest, 1, length);
    #endif
    }
    inline void zrvmul(const SplitComplex * srcCom, const float * srcReal, const SplitComplex * dest, VecLength length)
    {
    #ifdef ARM_ANDROID
        vmul(srcCom->realp, srcReal, dest->realp, length);
        vmul(srcCom->imagp, srcReal, dest->imagp, length);
    #else
        ::vDSP_zrvmul(srcCom, 1, srcReal, 1, dest, 1, length);
    #endif
    };

    inline void zvphas(const SplitComplex * src, float * dest, VecLength length)
    {
    #ifdef ARM_ANDROID
        vvatan2f(dest, src->imagp, src->realp, length);
    #else
        ::vDSP_zvphas(src, 1, dest, 1, length);
    #endif

    };

    
    /***************************************/

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

    void vrvrs(float *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N); //reverse => vDSP Filter Only
    void vfill(const float *__vDSP_A, float *__vDSP_C, VecStride __vDSP_IA, VecLength __vDSP_N); //fill

    void vramp(const float *__vDSP_A, const float *__vDSP_B, float *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N);
    void vindex(const float *__vDSP_A, const float *__vDSP_B, VecStride __vDSP_IB, float *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N);
    void vgenp(const float *__vDSP_A, VecStride __vDSP_IA, const float *__vDSP_B, VecStride __vDSP_IB, float *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N, VecLength __vDSP_M);
    

    void maxmgv(const float *__vDSP_A, VecStride __vDSP_IA, float *__vDSP_C, VecLength __vDSP_N);
    void svemg(const float *__vDSP_A, VecStride __vDSP_IA, float *__vDSP_C, VecLength __vDSP_N);
    void maxv (float *__vDSP_A, VecStride __vDSP_I, float *__vDSP_C, VecLength __vDSP_N);
    void maxvi(const float *__vDSP_A, VecStride __vDSP_IA, float *__vDSP_C, VecLength *__vDSP_I, VecLength __vDSP_N);
    void mtrans(const float *__vDSP_A, VecStride __vDSP_IA, float *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_M, VecLength __vDSP_N);

    void conv(const float *__vDSP_A, VecStride __vDSP_IA, const float *__vDSP_F, VecStride __vDSP_IF, float *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N, VecLength __vDSP_P); //convolution
    void dotpr(const float *__vDSP_A, VecStride __vDSP_IA, const float *__vDSP_B, VecStride __vDSP_IB, float *__vDSP_C, VecLength __vDSP_N);
    
    void zvmov(const SplitComplex *__vDSP_A, VecStride __vDSP_IA, const SplitComplex *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N);
    
    void zvmul(const SplitComplex *__vDSP_A, VecStride __vDSP_IA, const SplitComplex *__vDSP_B, VecStride __vDSP_IB, const SplitComplex *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N, int __vDSP_Conjugate);
    
    void zvdiv(const SplitComplex *__vDSP_B, VecStride __vDSP_IB, const SplitComplex *__vDSP_A, VecStride __vDSP_IA, const SplitComplex *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N);
    
    void zrvmul(const SplitComplex *__vDSP_A, VecStride __vDSP_IA, const float *__vDSP_B, VecStride __vDSP_IB, const SplitComplex *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N);
    
    void zvconj(const SplitComplex *__vDSP_A, VecStride __vDSP_IA, const SplitComplex *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N);
    
    void zvphas(const SplitComplex *__vDSP_A, VecStride __vDSP_IA, float *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N);
    
        
};




#endif /* defined(__TapirLib__TapirDSP__) */
