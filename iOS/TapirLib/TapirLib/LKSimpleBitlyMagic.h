//
//  LKSimpleBitlyMagic.h
//  TapirLib
//
//  Created by dilu on 12/8/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import <Foundation/Foundation.h>
#define BITLY_MAGIC_BOTTLE 1
#define BITLY_MAGIC_CAKE 2

@protocol LKSimpleBitlyMagicDelegate <NSObject>
-(void)magic:(int)spellName transformed:(NSString*)original into:(NSString*)result by:(id)caster;
-(void)magic:(int)spellName failedToTransform:(NSString*)original  by:(id)caster;
@end

@interface LKSimpleBitlyMagic : NSObject{
    id<LKSimpleBitlyMagicDelegate> delegate;
}

@property id<LKSimpleBitlyMagicDelegate> delegate;

-(void)bottleMagic:(NSString*)original;
-(void)cakeMagic:(NSString*)original;

@end
