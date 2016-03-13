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
    NSString * bitlyAccessToken;
}
@property NSString * bitlyAccessToken;
@end

@implementation LKBitlyUrlShortener
@synthesize delegate;
@synthesize bitlyAccessToken;

- (id)init
{
    if(self = [super init])
    {
        //You should write your own Key.plist file including your bitly access token.
        //the format can be refered to Key_format.plist.
        NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Key" ofType:@"plist"]];
        bitlyAccessToken = [dictionary objectForKey:@"Key"];
//
    }
    return self;
}

-(void)shortenUrl:(NSString *)original{
    AFHTTPSessionManager * sessionManager = [AFHTTPSessionManager manager] ;
    [sessionManager GET:[NSString stringWithFormat:@"https://api-ssl.bitly.com/v3/shorten?access_token=%@&longUrl=%@", [self bitlyAccessToken], original]
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
    [sessionManager GET:[NSString stringWithFormat:@"https://api-ssl.bitly.com/v3/expand?access_token=%@&shortUrl=%@", [self bitlyAccessToken], original]
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
