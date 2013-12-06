//
//  LKBiquadHPF.h
//  TapirLib
//
//  Created by dilu on 11/29/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LKBiquadHPF : NSObject{
    int index;
    int lastIndex;
    float max;
    float lastSample;
    float x1;
    float x2;
    float y1;
    float y2;
}
-(float)next:(float)sample;
@end
