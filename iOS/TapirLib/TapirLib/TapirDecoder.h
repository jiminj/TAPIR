//
//  TapirViterbi.h
//  TapirLib
//
//  Created by Jimin Jeon on 11/27/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>
#import "TapirTrellisCode.h"

@protocol TapirDecoder <NSObject>

- (void)decode:(const float *)src dest:(int *)dest srcLength:(const int)srcLength;

@end

typedef struct _TapirViterbiNode
{
    struct _TapirViterbiNode * prevNode;
    int prevChoosedValue;
    int * outputValue;
    
} TapirViterbiNode;

@interface TapirViterbiDecoder : NSObject <TapirDecoder>
{
    int ** nextStateRouteTable;
    int ** outputTable;

    int noTrellis; //No. of trellis code used
    int noRegisterBits; // No. of register bits in Trellis Code (constraint Length - 1)
    int noStates; // No. of states enabled
    int noInfoTableCols; // Number of cases for input, obviously should be 2

//    int ** routeTable;
//    int ** trackInfoTable;
//    
//    TapirViterbiNode ** node;
    
}

//- (void)genTables:(NSMutableArray *)trellisArray;
- (id)initWithTrellisArray:(NSMutableArray *)trellisArray;
- (int)encodingRate;

@end
