//
//  AvalonQuest.m
//  
//
//  Created by Brandon Smith on 7/5/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import "AvalonQuest.h"
#import "AvalonPlayer.h"
#import "AvalonProposal.h"
#import "AvalonTypes.h"

@implementation AvalonQuest

+ (instancetype)questWithSize:(NSUInteger)numPlayers number:(NSUInteger)num failsRequired:(NSUInteger)numFails
{
    return [[self alloc] initWithSize:numPlayers number:num failsRequired:numFails];
}

- (id)initWithSize:(NSUInteger)numPlayers number:(NSUInteger)num failsRequired:(NSUInteger)numFails
{
    self = [super init];
    if (self) {
        _failsRequired = 1;
        _questNumber = num;
        _playerCount = numPlayers;
        _proposals = [NSMutableArray new];
    }
    return self;
}

- (void)addProposal:(AvalonProposal *)proposal
{
    proposal.voteNumber = [self.proposals count] + 1;
    proposal.questNumber = self.questNumber;
    proposal.failsRequired = self.failsRequired;
    [self.proposals addObject:proposal];
}

- (instancetype)sanitizedForPlayer:(AvalonPlayer *)player
{
    AvalonQuest *quest = [[self class] questWithSize:self.playerCount number:self.questNumber failsRequired:self.failsRequired];
    quest.passed = _passed;
    quest.complete = _complete;
    
    for (AvalonProposal *prp in self.proposals) {
        [quest addProposal:[prp sanitizedForPlayer:player]];
    }
    
    return quest;
}

- (BOOL)isComplete
{
    if (_complete) return YES;
    
    for (AvalonProposal *prp in self.proposals) {
        if ([prp isAccepted] && [prp isComplete]) {
            self.complete = YES;
            return YES;
        }
    }
    return NO;
}

- (BOOL)isPass
{
    if (_passed) return YES;
    
    for (AvalonProposal *prp in self.proposals) {
        if ([prp isPass]) {
            self.passed = YES;
            return YES;
        }
    }
    return NO;
}

- (AvalonProposal *)currentProposal
{
    return [self.proposals lastObject];
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"Quest[number=%d, playerCount=%d, failsRequired=%d]", self.questNumber, self.playerCount, self.failsRequired];
}

#pragma mark - JSON

- (NSDictionary *)toJSON
{
    return @{@"questNumber" : @(self.questNumber),
             @"failsRequired" : @(self.failsRequired),
             @"playerCount" : @(self.playerCount),
             @"proposals" : self.proposals ? [self.proposals toJSON] : [NSNull null],
             @"currentProposal" : self.currentProposal ? [self.currentProposal toJSON] : [NSNull null],
             @"complete" : @(self.complete),
             @"passed" : @(self.passed)};
}

@end
