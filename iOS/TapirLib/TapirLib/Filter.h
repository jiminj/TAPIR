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
        virtual void setFilter(const float * coeff, const int order, const int bufferSize) = 0;
        virtual void process(const float * src, float * dest, int length) const = 0;
    };

    
    //FIR(Linear) Filter
    class FilterFIR : public Filter
    {
    public:
        FilterFIR();
        FilterFIR(const float * coeff, const int order, const int bufferSize);
        void setFilter(const float * coeff, const int order, const int bufferSize);

        void process(const float * src, float * dest, int length) const ;
        int getFilterOrder() { return m_order;};

        virtual ~FilterFIR();

    protected:
        void clear();
        float * m_coeff;
        float * m_buffer;
        int m_order;
        
    };
    
    
    //IIR(Biquad) Filter
    class FilterIIR : public Filter
    {
    public:
        FilterIIR();
        FilterIIR(const float * coeff, const int section, const int bufferSize = 0);
        void setFilter(const float * coeff, const int section, const int bufferSize = 0);

        void process(const float * src, float * dest, int length) const;

        virtual ~FilterIIR();

    protected:
        void clear();
        
        double * m_coeff;
        int m_section;
        
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
