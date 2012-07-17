//
//  MWAppDelegate.m
//  ButtonInsetsPlayground
//
//  Created by Michael Weller on 17.07.12.
//  Copyright (c) 2012 Michael Weller. All rights reserved.
//

#import "MWAppDelegate.h"
#import "MWViewController.h"

@implementation MWAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	self.window.rootViewController = [[MWViewController alloc] init];
	[self.window makeKeyAndVisible];
	return YES;
}

@end
