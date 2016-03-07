//
//  TapirDSP.cpp
//  TapirLib
//
//  Created by Jimin Jeon on 2/13/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#include "../include/TapirDSP.h"

namespace TapirDSP {


    //new

    float vsinf(float x)
    {
        union {
            float   f;
            int     i;
        } ax;
        
        int m, n;
        ax.f = fabsf(x);
        
        //Range Reduction:
        m = (int) (ax.f * M_2_PI);
        ax.f = ax.f - (((float)m) * M_PI_2);
        
        //Test Quadrant
        n = m & 1;
        ax.f = ax.f - n * M_PI_2;
        n = n ^ (m >> 1);
        n = ( n ^ (x < 0.0) ) << 31;
        ax.i = ax.i ^ n;
        
        x = ax.f;
        
        //http://devmaster.net/posts/9648/fast-and-accurate-sine-cosine
        
        float result;
        if ( x < 0)
        { result = 1.27323954f * x + .405284735f * x * x; }
        else
        { result = 1.27323954f * x - .405284735f * x * x; }
        
        if (result < 0)
        { result = .225 * ( (-result) * result - result) + result; }
        else
        { result = .225 * (result * result - result) + result; }
        
        return result;
    };
    float vcosf(float x)
    {
        return vsinf(x + M_PI_2);
    };
    float vatan2f(float y, float x)
    {
        // refered to "Full Quadrant Approximations for the Arctangent Function - Xavier Girones, et al."
        // http://ieeexplore.ieee.org/xpl/articleDetails.jsp?arnumber=6375931
        
        static const uint32_t signMask = 0x80000000;
        static const float approxConst = 0.596227f;
        
        // Extract the sign bits
        uint32_t ux_s = signMask & (uint32_t &)x;
        uint32_t uy_s = signMask & (uint32_t &)y;
        
        // Determine the quadrant offset
        float q=(float)((~ux_s&uy_s)>>29|ux_s>>30);
        // Calculate the arctangent in the first quadrant
        float bxy_a = ::fabs(approxConst * x * y);
        float num = bxy_a + y * y;
        float atan_1q = num / (x * x + bxy_a + num);
        // Translate it to the proper quadrant
        uint32_t uatan_2q = (ux_s ^ uy_s) | (uint32_t &)atan_1q;
        float normResult = q + (float &)uatan_2q;
        
        float result = M_PI_2 * normResult;
        if(result > M_PI)
        { result -= M_PI; }
        if( (result > 0) && (y < 0) )
        { result -= M_PI; }
        return result;
        
    };
    
    void vadd_cpp(const float *src1, const float *src2, float *dest, VecLength length)
    {
        for(VecLength i=0; i<length; ++i)
        {
            (*dest++) = (*src1++) + (*src2++);
        }
    };
    void vmul_cpp(const float *src1, const float *src2, float *dest, VecLength length)
    {
        for(VecLength i=0; i<length; ++i)
        {
            (*dest++) = (*src1++) * (*src2++);
        }
    };
    
    void vsadd_cpp(const float * src, const float * scalSrc, float * dest, VecLength length)
    {
        for(VecLength i=0; i< length; ++i)
        {
            (*dest++) = (*src++) + (*scalSrc);
        }
    };
    void vsmul_cpp(const float * src, const float * scalSrc, float * dest, VecLength length)
    {
        for(VecLength i=0; i< length; ++i)
        {
            (*dest++) = (*src++) * (*scalSrc);
        }
    };
    void vsdiv_cpp(const float * src, const float * scalSrc, float * dest, VecLength length)
    {
        for(VecLength i=0; i< length; ++i)
        {
            (*dest++) = (*src++) / (*scalSrc);
        }
    };
    void vsmsa_cpp(const float * src, const float * scalSrcMul, const float *scalSrcAdd, float * dest, VecLength length)
    {
        for(VecLength i=0; i< length; ++i)
        {
            (*dest++) = (*src++) * (*scalSrcMul) + (*scalSrcAdd);
        }
    };
    
    void vfix16_cpp(const float * src, short * dest, VecLength length)
    {
        for(VecLength i=0; i<length; ++i)
        { dest[i] = static_cast<short>(src[i]); }
    };
    void vfix32_cpp(const float * src, int * dest, VecLength length)
    {
        for(VecLength i=0; i<length; ++i)
        { dest[i] = static_cast<int>(src[i]); }
    };
    void vflt16_cpp(const short * src, float * dest, VecLength length)
    {
        for(VecLength i=0; i<length; ++i)
        { dest[i] = static_cast<float>(src[i]); }
    };
    
    void vflt32_cpp(const int * src, float * dest, VecLength length)
    {
        for(VecLength i=0; i<length; ++i)
        { dest[i] = static_cast<float>(src[i]); }
    };

    
    
    void vrvrs_cpp(float * src, VecLength length)
    {
        float temp;
        float * srcBackward = src + length - 1;
        while(src < srcBackward)
        {
            temp = *src;
            *(src++) = *srcBackward;
            *(srcBackward--) = temp;
        }
    };
    void vfill_cpp(const float * src, float * dest, VecLength length)
    {
        for(VecLength i = 0; i < length; ++i)
        { *(dest++) = *src; }
    };
    void vramp_cpp(const float * scalInit, const float * scalInc, float * dest, VecLength length)
    {
        for(VecLength i = 0; i< length; ++i)
        { dest[i] = (*scalInit) + (*scalInc) * i; }
    };
    
