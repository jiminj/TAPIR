//
//  TrellisCode.h
//  TapirLib
//
//  Created by Jimin Jeon on 1/24/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#ifndef __TapirLib__TrellisCode__
#define __TapirLib__TrellisCode__

namespace Tapir {

    class TrellisCode
    {
    public:
        TrellisCode(const int g);
        TrellisCode(const TrellisCode& rhs);
        virtual ~TrellisCode();
        void extendTo(const int extLength);

        int getLength() { return m_length;};
        int getBitsAsInteger();
        const float * getEncodedCode() { return m_encodedCode;};
    private:
        int m_g;
        int m_length;
        float * m_encodedCode;

    };
    
};



#endif /* defined(__TapirLib__TrellisCode__) */
