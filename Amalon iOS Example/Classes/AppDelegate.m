//
//  AppDelegate.m
//  Amalon iOS Example
//
//  Created by Brandon Smith on 7/12/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import "AppDelegate.h"
#import <Amalon/Avalon.h>
#import <Amalon/AvalonEngine.h>
#import <Amalon/AvalonMultiBotGameController.h>
#import <Amalon/JavaScriptDecider.h>

NSString *BundledScript(NSString *nameWithoutExtension)
{
    NSString *script = [[NSBundle mainBundle] pathForResource:nameWithoutExtension ofType:@"js"];
    return [NSString stringWithContentsOfFile:script encoding:NSUTF8StringEncoding error:nil];
};

#import "GameCollectionViewController.h"
#import "GameCollectionViewLayout.h"

@interface AppDelegate ()
@end

@interface AMLCollectionViewConfig : NSObject
+ (instancetype)configWithController:(Class)controllerClass layout:(Class)layoutClass title:(NSString *)title;
@property (nonatomic, assign) Class controllerClass;
@property (nonatomic, assign) Class layoutClass;
@property (nonatomic, copy) NSString *title;
- (UINavigationController *)wrappedController;
@end

@implementation AppDelegate

- (void)runSampleGameWithPlayerCount:(NSUInteger)size variant:(AvalonGameVariant)variant
{

    AvalonMultiBotGameController *controller = [[AvalonMultiBotGameController alloc] initWithEngine:[AvalonEngine new]];
    AvalonGame *g = [AvalonGame gameWithVariant:variant];
    for (int i = 1; i <= size; i++) {
        AvalonPlayer *p = [AvalonPlayer playerWithId:[NSString stringWithFormat:@"BOT %d", i]];
        id<AvalonDecider> bot = nil;
        if (i %2 == 0) {
            bot = [AbstractDecider new];
        } else {
            bot = [JavaScriptDecider deciderWithScript:BundledScript(@"simple_bot")];
        }
        [controller setBot:bot forPlayer:p];
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

- (NSArray *)controllerConfigs
{
    return
    @[[AMLCollectionViewConfig configWithController:[GameCollectionViewController class] layout:[GameCollectionViewLayout class] title:@"Game"]
      ];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[self controllerConfigs][0] wrappedController];
    [self.window makeKeyAndVisible];
    return YES;
}

@end

@implementation AMLCollectionViewConfig

+ (instancetype)configWithController:(Class)controllerClass layout:(Class)layoutClass title:(NSString *)title;
{
    AMLCollectionViewConfig *config = [self new];
    config.controllerClass = controllerClass;
    config.layoutClass = layoutClass;
    config.title = title;
    return config;
}

- (UINavigationController *)wrappedController;
{
    UICollectionViewController *collectionViewController = [[self.controllerClass alloc] initWithCollectionViewLayout:[[self.layoutClass alloc] init]];
    collectionViewController.title = self.title;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:collectionViewController];
    return navController;
}

@end
