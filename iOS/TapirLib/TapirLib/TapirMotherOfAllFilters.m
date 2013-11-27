//
//  TapirMotherOfAllFilters.m
//  TapirLib
//
//  Created by dilu on 11/26/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import "TapirMotherOfAllFilters.h"
#import <Accelerate/Accelerate.h>

@implementation TapirMotherOfAllFilters
-(id)initWithLength:(int)l{
    if(self=[super init]){
        length = l;
        buffer = malloc(sizeof(float)*l);
        coefficients = malloc(sizeof(float)*l);
        for(int i = 0; i<l; i++){
            buffer[i]=coefficients[i]=0;
        }
    }
    return self;
}

-(void)setCoef:(float *)values length:(int)l{
    for(int i = 0; i<l; i++){
        coefficients[i] = values[i];
    }
}
-(void)next:(float)newValue writeTo:(float *)destination{
    for(int i = 1; i<length; i++){
        buffer[i-1]=buffer[i];
    }
    buffer[0]=newValue;
    vDSP_dotpr(buffer,1,coefficients,1,destination,length);
}
@end
