//
//  TapirEncoder.h
//  TapirLib
//
//  Created by Jimin Jeon on 11/25/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>
#import "TapirTrellisCode.h"



@protocol TapirEncoder <NSObject>

- (void)encode:(const int *)src dest:(float *)dest srcLength:(const int)srcLength;

@end


@interface TapirConvEncoder : NSObject <TapirEncoder>
{
    NSArray * trelCodeArr;
    int trellisCodeLength;
}
- (id)initWithTrellisArray : (NSArray *)trelArray;
//- (void)addTrellisCodeWithTrellisArray:(const NSMutableArray *)trelArray;
//- (void)clearTrellisCode;
- (float)getEncodingRate;

@property int trellisCodeLength;
@end