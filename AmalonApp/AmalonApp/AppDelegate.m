//
//  AppDelegate.m
//  AmalonApp
//
//  Created by Brandon Smith on 7/6/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import "AppDelegate.h"
#import "AvalonEngine.h"
#import "AvalonGame.h"
#import "AbstractDecider.h"

#import "ReplayViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    ReplayViewController *gvc = [[ReplayViewController alloc] initWithNibName:nil bundle:nil];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:gvc];
    self.window.rootViewController = nav;
    
    [self.window makeKeyAndVisible];
    return YES;
}

@end
