//
//  iAmHearGraph.h
//  iAmHear
//
//  Created by Seunghun Kim on 9/2/12.
//  Copyright (c) 2012 KAIST. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface iAmHearGraph : UIView{

    double vals[30];
    double threshold;
}

-(void) setVals:(double*) val;
-(void) setThreshold:(double) val;

@end
