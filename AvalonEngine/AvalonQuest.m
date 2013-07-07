//
//  AvalonQuest.m
//  
//
//  Created by Brandon Smith on 7/5/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import "AvalonQuest.h"
#import "AvalonPlayer.h"

@implementation AvalonQuest

+ (instancetype)questWithPlayers:(NSArray *)players proposer:(AvalonPlayer *)proposer
{
    return [[self alloc] initWithPlayers:players proposer:proposer];
}

- (id)initWithPlayers:(NSArray *)players proposer:(AvalonPlayer *)proposer
{
    self = [super init];
    if (self) {
        _players = players;
        _proposer = proposer;
        _votes = [NSMutableDictionary new];
        _results = [NSMutableDictionary new];
        _failsRequired = 1;
        _questNumber = 1;
        _voteNumber = 1;
    }
    return self;
}

- (NSUInteger)numberOfPasses
{
    NSUInteger passes = 0;
    for (NSNumber *n in self.results.allValues) {
        if (n.boolValue) passes++;
    }
    return passes;
}

- (NSUInteger)numberOfAccepts
{
    NSUInteger accepts = 0;
    for (NSNumber *n in self.votes.allValues) {
        if ([n boolValue]) accepts++;
    }
    return accepts;
}

- (void)setVote:(BOOL)vote forPlayer:(AvalonPlayer *)player
{
    self.votes[player.playerId] = [NSNumber numberWithBool:vote];
    self.accepted = [self numberOfAccepts] > [self.votes.allValues count]/2;
}

- (void)setPass:(BOOL)vote forPlayer:(AvalonPlayer *)player
{
    self.results[player.playerId] = [NSNumber numberWithBool:vote];
    self.complete = [self.results.allKeys count] >= [self.players count];
    
    if (self.complete) {
        self.succeeded = ([self.players count] - [self numberOfPasses]) < self.failsRequired;
    }
}

- (instancetype)sanitizedForPlayer:(AvalonPlayer *)player
{
    NSMutableArray *sanitizedPlayers = [NSMutableArray new];
    for (AvalonPlayer *p in self.players) {
        [sanitizedPlayers addObject:[p sanitizedForPlayer:player]];
    }
    AvalonPlayer *sanitizedProposer = [self.proposer sanitizedForPlayer:player];
    AvalonQuest *quest = [[self class] questWithPlayers:sanitizedPlayers proposer:sanitizedProposer];
    quest.votes = [self.votes copy];
    quest.failsRequired = self.failsRequired;
    quest.questNumber = self.questNumber;
    quest.voteNumber = self.voteNumber;
    quest.results = [NSMutableDictionary new];
    quest.accepted = self.accepted;
    quest.succeeded = self.succeeded;
    quest.complete = self.complete;
    
    NSUInteger idx = 1;
    for (NSString *playerId in self.results.allKeys) {
        if ([playerId isEqualToString:player.playerId]) {
            quest.results[playerId] = self.results[playerId];
        } else {
            NSString *anonymousId = [NSString stringWithFormat:@"Anonymous %d", idx];
            quest.results[anonymousId] = self.results[playerId];
            idx++;
        }
    }
    return quest;
}

- (NSString *)description
{
    NSMutableArray *failedBy = [NSMutableArray new];
    for (NSString *playerId in self.results) {
        if (! [self.results[playerId] boolValue]) [failedBy addObject:playerId];
    }
    NSString *result;
    if (self.complete) {
        if (self.succeeded) result = @"Pass";
        else result = [NSString stringWithFormat:@"Fail (%@)", [failedBy componentsJoinedByString:@" "]];
    } else {
        result = @"";
    }
    return [NSString stringWithFormat:@"%d.%d: %d / %d %@",
            self.questNumber, self.voteNumber, [self numberOfAccepts], [self.votes.allKeys count], result];
}

#pragma mark - JSON

- (NSDictionary *)toJSON
{
    return @{@"proposer" : [self.proposer toJSON],
             @"questNumber" : @(self.questNumber),
             @"voteNumber" : @(self.voteNumber),
             @"failsRequired" : @(self.failsRequired),
             @"players" : [self.players toJSON],
             @"votes" : [self.votes toJSON],
             @"results" : [self.results toJSON],
             @"accepted" : @(self.accepted),
             @"complete" : @(self.complete),
             @"succeeded" : @(self.succeeded)};
}

@end
