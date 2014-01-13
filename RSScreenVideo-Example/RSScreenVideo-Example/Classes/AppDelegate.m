//
//  AppDelegate.m
//  RSScreenVideo-Example
//
//  Created by Austin Borden on 1/12/14.
//  Copyright RareSloth LLC 2014. All rights reserved.
//
// -----------------------------------------------------------------------

#import "AppDelegate.h"
#import "IntroScene.h"

@implementation AppDelegate

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[self setupCocos2dWithOptions:nil];
	
	return YES;
}

-(CCScene *)startScene
{
	// This method should return the very first scene to be run when your app starts.
	return [IntroScene new];
}

@end
