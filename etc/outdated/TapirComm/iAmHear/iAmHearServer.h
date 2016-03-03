//
//  iAmHearServer.h
//  iAmHear
//
//  Created by Seunghun Kim on 8/13/11.
//  Copyright 2011 KAIST. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/socket.h>
#import <sys/stat.h>
#import <arpa/inet.h>

@interface iAmHearServer : NSObject {
    int server_sockfd;
	int senderfd;
    
    int sockfd;
    
    int state;
    int state_server;
    
}

- (void)initServer;
-(void)checkSocket:(NSTimer*)timer;
-(int)getState;
@end
