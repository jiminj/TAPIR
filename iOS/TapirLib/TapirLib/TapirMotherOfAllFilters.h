//
//  TapirMotherOfAllFilters.h
//  TapirLib
//
//  Created by dilu on 11/26/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>

#import "TapirLib.h"

@interface TapirMotherOfAllFilters : NSObject{
    int length;
    float* buffer;
    float* coefficients;
}
+(id)createHPF1;
-(id)initWithLength:(int)l;
-(void)setCoef:(float*)values length:(int)length;
-(void)next:(float)newValue writeTo:(float*)destination;
@end
