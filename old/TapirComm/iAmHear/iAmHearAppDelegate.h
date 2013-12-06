//
//  iAmHearAppDelegate.h
//  iAmHear
//
//  Created by Luke Kim on 7/15/11.
//  Copyright 2011 KAIST. All rights reserved.
//

#import <UIKit/UIKit.h>

@class iAmHearViewController;

@interface iAmHearAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet iAmHearViewController *viewController;

@end
