//
//  TapirViterbi.m
//  TapirLib
//
//  Created by Jimin Jeon on 11/27/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import "TapirDecoder.h"

//@implementation TapirViterbiNode
//@synthesize prevNode, outputValue, choosedRoute;
//
//@end

@interface TapirViterbiDecoder()

- (void) genNextStatusTable;
- (void) genOutputTableWith:(NSArray *)trellisArray;
- (void) genTables:(NSArray *)trellisArray;

- (int) calHammingDistance:(int)a with:(int)b;

@end

@implementation TapirViterbiDecoder

-(id)init
{
    return nil;
}

- (id)initWithTrellisArray:(NSArray *)trellisArray
{
    if(self = [super init])
    {
        [self genTables:trellisArray];
    }
    return self;
}

- (int)encodingRate
{
    return noTrellis;
}

-(void)dealloc
{
    
    if(nextStateRouteTable != NULL)
    {
        for(int i=0; i<noStates; ++i)
        {
            if(nextStateRouteTable[i] != NULL)
            { free(nextStateRouteTable[i]); }
        }
        free(nextStateRouteTable);
    }
    
    if(outputTable != NULL)
    {
        for(int i=0; i<noStates; ++i)
        {
            if(outputTable[i] != NULL)
            { free(outputTable[i]); }
        }
        free(outputTable);
    }
    
}

- (void) genNextStatusTable;
{

    nextStateRouteTable = malloc(sizeof(int *) * noStates);

    for(int i=0; i< noStates; ++i)
    {
        
        nextStateRouteTable[i] = malloc(sizeof(int) * noInfoTableCols );
        //set Next Route Path;
        // e.g. 0011 => 0001 (When next input is zero) => 0011 (When next input is one);
        
        for(int j=0; j<noInfoTableCols; ++j)
        {
            nextStateRouteTable[i][j] = (i >> 1) | (j << (noRegisterBits-1));
        }
    }

}


- (void)genOutputTableWith:(NSArray *)trellisArray;
{
    outputTable = malloc(sizeof(int *) * noStates);
    noTrellis = (int)[trellisArray count];
    
    for(int row=0; row<noStates; ++row)
    {
        outputTable[row] = calloc(noInfoTableCols, sizeof(int));
        for(int col=0; col<noInfoTableCols; ++col)
        {
//            int loc = noTrellis;
            for(int idxTrel=0; idxTrel<noTrellis; ++idxTrel)
            {
                int encoded = [[trellisArray objectAtIndex:idxTrel] getBitsAsInteger] & ( row | ( col << noRegisterBits)) ;
                // e.g.) no of Register :2, curState : 10 => for input 0 : 000 | trel
                //                                        => for input 1 : 100 | trel
                
                int bitsXorResult = encoded & 1; //assign a last bit of result
                while(encoded != 0)
                {
                    encoded >>= 1;
                    bitsXorResult = (encoded & 1) ^ (bitsXorResult & 1);
                }
                outputTable[row][col] += bitsXorResult << (noTrellis - idxTrel - 1);
            }
        }
    }

}


- (void)genTables:(NSArray *)trellisArray
{
    //Assume that all trellis codes have same length
    noRegisterBits = [[trellisArray objectAtIndex:0] length] - 1;
    noStates = 1 << (noRegisterBits);
    noInfoTableCols = 2;
    
    [self genNextStatusTable];
    [self genOutputTableWith:trellisArray];
}



- (int)calHammingDistance:(int)a with:(int)b
{
    int retVal = 0;
    while( (a != 0) || (b != 0) )
    {
        retVal += ((a & 1) ^ (b & 1));
        a >>= 1;
        b >>= 1;
    }
    return retVal;
}

- (void)decode:(const float *)src dest:(int *)dest srcLength:(const int)srcLength
{
    [self decode:src dest:dest srcLength:srcLength extLength:0];
}

