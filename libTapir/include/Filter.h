//
//  Filter.h
//  TapirLib
//
//  Created by Jimin Jeon on 1/9/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#ifndef __TapirLib__Filter__
#define __TapirLib__Filter__
#include "TapirDSP.h"
#include <vector>
#include <tr1/functional>
#include <cmath>

namespace Tapir {

    class Filter
    {
    public:
        virtual ~Filter() {};
        virtual void clearBuffer() = 0;
        virtual void process(const float * src, float * dest, int length) = 0;
        virtual int getGroupDelay() = 0;
    };

    
    //FIR(Linear) Filter
    class FilterFIR : public Filter
    {
    public:
        FilterFIR(const float * coeff, const int filtOrder, const int maxBufferSize);
        void process(const float * src, float * dest, int length) ;
        void clearBuffer();
        int getGroupDelay() { return ceil(m_order / 2);};

        virtual ~FilterFIR();

    protected:
        int m_order;
        float * m_coeff;
        int m_bufferSize;
        float * m_buffer;
 
    };
    
#ifdef __APPLE__
    //IIR(Biquad) Filter
    class FilterIIR : public Filter
    {
    public:
        FilterIIR(const float * coeff, const int numSection);
        void clearBuffer();
        void process(const float * src, float * dest, int length);
        virtual ~FilterIIR();

    protected:
        int m_numSection;
        double * m_coeff;
        float * m_filtDelay;
        vDSP_biquad_Setup m_filterSetup;

    };
#endif
    
    class FilterCreator
    {
    public:

        enum FilterType //should match order to static vector of functions, 'functions'
        {
            HAMMING_19k_50 = 0,
            CHEVYSHEV_19k_150,
            CHEVYSHEV_19k_250,
            EQUIRIPPLE_19k_250
        };

        static Filter * create(const int maxBufSize, FilterType fType);
        
    protected:
        
        FilterCreator() {};
        
        static Filter * createHamming19k50(const int maxBufSize);
        static Filter * createChevyshev19k150(const int maxBufSize);
        static Filter * createChevyshev19k250(const int maxBufSize);
        static Filter * createEquiripple19k250(const int maxBufSize);
        
//        static std::vector<std::tr1::function<Filter *(const int)> > filterCreateFuncs;
        
    };

    
    
    
};


#endif /* defined(__TapirLib__Filter__) */
