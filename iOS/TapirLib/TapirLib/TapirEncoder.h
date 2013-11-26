//
//  TapirEncoder.h
//  TapirLib
//
//  Created by Jimin Jeon on 11/25/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>

@interface TrellisCode : NSObject
{
    int g;
    float * encodedCode;
    int length;
}
- (void) encode: (int) _g;
- (id)initWithG: (int)_g;
- (void)extendTo : (int)extLength;
@property int length;
@property float * encodedCode;

@end


@protocol TapirEncoder <NSObject>

- (void)encode:(const float *)src dest:(float *)dest srcLength:(const int)srcLength;
- (void)decode:(const float *)src dest:(float *)dest;

@end


@interface TapirConvEncoder : NSObject <TapirEncoder>
{
    NSMutableArray * trelCodeArr;
    int trelCodeLen;
}
- (id)init;
- (id)initWithTrellisCode:(TrellisCode *)code;
- (id)initWithTrellisG:(const int)trellisG;
- (id)initWithTrellisArray : (const NSMutableArray *)trelArray;

- (void)addTrellisCode:(TrellisCode *)code;
- (void)addTrellisCodeWithG:(const int)g;
- (void)addTrellisCodeWithTrellisArray:(const NSMutableArray *)trelArray;

- (void)clearTrellisCode;
- (float)getEncodingRate;

@property NSMutableArray * trelCodeArr;
@end