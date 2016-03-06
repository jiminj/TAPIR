//
//  LKSimpleBitlyMagic.m
//  TapirLib
//
//  Created by dilu on 12/8/13.
//  Copyright (c) 2013 Jimin Jeon. All rights reserved.
//

#import "LKBitlyUrlShortener.h"
#import "AFNetworking.h"

@interface LKBitlyUrlShortener ()
{
    NSString * kBitlyAccessToken;
}
@property NSString * kBitlyAccessToken;
@end

@implementation LKBitlyUrlShortener
@synthesize delegate;
@synthesize kBitlyAccessToken;

- (id)init
{
    if(self = [super init])
    {
        kBitlyAccessToken = @"***REMOVED***";
    }
    return self;
}

-(void)shortenUrl:(NSString *)original{
    AFHTTPSessionManager * sessionManager = [AFHTTPSessionManager manager] ;
    [sessionManager GET:[NSString stringWithFormat:@"https://api-ssl.bitly.com/v3/shorten?access_token=%@&longUrl=%@", [self kBitlyAccessToken], original]
             parameters:nil
               progress:nil
                success:^(NSURLSessionTask *task, id responseObject) {
                      NSDictionary* responseData = [(NSDictionary*)responseObject objectForKey:@"data"];
                      [delegate didFinishBitlyConvertFrom:[responseData objectForKey:@"long_url"] to:[responseData objectForKey:@"url"] by:self];
        
                }
                failure:^(NSURLSessionTask *operation, NSError *error) {
                      [delegate didFinishBitlyConvertFrom:original to:@"" by:self];
                }];

}

-(void)getOriginalUrl:(NSString *)original{
    AFHTTPSessionManager* sessionManager = [[AFHTTPSessionManager alloc] init];
    [sessionManager GET:[NSString stringWithFormat:@"https://api-ssl.bitly.com/v3/expand?access_token=%@&shortUrl=%@", [self kBitlyAccessToken], original]
             parameters:nil
               progress:nil
                success:^(NSURLSessionTask *task, id responseObject) {
                      NSDictionary* responseData = [(NSDictionary*)responseObject objectForKey:@"data"];
                      [delegate didFinishBitlyConvertFrom:[responseData objectForKey:@"short_url"] to:[responseData objectForKey:@"long_url"] by:self];
                }
                failure:^(NSURLSessionTask *task, NSError *error) {
                      [delegate didFinishBitlyConvertFrom:original to:@""  by:self];
                }];
}

@end
