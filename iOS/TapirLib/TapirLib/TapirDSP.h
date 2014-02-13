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
    
    
};




#endif /* defined(__TapirLib__TapirDSP__) */