    void vindex_cpp(const float * src, const float * idx, float * dest, VecLength length)
    {
        for(VecLength i=0; i<length; ++i)
        { dest[i] = src[static_cast<unsigned int>(idx[i])]; }
    };
    
    void mtrans_cpp(const float * src, float * dest, VecLength lengthM, VecLength lengthN)
    {
        VecLength idx = 0;
        VecLength totLength = lengthM * lengthN;
        for(VecLength i=0; i< lengthM; ++i)
        {
            for(VecLength j = i; j < totLength; j += lengthM)
            {
                dest[idx++] = src[j];
            }
        }
    };
    
    void vgenp_cpp(const float * src, const float * idx, float * dest, VecLength destLength, VecLength srcLength)
    {
        int firstIdx = static_cast<int>(idx[0]);
        for(int i=0; i < firstIdx; ++i)
        { dest[i] = src[0]; }
        
        int prevIdx = 0;
        float prevVal = src[0];
        
        for(VecLength i=0; i< srcLength; ++i)
        {
            int destIdx = static_cast<int>(idx[i]);
            float destVal = src[i];
            float incVal = (destVal - prevVal) / (destIdx - prevIdx);
            float nextVal = prevVal;
            
            for(int j = prevIdx; j < destIdx; ++j)
            {
                dest[j] = nextVal;
                nextVal += incVal;
            }
            prevVal = destVal;
            prevIdx = destIdx;
        }
        int lastIdx = static_cast<int>(idx[srcLength-1]);
        for(int i = lastIdx; i < destLength; ++i)
        { dest[i] = src[srcLength - 1]; }
    };
    
    
    void vvsincosf_cpp(float * z, float * y, const float * x, VecLength length)
    {
        for(VecLength i=0; i<length; ++i)
        {
            *(z++) = vsinf(*x);
            *(y++) = vcosf(*(x++));
        }
    };
    void vvatan2f_cpp(float * z, const float * y, const float * x, VecLength length)
    {
        for(VecLength i=0; i<length; ++i)
        {
            z[i] = vatan2f(y[i], x[i]);
        }
    };
    
    void maxv_cpp(const float * src, float * dest, VecLength length)
    {
        const float * maxVal = src;
        
        const float * cur;
        for(VecLength i=1; i<length; ++i)
        {
            cur = src + i;
            if( (*cur) > (*maxVal) )
            { maxVal = cur; }
        }
        *(dest) = *(maxVal);
    };
    void maxmgv_cpp(const float * src, float * dest, VecLength length)
    {
        float maxVal = 0;
        
        float absCur;
        for(VecLength i=1; i<length; ++i)
        {
            absCur = fabsf(*(src + i));
            if( absCur > maxVal )
            { maxVal = absCur; }
        }
        *(dest) = maxVal;
    };
    void maxvi_cpp(const float * src, float * maxVal, VecLength * maxIdx, VecLength length)
    {
        maxv(src, maxVal, length);
        *maxIdx = 0;
        for(VecLength i=0; i<length; ++i)
        {
            if(*(maxVal) == *(src + i))
            {
                *maxIdx = i;
                break;
            }
        }
    };
    void svemg_cpp(const float * src, float * dest, VecLength length)
    {
        (*dest) = 0;
        for(VecLength i = 0; i<length; ++i)
        {
            *dest += fabsf(*(src+i));
        }
    };
    
    void zvconj_cpp(const SplitComplex * src, const SplitComplex * dest, VecLength length)
    {
        zvmov(src, dest, length);
        float * destImag = dest->imagp;
        for(VecLength i=0; i<length; ++i)
        {
            (*destImag) = -(*destImag);
            ++destImag;
        }
        
    };
    void zvmov_cpp(const SplitComplex * src, const SplitComplex * dest, VecLength length)
    {
        copy(src->realp, src->realp + length, dest->realp);
        copy(src->imagp, src->imagp + length, dest->imagp);
    };
    void zvmul_cpp(const SplitComplex * src1, const SplitComplex * src2, const SplitComplex * dest, VecLength length, int conjFlag)
    {
        float * src1Real = src1->realp;
        float * src1Imag = src1->imagp;
        float * src2Real = src2->realp;
        float * src2Imag = src2->imagp;
        float * destReal = dest->realp;
        float * destImag = dest->imagp;
        
        for(VecLength i=0; i<length; ++i)
        {
            *(destReal++) = (*src1Real) * (*src2Real) - conjFlag * ( (*src1Imag) * (*src2Imag));
            *(destImag++) = (*(src1Real++)) * (*(src2Imag++)) + conjFlag * ( (*(src1Imag++)) * (*(src2Real++)));
        }
    };
    void zvdiv_cpp(const SplitComplex * srcDen, const SplitComplex  * srcNum, const SplitComplex * dest, VecLength length)
    {
        float * srcDenReal = srcDen->realp;
        float * srcDenImag = srcDen->imagp;
        float * srcNumReal = srcNum->realp;
        float * srcNumImag = srcNum->imagp;
        float * destReal = dest->realp;
        float * destImag = dest->imagp;
        float den;
        
        for(VecLength i=0; i<length; ++i)
        {
            den = (*srcDenReal) * (*srcDenReal) + (*srcDenImag) * (*srcDenImag);
            *(destReal++) = ((*srcNumReal) * (*srcDenReal) + (*srcNumImag) * (*srcDenImag)) / den;
            *(destImag++) = ((*srcNumImag++) * (*srcDenReal++) - (*srcNumReal++) * (*srcDenImag++)) / den;
        }
    };

    
    
