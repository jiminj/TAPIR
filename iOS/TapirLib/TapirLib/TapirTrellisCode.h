//
//  TapirTrellisCode.h
//  TapirLib
//
//  Created by Jimin Jeon on 11/29/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TapirTrellisCode : NSObject
{
    int g;
    float * encodedCode;
    int length;
}
- (void)encode: (int) _g;
- (id)initWithG: (int)_g;
- (void)extendTo : (int)extLength;
- (int)getBitsAsInteger;
- (void)test;


@property int length;
@property float * encodedCode;

@end