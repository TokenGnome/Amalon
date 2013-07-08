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
@end

@implementation AvalonGame

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

- (NSMutableArray *)roles
{
    if (_roles) return _roles;
    NSMutableArray *roles = [NSMutableArray new];
    for (AvalonPlayer *player in self.players) {
        [roles addObject:player.role];
    }
    return roles;
}

+ (instancetype)gameWithPlayers:(NSArray *)players quests:(NSArray *)quests roles:(NSArray *)roles
{
    AvalonGame *game = [AvalonGame new];
    game.players = [players mutableCopy];
    game.quests = [players mutableCopy];
    game.roles = [roles mutableCopy];
    return game;
}

- (id)init
{
    self = [super init];
    if (self) {
        _players = [NSMutableArray new];
        _quests = [NSMutableArray new];
        _voteNumber = 1;
        _questNumber = 1;
        _passedQuestCount = 0;
        _failedQuestCount = 0;
    }
    return self;
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
    game.currentQuest = [self.currentQuest sanitizedForPlayer:player];
    game.finished = self.finished;
    game.state = self.state;
    game.voteNumber = self.voteNumber;
    game.questNumber = self.questNumber;
    game.passedQuestCount = self.passedQuestCount;
    game.failedQuestCount = self.failedQuestCount;
    game.observer = player;
    return game;
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
             @"failedQuestCount" : @(self.failedQuestCount)};
}

@end
