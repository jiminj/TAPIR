//
//  TapirDSP.cpp
//  TapirLib
//
//  Created by Jimin Jeon on 2/13/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#include "../include/TapirDSP.h"

namespace TapirDSP {

    void init() {
    #ifdef ARM_ANDROID
    	 ne10_init();
    #endif
    };

    //new
    void vadd(const float *src1, const float *src2, float *dest, VecLength length)
    {
    #ifdef ARM_ANDROID
        ne10_add_float(dest, const_cast<float *>(src1), const_cast<float *>(src2), length);
    #else
        ::vDSP_vadd(src1, 1, src2, 1,dest, 1, length);
    #endif
    };

    void vmul(const float *src1, const float *src2, float *dest, VecLength length)
    {
    #ifdef ARM_ANDROID
        ne10_mul_float(dest, const_cast<float *>(src1), const_cast<float *>(src2), length);
    #else
        ::vDSP_vmul(src1, 1, src2, 1, dest, 1, length);
    #endif
    };

    void vsadd(const float * src, const float * scalSrc, float * dest, VecLength length)
    {
    #ifdef ARM_ANDROID
        ne10_addc_float(dest, const_cast<float *>(src), *scalSrc, length);
    #else
        ::vDSP_vsadd(src, 1, scalSrc, dest, 1, length);
    #endif
    };

    void vsmul(const float * src, const float * scalSrc, float * dest, VecLength length)
    {
    #ifdef ARM_ANDROID
        ne10_mulc_float(dest, const_cast<float *>(src), *scalSrc, length);
    #else
        ::vDSP_vsmul(src, 1, scalSrc, dest, 1, length);
    #endif
    };

    void vsdiv(const float * src, const float * scalSrc, float * dest, VecLength length)
    {
    #ifdef ARM_ANDROID
        ne10_divc_float(dest, const_cast<float *>(src), *scalSrc, length);
    #else
        ::vDSP_vsdiv(src, 1, scalSrc, dest, 1, length);
    #endif
    };
    void vsmsa(const float * src, const float * scalSrcMul, const float *scalSrcAdd, float * dest, VecLength length)
    {
    //FIX LATER
    #ifdef ARM_ANDROID
        vsmul(src, scalSrcMul, dest, length);
        vsadd(dest, scalSrcAdd, dest, length);
    #else
        ::vDSP_vsmsa(src, 1, scalSrcMul, scalSrcAdd, dest, 1, length);
    #endif
    };

