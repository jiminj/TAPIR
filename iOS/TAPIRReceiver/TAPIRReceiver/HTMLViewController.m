//
//  HTMLViewController.m
//  TAPIRReceiver
//
//  Created by dilu on 2/9/14.
//  Copyright (c) 2014 dilu. All rights reserved.
//

#import "HTMLViewController.h"

@interface HTMLViewController ()

@end

@implementation HTMLViewController
@synthesize htmlPageName;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    webView.allowsInlineMediaPlayback = YES;
    webView.mediaPlaybackRequiresUserAction = NO;
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:htmlPageName]]];
    //NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    //[webView loadHTMLString:htmlString baseURL:nil];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortraitUpsideDown;
}

@end
