//
//  Decoder.cpp
//  TapirLib
//
//  Created by Jimin Jeon on 1/24/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#include "Decoder.h"

namespace Tapir {
    ViterbiDecoder::ViterbiDecoder(const std::vector<TrellisCode>& trelArray)
    :m_noTrellis(static_cast<int>(trelArray.size())),
    m_noRegisterBits(static_cast<int>(trelArray.front().getLength() - 1)),
    m_noStates(1 << m_noRegisterBits),
    m_noInfoTableCols(2),
    m_nextStateRouteTable(new int *[m_noStates]),
    m_outputTable(new int *[m_noStates])
    {
        genTables(trelArray);
    };

    ViterbiDecoder::~ViterbiDecoder()
    {
        for(int i=0; i<m_noStates; ++i)
        {
            delete [] m_nextStateRouteTable[i];
            delete [] m_outputTable[i];
        }
        delete [] m_nextStateRouteTable;
        delete [] m_outputTable;
    };
    
    void ViterbiDecoder::genTables(const std::vector<TrellisCode>& trelArray)
    {
        //Assume that all trellis codes have same length

        //Generate Output Table
        for(int row=0; row<m_noStates; ++row)
        {
            m_outputTable[row] = new int[m_noInfoTableCols]();
            for(int col=0; col<m_noInfoTableCols; ++col)
            {
                for(int idxTrel=0; idxTrel<m_noTrellis; ++idxTrel)
                {
                    int encoded = trelArray.at(idxTrel).getBitsAsInteger() & ( row | ( col << m_noRegisterBits)) ;
                    // e.g.) no of Register :2, curState : 10 => for input 0 : 000 | trel
                    //                                        => for input 1 : 100 | trel
                    
                    int bitsXorResult = encoded & 1; //assign a last bit of result
                    while(encoded != 0)
                    {
                        encoded >>= 1;
                        bitsXorResult = (encoded & 1) ^ (bitsXorResult & 1);
                    }
                    m_outputTable[row][col] += bitsXorResult << (m_noTrellis - idxTrel - 1);
                }
            }
        }

        //Generate Next Status Table
        for(int i=0; i< m_noStates; ++i)
        {
            m_nextStateRouteTable[i] = new int[m_noInfoTableCols];
            //set Next Route Path;
            // e.g. 0011 => 0001 (When next input is zero) => 0011 (When next input is one);
            
            for(int j=0; j<m_noInfoTableCols; ++j)
            {
                m_nextStateRouteTable[i][j] = (i >> 1) | (j << (m_noRegisterBits - 1));
            }
        }
        
        
    };

    
    
    void ViterbiDecoder::decode(const float * src, int * dest, const int srcLength, const int extLength)
    {
        
        //Make input blocks (bind m_noTrellis blocks to one block)
        int * intSrc = new int[srcLength];
        vDSP_vfix32(src, 1, intSrc, 1, srcLength);
        
        int outputLength = srcLength / m_noTrellis;
        int inputLength = outputLength + extLength;
        int * input = new int[inputLength]();
        
        for(int i=0; i<inputLength - extLength; ++i)
        {
            int srcLoc = i * m_noTrellis;
            for(int j=0; j< m_noTrellis; ++j)
            {
                input[i] += (intSrc[srcLoc + j] & 1) << (m_noTrellis - j - 1);
            }
        }
        
        // allocte a weight table and a tracking information table
        int ** weightTable = new int * [m_noStates];
        int ** trackInfoTable = new int * [m_noStates];
        int ** selectionTable = new int * [m_noStates];
        
        for(int i=0; i<m_noStates; ++i)
        {
            weightTable[i] = new int[inputLength + 1];
            trackInfoTable[i] = new int[inputLength];
            selectionTable[i] = new int[inputLength];
            std::fill(weightTable[i], weightTable[i] + inputLength + 1, -1);
            std::fill(trackInfoTable[i], trackInfoTable[i] + inputLength, -1);
            std::fill(selectionTable[i], selectionTable[i] + inputLength, -1);
        }
        
        // Weight Table
        //              0   1   2   3   => steps
        //      --------------------
        //      0   |    0  0   ..
        //      1   |   -1  -1
        //      2   |   -1  3
        //      3   |   -1  -1
        //     ...  |   ..
        //  (states)|
        
        
        weightTable[0][0] = 0; //Always starts at 0
        //var inputLength is equal to (tableLength - 1)
        
        for(int step = 0; step < inputLength; ++step) // For each step
        {
            int nextStep = step + 1;
            for(int curState=0; curState < m_noStates; ++curState) // For every state element in a same col
            {
                int curWeight = weightTable[curState][step];
                if( curWeight != -1)
                {
                    for(int i=0; i < m_noInfoTableCols; ++i)
                    {
                        int nextState = m_nextStateRouteTable[curState][i]; //search next State Table
                        int newWeight = curWeight + calHammingDistance(input[step], m_outputTable[curState][i]);
                        if( (weightTable[nextState][nextStep] == -1 ) || (weightTable[nextState][nextStep] > newWeight) )
                        {
                            //replace when the next state value is unsetted or bigger than current weight
                            weightTable[nextState][nextStep] = newWeight;
                            trackInfoTable[nextState][step] = curState;
                            selectionTable[nextState][step] = i; //0 or 1
                        }
                    }
                }
            }
        }
        
        int minRouteIdx = 0;
        int minValue = inputLength * 2; //maximum hamming distance;
        
        //Search minimum value at last step
        for(int i=0; i< m_noStates; ++i)
        {
            int curStateVal = weightTable[i][inputLength];
            if( (curStateVal != -1) && (curStateVal < minValue) )
            {
                minRouteIdx = i;
                minValue = curStateVal;
            }
        }
        
        //Backtrack
        int * backtrackResult = new int[inputLength];
        for(int i=inputLength-1; i >= 0; --i)
        {
            backtrackResult[i] = selectionTable[minRouteIdx][i];
            minRouteIdx = trackInfoTable[minRouteIdx][i];
        }
//        std::copy(backtrackResult, backtrackResult + outputLength, dest);
        TapirDSP::copy(backtrackResult, backtrackResult + outputLength, dest);

        
        //clean
        
        delete [] intSrc;
        delete [] input;
        
        for(int i=0; i< m_noStates; ++i)
        {
            delete [] weightTable[i];
            delete [] trackInfoTable[i];
            delete [] selectionTable[i];
        }
        delete [] weightTable;
        delete [] trackInfoTable;
        delete [] selectionTable;
        delete [] backtrackResult;
    }
    
    
};
