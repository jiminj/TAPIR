//
//  LKVirtualSampleBuffer.h
//  AudioBufferCorrelationTest
//
//  Created by dilu on 11/12/13.
//  Copyright (c) 2013 dilu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LKRealSampleBuffer.h"

// virtual sample buffer
// contains no real data
// refer to a real sample buffer

@interface LKVirtualSampleBuffer : NSObject{
    LKRealSampleBuffer* realBuffer;
    int length;
    int offset;
}
-(id)initWithRealSampleBuffer:(LKRealSampleBuffer*)buffer offSet:(int)offsetValue andLength:(int)lengthValue;
-(float)lastSample;
-(float)sampleAt:(int)index;
@end
