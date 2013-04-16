//
//  iAmHearGraph.m
//  iAmHear
//
//  Created by Seunghun Kim on 9/2/12.
//  Copyright (c) 2012 KAIST. All rights reserved.
//

#import "iAmHearGraph.h"

@implementation iAmHearGraph

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        for(int i = 0; i < 30; ++i){
            vals[i] = 0;
        }
        threshold = 0.01;
    }
    return self;
}

-(void) setVals:(double*) val
{
    for(int i = 0; i < 10; ++i){
        vals[9-i] = val[i];
    }
   
}

-(void) setThreshold:(double) val
{
    threshold = val;
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context    = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    
    // Draw them with a 2.0 stroke width so they are a bit more visible.
    CGContextSetLineWidth(context, 2.0);
    
    CGContextMoveToPoint(context, 250,190); //start at this point
    
    for(int i = 0; i < 10; ++i){
        CGContextAddLineToPoint(context, 250.0 - i/10.0*250.0 - 15.0, 190 - vals[i]/(threshold*2)*190);
        CGContextMoveToPoint(context, 250.0 - i/10.0*250.0 - 15.0, 190 - vals[i]/(threshold*2)*190);
    }
    CGContextAddLineToPoint(context, 0, 190);
    
    CGContextStrokePath(context);
    
    context    = UIGraphicsGetCurrentContext();

    
    CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
    
    float dash[2]={6 ,5}; // pattern 6 times “solid”, 5 times “empty”
    
    CGContextSetLineDash(context,0,dash,2);
    
    CGContextMoveToPoint(context, 250,190-0.002/0.008*190); //start at this point
    
    CGContextAddLineToPoint(context, 0,190-0.002/0.008*190);
    
    float normal[1]={1};
    CGContextSetLineDash(context,0,normal,0);
    
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    
    // and now draw the Path!
    CGContextStrokePath(context);
    

}


@end