    void vfix16(const float * src, short * dest, VecLength length)
    {
    #ifdef ARM_ANDROID
        #if __ARM_NEON__
            float32x4_t src_f32x4;
            int32x4_t   src_s32x4;
            int16x4_t   src_s16x4_0, src_s16x4_1;
            int16x8_t   result_s16x8;

            int remainedLength = length % 8;
            length -= remainedLength;
            if(length > 0)
            {
                for(; length != 0; length -= 8 )
                {
                    src_f32x4 = vld1q_f32(src);
                    src_s32x4 = vcvtq_s32_f32(src_f32x4);
                    src_s16x4_0 = vqmovn_s32(src_s32x4);
                    src += 4;

                    src_f32x4 = vld1q_f32(src);
                    src_s32x4 = vcvtq_s32_f32(src_f32x4);
                    src_s16x4_1 = vqmovn_s32(src_s32x4);

                    result_s16x8 = vcombine_s16(src_s16x4_0, src_s16x4_1);
                    vst1q_s16(dest, result_s16x8);
                    dest += 8;
                    src += 4;
                }
            }
            if(remainedLength != 0)
            {
                if(remainedLength > 4)
                {
                    src_f32x4 = vld1q_f32(src);
                    src_s32x4 = vcvtq_s32_f32(src_f32x4);
                    src_s16x4_0 = vqmovn_s32(src_s32x4);
                    vst1_s16(dest, src_s16x4_0);
                    remainedLength -= 4;
                    src += 4;
                    dest += 4;
                }
                for(; remainedLength != 0; --remainedLength)
                { *(dest++) = static_cast<short>(*(src++)); }
            }
        #else
            for(int i=0; i<length; ++i)
            { dest[i] = static_cast<short>(src[i]); }
        #endif
    #else
        ::vDSP_vfix16(src, 1, dest, 1, length);
    #endif
    };
    void vfix32(const float * src, int * dest, VecLength length)
    {
    #ifdef ARM_ANDROID
        #if __ARM_NEON__
            float32x4_t src_f32x4;
            int32x4_t   result_s32x4;

            int remainedLength = length % 4;
            length -= remainedLength;
            if(length > 0)
            {
                for(; length != 0; length -= 4 )
                {
                    src_f32x4 = vld1q_f32(src);
                    result_s32x4 = vcvtq_s32_f32(src_f32x4);
                    vst1q_s32(dest, result_s32x4);
                    src += 4;
                    dest += 4;
                }
            }
            if(remainedLength != 0)
            {
                for(; remainedLength != 0; --remainedLength)
                { *(dest++) = static_cast<int>(*(src++)); }
            }
        #else
            for(int i=0; i<length; ++i)
            { dest[i] = static_cast<int>(src[i]); }
        #endif
    #else
        ::vDSP_vfix32(src, 1, dest, 1, length);
    #endif
    };
    void vflt16(const short * src, float * dest, VecLength length)
    {
    #ifdef ARM_ANDROID
        #if __ARM_NEON__
            int16x8_t   src_s16x8;
            int16x4_t   src_s16x4_0, src_s16x4_1;
            int32x4_t   src_s32x4;
            float32x4_t result_f32x4;

            int remainedLength = length % 8;
            length -= remainedLength;
            if(length > 0)
            {
                for(; length != 0; length -= 8 )
                {
                    src_s16x8 = vld1q_s16(src);
                    src_s16x4_0 = vget_low_s16(src_s16x8);
                    src_s16x4_1 = vget_high_s16(src_s16x8);
                    
                    src_s32x4 = vmovl_s16(src_s16x4_0);
                    result_f32x4 = vcvtq_f32_s32(src_s32x4);
                    vst1q_f32(dest, result_f32x4);
                    src += 4;
                    dest += 4;

                    src_s32x4 = vmovl_s16(src_s16x4_1);
                    result_f32x4 = vcvtq_f32_s32(src_s32x4);
                    vst1q_f32(dest, result_f32x4);
                    src += 4;
                    dest += 4;

                }
            }
            if(remainedLength != 0)
            {
                if(remainedLength > 4)
                {
                    src_s16x4_0 = vld1_s16(src);
                    src_s32x4 = vmovl_s16(src_s16x4_0);
                    result_f32x4 = vcvtq_f32_s32(src_s32x4);
                    vst1q_f32(dest, result_f32x4);
                    remainedLength -= 4;
                    src += 4;
                    dest += 4;
                }
                for(; remainedLength != 0; --remainedLength)
                { *(dest++) = static_cast<float>(*(src++)); }
            }

        #else
            for(int i=0; i<length; ++i)
            { dest[i] = static_cast<float>(src[i]); }
        #endif
    #else
        ::vDSP_vflt16(src, 1, dest, 1, length);
    #endif

    };
    void vflt32(const int * src, float * dest, VecLength length)
    {
    #ifdef ARM_ANDROID
        #if __ARM_NEON__
            int32x4_t   src_s32x4;
            float32x4_t result_f32x4;

            int remainedLength = length % 4;
            length -= remainedLength;
            if(length > 0)
            {
                for(; length != 0; length -= 4 )
                {
                    src_s32x4 = vld1q_s32(src);
                    result_f32x4 = vcvtq_f32_s32(src_s32x4);
                    vst1q_f32(dest, result_f32x4);
                    src += 4;
                    dest += 4;
                }
            }
            if(remainedLength != 0)
            {
                for(; remainedLength != 0; --remainedLength)
                { *(dest++) = static_cast<float>(*(src++)); }
            }

        #else
            for(int i=0; i<length; ++i)
            { dest[i] = static_cast<float>(src[i]); }
        #endif
    #else
        ::vDSP_vflt32(src, 1, dest, 1, length);
    #endif
    };

    //reverse
    void vrvrs(float * src, VecLength length)
    {
    #ifdef ARM_ANDROID
    #else
        ::vDSP_vrvrs(src, 1, length);
    #endif
    };

    void vfill(const float * src, float * dest, VecLength length)
    {
    #ifdef ARM_ANDROID
    #else
        ::vDSP_vfill(src, dest, 1, length);
    #endif
    };

    void vramp(const float * src1, const float * src2, float * dest, VecLength length)
    {

    };
    void vindex(const float * src1, const float * idx, float * dest, VecLength length)
    {
    };
    void vgenp(const float * src1, const float * src2, float * dest, VecLength destLength, VecLength srcLength)
    {
    };


    //old
    void vadd(const float *__vDSP_A, VecStride __vDSP_IA, const float *__vDSP_B, VecStride __vDSP_IB, float *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N)
    {
    #ifdef __APPLE__
        ::vDSP_vadd(__vDSP_A, __vDSP_IA, __vDSP_B, __vDSP_IB,__vDSP_C, __vDSP_IC, __vDSP_N);
    #endif
    };
    
