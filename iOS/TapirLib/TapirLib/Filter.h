//
//  Filter.h
//  TapirLib
//
//  Created by Jimin Jeon on 1/9/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#ifndef __TapirLib__Filter__
#define __TapirLib__Filter__
#include <Accelerate/Accelerate.h>

namespace Tapir {

    class Filter
    {
    public:
        virtual ~Filter() {};
        virtual void clearBuffer() = 0;
        virtual void process(const float * src, float * dest, int length) = 0;
    };

    
    //FIR(Linear) Filter
    class FilterFIR : public Filter
    {
    public:
        FilterFIR(const float * coeff, const int filtOrder, const int maxBufferSize);
        void process(const float * src, float * dest, int length) ;
        void clearBuffer();
        int getFilterOrder() { return m_order;};

        virtual ~FilterFIR();

    protected:
        int m_order;
        float * m_coeff;
        int m_bufferSize;
        float * m_buffer;
 
    };
    
    
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
    
    class TapirFilters
    {
    public:
        static FilterFIR * getTxRxHpf(int maxBufSize);
    protected:
        TapirFilters();
        static FilterFIR * txrxHpf;
    };
    
};


#endif /* defined(__TapirLib__Filter__) */
