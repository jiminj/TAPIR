//
//  TapirDSP.cpp
//  TapirLib
//
//  Created by Jimin Jeon on 2/13/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#include "../include/TapirDSP.h"

namespace TapirDSP {
    
    
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
