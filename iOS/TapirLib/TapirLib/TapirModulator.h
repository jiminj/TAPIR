//
//  TapirModulator.h
//  TapirLib
//
//  Created by Jimin Jeon on 11/19/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>

@protocol TapirModulator <NSObject>

@required
-(void)modulate:(const float *)source dest:(DSPSplitComplex *) dest length:(const int)length;
-(void)demodulate:(const DSPSplitComplex *)source dest:(float *)dest length:(const int)length;

@end


@interface TapirPskModulator : NSObject <TapirModulator>
{
    int symbolRate;
    float initialPhase;
    float magnitude;
}
-(id)init;
-(id)initWithSymbolRate:(int)_symbolRate;
-(id)initWithSymbolRate:(int)_symbolRate initPhase:(float)_initPhase;
-(id)initWithSymbolRate:(int)_symbolRate initPhase:(float)_initPhase magnitude:(float)_magnitude;

@property int symbolRate;
@property float initialPhase;
@property float magnitude;
@end

@interface TapirDpskModulator : TapirPskModulator <TapirModulator>

@end