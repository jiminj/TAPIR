//
//  AutoCorrelator.h
//  TapirLib
//
//  Created by Jimin Jeon on 1/15/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#ifndef __TapirLib__AutoCorrelator__
#define __TapirLib__AutoCorrelator__

namespace Tapir {
    
    
    class AutoCorrelator
    {
    public:
        AutoCorrelator();
        virtual ~AutoCorrelator();
        
        void addBuffer(float * );
        void clearBuffer();
        
        
    protected:
        int m_numBlocks;
        int m_blockSize;
        float * buffer;
        
        int curBufBlk;
        float * curInsertPos;
        
        float * stBuffer;
        float * edBuffer;
    };

}


#endif /* defined(__TapirLib__AutoCorrelator__) */
