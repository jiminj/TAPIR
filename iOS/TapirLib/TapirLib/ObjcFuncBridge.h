//
//  ObjcFuncBridge.h
//  TapirLib
//
//  Created by Jimin Jeon on 1/23/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#ifndef TapirLib_ObjcFuncBridge_h
#define TapirLib_ObjcFuncBridge_h

namespace Tapir {
//    
    template <typename F> class ObjcFuncBridge;
    
    template <typename _R, typename... _Args>
    class ObjcFuncBridge<_R(_Args...)>
    {
    public:
        typedef _R (*func)(id, SEL, _Args...);
        
        ObjcFuncBridge(SEL sel, id obj)
        :m_sel(sel),
        m_obj(obj),
        m_func((func)[m_obj methodForSelector:sel])
        { };
        
        inline _R operator ()(_Args... args)
        {
            return m_func(m_obj, m_sel, args...);
        }
        
    protected:
        SEL m_sel;
        id m_obj;
        func m_func;
    };
    
    
    
    
};


#endif
