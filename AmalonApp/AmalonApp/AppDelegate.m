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

@implementation AppDelegate

- (void)testRun
{
    AvalonEngine *engine = [AvalonEngine engine];
    AvalonGame *game = [AvalonEngine newGame];
    
    [engine addPlayer:@"Player1" toGame:game decider:[AbstractDecider deciderWithId:@"Player1"]];
    [engine addPlayer:@"Player2" toGame:game decider:[AbstractDecider deciderWithId:@"Player2"]];
    [engine addPlayer:@"Player3" toGame:game decider:[AbstractDecider deciderWithId:@"Player3"]];
    [engine addPlayer:@"Player4" toGame:game decider:[AbstractDecider deciderWithId:@"Player4"]];
    [engine addPlayer:@"Player5" toGame:game decider:[AbstractDecider deciderWithId:@"Player5"]];
    [engine addPlayer:@"Player6" toGame:game decider:[AbstractDecider deciderWithId:@"Player6"]];
    [engine addPlayer:@"Player7" toGame:game decider:[AbstractDecider deciderWithId:@"Player7"]];
    
    [engine runGame:game withVariant:AvalonVariantNoOberon];
    
    NSLog(@"Good: %d | Evil: %d", game.passedQuestCount, game.failedQuestCount);
    NSLog(@"Outcome:\n\t%@", [game.quests componentsJoinedByString:@"\n\t"]);
    NSLog(@"Assassinated player: %@", game.assassinatedPlayer);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self testRun];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
