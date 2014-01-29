//
//  Filter.cpp
//  TapirLib
//
//  Created by Jimin Jeon on 1/9/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#include "Filter.h"

namespace Tapir {

    //****** FIR Filter ********
    FilterFIR::FilterFIR(const float * coeff, const int filtOrder, const int maxBufferSize)
    :m_order(filtOrder),
    m_coeff(new float[m_order]),
    m_bufferSize(filtOrder + maxBufferSize),
    m_buffer(new float[m_bufferSize]())
    {
        memcpy(m_coeff, coeff, sizeof(float) * filtOrder);
        vDSP_vrvrs(m_coeff, 1, m_order);

    };
    void FilterFIR::process(const float * src, float * dest, int length)
    {
        //copy data to buffer
        memcpy(m_buffer + m_order, src, length * sizeof(float));
        float * curBufferPos = m_buffer;
        for(int i=0; i<length; ++i)
        {
            vDSP_dotpr(curBufferPos++, 1, m_coeff, 1, dest++, m_order);
        }
        //copy result to buffer
        memcpy(m_buffer, src + length - m_order, m_order * sizeof(float));
        
    };
    void FilterFIR::clearBuffer()
    {
        std::fill(m_buffer, m_buffer + m_bufferSize, 0);
    };
    FilterFIR::~FilterFIR()
    {
        if(m_coeff != nullptr)
        { delete [] m_coeff; m_coeff = nullptr; }
        if(m_buffer != nullptr)
        { delete [] m_buffer; m_buffer = nullptr; }
    };
    
    //****** IIR Filter ********
//    FilterIIR::FilterIIR()
//    : m_coeff(nullptr), m_section(0), m_filtDelay(nullptr), m_filterSetup(nullptr)
//    {};
    FilterIIR::FilterIIR(const float * coeff, const int numSection)
    :m_numSection(numSection),
    m_coeff(new double[m_numSection * 5]),
    m_filtDelay(new float[ 2* m_numSection + 2]),
    m_filterSetup(vDSP_biquad_CreateSetup(m_coeff, m_numSection))
    {
        vDSP_vspdp(coeff, 1, m_coeff, 1, m_numSection * 5);
    };
    void FilterIIR::process(const float * src, float * dest, int length)
    {
        vDSP_biquad(m_filterSetup, m_filtDelay, src, 1, dest, 1, length);
        
        /*************************
        * vDSP_biquad(const struct vDSP_biquad_SetupStruct *__vDSP_Setup, float *__vDSP_Delay, const float *__vDSP_X, vDSP_Stride __vDSP_IX, float *__vDSP_Y, vDSP_Stride __vDSP_IY, vDSP_Length __vDSP_N)

         S, A0, A1, A2, B1, and B2 are determined by Setup.
         S is the number of sections.
         
         X provides the bulk of the input signal.  Delay provides prior state
         data for S biquadratic filters.  The filters are applied to the data in
         turn.  The output of the final filter is stored in Y, and the final
         state data of the filters are stored in Delay.
         
        // Initialize the first row of a matrix x with data from X:
        for (n = 0; n < N; ++n)
            x[0][n ] = X[n*IX];
        
        // Initialize the "past" information, elements -2 and -1, from Delay:
        for (s = 0; s <= S; ++s)
        {
            x[s][-2] = Delay[2*s+0];
            x[s][-1] = Delay[2*s+1];
        }
        
        // Apply each filter:
        for (s = 1; s <= S; ++s)
            for (n = 0; n < N; ++n)
                x[s][n] =
                + A0[s] * x[s-1][n-0]
                + A1[s] * x[s-1][n-1]
                + A2[s] * x[s-1][n-2]
                - B1[s] * x[s  ][n-1]
                - B2[s] * x[s  ][n-2];
        
        // Save the updated state data from the end of each row:
        for (s = 0; s <= S; ++s)
        {
            Delay[2*s+0] = x[s][N-2];
            Delay[2*s+1] = x[s][N-1];
        }
        
        // Store the results of the final filter:
        for (n = 0; n < N; ++n)
            Y[n*IY] = x[S][n];
        *********************************/
        
        
    };
    void FilterIIR::clearBuffer()
    {
        std::fill(m_filtDelay, m_filtDelay + (2 * m_numSection + 2), 0);
    };
    FilterIIR::~FilterIIR()
    {
        if(m_filterSetup != nullptr)
        { vDSP_biquad_DestroySetup(m_filterSetup); }
        if(m_coeff != nullptr)
        { delete [] m_coeff; m_coeff = nullptr; }
        if(m_filtDelay != nullptr)
        { delete [] m_filtDelay; m_filtDelay = nullptr;}
    };
    

    //****** Filters For Tapir *******
    
    FilterFIR * TapirFilters::txrxHpf = nullptr;

    FilterFIR * TapirFilters::getTxRxHpf(int maxBufSize)
    {
        if(txrxHpf == nullptr)
        {
            int order = 51;
            float coef[] = {
                -0.000974904910325978405274960358894986712,
                0.001061570369449390963470514215316597983,
                -0.000845968749311988327428679657060683894,
                0.000207446002690359727286401048118591461,
                0.000898872800870446886888076587496243519,
                -0.002280760783206247418325451903342582227,
                0.003421613224756182413538452280477031309,
                -0.003573513116002676164723039775594770617,
                0.002059077967269363866609221958015041309,
                0.001306637501988568150768088571567204781,
                -0.005863888601476439227377923657513747457,
                0.010042861492369518569556241516238515032,
                -0.01172573863896613291513126853260473581,
                0.009010891522838104447656881745842838427,
                -0.001159090966887983296593200854829319724,
                -0.01063785830046301041085232697014362202,
                0.023036860284334149256979529241107229609,
                -0.031097860730212163044017259494466998149,
                0.029574426226330587097468338697581202723,
                -0.014609057854509839569079332477485877462,
                -0.014705576307981381434242251771138398908,
                0.055467322703750356061025428289212868549,
                -0.101195096771377376909661904846871038899,
                0.143197100713312597264348369208164513111,
                -0.172738244745205077324001763372507411987,
                0.183375122580046623355087831441778689623,
                -0.172738244745205077324001763372507411987,
                0.143197100713312597264348369208164513111,
                -0.101195096771377376909661904846871038899,
                0.055467322703750356061025428289212868549,
                -0.014705576307981381434242251771138398908,
                -0.014609057854509839569079332477485877462,
                0.029574426226330587097468338697581202723,
                -0.031097860730212163044017259494466998149,
                0.023036860284334149256979529241107229609,
                -0.01063785830046301041085232697014362202,
                -0.001159090966887983296593200854829319724,
                0.009010891522838104447656881745842838427,
                -0.01172573863896613291513126853260473581,
                0.010042861492369518569556241516238515032,
                -0.005863888601476439227377923657513747457,
                0.001306637501988568150768088571567204781,
                0.002059077967269363866609221958015041309,
                -0.003573513116002676164723039775594770617,
                0.003421613224756182413538452280477031309,
                -0.002280760783206247418325451903342582227,
                0.000898872800870446886888076587496243519,
                0.000207446002690359727286401048118591461,
                -0.000845968749311988327428679657060683894,
                0.001061570369449390963470514215316597983,
                -0.000974904910325978405274960358894986712 };
            txrxHpf = new FilterFIR(coef, order, maxBufSize);
        }
        
        return txrxHpf;
    };
    
};