//
//  iAmHearServer.m
//  iAmHear
//
//  Created by Seunghun Kim on 8/13/11.
//  Copyright 2011 KAIST. All rights reserved.
//

#import "iAmHearServer.h"


@implementation iAmHearServer
- (void)initServer{
    
	int client_len;
	struct sockaddr_in serveraddr;
	
    
	
	if((server_sockfd = socket (AF_INET, SOCK_STREAM, 0)) <0){
		perror("socket error : ");
		exit(0);
	}
	
	bzero(&serveraddr, sizeof(serveraddr));
	serveraddr.sin_family = AF_INET;
	serveraddr.sin_addr.s_addr = htonl(INADDR_ANY);
    
	serveraddr.sin_port = htons(1986);
	bind(server_sockfd, (struct sockaddr *)&serveraddr, sizeof(serveraddr));
	
	listen(server_sockfd, 5);
	//[self checkSocket:nil];
    
    state = 0;
    senderfd = 0;
    state_server = 0;
	[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(checkSocket:) userInfo:nil repeats:YES];
    NSLog(@"server init");
}

-(void)checkSocket:(NSTimer*)timer{
	int client_len;
	struct sockaddr_in clientaddr;
	client_len = sizeof(clientaddr);	
	char buf[256];
	
    //[rcvLabel setText:@"server init"];
	//[self checkDisconnection];
    NSLog(@"state_server : %d",state_server);
    if(state_server == 0){
        NSLog(@"checkSocket");
	while(1){
        
        senderfd = accept(server_sockfd, (struct sockaddr *)&clientaddr, &client_len);
		if(senderfd<0){
            NSLog(@"-----------");
			return;
		}else{
			NSLog(@"connected");
			int n;
			if((n = read(senderfd, buf, 256)) <= 0){
                NSLog(@"reading error");
                //NSLog(@"%d",senderfd);
				close(senderfd);
			}else{
                NSLog(@"server received");
                state = 1;
                state_server = 1;
                
			}
            return;
		}
	}
    }
}

-(int)getState{
    int tmp = state;
    state = 0;
    return tmp;
}

@end
