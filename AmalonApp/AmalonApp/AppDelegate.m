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
#import "AvalonRole.h"
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

@interface AppDelegate ()
@property (nonatomic, strong) NSMutableDictionary *results;
@property (nonatomic, strong) AvalonEngine *engine;
@property (nonatomic, assign) NSUInteger goodWins;
@property (nonatomic, assign) NSUInteger evilWins;
@end

@implementation AppDelegate

- (void)runSampleGame:(id<AvalonDecider>)bot playerCount:(NSUInteger)size variant:(AvalonGameVariant)variant
{
    AvalonEngine *e = self.engine;
    AvalonGame *g = [AvalonGame new];
    
    AbstractDecider *rnd = [AbstractDecider new];
        
    for (int i = 1; i <= size; i++) {
        id<AvalonDecider> d = (i % 2 == 0) ? bot : bot;
        [e addPlayer:[NSString stringWithFormat:@"%@ %d", (i%2 == 0) ? @"RND" : @"SMP", i] toGame:g decider:d];
    }
    [e startGame:g withVariant:variant];
    
    while (! [g isFinished]) {
        [e step:g];
    }
    [e step:g];
    
    BOOL goodWin = (g.passedQuestCount > g.failedQuestCount) && (g.assassinatedPlayer.role.type != AvalonRoleMerlin);
    goodWin ? self.goodWins++ : self.evilWins++;
    
    for (AvalonPlayer *p in g.players) {
        if (!self.results[p.playerId]) self.results[p.playerId] = [NSMutableDictionary new];
         NSMutableDictionary *roles = self.results[p.playerId];
        
        if (!roles[p.role.name]) self.results[p.playerId][p.role.name] = [NSMutableDictionary dictionaryWithDictionary:@{@"wins": @(0), @"total" : @(0)}];
        NSMutableDictionary *role = self.results[p.playerId][p.role.name];
        
        if (((p.role.type & AvalonRoleGood) && goodWin) || ((p.role.type & AvalonRoleEvil) && !goodWin)) {
            self.results[p.playerId][p.role.name][@"wins"] = @([role[@"wins"] intValue] + 1);
        }
        self.results[p.playerId][p.role.name][@"total"] = @([role[@"total"] intValue] + 1);
    }
    
}

- (void)runAllGames
{
    self.engine = [AvalonEngine engine];
    JavaScriptDecider *bot = [JavaScriptDecider deciderWithScript:BundledScript(@"simple_bot")];
    
    NSArray *vars = @[@(AvalonVariantDefault), @(AvalonVariantPercival), @(AvalonVariantMorgana), @(AvalonVariantMordred), @(AvalonVariantNoOberon)];
    NSString *result = @"";

    for (int numPlayers = 5; numPlayers < 11; numPlayers++) {
        for (NSNumber *var in vars) {
            self.results = [NSMutableDictionary new];
            for (int i = 1; i <= 100; i++) {
                @autoreleasepool {
                    [self runSampleGame:bot playerCount:numPlayers variant:[var intValue]];
                }
            }

            for (NSString *pid in self.results.allKeys) {
                for (NSString *role in [self.results[pid] allKeys]) {
                    result = [result stringByAppendingFormat:
                              @"%@, %d, %@, %@, %@, %@\n",
                              var, numPlayers, pid, role, self.results[pid][role][@"wins"], self.results[pid][role][@"total"]];
                }
            }
        }
    }
    
    NSLog(@"\n%@", result);
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
//    self.engine = [AvalonEngine engine];
//    [self runSampleGame:[JavaScriptDecider deciderWithScript:BundledScript(@"simple_bot")] playerCount:10 variant:AvalonVariantDefault];
    
    ReplayViewController *gvc = [[ReplayViewController alloc] initWithStyle:UITableViewStylePlain];
    
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

@implementation NSObject (AvalonJSON)
- (id)toJSON
{
    return [self description];
}

@end
