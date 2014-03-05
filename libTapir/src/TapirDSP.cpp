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

            VecLength remainedLength = length % 8;
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
            for(VecLength i=0; i<length; ++i)
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

            VecLength remainedLength = length % 4;
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
            for(VecLength i=0; i<length; ++i)
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

            VecLength remainedLength = length % 8;
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
            for(VecLength i=0; i<length; ++i)
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

            VecLength remainedLength = length % 4;
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
            for(VecLength i=0; i<length; ++i)
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
        #ifdef __ARM_NEON__

            float * srcBackward;
            float32x2_t src_f32x2, srcBackward_f32x2;
            float32x2_t dest1_f32x2, dest2_f32x2, destBackward1_f32x2, destBackward2_f32x2;

            float32x4_t dest_f32x4, destBackward_f32x4;
            float32x4_t temp_f32x4;

            srcBackward = src + length - 4;
            VecLength remainedLength = length;

            if(length >= 8)
            {
                remainedLength = length % 8;
                length -= remainedLength;

                for(; length != 0; length -= 8) 
                {
                    src_f32x2 = vld1_f32(src);
                    srcBackward_f32x2 = vld1_f32(srcBackward + 2);
                    dest1_f32x2 = vrev64_f32(srcBackward_f32x2);
                    destBackward2_f32x2 = vrev64_f32(src_f32x2);

                    src_f32x2 = vld1_f32(src + 2);
                    srcBackward_f32x2 = vld1_f32(srcBackward);
                    dest2_f32x2 = vrev64_f32(srcBackward_f32x2);
                    destBackward1_f32x2 = vrev64_f32(src_f32x2);

                    dest_f32x4 = vcombine_f32(dest1_f32x2, dest2_f32x2);
                    destBackward_f32x4 = vcombine_f32(destBackward1_f32x2, destBackward2_f32x2);

                    vst1q_f32(src, dest_f32x4);
                    vst1q_f32(srcBackward, destBackward_f32x4);

                    src += 4;
                    srcBackward -= 4;
                }
            }
            if(remainedLength != 0)
            {
                float temp;
                srcBackward = src + remainedLength - 1;

                while(src < srcBackward)
                {
                    temp = *src;
                    *(src++) = *srcBackward;
                    *(srcBackward--) = temp;
                }
            }
        #else
            float temp;
            float * srcBackward = src + length - 1;
            while(src < srcBackward)
            {
                temp = *src;
                *(src++) = *srcBackward;
                *(srcBackward--) = temp;
            }
        #endif
    #else
        ::vDSP_vrvrs(src, 1, length);
    #endif
    };

    void vfill(const float * src, float * dest, VecLength length)
    {
    #ifdef ARM_ANDROID
        #ifdef __ARM_NEON__
            VecLength remainedLength = length % 4;
            length -= remainedLength;

            float32x4_t dest_f32x4;
            
            if(length > 0)
            {
                float32_t src_f32x1 = *(src);
                for(; length != 0; length -= 4)
                {
                    dest_f32x4 = vdupq_n_f32(src_f32x1);
                    vst1q_f32(dest, dest_f32x4);
                    dest += 4;
                }
            }
            if(remainedLength != 0)
            {
                for(; remainedLength != 0; --remainedLength)
                { *(dest++) = *src; }
            }
        #else
            for(VecLength i = 0; i < length; ++i)
            { *(dest++) = *src; }
        #endif
    #else
        ::vDSP_vfill(src, dest, 1, length);
    #endif
    };

    void vramp(const float * scalInit, const float * scalInc, float * dest, VecLength length)
    {
    #ifdef ARM_ANDROID
        #if __ARM_NEON__
            float * origDest = dest;
            VecLength remainedLength = length % 4;
            length -= remainedLength;

            float32x4_t inc_f32x4, incStep_f32x4;
            float32x4_t src_f32x4;
            float32x4_t dest_f32x4;
            if(length > 0)
            {
                src_f32x4 = vdupq_n_f32(*(scalInit));
                incStep_f32x4 = vdupq_n_f32(*(scalInc));
                inc_f32x4 = {0.f, 1.f, 2.f, 3.f};
                inc_f32x4 = vmulq_f32(inc_f32x4, incStep_f32x4);

                for(; length != 0; length -= 4)
                {
                    dest_f32x4 = vaddq_f32(src_f32x4, inc_f32x4);
                    inc_f32x4 = vaddq_f32(inc_f32x4, incStep_f32x4);
                    vst1q_f32(dest, dest_f32x4);
                    dest += 4;
                }
            }
            if(remainedLength != 0)
            {
                VecLength i = dest - origDest;
                for(; remainedLength != 0; --remainedLength)
                {
                    *(origDest+i) = (*scalInit) + (*scalInc) * i;
                    i++;
                }
            }
        #else
            for(VecLength i = 0; i< length; ++i)
            { dest[i] = (*scalInit) + (*scalInc) * i; }
        #endif
    #else
        ::vDSP_vramp(scalInit, scalInc, dest, 1, length);
    #endif

    };
    void vindex(const float * src, const float * idx, float * dest, VecLength length)
    {
    #ifdef ARM_ANDROID
    #else
        ::vDSP_vindex(src, idx, 1, dest, 1, length);
    #endif
    };

    void vgenp(const float * src1, const float * src2, float * dest, VecLength destLength, VecLength srcLength)
    {
    #ifdef ARM_ANDROID
    #else
        ::vDSP_vgenp(src1, 1, src2, 1, dest, 1, destLength, srcLength);
    #endif
    };


    void maxv_neon(const float * src, float * dest, VecLength length)
    {
        VecLength remainedLength = length % 4;
        length -= remainedLength;

        float32x4_t src_f32x4, max_f32x4;
        float32x2_t max_f32x2;

        if(length > 0)
        {
            max_f32x4 = vld1q_f32(src);
            for(; length != 0; length -= 4)
            {
                src_f32x4 = vld1q_f32(src);
                max_f32x4 = vmaxq_f32(src_f32x4, max_f32x4);
                src += 4;
            }
            max_f32x2 = vmax_f32(vget_low_f32(max_f32x4), vget_high_f32(max_f32x4));
            *dest = (max_f32x2[0] > max_f32x2[1]) ? max_f32x2[0] : max_f32x2[1];
        }
        if(remainedLength != 0)
        {
            for(; remainedLength != 0; --remainedLength)
            {
                if((*src) > (*dest))
                { *dest = *src; }
                ++src;
            }
        }
    };

    void maxv_cpp(const float * src, float * dest, VecLength length)
    {
        float * noConstSrc = const_cast<float *>(src);
        float * maxVal = noConstSrc;

        float * cur;
        for(VecLength i=1; i<length; ++i)
        {
            cur = noConstSrc + i;
            if( (*cur) > (*maxVal) )
            { maxVal = cur; }
        }
        *(dest) = *(maxVal);
    };

    void maxmgv_neon(const float * src, float * dest, VecLength length)
    {
        VecLength remainedLength = length % 4;
        length -= remainedLength;

        float32x4_t src_f32x4, max_f32x4;
        float32x2_t max_f32x2;

        if(length > 0)
        {
            max_f32x4 = vdupq_n_f32(0.f);
            for(; length != 0; length -= 4)
            {
                src_f32x4 = vabsq_f32(vld1q_f32(src));
                max_f32x4 = vmaxq_f32(src_f32x4, max_f32x4);
                src += 4;
            }
            max_f32x2 = vmax_f32(vget_low_f32(max_f32x4), vget_high_f32(max_f32x4));
            *dest = (max_f32x2[0] > max_f32x2[1]) ? max_f32x2[0] : max_f32x2[1];
        }
        if(remainedLength != 0)
        {
            float absSrc;
            for(; remainedLength != 0; --remainedLength)
            {
                absSrc = fabsf(*src);
                if(absSrc > (*dest))
                { *dest = absSrc; }
                ++src;
            }
        }
    };
    void maxmgv_cpp(const float * src, float * dest, VecLength length)
    {
        float * noConstSrc = const_cast<float *>(src);
        float maxVal = 0;

        float absCur;
        for(VecLength i=1; i<length; ++i)
        {
            absCur = fabsf( *(noConstSrc + i) );

            if( absCur > maxVal )
            { maxVal = absCur; }
        }
        *(dest) = maxVal;
    };
    
    void svemg_cpp(const float * src, float * dest, VecLength length)
    {
        (*dest) = 0;
        for(VecLength i = 0; i<length; ++i)
        {
            *dest += fabsf(*(src+i));
        }
    };

    
    void svemg_neon(const float * src, float * dest, VecLength length)
    {
        VecLength remainedLength = length % 4;
        length -= remainedLength;
        
        float32x4_t src_f32x4;
        float32x4_t sum_f32x4;
        float32x2_t sum_f32x2;
        
        if(length > 0)
        {
            sum_f32x4 = vdupq_n_f32(0.f);
            for(; length != 0; length -= 4)
            {
                src_f32x4 = vabsq_f32(vld1q_f32(src));
                sum_f32x4 = vaddq_f32(sum_f32x4, src_f32x4);
                src += 4;
            }
            sum_f32x2 = vadd_f32(vget_low_f32(sum_f32x4), vget_high_f32(sum_f32x4));
            *dest = sum_f32x2[0] + sum_f32x2[1];
        }
        if(remainedLength != 0)
        {
            for(; remainedLength != 0; --remainedLength)
            {
                *dest += fabsf(*src);
                ++src;
            }
        }

    };
    
    void maxvi_cpp(const float * src, float * maxVal, VecLength * maxIdx, VecLength length)
    {
        maxv(src, maxVal, length);
        *maxIdx = 0;
        for(int i=0; i<length; ++i)
        {
            if(*(maxVal) == *(src + i))
            {
                *maxIdx = i;
                break;
            }
        }
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
    void maxv (float *__vDSP_A, VecStride __vDSP_I, float *__vDSP_C, VecLength __vDSP_N)
    {
    #ifdef __APPLE__
        ::vDSP_maxv(__vDSP_A, __vDSP_I, __vDSP_C, __vDSP_N);
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
