//
//  strDecoder.m
//  iAmHear
//
//  Created by Seunghun Kim on 9/4/12.
//  Copyright (c) 2012 KAIST. All rights reserved.
//

#import "strDecoder.h"

@implementation strDecoder

- (void) setStr:(char*) t{
    for(int i = 0; i < 6; ++i){
        str[i] = t[i+4];
    }
    
    bool tmp = true;
 //   NSLog(@"%s",str);
    for(int i = 0; i < 6; ++i){
        if(str[i] == '0'){
            tmp = false;
        }
    }
    
    if(check == 0 && tmp == true){
        check = 1;
    }
    else if(check != 0){
        ++check;
    }
   
    
}
- (void) setCheck{
    check = 0;
}
- (int) getCheck{
    return check;
}
- (char) getStr{
    if(check < 7){
        return ',';
    }
    else{
        int k = 1;
        int sum = 0;
        char result = ',';
        for(int i = 5; i >= 1; --i){
            sum = sum + k*(str[i] - '0');
            k *= 2;
        }
        
        if(sum <= 26){
            if(str[0] == '1')
                result = sum - 1 + 'a';
            else
                result = sum - 1 + 'A';
        }
        if(str[0] == '0'){
        if(sum == 27){
            result = ':';
        }
        else if(sum == 28){
            result = '~';
        }
        else if(sum == 29){
            result = '/';
        }
        else if(sum == 30){
            result = '.';
        }
        else if(sum == 31){
            result = '-';
        }
        }
        if(str[0] == '1' && sum == 31){
            result = ',';
        }
        if(sum != 0)
            check = 1;
        else{
            result = ',';
            check = 0;
        }
        
        return result;
    }
}


@end
