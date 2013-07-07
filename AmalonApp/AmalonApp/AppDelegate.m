//
//  AppDelegate.m
//  AmalonApp
//
//  Created by Brandon Smith on 7/6/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import "AppDelegate.h"
#import "Avalon.h"
#import "AvalonEngine.h"
#import "AvalonGame.h"
#import "AvalonPlayer.h"
#import "AbstractDecider.h"
#import "JavaScriptDecider.h"

#import "ReplayViewController.h"

#import <JavaScriptCore/JavaScriptCore.h>
#import "AvalonJSExports.h"

NSString *BundledScript(NSString *nameWithoutExtension)
{
    NSString *script = [[NSBundle mainBundle] pathForResource:nameWithoutExtension ofType:@"js"];
    return [NSString stringWithContentsOfFile:script encoding:NSUTF8StringEncoding error:nil];
};

@implementation AppDelegate

- (void)runSampleGame
{
    AvalonEngine *e = [AvalonEngine engine];
    AvalonGame *g = [AvalonEngine newGame];
        
    JavaScriptDecider *j = [JavaScriptDecider deciderWithId:@"JSBot" script:BundledScript(@"random_bot")];
    [e addPlayer:@"JSBot" toGame:g decider:j];
    
    [e addPlayer:@"Bot 1" toGame:g decider:[AbstractDecider deciderWithId:@"Bot 1"]];
    [e addPlayer:@"Bot 2" toGame:g decider:[AbstractDecider deciderWithId:@"Bot 2"]];
    [e addPlayer:@"Bot 3" toGame:g decider:[AbstractDecider deciderWithId:@"Bot 3"]];
    [e addPlayer:@"Bot 4" toGame:g decider:[AbstractDecider deciderWithId:@"Bot 4"]];
    
    [e startGame:g withVariant:AvalonVariantDefault];
    
    while (! [g isFinished]) {
        [e step:g];
    }
    
    NSLog(@"%@", [j dumpState:g]);
}

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

@implementation NSArray (AvalonJSON)
- (id)toJSON
{
    NSMutableArray *arr = [NSMutableArray new];
    for (id obj in self) {
        if ([obj respondsToSelector:@selector(toJSON)]) {
            [arr addObject:[obj toJSON]];
        }
    }
    return [NSArray arrayWithArray:arr];
}
@end

@implementation NSDictionary (AvalonJSON)
- (id)toJSON
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    for (NSString *key in self.allKeys) {
        if ([key isKindOfClass:[NSString class]] && [self[key] respondsToSelector:@selector(toJSON)]) {
            dict[key] = [self[key] toJSON];
        }
    }
    return [NSDictionary dictionaryWithDictionary:dict];
}
@end