- (void)decode:(const float *)src dest:(int *)dest srcLength:(const int)srcLength extLength:(const int)extTbLength
{
    
    //Make input blocks (bind noTrellis blocks to one block)
    int * intSrc = malloc(sizeof(int) * srcLength);
    vDSP_vfix32(src, 1, intSrc, 1, srcLength);
    
    int outputLength = srcLength / noTrellis;
    int inputLength = outputLength + extTbLength;
    int * input = calloc(inputLength, sizeof(int));
    
    for(int i=0; i<inputLength - extTbLength; ++i)
    {
        int srcLoc = i * noTrellis;
        for(int j=0; j<noTrellis; ++j)
        {
            input[i] += (intSrc[srcLoc + j] & 1) << (noTrellis - j - 1);
        }
    }
    free(intSrc);

    // allocte a weight table and a tracking information table
    int ** weightTable = malloc(sizeof(int *) * noStates);
    int ** trackInfoTable = malloc(sizeof(int *) * noStates);
    int ** selectionTable = malloc(sizeof(int *) * noStates);
    
//    int tableCols = inputLength + 1; // add one more col for initial status
    
    for(int i=0; i<noStates; ++i)
    {
        weightTable[i] = malloc(sizeof(int) * inputLength + 1);
        trackInfoTable[i] = malloc(sizeof(int) * inputLength);
        selectionTable[i] = malloc(sizeof(int) * inputLength);
        
        for(int j=0; j<inputLength; ++j)
        {
            weightTable[i][j] = -1;
            trackInfoTable[i][j] = -1;
            selectionTable[i][j] = -1;
        }
        weightTable[i][inputLength] = -1;
    }
    
    
    // Weight Table
    //              0   1   2   3   => steps
    //      --------------------
    //      0   |    0  0   ..
    //      1   |   -1  -1
    //      2   |   -1  3
    //      3   |   -1  -1
    //     ...  |   ..
    //  (states)|
    

    weightTable[0][0] = 0; //Always starts at 0
    //var inputLength is equal to (tableLength - 1)
    for(int step = 0; step < inputLength; ++step) // For each step
    {
        int nextStep = step + 1;
        for(int curState=0; curState < noStates; ++curState) // For every state element in a same col
        {
            int curWeight = weightTable[curState][step];
            if( curWeight != -1)
            {
                for(int i=0; i < noInfoTableCols; ++i)
                {
                    int nextState = nextStateRouteTable[curState][i]; //search next State Table
                    int newWeight = curWeight + [self calHammingDistance:input[step] with:outputTable[curState][i]];
//                    NSLog(@"step %d state %d to %d ==== input:%d, curWeight:%d, newWeight:%d", step, curState, nextState, input[step], curWeight, nextWeight);
                    if( (weightTable[nextState][nextStep] == -1 ) || (weightTable[nextState][nextStep] > newWeight) )
                    {
                        //replace when the next state value is unsetted or bigger than current weight
                        weightTable[nextState][nextStep] = newWeight;
                        trackInfoTable[nextState][step] = curState;
                        selectionTable[nextState][step] = i; //0 or 1
                    }
                }
            }
        }
    }
    
    int minRouteIdx = 0;
    int minValue = inputLength * 2; //maximum hamming distance;
    
    //Search minimum value at last step
    for(int i=0; i<noStates; ++i)
    {
        int curStateVal = weightTable[i][inputLength];
        if( (curStateVal != -1) && (curStateVal < minValue) )
        {
            minRouteIdx = i;
            minValue = curStateVal;
        }
    }

    int * tbResult = malloc(sizeof(int) * inputLength);

    //Backtrack
//    NSLog(@"minStartingPoint : %d", minRouteIdx);
    for(int i=inputLength-1; i >= 0; --i)
    {
//        dest[i] = selectionTable[minRouteIdx][i];
        tbResult[i] = selectionTable[minRouteIdx][i];
        minRouteIdx = trackInfoTable[minRouteIdx][i];
    }
    
    memcpy(dest, tbResult, sizeof(int) * outputLength);
    
//
// ======== DUMP ===========
//    
//    NSMutableString * nsTableView = [[NSMutableString alloc] initWithFormat:@"\n==Next State Table== \n"];
//    NSMutableString * outputTableView = [[NSMutableString alloc] initWithFormat:@"\n==Output Table== \n"];
//    for(int i=0; i<noStates; ++i)
//    {
//        int * nTemp = nextStateRouteTable[i];
//        int * oTemp = outputTable[i];
//        [nsTableView appendFormat:@"[%d] => ",i];
//        [outputTableView appendFormat:@"[%d] => ", i];
//        
//        for(int j=0; j<noInfoTableCols; ++j)
//        {
//            [nsTableView appendFormat:@"%d\t",nTemp[j]];
//            [outputTableView appendFormat:@"%d\t",oTemp[j]];
//        }
//        [nsTableView appendFormat:@"\n"];
//        [outputTableView appendFormat:@"\n"];
//    }
//    NSLog(@"%@",nsTableView);
//    NSLog(@"%@",outputTableView);
//    
//    NSMutableString * wTableView = [[NSMutableString alloc] initWithFormat:@"\n==Weight Table== \n"];
//    NSMutableString * rTableView = [[NSMutableString alloc] initWithFormat:@"\n==Route Table == \n"];
//    NSMutableString * sTableView = [[NSMutableString alloc] initWithFormat:@"\n==Selection Table == \n"];
//    for(int i=0; i<noStates; ++i)
//    {
//        int * wTemp = weightTable[i];
//        int * rTemp = trackInfoTable[i];
//        int * sTemp = selectionTable[i];
//        [wTableView appendFormat:@"[%d] => ",i];
//        [rTableView appendFormat:@"[%d] => ",i];
//        [sTableView appendFormat:@"[%d] => ",i];
//        for(int j=0; j<inputLength; ++j)
//        {
//            [wTableView appendFormat:@"%d\t",wTemp[j]];
//            [rTableView appendFormat:@"%d\t",rTemp[j]];
//            [sTableView appendFormat:@"%d\t",sTemp[j]];
//        }
//        [wTableView appendFormat:@"%d\t",wTemp[inputLength]];
//        
//        [wTableView appendFormat:@"\n"];
//        [rTableView appendFormat:@"\n"];
//        [sTableView appendFormat:@"\n"];
//    }
//    NSLog(@"%@", wTableView);
//    NSLog(@"%@", rTableView);
//    NSLog(@"%@", sTableView);
//
//    NSMutableString * inputView = [[NSMutableString alloc] initWithFormat:@"\n==Input== \n"];
//    NSMutableString * resultView = [[NSMutableString alloc] initWithFormat:@"\n==Result== \n"];
//    NSMutableString * outputView = [[NSMutableString alloc] initWithFormat:@"\n==Output==(Length : %d)\n",outputLength];
//    for(int i=0; i<inputLength; ++i)
//    {
//        [inputView appendFormat:@"%d\t", input[i]];
//        [resultView appendFormat:@"%d\t", tbResult[i]];
//    }
//    for(int i=0; i<inputLength; ++i)
//    {
//        [outputView appendFormat:@"%d\t", dest[i]];
//    }
//    
//    NSLog(@"%@",inputView);
//    NSLog(@"%@",resultView);
//    NSLog(@"%@",outputView);
//    
//    NSLog(@"Minimum : %d", minRouteIdx);
//    
    for(int i=0; i< noStates; ++i)
    {
        free(weightTable[i]);
        free(trackInfoTable[i]);
        free(selectionTable[i]);
    }
    free(weightTable);
    free(trackInfoTable);
    free(selectionTable);
    free(tbResult);
//    free(result);
}

@end