    void vmul(const float *__vDSP_A, VecStride __vDSP_IA, const float *__vDSP_B, VecStride __vDSP_IB, float *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N)
    {
    #ifdef __APPLE__
        ::vDSP_vmul(__vDSP_A, __vDSP_IA, __vDSP_B, __vDSP_IB,__vDSP_C, __vDSP_IC, __vDSP_N);
    #endif
    };
   
    void vsadd(const float *__vDSP_A, VecStride __vDSP_IA, const float *__vDSP_B, float *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N)
    {
    #ifdef __APPLE__
        ::vDSP_vsadd(__vDSP_A, __vDSP_IA, __vDSP_B, __vDSP_C, __vDSP_IC, __vDSP_N);
    #endif
    }
    
    void vsmul(const float *__vDSP_A, VecStride __vDSP_IA, const float *__vDSP_B, float *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N)
    {
    #ifdef __APPLE__
        ::vDSP_vsmul(__vDSP_A, __vDSP_IA, __vDSP_B, __vDSP_C, __vDSP_IC,__vDSP_N);
    #endif
    
    };
    void vsdiv(const float *__vDSP_A, VecStride __vDSP_IA, const float *__vDSP_B, float *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N)
    {
    #ifdef __APPLE__
        ::vDSP_vsdiv(__vDSP_A, __vDSP_IA, __vDSP_B, __vDSP_C, __vDSP_IC, __vDSP_N);
    #endif
    };
    
    void vsmsa(const float *__vDSP_A, VecStride __vDSP_IA, const float *__vDSP_B, const float *__vDSP_C, float *__vDSP_D, VecStride __vDSP_ID, VecLength __vDSP_N)
    {
    #ifdef __APPLE__
        ::vDSP_vsmsa(__vDSP_A, __vDSP_IA, __vDSP_B,__vDSP_C, __vDSP_D, __vDSP_ID, __vDSP_N);
    #endif
    };
    
    void vfix16(const float *__vDSP_A, VecStride __vDSP_IA, short *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N)
    {
    #ifdef __APPLE__
        ::vDSP_vfix16(__vDSP_A, __vDSP_IA, __vDSP_C, __vDSP_IC,__vDSP_N);
    #endif
    };
    
    void vfix32(const float *__vDSP_A, VecStride __vDSP_IA, int *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N)
    {
    #ifdef __APPLE__
        ::vDSP_vfix32(__vDSP_A, __vDSP_IA, __vDSP_C, __vDSP_IC, __vDSP_N);
    #endif
    }
    
    void vflt16(const short *__vDSP_A, VecStride __vDSP_IA, float *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N)
    {
    #ifdef __APPLE__
        ::vDSP_vflt16(__vDSP_A, __vDSP_IA, __vDSP_C, __vDSP_IC, __vDSP_N);
    #endif
    };
    
    void vflt32(const int *__vDSP_A, VecStride __vDSP_IA, float *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N)
    {
    #ifdef __APPLE__
        ::vDSP_vflt32(__vDSP_A, __vDSP_IA, __vDSP_C, __vDSP_IC, __vDSP_N);
    #endif
    };
    
    
    void vrvrs(float *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N)
    {
    #ifdef __APPLE__
        ::vDSP_vrvrs(__vDSP_C, __vDSP_IC, __vDSP_N);
    #endif
    };

    void vfill(const float *__vDSP_A, float *__vDSP_C, VecStride __vDSP_IA, VecLength __vDSP_N)
    {
    #ifdef __APPLE__
        ::vDSP_vfill(__vDSP_A, __vDSP_C, __vDSP_IA, __vDSP_N);
    #endif
    };
    
    
    
    void vramp(const float *__vDSP_A, const float *__vDSP_B, float *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N)
    {
    #ifdef __APPLE__
        ::vDSP_vramp(__vDSP_A, __vDSP_B, __vDSP_C, __vDSP_IC, __vDSP_N);
    #endif
    }
    
    void vindex(const float *__vDSP_A, const float *__vDSP_B, VecStride __vDSP_IB, float *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N)
    {
    #ifdef __APPLE__
        ::vDSP_vindex(__vDSP_A, __vDSP_B, __vDSP_IB, __vDSP_C,__vDSP_IC, __vDSP_N);
    #endif
    }
    
    void vgenp(const float *__vDSP_A, VecStride __vDSP_IA, const float *__vDSP_B, VecStride __vDSP_IB, float *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N, VecLength __vDSP_M)
    {
    #ifdef __APPLE__
        ::vDSP_vgenp(__vDSP_A, __vDSP_IA, __vDSP_B, __vDSP_IB,__vDSP_C, __vDSP_IC, __vDSP_N, __vDSP_M);
    #endif
    }
    
    
    void maxmgv(const float *__vDSP_A, VecStride __vDSP_IA, float *__vDSP_C, VecLength __vDSP_N)
    {
    #ifdef __APPLE__
        ::vDSP_maxmgv(__vDSP_A, __vDSP_IA, __vDSP_C, __vDSP_N);
    #endif
    }
    