    void dotpr_cpp(const float * src1, const float * src2, float * dest, VecLength length)
    {
        *dest = 0;
        for(VecLength i=0; i<length; ++i)
        {
            (*dest) += (*src1++) * (*src2++);
        }
    };
    void conv_cpp(const float * src, const float * filter, float * dest, VecLength lengthDest, VecLength lengthFilter)
    {
        std::fill(dest, dest + lengthDest, 0.f);
        
        for(VecLength i = 0; i < lengthDest; ++i)
        {
            for(VecLength j = 0; j < lengthFilter; ++j)
            {
                *(dest) += (*(src + j)) * (*(filter + lengthFilter - 1 - j));
            }
            src += 1; dest += 1;
        }
    };
    
    void corr_cpp(const float * src, const float * filter, float * dest, VecLength lengthDest, VecLength lengthFilter)
    {
        std::fill(dest, dest + lengthDest, 0.f);
        
        for(VecLength i = 0; i < lengthDest; ++i)
        {
            for(VecLength j = 0; j < lengthFilter; ++j)
            {
                *(dest) += (*(src + j)) * (*(filter + j));
            }
            ++src; ++dest;
        }
    };
    
    void ztoc_cpp(const SplitComplex * src, Complex * dest, VecLength length)
    {
        float * srcReal = src->realp;
        float * srcImag = src->imagp;
        
        for(int i=0; i<length; ++i)
        {
            dest->real = (*srcReal++);
            dest->imag = (*srcImag++);
            ++dest;
        }
    };
    
    void ctoz_cpp ( const Complex * src, SplitComplex * dest, VecLength length)
    {
        float * destReal = dest->realp;
        float * destImag = dest->imagp;
        for(int i=0; i<length; ++i)
        {
            (*destReal++) = src->real;
            (*destImag++) = src->imag;
            ++src;
        }
    };
    
    
#ifdef __ARM_NEON__
    
    void vadd_neon(const float *src1, const float *src2, float *dest, VecLength length)
    {
        VecLength remainedLength = length % 4;
        length -= remainedLength;
        
        if(length > 0)
        {
            for(; length != 0; length -= 4)
            {
                vst1q_f32(dest, vaddq_f32(vld1q_f32(src1), vld1q_f32(src2)));
                src1 += 4; src2 += 4; dest += 4;
            }
        }
        if(remainedLength != 0)
        {
            for(; remainedLength != 0; --remainedLength)
            { (*dest++) = (*src1++) + (*src2++); }
        }
        
    };
    void vmul_neon(const float *src1, const float *src2, float *dest, VecLength length)
    {
        VecLength remainedLength = length % 4;
        length -= remainedLength;
        
        if(length > 0)
        {
            for(; length != 0; length -= 4)
            {
                vst1q_f32(dest, vmulq_f32(vld1q_f32(src1), vld1q_f32(src2)));
                src1 += 4; src2 += 4; dest += 4;
            }
        }
        if(remainedLength != 0)
        {
            for(; remainedLength != 0; --remainedLength)
            { (*dest++) = (*src1++) * (*src2++); }
        }
        
    };

    void vsadd_neon(const float * src, const float * scalSrc, float * dest, VecLength length)
    {
        VecLength remainedLength = length % 4;
        length -= remainedLength;
        
        float32x4_t scalSrc_f32x4 = vdupq_n_f32(*scalSrc);
        
        if(length > 0)
        {
            for(; length != 0; length -= 4)
            {
                vst1q_f32(dest, vaddq_f32(vld1q_f32(src), scalSrc_f32x4));
                src += 4; dest += 4;
            }
        }
        if(remainedLength != 0)
        {
            for(; remainedLength != 0; --remainedLength)
            { (*dest++) = (*src++) + (*scalSrc); }
        }
    };

