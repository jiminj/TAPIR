//
//  TapirSignalAnalyzer.h
//  TAPIRReceiver
//
//  Created by Jimin Jeon on 12/1/13.
//  Copyright (c) 2013 dilu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>
#import <TapirLib/TapirLib.h>

@interface TapirSignalAnalyzer : NSObject

-(void)analyzeSignal:(const DSPSplitComplex *)signal;

@end
