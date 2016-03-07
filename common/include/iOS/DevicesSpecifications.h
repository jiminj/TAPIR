//
//  TapirFreqOffset.h
//  TapirLib
//
//  Created by Jimin Jeon on 1/25/14.
//  Copyright (c) 2014 Jimin Jeon. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sys/types.h>
#include <sys/sysctl.h>

@interface DevicesSpecifications : NSObject

+ (NSString *)getPlatform;
+ (NSString *)getPlatformInfo:(NSString *)platform;
+ (float) getTransmitterFreqOffset;
+ (float) getTransmitterFreqOffsetUsingBuiltInSpeaker;
+ (float) getReceiverFreqOffset;
+ (float) getThreshold;

@end