    void vsmul_neon(const float * src, const float * scalSrc, float * dest, VecLength length)
    {
        VecLength remainedLength = length % 4;
        length -= remainedLength;
        
        float32x4_t scalSrc_f32x4 = vdupq_n_f32(*scalSrc);
        
        if(length > 0)
        {
            for(; length != 0; length -= 4)
            {
                vst1q_f32(dest, vmulq_f32(vld1q_f32(src), scalSrc_f32x4));
                src += 4; dest += 4;
            }
        }
        if(remainedLength != 0)
        {
            for(; remainedLength != 0; --remainedLength)
            { (*dest++) = (*src++) * (*scalSrc); }
        }
    };
    void vsdiv_neon(const float * src, const float * scalSrc, float * dest, VecLength length)
    {
        VecLength remainedLength = length % 4;
        length -= remainedLength;
        
        float32x4_t scalSrc_f32x4 = vdupq_n_f32(*scalSrc);
        
        if(length > 0)
        {
            for(; length != 0; length -= 4)
            {
                vst1q_f32(dest, vmulq_f32(vld1q_f32(src), vrecpeq_f32(scalSrc_f32x4)));
                src += 4; dest += 4;
            }
        }
        if(remainedLength != 0)
        {
            for(; remainedLength != 0; --remainedLength)
            { (*dest++) = (*src++) / (*scalSrc); }
        }
    };
    
    void vsmsa_neon(const float * src, const float * scalSrcMul, const float *scalSrcAdd, float * dest, VecLength length)
    {
        VecLength remainedLength = length % 4;
        length -= remainedLength;
        
        float32x4_t scalSrcMul_f32x4 = vdupq_n_f32(*scalSrcMul);
        float32x4_t scalSrcAdd_f32x4 = vdupq_n_f32(*scalSrcAdd);
        
        if(length > 0)
        {
            for(; length != 0; length -= 4)
            {
                vst1q_f32(dest, vmlaq_f32(scalSrcAdd_f32x4, vld1q_f32(src), scalSrcMul_f32x4));
                src += 4; dest += 4;
            }
        }
        if(remainedLength != 0)
        {
            for(; remainedLength != 0; --remainedLength)
            (*dest++) = (*src++) * (*scalSrcMul) + (*scalSrcAdd);
        }
    };
    
