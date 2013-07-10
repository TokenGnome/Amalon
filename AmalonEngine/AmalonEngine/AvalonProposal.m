//
//  AvalonProposal.m
//  AmalonApp
//
//  Created by Brandon Smith on 7/8/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import "AvalonProposal.h"
#import "AvalonPlayer.h"

@implementation AvalonProposal

+ (instancetype)proposalWithPlayers:(NSArray *)players proposer:(AvalonPlayer *)proposer
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
    self.votes[player.playerId] = @(vote);
    self.accepted = [self numberOfAccepts] > [self.votes.allValues count]/2;
}

- (void)setPass:(BOOL)vote forPlayer:(AvalonPlayer *)player
{
    self.results[player.playerId] = @(vote);
    self.complete = [self.results.allKeys count] >= [self.players count];
    
    if (self.complete) {
        self.passed = ([self.players count] - [self numberOfPasses]) < self.failsRequired;
    }
}

- (instancetype)sanitizedForPlayer:(AvalonPlayer *)player
{
    NSMutableArray *sanitizedPlayers = [NSMutableArray new];
    for (AvalonPlayer *p in self.players) {
        [sanitizedPlayers addObject:[p sanitizedForPlayer:player]];
    }
    AvalonPlayer *sanitizedProposer = [self.proposer sanitizedForPlayer:player];
    AvalonProposal *prop = [[self class] proposalWithPlayers:sanitizedPlayers proposer:sanitizedProposer];
    prop.votes = [self.votes mutableCopy];
    prop.failsRequired = self.failsRequired;
    prop.questNumber = self.questNumber;
    prop.voteNumber = self.voteNumber;
    prop.results = [NSMutableDictionary new];
    prop.accepted = self.accepted;
    prop.passed = self.passed;
    prop.complete = self.complete;
    
    NSUInteger idx = 1;
    for (NSString *playerId in self.results) {
        if ([playerId isEqualToString:player.playerId]) {
            prop.results[playerId] = self.results[playerId];
        } else {
            NSString *anonymousId = [NSString stringWithFormat:@"Anonymous %d", idx];
            prop.results[anonymousId] = self.results[playerId];
            idx++;
        }
    }
    return prop;
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
             @"passed" : @(self.passed)};
}

@end
