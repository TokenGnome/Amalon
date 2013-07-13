//
//  AppDelegate.m
//  Amalon iOS Example
//
//  Created by Brandon Smith on 7/12/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import "AppDelegate.h"
#import <Amalon/Avalon.h>
#import <Amalon/AbstractDecider.h>

@implementation AppDelegate

- (void)runSampleGameWithPlayerCount:(NSUInteger)size variant:(AvalonGameVariant)variant
{
    AvalonGameController *controller = [AvalonGameController new];
    controller.engine = [AvalonEngine engine];
    controller.engine.delegate = controller;
    controller.bot = [AbstractDecider new];
    
    //controller.bot = [JavaScriptDecider deciderWithScript:BundledScript(@"simple_bot")];
    
    AvalonGame *g = [AvalonGame gameWithVariant:variant];
    for (int i = 1; i <= size; i++) {
        AvalonPlayer *p = [AvalonPlayer playerWithId:[NSString stringWithFormat:@"BOT %d", i]];
        [g addPlayer:p];
    }
    while (! [g isFinished]) {
        [controller.engine step:g];
    }
    [controller.engine step:g];
    
    BOOL goodWin = (g.passedQuestCount > g.failedQuestCount) && (g.assassinatedPlayer.role.type != AvalonRoleMerlin);
    
    NSMutableDictionary *results = [NSMutableDictionary new];
    
    for (AvalonPlayer *p in g.players) {
        if (!results[p.playerId]) results[p.playerId] = [NSMutableDictionary new];
        NSMutableDictionary *roles = results[p.playerId];
        
        if (!roles[p.role.name]) results[p.playerId][p.role.name] = [NSMutableDictionary dictionaryWithDictionary:@{@"wins": @(0), @"total" : @(0)}];
        NSMutableDictionary *role = results[p.playerId][p.role.name];
        
        if (((p.role.type & AvalonRoleGood) && goodWin) || ((p.role.type & AvalonRoleEvil) && !goodWin)) {
            results[p.playerId][p.role.name][@"wins"] = @([role[@"wins"] intValue] + 1);
        }
        results[p.playerId][p.role.name][@"total"] = @([role[@"total"] intValue] + 1);
    }
    
    NSLog(@"%@", results);
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self runSampleGameWithPlayerCount:10 variant:AvalonVariantDefault];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
