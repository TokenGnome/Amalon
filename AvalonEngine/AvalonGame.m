//
//  AvalonGame.m
//  
//
//  Created by Brandon Smith on 7/6/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import "AvalonGame.h"
#import "AvalonPlayer.h"
#import "AvalonQuest.h"

@interface AvalonGame ()
@property (nonatomic, strong) NSMutableDictionary *playerMap;

@property (nonatomic, strong) NSMutableArray *mutablePlayers;
@property (nonatomic, strong) NSMutableArray *mutableQuests;
@property (nonatomic, strong) NSMutableArray *mutableRoles;

@end

@implementation AvalonGame

+ (instancetype)gameWithVariant:(AvalonGameVariant)variant
{
    return [[self alloc] initWithVariant:variant];
}

+ (instancetype)gameWithPlayers:(NSArray *)players quests:(NSArray *)quests roles:(NSArray *)roles
{
    AvalonGame *game = [AvalonGame new];
    game.mutablePlayers = [players mutableCopy];
    game.mutableQuests = [quests mutableCopy];
    game.mutableRoles = [roles mutableCopy];
    return game;
}

- (id)initWithVariant:(AvalonGameVariant)variant
{
    self = [super init];
    if (self) {
        _mutablePlayers = [NSMutableArray new];
        _mutableQuests = [NSMutableArray new];
        _mutableRoles = [NSMutableArray new];
        _voteNumber = 1;
        _questNumber = 1;
        _passedQuestCount = 0;
        _failedQuestCount = 0;
        _variant = variant;
        _state = GameStateNotStarted;
    }
    return self;
}

- (id)init
{
    return [self initWithVariant:AvalonVariantDefault];
}

- (instancetype)sanitizedCopyForPlayer:(AvalonPlayer *)player
{
    NSMutableArray *players = [NSMutableArray new];
    NSMutableArray *roles = [NSMutableArray new];
    for (AvalonPlayer *knownPlayer in self.players) {
        AvalonPlayer *unknownPlayer = [knownPlayer sanitizedForPlayer:player];
        [players addObject:unknownPlayer];
        [roles addObject:knownPlayer.role];
    }
    NSMutableArray *quests = [NSMutableArray new];
    for (AvalonQuest *quest in self.quests) {
        [quests addObject:[quest sanitizedForPlayer:player]];
    }
    
    AvalonGame *game = [AvalonGame gameWithPlayers:players quests:quests roles:roles];
    game.currentLeader = [self.currentLeader sanitizedForPlayer:player];
    game.finished = self.finished;
    game.state = self.state;
    game.voteNumber = self.voteNumber;
    game.questNumber = self.questNumber;
    game.passedQuestCount = self.passedQuestCount;
    game.failedQuestCount = self.failedQuestCount;
    game.observer = player;
    return game;
}

#pragma mark - Mutations

- (void)addPlayer:(AvalonPlayer *)player
{
    [self.mutablePlayers addObject:player];
}

- (void)removePlayer:(AvalonPlayer *)player
{
    [self.mutablePlayers removeObject:player];
}

- (NSArray *)players
{
    return [self.mutablePlayers copy];
}

- (BOOL)hasPlayer:(AvalonPlayer *)player
{
    if (self.playerMap && self.playerMap[player.playerId]) return YES;
    
    for (AvalonPlayer *existingPlayer in self.players) {
        if ([player isEqual:existingPlayer]) return YES;
    }
    return NO;
}

- (BOOL)hasPlayers:(NSArray *)players
{
    for (id obj in players) {
        AvalonPlayer *player = [obj isKindOfClass:[AvalonPlayer class]] ? obj : [AvalonPlayer playerWithId:obj];
        if (! [self hasPlayer:player]) return NO;
    }
    return YES;
}

- (AvalonPlayer *)playerWithId:(NSString *)playerId
{
    if (self.playerMap) return self.playerMap[playerId];
    
    for (AvalonPlayer *player in self.players) {
        if ([player.playerId isEqualToString:playerId]) return player;
    }
    return nil;
}

- (NSArray *)playersWithIds:(NSArray *)playerIds
{
    NSMutableArray *players = [NSMutableArray new];
    for (NSString *pid in playerIds) {
        [players addObject:[self playerWithId:pid]];
    }
    return players;
}

- (void)mapPlayers
{
    self.playerMap = [NSMutableDictionary new];
    for (AvalonPlayer *player in self.players) {
        self.playerMap[player.playerId] = player;
    }
}

- (void)setState:(AvalonGameState)state
{
    if (state == GameStateRolesAssigned) {
        [self mapPlayers];
    }
    
    if (state == GameStateEnded) {
        self.finished = YES;
    }
    _state = state;
}

- (NSArray *)roles
{
    return [self.mutableRoles copy];
}

- (void)addQuest:(AvalonQuest *)quest
{
    [self.mutableQuests addObject:quest];
}

- (NSArray *)quests
{
    return [self.mutableQuests copy];
}

- (AvalonQuest *)currentQuest
{
    return [self.quests lastObject];
}

#pragma mark - JSON

- (NSDictionary *)toJSON
{
    return @{@"currentLeader" : self.currentLeader ? [self.currentLeader toJSON] : [NSNull null],
             @"questNumber" : @(self.questNumber),
             @"voteNumber" : @(self.voteNumber),
             @"currentQuest" : self.currentQuest ? [self.currentQuest toJSON] : [NSNull null],
             @"players" : [self.players toJSON],
             @"quests" : [self.quests toJSON],
             @"roles" : self.roles ? [self.roles toJSON] : @[],
             @"finished" : @(self.finished),
             @"state" : @(self.state),
             @"passedQuestCount" : @(self.passedQuestCount),
             @"failedQuestCount" : @(self.failedQuestCount),
             @"observer" : self.observer ? [self.observer toJSON] : [NSNull null]};
}

@end
