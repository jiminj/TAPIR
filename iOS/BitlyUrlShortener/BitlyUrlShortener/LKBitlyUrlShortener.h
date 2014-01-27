//
//  LKSimpleBitlyMagic.h
//  TapirLib
//
//  Created by dilu on 12/8/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LKBitlyUrlConverterDelegate <NSObject>
-(void)didFinishBitlyConvertFrom:(NSString*)original to:(NSString*)result by:(id)obj;

@end

@interface LKBitlyUrlShortener : NSObject{
    id<LKBitlyUrlConverterDelegate> delegate;
}

@property id<LKBitlyUrlConverterDelegate> delegate;

-(void)shortenUrl:(NSString*)original;
-(void)getOriginalUrl:(NSString*)original;

@end
