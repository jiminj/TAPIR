//
//  LKSimpleBitlyMagic.m
//  TapirLib
//
//  Created by dilu on 12/8/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import "LKSimpleBitlyMagic.h"
#import "AFNetworking.h"

#define MY_PRECIOUS_SOURCE_OF_MANA @"***REMOVED***"

@implementation LKSimpleBitlyMagic
@synthesize delegate;

-(void)bottleMagic:(NSString *)original{
    AFHTTPRequestOperationManager* operationManager = [AFHTTPRequestOperationManager manager] ;
    [operationManager GET:[NSString stringWithFormat:@"https://api-ssl.bitly.com/v3/shorten?access_token=%@&longUrl=%@", MY_PRECIOUS_SOURCE_OF_MANA, original] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* responseData = [(NSDictionary*)responseObject objectForKey:@"data"];
        [delegate magic:BITLY_MAGIC_BOTTLE transformed:[responseData objectForKey:@"long_url"] into:[responseData objectForKey:@"url"] by:self];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [delegate magic:BITLY_MAGIC_BOTTLE failedToTransform:original  by:self];
    }];
}

-(void)cakeMagic:(NSString *)original{
    AFHTTPRequestOperationManager* operationManager = [[AFHTTPRequestOperationManager alloc] init];
    [operationManager GET:[NSString stringWithFormat:@"https://api-ssl.bitly.com/v3/expand?access_token=%@&shortUrl=%@", MY_PRECIOUS_SOURCE_OF_MANA, original] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* responseData = [(NSDictionary*)responseObject objectForKey:@"data"];
        [delegate magic:BITLY_MAGIC_CAKE transformed:[responseData objectForKey:@"short_url"] into:[responseData objectForKey:@"long_url"]  by:self];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [delegate magic:BITLY_MAGIC_CAKE failedToTransform:original  by:self];
    }];
}

@end