    void vfix16_neon(const float * src, short * dest, VecLength length)
    {
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
    };
    void vfix32_neon(const float * src, int * dest, VecLength length)
    {
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
    }
    void vflt16_neon(const short * src, float * dest, VecLength length)
    {
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
    };
    void vflt32_neon(const int * src, float * dest, VecLength length)
    {
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
    };

    
    //reverse
    void vrvrs_neon(float * src, VecLength length)
    {
        float * srcBackward;
        float32x4_t src_f32x4, srcBackward_f32x4, dest_f32x4, destBackward_f32x4;

        srcBackward = src + length - 4;
        VecLength remainedLength = length;

        if(length >= 8)
        {
            remainedLength = length % 8;
            length -= remainedLength;

            for(; length != 0; length -= 8) 
            {
                src_f32x4 = vld1q_f32(src);
                srcBackward_f32x4 = vld1q_f32(srcBackward);

                dest_f32x4 = vcombine_f32(vrev64_f32(vget_high_f32(srcBackward_f32x4)), vrev64_f32(vget_low_f32(srcBackward_f32x4)));
                destBackward_f32x4 = vcombine_f32(vrev64_f32(vget_high_f32(src_f32x4)), vrev64_f32(vget_low_f32(src_f32x4)));

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
    };
    void vfill_neon(const float * src, float * dest, VecLength length)
    {
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
    };
    void vramp_neon(const float * scalInit, const float * scalInc, float * dest, VecLength length)
    {
        float * origDest = dest;
        VecLength remainedLength = length % 4;
        length -= remainedLength;
        float incConst[4] = {0.f, 1.f, 2.f, 3.f};
        
        float32x4_t incConst_f32x4 = vld1q_f32(incConst);
        float32x4_t incStep_f32x4 = vdupq_n_f32(4 * (*scalInc));

        float32x4_t src_f32x4;
        float32x4_t dest_f32x4;
        if(length > 0)
        {
            src_f32x4 = vdupq_n_f32(*(scalInit));
            float32x4_t inc_f32x4 = vmulq_f32(incConst_f32x4, vdupq_n_f32(*(scalInc)));
            for(; length != 0; length -= 4)
            {
                dest_f32x4 = vaddq_f32(src_f32x4, inc_f32x4);
                vst1q_f32(dest, dest_f32x4);
                inc_f32x4 = vaddq_f32(inc_f32x4, incStep_f32x4);
                dest += 4;
            }
        }
        if(remainedLength != 0)
        {
            VecLength i = dest - origDest;
            for(; remainedLength != 0; --remainedLength)
            {
                *(origDest+i) = (*scalInit) + (*scalInc) * i;
                ++i;
            }
        }        
    };

    void vvsincosf_neon(float * z, float * y, const float * x, VecLength length)
    {
        VecLength remainedLength = length % 4;
        length -= remainedLength;
        
        float32x4_t m2_PiConst_f32x4 = vdupq_n_f32(M_2_PI);
        float32x4_t mPi_2Const_f32x4 = vdupq_n_f32(M_PI_2);
        float32x4_t approxConstA = vdupq_n_f32(1.27323954f);
        float32x4_t approxConstB = vdupq_n_f32(.405284735f);
        float32x4_t approxConstC = vdupq_n_f32(.225f);
        
        float32x4_t sinSrc_f32x4, cosSrc_f32x4, sinAbsSrc_f32x4, cosAbsSrc_f32x4, sinReduced_f32x4, cosReduced_f32x4;
        int32x4_t mSin_s32x4, mCos_s32x4, nSin_s32x4, nCos_s32x4;
        int32x4_t one_s32x4 = vdupq_n_s32(1);
        float32x4_t zero_f32x4 = vdupq_n_f32(0.f);
        float32x4_t sinResult_f32x4, cosResult_f32x4;
        
        if(length > 0)
        {
            for(; length != 0; length-= 4)
            {
                sinSrc_f32x4 = vld1q_f32(x);
                cosSrc_f32x4 = vaddq_f32(sinSrc_f32x4, mPi_2Const_f32x4);
                
                sinAbsSrc_f32x4 = vabsq_f32(sinSrc_f32x4);
                cosAbsSrc_f32x4 = vabsq_f32(cosSrc_f32x4);
                
                mSin_s32x4 = vcvtq_s32_f32( vmulq_f32(sinAbsSrc_f32x4, m2_PiConst_f32x4));
                mCos_s32x4 = vcvtq_s32_f32( vmulq_f32(cosAbsSrc_f32x4, m2_PiConst_f32x4));
                sinReduced_f32x4 = vmlsq_f32(sinAbsSrc_f32x4, vcvtq_f32_s32(mSin_s32x4), mPi_2Const_f32x4);
                cosReduced_f32x4 = vmlsq_f32(cosAbsSrc_f32x4, vcvtq_f32_s32(mCos_s32x4), mPi_2Const_f32x4);
                
                //                //testQuadrant
                nSin_s32x4 = vandq_s32(mSin_s32x4, one_s32x4);
                sinReduced_f32x4 = vmlsq_f32(sinReduced_f32x4, vcvtq_f32_s32(nSin_s32x4), mPi_2Const_f32x4);
                nSin_s32x4 = veorq_s32(nSin_s32x4, vshrq_n_s32(mSin_s32x4, 1));
                nSin_s32x4 = vshlq_n_s32(veorq_s32(nSin_s32x4, vcltq_f32(sinSrc_f32x4, zero_f32x4)) , 31);
                sinReduced_f32x4 = vreinterpretq_f32_s32(veorq_s32(vreinterpretq_s32_f32(sinReduced_f32x4), nSin_s32x4));
                
                //http://devmaster.net/posts/9648/fast-and-accurate-sine-cosine
                nCos_s32x4 = vandq_s32(mCos_s32x4, one_s32x4);
                cosReduced_f32x4 = vmlsq_f32(cosReduced_f32x4, vcvtq_f32_s32(nCos_s32x4), mPi_2Const_f32x4);
                nCos_s32x4 = veorq_s32(nCos_s32x4, vshrq_n_s32(mCos_s32x4, 1));
                nCos_s32x4 = vshlq_n_s32(veorq_s32(nCos_s32x4, vcltq_f32(cosSrc_f32x4, zero_f32x4)), 31) ;
                cosReduced_f32x4 = vreinterpretq_f32_s32(veorq_s32(vreinterpretq_s32_f32(cosReduced_f32x4), nCos_s32x4));
                
                sinResult_f32x4 = vmlsq_f32(vmulq_f32(approxConstA, sinReduced_f32x4), approxConstB, vmulq_f32(sinReduced_f32x4, vabsq_f32(sinReduced_f32x4)));
                cosResult_f32x4 = vmlsq_f32(vmulq_f32(approxConstA, cosReduced_f32x4), approxConstB, vmulq_f32(cosReduced_f32x4, vabsq_f32(cosReduced_f32x4)));
                
                sinResult_f32x4 = vmlaq_f32(sinResult_f32x4, approxConstC, vmlaq_f32(vnegq_f32(sinResult_f32x4), vabsq_f32(sinResult_f32x4), sinResult_f32x4));
                cosResult_f32x4 = vmlaq_f32(cosResult_f32x4, approxConstC, vmlaq_f32(vnegq_f32(cosResult_f32x4), vabsq_f32(cosResult_f32x4), cosResult_f32x4));
                
                vst1q_f32(z, sinResult_f32x4);
                vst1q_f32(y, cosResult_f32x4);
                
                z+= 4; y+=4; x+= 4;
            }
        }
        if(remainedLength != 0)
        {
            for(; remainedLength != 0; --remainedLength)
            {
                *(z++) = vsinf(*x);
                *(y++) = vcosf(*(x++));
            }
        }
        
    };
    void vvatan2f_neon(float * z, const float * y, const float * x, VecLength length)
    {
        // refered to "Full Quadrant Approximations for the Arctangent Function - Xavier Girones, et al."
        // http://ieeexplore.ieee.org/xpl/articleDetails.jsp?arnumber=6375931
        
        VecLength remainedLength = length % 4;
        length -= remainedLength;
        
        float32x4_t x_f32x4, y_f32x4;
        uint32x4_t signMask_u32x4 = vdupq_n_u32(0x80000000);
        float32x4_t approxConst_f32x4 = vdupq_n_f32(0.596227f);
        float32x4_t mPi2Const_f32x4 = vdupq_n_f32(M_PI_2);
        float32x4_t mPiConst_f32x4 = vdupq_n_f32(M_PI);
        float32x4_t mZero_f32x4 = vdupq_n_f32(0.f);
        
        uint32x4_t signSrcReal_u32x4, signSrcImag_u32x4, signSrcNotRealAndImag_u32x4, signSrcRealXorImag_u32x4;
        float32x4_t quadOffest_f32x4, temp1_f32x4, temp2_f32x4, atan1q_f32x4;
        uint32x4_t atan2q_u32x4, compResult_u32x4;
        float32x4_t normalizedDest_f32x4, dest_f32x4, subtrahend_f32x4;
        
        if(length > 0)
        {
            for(; length != 0; length -= 4)
            {
                x_f32x4 = vld1q_f32(x);
                y_f32x4 = vld1q_f32(y);
                
                signSrcReal_u32x4 = vandq_u32(signMask_u32x4, vreinterpretq_u32_f32(x_f32x4));
                signSrcImag_u32x4 = vandq_u32(signMask_u32x4, vreinterpretq_u32_f32(y_f32x4));
                signSrcNotRealAndImag_u32x4 = vandq_u32(vmvnq_u32(signSrcReal_u32x4), signSrcImag_u32x4);
                signSrcRealXorImag_u32x4 = veorq_u32(signSrcReal_u32x4, signSrcImag_u32x4);
                
                //Determine the quadrant offset
                quadOffest_f32x4 = vcvtq_f32_u32( vorrq_u32(vshrq_n_u32(signSrcReal_u32x4, 30),
                                                            vshrq_n_u32( signSrcNotRealAndImag_u32x4, 29)));
                //
                //Calculate the arctangent in the first quadrant
                temp1_f32x4 = vabsq_f32(vmulq_f32(approxConst_f32x4, vmulq_f32(x_f32x4,y_f32x4)));
                temp2_f32x4 = vaddq_f32(temp1_f32x4, vmulq_f32(y_f32x4, y_f32x4));
                atan1q_f32x4 = vmulq_f32(temp2_f32x4,vrecpeq_f32(vaddq_f32(temp2_f32x4, vaddq_f32(temp1_f32x4, vmulq_f32(x_f32x4, x_f32x4)))));
                
                //Translate it to the proper quadrant
                
                atan2q_u32x4 = vorrq_u32(signSrcRealXorImag_u32x4, vreinterpretq_u32_f32(atan1q_f32x4));
                normalizedDest_f32x4 = vaddq_f32(quadOffest_f32x4, vreinterpretq_f32_u32(atan2q_u32x4));
                
                //unnormalize
                dest_f32x4 = vmulq_f32(mPi2Const_f32x4, normalizedDest_f32x4);
                
                //if(dest > M_PI) { dest -= M_PI; }
                compResult_u32x4 = vcgtq_f32(dest_f32x4, mPiConst_f32x4);
                subtrahend_f32x4 = vreinterpretq_f32_u32(vandq_u32(vreinterpretq_u32_f32(mPiConst_f32x4), compResult_u32x4));
                dest_f32x4 = vsubq_f32(dest_f32x4, subtrahend_f32x4);
                
                //if(dest > 0 && y < 0) { dest -= M_PI; }
                compResult_u32x4 = vandq_u32(vcgtq_f32(dest_f32x4, mZero_f32x4), vcleq_f32(y_f32x4, mZero_f32x4));
                subtrahend_f32x4 = vreinterpretq_f32_u32(vandq_u32(vreinterpretq_u32_f32(mPiConst_f32x4), compResult_u32x4));
                dest_f32x4 = vsubq_f32(dest_f32x4, subtrahend_f32x4);
                
                vst1q_f32(z, dest_f32x4);
                x += 4; y += 4; z += 4;
            }
        }
        if(remainedLength != 0)
        {
            for(; remainedLength != 0; --remainedLength)
            {
                (*z++) = vatan2f((*y++), (*x++));
            }
        }
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
    
    void zvconj_neon(const SplitComplex * src, const SplitComplex * dest, VecLength length)
    {
        zvmov(src, dest, length);
        VecLength remainedLength = length % 4;
        length -= remainedLength;
        
        float * destImag = dest->imagp;
        float32x4_t srcImag_f32x4, destImag_f32x4;
        
        if(length > 0)
        {
            for(; length != 0; length -=4 )
            {
                srcImag_f32x4 = vld1q_f32(destImag);
                destImag_f32x4 = vnegq_f32(srcImag_f32x4);
                vst1q_f32(destImag, destImag_f32x4);
                destImag += 4;
            }
        }
        if(remainedLength != 0)
        {
            for(; remainedLength != 0; --remainedLength)
            {
                (*destImag++) *= -1;
            }
        }
    };
    void zvmul_neon(const SplitComplex * src1, const SplitComplex * src2, const SplitComplex * dest, VecLength length, int conjFlag)
    {
        VecLength remainedLength = length % 4;
        length -= remainedLength;
        float * src1Real = src1->realp;
        float * src1Imag = src1->imagp;
        float * src2Real = src2->realp;
        float * src2Imag = src2->imagp;
        float * destReal = dest->realp;
        float * destImag = dest->imagp;


        float32x4_t src1Real_f32x4, src1Imag_f32x4, src2Real_f32x4, src2Imag_f32x4;
        float32x4_t destReal_f32x4, destImag_f32x4;
        float32x4_t destRealReRe_f32x4, destRealImIm_f32x4, destImagReIm_f32x4, destImagImRe_f32x4;
        float32x4_t conjFlag_f32x4 = vdupq_n_f32(static_cast<float>(conjFlag));
        
        if(length > 0)
        {
            for(; length != 0 ; length -= 4)
            {
                src1Real_f32x4 = vld1q_f32(src1Real);
                src1Imag_f32x4 = vld1q_f32(src1Imag);
                src2Real_f32x4 = vld1q_f32(src2Real);
                src2Imag_f32x4 = vld1q_f32(src2Imag);
                
                destRealReRe_f32x4 = vmulq_f32(src1Real_f32x4, src2Real_f32x4);
                destRealImIm_f32x4 = vmulq_f32(src1Imag_f32x4, src2Imag_f32x4);
                destImagReIm_f32x4 = vmulq_f32(src1Real_f32x4, src2Imag_f32x4);
                destImagImRe_f32x4 = vmulq_f32(src1Imag_f32x4, src2Real_f32x4);
                
                destReal_f32x4 = vmlsq_f32(destRealReRe_f32x4, destRealImIm_f32x4, conjFlag_f32x4);
                destImag_f32x4 = vmlaq_f32(destImagReIm_f32x4, destImagImRe_f32x4, conjFlag_f32x4);

                vst1q_f32(destReal, destReal_f32x4);
                vst1q_f32(destImag, destImag_f32x4);
                
                src1Real += 4; src1Imag += 4; src2Real += 4; src2Imag += 4;
                destReal += 4; destImag += 4;
            }
        }
        if(remainedLength != 0)
        {
            for(; remainedLength != 0; --remainedLength)
            {
                *(destReal++) = (*src1Real) * (*src2Real) - conjFlag * ( (*src1Imag) * (*src2Imag));
                *(destImag++) = (*(src1Real++)) * (*(src2Imag++)) + conjFlag * ( (*(src1Imag++)) * (*(src2Real++)));
            }
        }
    };
    void zvdiv_neon(const SplitComplex * srcDen, const SplitComplex  * srcNum, const SplitComplex * dest, VecLength length)
    {
        float * srcDenReal = srcDen->realp;
        float * srcDenImag = srcDen->imagp;
        float * srcNumReal = srcNum->realp;
        float * srcNumImag = srcNum->imagp;
        float * destReal = dest->realp;
        float * destImag = dest->imagp;
        
        VecLength remainedLength = length % 4;
        length -= remainedLength;
        
        float32x4_t den_f32x4, denReciprocal_f32x4, denRealPow_f32x4, denImagPow_f32x4;
        float32x4_t srcDenReal_f32x4, srcDenImag_f32x4, srcNumReal_f32x4, srcNumImag_f32x4;
        float32x4_t destRealReRe_f32x4, destRealImIm_f32x4, destRealSum_f32x4, destReal_f32x4;
        float32x4_t destImagImRe_f32x4, destImagReIm_f32x4, destImagSum_f32x4, destImag_f32x4;
        
        if(length > 0)
        {
            for(; length != 0; length -= 4)
            {
                srcDenReal_f32x4 = vld1q_f32(srcDenReal);
                srcDenImag_f32x4 = vld1q_f32(srcDenImag);
                srcNumReal_f32x4 = vld1q_f32(srcNumReal);
                srcNumImag_f32x4 = vld1q_f32(srcNumImag);
                
                denRealPow_f32x4 = vmulq_f32(srcDenReal_f32x4, srcDenReal_f32x4);
                denImagPow_f32x4 = vmulq_f32(srcDenImag_f32x4, srcDenImag_f32x4);
                den_f32x4 = vaddq_f32(denRealPow_f32x4, denImagPow_f32x4);
                denReciprocal_f32x4 = vrecpeq_f32(den_f32x4);

                
                destRealReRe_f32x4 = vmulq_f32(srcDenReal_f32x4, srcNumReal_f32x4);
                destRealImIm_f32x4 = vmulq_f32(srcDenImag_f32x4, srcNumImag_f32x4);
                destImagImRe_f32x4 = vmulq_f32(srcNumImag_f32x4, srcDenReal_f32x4);
                destImagReIm_f32x4 = vmulq_f32(srcNumReal_f32x4, srcDenImag_f32x4);
                
                destRealSum_f32x4 = vaddq_f32(destRealReRe_f32x4, destRealImIm_f32x4);
                destReal_f32x4 = vmulq_f32(destRealSum_f32x4, denReciprocal_f32x4);
                destImagSum_f32x4 = vsubq_f32(destImagImRe_f32x4, destImagReIm_f32x4);
                destImag_f32x4 = vmulq_f32(destImagSum_f32x4, denReciprocal_f32x4);
                
                vst1q_f32(destReal, destReal_f32x4);
                vst1q_f32(destImag, destImag_f32x4);
                
                srcDenReal += 4; srcDenImag += 4; srcNumReal += 4; srcNumImag += 4;
                destReal += 4; destImag += 4;
                
            }
        }
        if(remainedLength != 0)
        {
            float den;
            for(; remainedLength != 0; --remainedLength)
            {
                den = (*srcDenReal) * (*srcDenReal) + (*srcDenImag) * (*srcDenImag);
                *(destReal++) = ((*srcNumReal) * (*srcDenReal) + (*srcNumImag) * (*srcDenImag)) / den;
                *(destImag++) = ((*srcNumImag++) * (*srcDenReal++) - (*srcNumReal++) * (*srcDenImag++)) / den;
            }
        }
    };

 
    void dotpr_neon(const float * src1, const float * src2, float * dest, VecLength length)
    {
        VecLength remainedLength = length % 4;
        length -= remainedLength;
        *dest = 0;
        float32x4_t srcMul_f32x4;
        float32x4_t sum_f32x4;
        float32x2_t sum_f32x2;
        
        if(length > 0)
        {
            sum_f32x4 = vdupq_n_f32(0.f);
            for(; length != 0; length -= 4)
            {
                srcMul_f32x4 = vmulq_f32(vld1q_f32(src1), vld1q_f32(src2));
                sum_f32x4 = vaddq_f32(sum_f32x4, srcMul_f32x4);
                src1 += 4; src2 += 4;
            }
            sum_f32x2 = vadd_f32(vget_low_f32(sum_f32x4), vget_high_f32(sum_f32x4));
            *dest = sum_f32x2[0] + sum_f32x2[1];
        }
        if(remainedLength != 0)
        {
            for(; remainedLength != 0; --remainedLength)
            {
                (*dest) += (*src1++) * (*src2++);
            }
        }

        
    };

    void conv_neon(const float * src, const float * filter, float * dest, VecLength lengthDest, VecLength lengthFilter)
    {
        VecLength remainedFilterLength = lengthFilter % 4;
        lengthFilter -= remainedFilterLength;
        
        float32x4_t src_f32x4, filter_f32x4, filterReversed_f32x4, dest_f32x4;
        float32x2_t destSum_f32x2;
        
        
        if(lengthFilter != 0)
        {
            for(VecLength i = 0; i < lengthDest; ++i)
            {
                dest_f32x4 = vdupq_n_f32(0.f);
                for(VecLength j = 0; j < lengthFilter; j += 4)
                {
                    src_f32x4 = vld1q_f32(src + j);
                    filter_f32x4 = vld1q_f32(filter + remainedFilterLength + lengthFilter - j - 4);
                    filterReversed_f32x4 =vcombine_f32(vrev64_f32(vget_high_f32(filter_f32x4)), vrev64_f32(vget_low_f32(filter_f32x4)));
                    dest_f32x4 = vmlaq_f32(dest_f32x4, src_f32x4, filterReversed_f32x4 );
                }
                destSum_f32x2 = vadd_f32(vget_low_f32(dest_f32x4), vget_high_f32(dest_f32x4));
                *dest = destSum_f32x2[0] + destSum_f32x2[1];
                ++src; ++dest;
            }
        }
        if(remainedFilterLength != 0)
        {
            src -= lengthDest;
            dest -= lengthDest;
            for(VecLength i = 0; i < lengthDest; ++i)
            {
                for(VecLength j = 0; j < remainedFilterLength; ++j)
                {
                    *(dest) += (*(src + lengthFilter + j)) * (*(filter + remainedFilterLength - 1 - j));
                }
                ++src; ++dest;
            }
        }
    };

    void corr_neon(const float * src, const float * filter, float * dest, VecLength lengthDest, VecLength lengthFilter)
    {
        VecLength remainedFilterLength = lengthFilter % 4;
        lengthFilter -= remainedFilterLength;

        float32x4_t dest_f32x4;
        float32x2_t destSum_f32x2;
        if(lengthFilter != 0)
        {
            for(VecLength i = 0; i < lengthDest; ++i)
            {
                dest_f32x4 = vdupq_n_f32(0.f);
                for(VecLength j = 0; j < lengthFilter; j += 4)
                {
                    dest_f32x4 = vmlaq_f32(dest_f32x4, vld1q_f32(src + j), vld1q_f32(filter + j) );
                }
                destSum_f32x2 = vadd_f32(vget_low_f32(dest_f32x4), vget_high_f32(dest_f32x4));
                *dest = destSum_f32x2[0] + destSum_f32x2[1];
                ++src; ++dest;
            }
        }
        if(remainedFilterLength != 0)
        {
            src -= lengthDest;
            dest -= lengthDest;
            VecLength origFilterLength = lengthFilter + remainedFilterLength;
            for(VecLength i = 0; i < lengthDest; ++i)
            {
                for(VecLength j = lengthFilter; j < origFilterLength; ++j)
                {
                    *(dest) += (*(src + j)) * (*(filter + j));
                }
                ++src; ++dest;
            }
        }

    }
#endif

    //************* deprecated *******************
    /*
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
     */    
    
    
};
