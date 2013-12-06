//
//  LKBiquadHPF.m
//  TapirLib
//
//  Created by dilu on 11/29/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import "LKBiquadHPF.h"

@implementation LKBiquadHPF

-(id)init{
    if(self=[super init]){
        x1 = 0;
        x2 = 0;
        y1 = 0;
        y2 = 0;
        lastSample = 0;
    }
    return self;
}
-(float)next:(float)sample{

    y2 = y1;
    y1 = lastSample;
    lastSample = 0.017*sample -0.017*x2 -1.055*y1 - 0.967*y2;
    x2 = x1;
    x1 = sample;

    return lastSample;
}

@end