    void conv(const float *__vDSP_A, VecStride __vDSP_IA, const float *__vDSP_F, VecStride __vDSP_IF, float *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N, VecLength __vDSP_P)
    {
    #ifdef __APPLE__
        ::vDSP_conv(__vDSP_A, __vDSP_IA, __vDSP_F, __vDSP_IF, __vDSP_C, __vDSP_IC,  __vDSP_N, __vDSP_P);
    #endif
    };
    
    void dotpr(const float *__vDSP_A, VecStride __vDSP_IA, const float *__vDSP_B, VecStride __vDSP_IB, float *__vDSP_C, VecLength __vDSP_N)
    {
    #ifdef __APPLE__
        ::vDSP_dotpr(__vDSP_A, __vDSP_IA, __vDSP_B, __vDSP_IB, __vDSP_C, __vDSP_N);
    #endif
    };
    
    void svemg(const float *__vDSP_A, VecStride __vDSP_IA, float *__vDSP_C, VecLength __vDSP_N)
    {
    #ifdef __APPLE__
        ::vDSP_svemg(__vDSP_A, __vDSP_IA, __vDSP_C, __vDSP_N);
    #endif
    };
    
    void maxvi(const float *__vDSP_A, VecStride __vDSP_IA, float *__vDSP_C, VecLength *__vDSP_I, VecLength __vDSP_N)
    {
    #ifdef __APPLE__
        ::vDSP_maxvi(__vDSP_A, __vDSP_IA, __vDSP_C, __vDSP_I, __vDSP_N);
    #endif
    };
    
    
    void mtrans(const float *__vDSP_A, VecStride __vDSP_IA, float *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_M, VecLength __vDSP_N)
    {
    #ifdef __APPLE__
        ::vDSP_mtrans(__vDSP_A, __vDSP_IA, __vDSP_C, __vDSP_IC, __vDSP_M, __vDSP_N);
    #endif
    };
    
    
    void zvmov(const SplitComplex *__vDSP_A, VecStride __vDSP_IA, const SplitComplex *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N)
    {
    #ifdef __APPLE__
        ::vDSP_zvmov(__vDSP_A, __vDSP_IA, __vDSP_C, __vDSP_IC, __vDSP_N);
    #endif
    };
    
    void zvmul(const SplitComplex *__vDSP_A, VecStride __vDSP_IA, const SplitComplex *__vDSP_B, VecStride __vDSP_IB, const SplitComplex *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N, int __vDSP_Conjugate)
    {
    #ifdef __APPLE__
        ::vDSP_zvmul(__vDSP_A, __vDSP_IA, __vDSP_B, __vDSP_IB, __vDSP_C, __vDSP_IC,  __vDSP_N, __vDSP_Conjugate);
        
    #endif
    };
    
    void zvdiv(const SplitComplex *__vDSP_B, VecStride __vDSP_IB, const SplitComplex *__vDSP_A, VecStride __vDSP_IA, const SplitComplex *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N)
    {
    #ifdef __APPLE__
        ::vDSP_zvdiv(__vDSP_B, __vDSP_IB, __vDSP_A, __vDSP_IA, __vDSP_C, __vDSP_IC, __vDSP_N);
    #endif
    };
    
    void zrvmul(const SplitComplex *__vDSP_A, VecStride __vDSP_IA, const float *__vDSP_B, VecStride __vDSP_IB, const SplitComplex *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N)
    {
    #ifdef __APPLE__
        ::vDSP_zrvmul(__vDSP_A, __vDSP_IA, __vDSP_B, __vDSP_IB,__vDSP_C,  __vDSP_IC, __vDSP_N);
    #endif
    };
    
    
    void zvconj(const SplitComplex *__vDSP_A, VecStride __vDSP_IA, const SplitComplex *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N)
    {
    #ifdef __APPLE__
        ::vDSP_zvconj(__vDSP_A, __vDSP_IA, __vDSP_C, __vDSP_IC, __vDSP_N);
    #endif
    };
    void zvphas(const SplitComplex *__vDSP_A, VecStride __vDSP_IA, float *__vDSP_C, VecStride __vDSP_IC, VecLength __vDSP_N)
    {
    #ifdef __APPLE__
        ::vDSP_zvphas(__vDSP_A, __vDSP_IA, __vDSP_C, __vDSP_IC, __vDSP_N);
    #endif
    };
    
    
    
    void vsincosf(float * z, float * y, const float * x , const int * n)
    {
    #ifdef __APPLE__
        ::vvsincosf(z,y,x,n);
    #endif
    }
    
    
    
};
