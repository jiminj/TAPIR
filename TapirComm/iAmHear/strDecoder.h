//
//  strDecoder.h
//  iAmHear
//
//  Created by Seunghun Kim on 9/4/12.
//  Copyright (c) 2012 KAIST. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface strDecoder : NSObject{
    char str[5];
    int check;
}

- (void) setStr:(char*) t;
- (char) getStr;
- (int) getCheck;
- (void) setCheck;
@end
